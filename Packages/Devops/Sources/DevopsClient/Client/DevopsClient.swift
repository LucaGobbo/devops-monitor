import Foundation

/// What the monitoring app needs from Azure DevOps, as a struct of closures (protocol witness) over domain models.
///
/// Look up the authenticated user once with ``currentUser`` and pass it as `me` to the other operations, so the
/// caller (store / view model) decides how long to cache it. Operations cover every project of the organization.
/// Use ``testValue`` / ``previewValue`` in tests and previews; the real implementation is
/// `DevopsClient.live(...)` in `DevopsClientLive`.
public struct DevopsClient: Sendable {
    /// The authenticated user.
    public var currentUser: @Sendable (_ organization: String) async throws -> Person
    /// Active pull requests `me` created, or is a reviewer of ("assigned").
    public var pullRequests: @Sendable (_ organization: String, _ involvement: PullRequestInvolvement, _ me: Person) async throws -> [PullRequest]
    /// Pull requests `me` created or reviews, in any status, that were created or closed at or after `since`.
    public var recentPullRequests: @Sendable (_ organization: String, _ involvement: PullRequestInvolvement, _ me: Person, _ since: Date) async throws -> [PullRequest]
    /// Pipeline runs of `me`, in any state, that were queued at or after `since`.
    public var recentBuilds: @Sendable (_ organization: String, _ me: Person, _ since: Date) async throws -> [Build]
    /// What happened on a pull request that the server records as system threads: votes and reviewers added.
    public var pullRequestEvents: @Sendable (_ organization: String, _ pullRequest: PullRequest) async throws -> [PullRequestEvent]
    /// Pipeline runs of `me` that are queued or running.
    public var activeBuilds: @Sendable (_ organization: String, _ me: Person) async throws -> [Build]
    /// One pull request by id, whatever its status (used to find out how a pull request ended).
    public var pullRequest: @Sendable (_ organization: String, _ project: String, _ id: Int) async throws -> PullRequest
    /// One pipeline run by id, whatever its state (used to find out how a run ended).
    public var build: @Sendable (_ organization: String, _ project: String, _ id: Int) async throws -> Build
    /// The stages, jobs and tasks of a pipeline run; empty while the run has not started.
    public var timeline: @Sendable (_ organization: String, _ project: String, _ buildId: Int) async throws -> BuildTimeline

    /// Sets `me`'s vote on a pull request.
    public var vote: @Sendable (_ organization: String, _ pullRequest: PullRequest, _ vote: ReviewVote, _ me: Person) async throws -> Void
    /// Sets auto-complete on a pull request: it completes with `strategy` once its policies pass.
    public var setAutoComplete: @Sendable (_ organization: String, _ pullRequest: PullRequest, _ strategy: MergeStrategy, _ me: Person) async throws -> Void
    /// Cancels auto-complete on a pull request.
    public var cancelAutoComplete: @Sendable (_ organization: String, _ pullRequest: PullRequest) async throws -> Void

    public init(
        currentUser: @escaping @Sendable (_ organization: String) async throws -> Person,
        pullRequests: @escaping @Sendable (_ organization: String, _ involvement: PullRequestInvolvement, _ me: Person) async throws -> [PullRequest],
        recentPullRequests: @escaping @Sendable (_ organization: String, _ involvement: PullRequestInvolvement, _ me: Person, _ since: Date) async throws -> [PullRequest],
        recentBuilds: @escaping @Sendable (_ organization: String, _ me: Person, _ since: Date) async throws -> [Build],
        pullRequestEvents: @escaping @Sendable (_ organization: String, _ pullRequest: PullRequest) async throws -> [PullRequestEvent],
        activeBuilds: @escaping @Sendable (_ organization: String, _ me: Person) async throws -> [Build],
        pullRequest: @escaping @Sendable (_ organization: String, _ project: String, _ id: Int) async throws -> PullRequest,
        build: @escaping @Sendable (_ organization: String, _ project: String, _ id: Int) async throws -> Build,
        timeline: @escaping @Sendable (_ organization: String, _ project: String, _ buildId: Int) async throws -> BuildTimeline,
        vote: @escaping @Sendable (_ organization: String, _ pullRequest: PullRequest, _ vote: ReviewVote, _ me: Person) async throws -> Void,
        setAutoComplete: @escaping @Sendable (_ organization: String, _ pullRequest: PullRequest, _ strategy: MergeStrategy, _ me: Person) async throws -> Void,
        cancelAutoComplete: @escaping @Sendable (_ organization: String, _ pullRequest: PullRequest) async throws -> Void
    ) {
        self.currentUser = currentUser
        self.pullRequests = pullRequests
        self.recentPullRequests = recentPullRequests
        self.recentBuilds = recentBuilds
        self.pullRequestEvents = pullRequestEvents
        self.activeBuilds = activeBuilds
        self.pullRequest = pullRequest
        self.build = build
        self.timeline = timeline
        self.vote = vote
        self.setAutoComplete = setAutoComplete
        self.cancelAutoComplete = cancelAutoComplete
    }
}
