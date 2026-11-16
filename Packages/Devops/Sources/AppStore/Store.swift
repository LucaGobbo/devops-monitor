import ActivityTimeline
import AuthClient
import DevopsClient
import Foundation
import MonitorClient
import NotificationClient
import Observation
import SnapshotClient

/// All app state in one place, so every feature reads the same data.
///
/// The data arrives from the ``MonitorClient`` stream, which polls in the background; the store applies each
/// event and forwards the changes (a pipeline finished, a pull request completed) as local notifications.
@MainActor @Observable
public final class Store {
    public private(set) var hasToken = false
    public private(set) var profile: Person?
    public private(set) var pipelines: [Build] = []
    public private(set) var createdPullRequests: [PullRequest] = []
    public private(set) var assignedPullRequests: [PullRequest] = []
    /// The stages, jobs and tasks of the runs that are being watched (see ``watchTimeline(of:)``).
    public private(set) var timelines: [Int: BuildTimeline] = [:]
    /// What happened in the last ``activityWindow``, newest first. Derived from the server, see ``loadActivity()``.
    public private(set) var activity: [ActivityEvent] = []
    public private(set) var isLoadingActivity = false
    public private(set) var errorMessage: String?

    /// The Azure DevOps organization (the name in `dev.azure.com/<organization>`), persisted in `defaults`.
    /// Changing it clears the loaded data and restarts monitoring, shortly after the last keystroke.
    public var organization: String {
        didSet {
            guard organization != oldValue else { return }
            defaults.set(organization, forKey: Self.organizationKey)
            pipelines = []
            createdPullRequests = []
            assignedPullRequests = []
            timelines = [:]
            clearActivity()
            Task { await publishSnapshot() }
            startMonitoring(after: .milliseconds(800))
        }
    }

    private static let organizationKey = "organization"

    private let auth: AuthClient
    private let client: DevopsClient
    private let monitor: MonitorClient
    private let notifications: NotificationClient
    private let snapshots: SnapshotClient
    let now: @Sendable () -> Date
    private let defaults: UserDefaults

    @ObservationIgnored private(set) var monitoringTask: Task<Void, Never>?
    @ObservationIgnored private var didRequestNotificationAuthorization = false
    /// Whether the Activity page asked for the timeline yet; only then do polls keep it fresh.
    @ObservationIgnored private var activityRequested = false
    @ObservationIgnored private var lastActivityLoad: Date?
    /// Tells a load that was replaced (new organization, newer load) not to write its result.
    @ObservationIgnored private var activityGeneration = 0
    @ObservationIgnored private(set) var activityTask: Task<Void, Never>?

    public init(
        auth: AuthClient,
        client: DevopsClient,
        monitor: MonitorClient,
        notifications: NotificationClient,
        snapshots: SnapshotClient,
        now: @escaping @Sendable () -> Date = { Date() },
        defaults: UserDefaults = .standard
    ) {
        self.auth = auth
        self.client = client
        self.monitor = monitor
        self.notifications = notifications
        self.snapshots = snapshots
        self.now = now
        self.defaults = defaults
        self.organization = defaults.string(forKey: Self.organizationKey) ?? ""
    }

    /// Reads the stored token, then starts monitoring. Call once at launch, from the composition root, so
    /// monitoring does not depend on a window being open.
    public func load() async {
        do {
            hasToken = try await auth.hasToken()
        } catch {
            errorMessage = error.localizedDescription
        }
        startMonitoring()
    }

    /// (Re)starts polling in the background. Does nothing without a token and an organization.
    public func startMonitoring(after delay: Duration = .zero) {
        monitoringTask?.cancel()
        monitoringTask = Task { [weak self] in
            if delay > .zero {
                try? await Task.sleep(for: delay)
                if Task.isCancelled { return }
            }
            await self?.runMonitoring()
        }
    }

    /// Polls right now instead of waiting for the next interval.
    public func refresh() async {
        if monitoringTask == nil { startMonitoring() }
        await monitor.refreshNow()
    }

    /// Sets the user's vote on a pull request, then polls so the list shows it.
    public func vote(_ vote: ReviewVote, on pullRequest: PullRequest) async {
        await update(pullRequest) { client, organization, me in
            try await client.vote(organization, pullRequest, vote, me)
        }
    }

    /// Sets auto-complete on a pull request with `strategy`, then polls so the list shows it.
    public func setAutoComplete(_ strategy: MergeStrategy, on pullRequest: PullRequest) async {
        await update(pullRequest) { client, organization, me in
            try await client.setAutoComplete(organization, pullRequest, strategy, me)
        }
    }

    /// Cancels auto-complete on a pull request, then polls so the list shows it.
    public func cancelAutoComplete(on pullRequest: PullRequest) async {
        await update(pullRequest) { client, organization, _ in
            try await client.cancelAutoComplete(organization, pullRequest)
        }
    }

    /// Runs a change to a pull request as the current user. A failure is reported in ``errorMessage`` and skips the poll.
    private func update(
        _ pullRequest: PullRequest,
        _ change: (DevopsClient, _ organization: String, _ me: Person) async throws -> Void
    ) async {
        guard let me = profile else { return }
        do {
            try await change(client, organization, me)
        } catch {
            errorMessage = error.localizedDescription
            return
        }
        await refresh()
    }

    /// Keeps `timelines[build.id]` up to date until cancelled. Meant for a view's `.task`, so a run's timeline is
    /// only fetched while the user has it open.
    public func watchTimeline(of build: Build) async {
        guard let project = build.project else { return }
        for await timeline in monitor.timelines(organization, project, build.id) {
            timelines[build.id] = timeline
        }
    }

