import ActivityTimeline
import AuthClient
import DevopsClient
import Foundation
import MonitorClient
import NotificationClient
import os
import SnapshotClient
import Testing

@testable import AppStore

@MainActor
struct StoreTests {
    private func makeStore(
        hasToken: Bool = true,
        organization: String = "fabrikam",
        client: DevopsClient = .previewValue,
        monitor: MonitorClient = .previewValue,
        notifications: NotificationClient = .testValue,
        snapshots: SnapshotClient = .testValue,
        now: @escaping @Sendable () -> Date = { Date() }
    ) -> Store {
        var auth = AuthClient.previewValue
        auth.personalAccessToken = { hasToken ? "token" : nil }
        let defaults = UserDefaults(suiteName: UUID().uuidString)!
        defaults.set(organization, forKey: "organization")
        return Store(auth: auth, client: client, monitor: monitor, notifications: notifications, snapshots: snapshots, now: now, defaults: defaults)
    }

    /// A monitor that publishes `events` and ends.
    private func monitor(publishing events: [MonitorEvent]) -> MonitorClient {
        MonitorClient(
            events: { _, _ in
                AsyncStream { continuation in
                    events.forEach { continuation.yield($0) }
                    continuation.finish()
                }
            },
            refreshNow: {},
            timelines: { _, _, _ in AsyncStream { $0.finish() } }
        )
    }

    /// A notification client that records what it was asked to show.
    private func recording(_ sent: OSAllocatedUnfairLock<[AppNotification]>) -> NotificationClient {
        NotificationClient(requestAuthorization: {}, send: { notification in sent.withLock { $0.append(notification) } })
    }

    /// Loads and waits for the monitoring task, which ends with the (finite) test streams.
    private func load(_ store: Store) async {
        await store.load()
        await store.monitoringTask?.value
    }

    @Test func loadRefreshesEverything() async {
        let store = makeStore()
        await load(store)
        #expect(store.hasToken)
        #expect(store.profile?.id == "preview-user")
        #expect(store.pipelines.count == 1)
        #expect(store.createdPullRequests.count == 2)
        #expect(store.assignedPullRequests.isEmpty) // both are also created by me, so listed once
    }

    @Test func badgeCountsOpenThingsAndCountsPullRequestsOnce() async {
        let store = makeStore()
        await load(store)
        // The sample pull requests are both created by and assigned to the user: they count once.
        #expect(store.openPipelinesCount == 1)
        #expect(store.openPullRequestsCount == 2)
        #expect(store.badgeCount == 3)
    }

    @Test func refreshDoesNothingWithoutToken() async {
        let store = makeStore(hasToken: false)
        await load(store)
        #expect(store.profile == nil)
        #expect(store.pipelines.isEmpty)
    }

    @Test func refreshDoesNothingWithoutOrganization() async {
        let store = makeStore(organization: "")
        await load(store)
        #expect(store.profile == nil)
    }

    @Test func removeTokenClearsLoadedState() async {
        let store = makeStore()
        await load(store)
        await store.removeToken()
        #expect(!store.hasToken)
        #expect(store.profile == nil)
        #expect(store.pipelines.isEmpty)
    }

    /// A snapshot client that records what it was asked to save.
    private func recording(_ saved: OSAllocatedUnfairLock<[WidgetSnapshot]>) -> SnapshotClient {
        SnapshotClient(save: { snapshot in saved.withLock { $0.append(snapshot) } }, load: { nil })
    }

    @Test func updatesAreHandedToTheWidgetsOnlyWhenWhatIsOpenChanges() async throws {
        let saved = OSAllocatedUnfairLock(initialState: [WidgetSnapshot]())
        let open = MonitorSnapshot(pipelines: [Build(id: 4, state: .inProgress, pipeline: "CI")])
        let store = makeStore(
            monitor: monitor(publishing: [.update(open, changes: []), .update(open, changes: [])]),
            snapshots: recording(saved)
        )
        await load(store)
        let snapshots = saved.withLock { $0 }
        #expect(snapshots.count == 1)
        #expect(try #require(snapshots.first).pipelines.map(\.id) == [4])
    }

    @Test func removingTheTokenClearsTheWidgets() async throws {
        let saved = OSAllocatedUnfairLock(initialState: [WidgetSnapshot]())
        let store = makeStore(snapshots: recording(saved))
        await load(store)
        await store.removeToken()
        let last = try #require(saved.withLock { $0.last })
        #expect(last.pipelines.isEmpty)
        #expect(last.pullRequests.isEmpty)
    }

    @Test func changesBecomeNotificationsButTheBaselineDoesNot() async {
        let sent = OSAllocatedUnfairLock(initialState: [AppNotification]())
        let finished = Build(id: 9, number: "7", state: .failed, pipeline: "CI", project: "P", branch: "main")
        let store = makeStore(
            monitor: monitor(publishing: [
                .update(MonitorSnapshot(pipelines: [Build(id: 9, state: .inProgress)]), changes: []),
                .update(MonitorSnapshot(), changes: [.buildFinished(finished)]),
            ]),
            notifications: recording(sent)
        )
        await load(store)
        #expect(sent.withLock { $0.map(\.id) } == ["build-9"])
        #expect(store.pipelines.isEmpty)
    }

    @Test func aFailedPollSetsTheErrorAndTheNextUpdateClearsIt() async {
        let store = makeStore(monitor: monitor(publishing: [.failure("offline")]))
        await load(store)
        #expect(store.errorMessage == "offline")

        let recovered = makeStore(monitor: monitor(publishing: [.failure("offline"), .update(MonitorSnapshot(), changes: [])]))
        await load(recovered)
        #expect(recovered.errorMessage == nil)
    }

    @Test func authorizationIsRequestedOnceBeforePolling() async {
        let requests = OSAllocatedUnfairLock(initialState: 0)
        let store = makeStore(
            notifications: NotificationClient(requestAuthorization: { requests.withLock { $0 += 1 } }, send: { _ in })
        )
        await load(store)
        await store.runMonitoring()
        #expect(requests.withLock { $0 } == 1)
    }

    @Test func notificationsDescribeTheChange() throws {
        let build = try #require(AppNotification(.buildFinished(Build(id: 3, number: "20241101.1", state: .succeeded, pipeline: "CI", project: "P", branch: "main"))))
        #expect(build.title == "Pipeline succeeded")
        #expect(build.subtitle == "CI 20241101.1")
        #expect(build.body == "P · main")

        let pullRequest = try #require(AppNotification(.pullRequestCompleted(PullRequest(id: 22, title: "Add it", repository: "app", project: "P"))))
        #expect(pullRequest.title == "Pull request completed")
        #expect(pullRequest.subtitle == "#22 Add it")
        #expect(pullRequest.body == "P / app")
    }

    @Test func theFirstFetchDoesNotWaitForTheNotificationPrompt() async {
        let prompt = NotificationClient(
            requestAuthorization: { try? await Task.sleep(for: .seconds(3600)) }, send: { _ in }
        )
        let store = makeStore(
            monitor: monitor(publishing: [.update(MonitorSnapshot(pipelines: [Build(id: 1)]), changes: [])]),
            notifications: prompt
        )
        await load(store)
        #expect(store.pipelines.count == 1)
    }

    @Test func watchingATimelineStoresItUnderTheBuildId() async {
        var monitor = MonitorClient.previewValue
        monitor.timelines = { _, project, _ in
            AsyncStream { continuation in
                continuation.yield(BuildTimeline(stages: [BuildStage(id: project, name: project, status: .running)]))
                continuation.finish()
            }
        }
        let store = makeStore(monitor: monitor)
        await store.watchTimeline(of: Build(id: 5, project: "Fabrikam"))
        #expect(store.timelines[5]?.stages.map(\.id) == ["Fabrikam"])

        await store.watchTimeline(of: Build(id: 6)) // no project: nothing to fetch
        #expect(store.timelines[6] == nil)
    }