    /// Looks up the user, then applies monitor events until the stream ends or the task is cancelled.
    func runMonitoring() async {
        guard hasToken, !organization.isEmpty else { return }
        let organization = organization
        // The permission prompt waits for the user, so it must not hold up the first fetch.
        let authorization = Task { [notifications, needsAuthorization = !didRequestNotificationAuthorization] in
            if needsAuthorization { await notifications.requestAuthorization() }
        }
        defer { authorization.cancel() }
        didRequestNotificationAuthorization = true
        guard let me = await currentUser(in: organization) else { return }
        for await event in monitor.events(organization, me) {
            await apply(event)
        }
    }

    private func currentUser(in organization: String) async -> Person? {
        if let profile { return profile }
        while !Task.isCancelled {
            do {
                let me = try await client.currentUser(organization)
                profile = me
                return me
            } catch {
                errorMessage = error.localizedDescription
                try? await Task.sleep(for: .seconds(30))
            }
        }
        return nil
    }

    private func apply(_ event: MonitorEvent) async {
        switch event {
        case .update(let snapshot, let changes):
            let dataChanged = pipelines != snapshot.pipelines
                || createdPullRequests != snapshot.createdPullRequests || assignedPullRequests != snapshot.assignedPullRequests
            let didChange = !changes.isEmpty || dataChanged
            if pipelines != snapshot.pipelines {
                pipelines = snapshot.pipelines
                let open = Set(pipelines.map(\.id))
                timelines = timelines.filter { open.contains($0.key) }
            }
            if createdPullRequests != snapshot.createdPullRequests { createdPullRequests = snapshot.createdPullRequests }
            if assignedPullRequests != snapshot.assignedPullRequests { assignedPullRequests = snapshot.assignedPullRequests }
            errorMessage = nil
            if dataChanged { await publishSnapshot() }
            for notification in changes.compactMap({ AppNotification($0) }) {
                await notifications.send(notification)
            }
            if activityRequested, lastActivityLoad == nil || didChange, activityIsDue { startActivityLoad() }
        case .failure(let message):
            errorMessage = message
        }
    }

    /// Stores the token and restarts monitoring. Returns whether the token was stored.
    @discardableResult
    public func saveToken(_ token: String) async -> Bool {
        do {
            try await auth.save(token)
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
        hasToken = true
        profile = nil
        errorMessage = nil
        startMonitoring()
        return true
    }

    /// Removes the token, stops monitoring and clears everything that was loaded with it.
    public func removeToken() async {
        do {
            try await auth.remove()
        } catch {
            errorMessage = error.localizedDescription
            return
        }
        monitoringTask?.cancel()
        monitoringTask = nil
        hasToken = false
        profile = nil
        pipelines = []
        createdPullRequests = []
        assignedPullRequests = []
        timelines = [:]
        clearActivity()
        errorMessage = nil
        await publishSnapshot()
    }

    /// Hands what is open to the widgets. Best effort: widgets are secondary, so a failure is not reported.
    private func publishSnapshot() async {
        let snapshot = WidgetSnapshot(
            pipelines: pipelines, created: createdPullRequests, assigned: assignedPullRequests,
            organization: organization, now: now()
        )
        try? await snapshots.save(snapshot)
    }
}

// MARK: Activity timeline

extension Store {
    /// How far back the timeline reaches.
    public static let activityWindow: Duration = .seconds(30 * 24 * 60 * 60)
    /// The least time between two automatic reloads of the timeline: a load costs a request per pull request.
    public static let activityRefreshInterval: Duration = .seconds(60)

    /// Loads (or reloads) the timeline from the server and returns when it is done. Meant for the Activity page's
    /// `.task` and its Refresh button. Once called, polls that change something reload it too (see
    /// ``activityRefreshInterval``). A failure is reported in ``errorMessage``; the timeline keeps what it had.
    public func loadActivity() async {
        activityRequested = true
        guard let task = startActivityLoad() else { return }
        await task.value
    }

    /// Whether the last load is old enough for a poll to trigger another one.
    private var activityIsDue: Bool {
        guard let lastActivityLoad else { return true }
        return now().timeIntervalSince(lastActivityLoad) >= Double(Self.activityRefreshInterval.components.seconds)
    }

    /// Starts a load, replacing the one in progress. `nil` when there is nothing to load yet (no token,
    /// organization or user); the first poll after that tries again.
    @discardableResult
    private func startActivityLoad() -> Task<Void, Never>? {
        guard hasToken, !organization.isEmpty, let me = profile else { return nil }
        activityTask?.cancel()
        activityGeneration += 1
        let generation = activityGeneration
        lastActivityLoad = now()
        isLoadingActivity = true
        let task = Task { await fetchActivity(generation: generation, organization: organization, me: me) }
        activityTask = task
        return task
    }

    private func fetchActivity(generation: Int, organization: String, me: Person) async {
        let since = now().addingTimeInterval(-TimeInterval(Self.activityWindow.components.seconds))
        do {
            let source = try await client.activitySource(
                organization: organization, me: me, since: since,
                openPullRequests: createdPullRequests + assignedPullRequests
            )
            // A load that was replaced meanwhile (another organization, a newer load) must not write.
            guard generation == activityGeneration else { return }
            activity = ActivityTimeline.events(
                builds: source.builds, pullRequests: source.pullRequests, pullRequestEvents: source.pullRequestEvents,
                me: me, organization: organization, since: since
            )
            if let failure = source.threadFailure { errorMessage = failure }
        } catch {
            guard generation == activityGeneration else { return }
            errorMessage = error.localizedDescription
        }
        isLoadingActivity = false
    }

    private func clearActivity() {
        activityTask?.cancel()
        activityTask = nil
        activityGeneration += 1
        activity = []
        isLoadingActivity = false
        lastActivityLoad = nil
    }
}