    @Test func timelinesOfRunsThatAreNoLongerOpenAreDropped() async {
        // The sample monitor publishes a timeline for any run; the events then show the run leaving the list.
        var monitor = MonitorClient.previewValue
        monitor.events = self.monitor(publishing: [
            .update(MonitorSnapshot(pipelines: [Build(id: 5, project: "P")]), changes: []),
            .update(MonitorSnapshot(), changes: []),
        ]).events
        let store = makeStore(monitor: monitor)
        await store.watchTimeline(of: Build(id: 5, project: "P"))
        #expect(store.timelines[5] != nil)

        await load(store)
        #expect(store.timelines.isEmpty)
    }

    // MARK: Activity timeline

    private struct Boom: Error {}

    nonisolated private static let start = Date(timeIntervalSince1970: 1_700_000_000)

    /// The store's clock, which a test moves by hand.
    private final class Clock: Sendable {
        private let date = OSAllocatedUnfairLock(initialState: StoreTests.start)
        var now: Date { date.withLock { $0 } }
        func advance(_ seconds: TimeInterval) { date.withLock { $0 = $0.addingTimeInterval(seconds) } }
    }

    /// A client whose timeline calls are counted and can be made to fail.
    private func timelineClient(
        loads: OSAllocatedUnfairLock<Int> = .init(initialState: 0), failing: OSAllocatedUnfairLock<Bool> = .init(initialState: false),
        builds: [Build] = [], pullRequests: [PullRequest] = [], threads: [Int: [PullRequestEvent]] = [:]
    ) -> DevopsClient {
        var client = DevopsClient.previewValue
        client.recentBuilds = { _, _, _ in
            loads.withLock { $0 += 1 }
            if failing.withLock({ $0 }) { throw Boom() }
            return builds
        }
        client.recentPullRequests = { _, _, _, _ in pullRequests }
        client.pullRequestEvents = { _, pullRequest in threads[pullRequest.id] ?? [] }
        return client
    }

    /// A monitor whose n-th `events` call publishes the n-th list (the last one is repeated), and ends.
    private func monitor(streams: [[MonitorEvent]]) -> MonitorClient {
        let calls = OSAllocatedUnfairLock(initialState: 0)
        return MonitorClient(
            events: { _, _ in
                let index = calls.withLock { count -> Int in defer { count += 1 }; return count }
                let events = streams[min(index, streams.count - 1)]
                return AsyncStream { continuation in
                    events.forEach { continuation.yield($0) }
                    continuation.finish()
                }
            },
            refreshNow: {},
            timelines: { _, _, _ in AsyncStream { $0.finish() } }
        )
    }

    /// Runs one more monitoring pass and waits for the timeline load it may start.
    private func poll(_ store: Store) async {
        store.startMonitoring()
        await store.monitoringTask?.value
        await store.activityTask?.value
    }

    private let changed = MonitorEvent.update(MonitorSnapshot(pipelines: [Build(id: 99)]), changes: [])
    private let unchanged = MonitorEvent.update(MonitorSnapshot(), changes: [])

    @Test func loadingTheActivityBuildsTheTimelineFromTheServer() async {
        let build = Build(id: 7, number: "1", state: .succeeded, pipeline: "CI", queuedAt: Self.start.addingTimeInterval(-3600), finishedAt: Self.start.addingTimeInterval(-60))
        let store = makeStore(client: timelineClient(builds: [build]), now: { Self.start })
        await load(store)
        await store.loadActivity()
        #expect(store.activity.map(\.kind) == [.buildSucceeded, .buildQueued])
        #expect(!store.isLoadingActivity)
    }

    @Test func eventsOlderThanTheWindowAreLeftOut() async {
        let old = Build(id: 7, state: .succeeded, queuedAt: Self.start.addingTimeInterval(-31 * 24 * 60 * 60))
        let store = makeStore(client: timelineClient(builds: [old]), now: { Self.start })
        await load(store)
        await store.loadActivity()
        #expect(store.activity.isEmpty)
    }

    @Test func pullRequestsThatAreOpenNowAreIncludedWhateverTheirAge() async {
        // The sample pull request 22 is open (monitor) but the server list for the window does not contain it.
        let vote = PullRequestEvent(id: 3, date: Self.start.addingTimeInterval(-60), kind: .voted(personID: "x", name: "Anna", vote: .approved))
        let store = makeStore(client: timelineClient(threads: [22: [vote]]), now: { Self.start })
        await load(store)
        await store.loadActivity()
        #expect(store.activity.map(\.id) == ["pr-22-pullRequestReviewed-3"])
    }

    @Test func aPollThatChangesSomethingReloadsTheTimelineOncePageHasAskedForIt() async {
        let loads = OSAllocatedUnfairLock(initialState: 0)
        let clock = Clock()
        let store = makeStore(
            client: timelineClient(loads: loads), monitor: monitor(streams: [[unchanged], [changed]]), now: { clock.now }
        )
        await load(store)
        await store.loadActivity()
        #expect(loads.withLock { $0 } == 1)

        clock.advance(61)
        await poll(store)
        #expect(loads.withLock { $0 } == 2)
    }

    @Test func aReloadWaitsForTheRefreshInterval() async {
        let loads = OSAllocatedUnfairLock(initialState: 0)
        let clock = Clock()
        let store = makeStore(
            client: timelineClient(loads: loads), monitor: monitor(streams: [[unchanged], [changed]]), now: { clock.now }
        )
        await load(store)
        await store.loadActivity()

        clock.advance(30)
        await poll(store)
        #expect(loads.withLock { $0 } == 1)
    }

    @Test func aPollThatChangesNothingDoesNotReload() async {
        let loads = OSAllocatedUnfairLock(initialState: 0)
        let clock = Clock()
        let store = makeStore(client: timelineClient(loads: loads), monitor: monitor(streams: [[unchanged]]), now: { clock.now })
        await load(store)
        await store.loadActivity()

        clock.advance(600)
        await poll(store)
        #expect(loads.withLock { $0 } == 1)
    }

    @Test func nothingLoadsBeforeThePageAsksForIt() async {
        let loads = OSAllocatedUnfairLock(initialState: 0)
        let store = makeStore(client: timelineClient(loads: loads), monitor: monitor(streams: [[unchanged], [changed]]))
        await load(store)
        await poll(store)
        #expect(loads.withLock { $0 } == 0)
        #expect(store.activity.isEmpty)
    }

    @Test func aFailedLoadIsReportedAndKeepsWhatWasShown() async {
        let failing = OSAllocatedUnfairLock(initialState: false)
        let build = Build(id: 7, state: .succeeded, queuedAt: Self.start.addingTimeInterval(-60))
        let store = makeStore(client: timelineClient(failing: failing, builds: [build]), now: { Self.start })
        await load(store)
        await store.loadActivity()
        #expect(store.activity.count == 1)

        failing.withLock { $0 = true }
        await store.loadActivity()
        #expect(store.errorMessage != nil)
        #expect(store.activity.count == 1)
        #expect(!store.isLoadingActivity)
    }

    @Test func aThreadThatCannotBeReadIsReportedButTheRestShows() async {
        var client = timelineClient(builds: [Build(id: 7, state: .succeeded, queuedAt: Self.start.addingTimeInterval(-60))])
        client.pullRequestEvents = { _, _ in throw Boom() }
        let store = makeStore(client: client, now: { Self.start })
        await load(store)
        await store.loadActivity()
        #expect(store.activity.map(\.kind) == [.buildQueued])
        #expect(store.errorMessage != nil)
    }

    @Test func changingTheOrganizationClearsTheTimeline() async {
        let build = Build(id: 7, state: .succeeded, queuedAt: Self.start.addingTimeInterval(-60))
        let store = makeStore(client: timelineClient(builds: [build]), now: { Self.start })
        await load(store)
        await store.loadActivity()
        #expect(!store.activity.isEmpty)

        store.organization = "other"
        #expect(store.activity.isEmpty)
        store.monitoringTask?.cancel()
    }

    @Test func onlyEndingsThatMatterNotify() async {
        let sent = OSAllocatedUnfairLock(initialState: [AppNotification]())
        let build = Build(id: 1, state: .canceled)
        let pullRequest = PullRequest(id: 2, title: "t", status: .abandoned)
        let store = makeStore(
            monitor: monitor(publishing: [
                .update(MonitorSnapshot(), changes: [.buildCanceled(build), .buildPartiallySucceeded(build), .pullRequestAbandoned(pullRequest)]),
            ]),
            notifications: recording(sent)
        )
        await load(store)
        #expect(sent.withLock { $0.isEmpty })
    }

    // MARK: Pull request actions

    /// A monitor that counts how often it was asked to poll.
    private func counting(_ refreshes: OSAllocatedUnfairLock<Int>) -> MonitorClient {
        var monitor = monitor(publishing: [])
        monitor.refreshNow = { refreshes.withLock { $0 += 1 } }
        return monitor
    }

    @Test func votingSendsTheVoteAsTheCurrentUserThenPolls() async {
        let calls = OSAllocatedUnfairLock<[String]>(initialState: [])
        let refreshes = OSAllocatedUnfairLock(initialState: 0)
        var client = DevopsClient.previewValue
        client.vote = { organization, pullRequest, vote, me in
            calls.withLock { $0.append("\(organization) #\(pullRequest.id) \(vote) \(me.id)") }
        }
        let store = makeStore(client: client, monitor: counting(refreshes))
        await load(store)

        await store.vote(.rejected, on: PullRequest(id: 7, title: "T"))

        #expect(calls.withLock { $0 } == ["fabrikam #7 rejected preview-user"])
        #expect(refreshes.withLock { $0 } == 1)
        #expect(store.errorMessage == nil)
    }

    @Test func settingAutoCompleteSendsTheStrategyThenPolls() async {
        let strategies = OSAllocatedUnfairLock<[MergeStrategy]>(initialState: [])
        let refreshes = OSAllocatedUnfairLock(initialState: 0)
        var client = DevopsClient.previewValue
        client.setAutoComplete = { _, _, strategy, _ in strategies.withLock { $0.append(strategy) } }
        let store = makeStore(client: client, monitor: counting(refreshes))
        await load(store)

        await store.setAutoComplete(.squash, on: PullRequest(id: 7, title: "T"))

        #expect(strategies.withLock { $0 } == [.squash])
        #expect(refreshes.withLock { $0 } == 1)
    }

    @Test func cancellingAutoCompleteCallsTheClientThenPolls() async {
        let cancelled = OSAllocatedUnfairLock<[Int]>(initialState: [])
        let refreshes = OSAllocatedUnfairLock(initialState: 0)
        var client = DevopsClient.previewValue
        client.cancelAutoComplete = { _, pullRequest in cancelled.withLock { $0.append(pullRequest.id) } }
        let store = makeStore(client: client, monitor: counting(refreshes))
        await load(store)

        await store.cancelAutoComplete(on: PullRequest(id: 7, title: "T", isAutoCompleteSet: true))

        #expect(cancelled.withLock { $0 } == [7])
        #expect(refreshes.withLock { $0 } == 1)
    }

    @Test func aFailedPullRequestActionIsReportedAndDoesNotPoll() async {
        let refreshes = OSAllocatedUnfairLock(initialState: 0)
        var client = DevopsClient.previewValue
        client.vote = { _, _, _, _ in throw Boom() }
        let store = makeStore(client: client, monitor: counting(refreshes))
        await load(store)

        await store.vote(.approved, on: PullRequest(id: 7, title: "T"))

        #expect(store.errorMessage != nil)
        #expect(refreshes.withLock { $0 } == 0)
    }
}
