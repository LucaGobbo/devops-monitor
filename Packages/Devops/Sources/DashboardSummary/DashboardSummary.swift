import ActivityTimeline
import DevopsClient
import Foundation

/// What the dashboard shows, derived from what the app already holds. Pure: no requests, no stored state.
public struct DashboardSummary: Sendable, Hashable {
    /// How many finished runs the dashboard lists.
    public static let recentRunsLimit = 7
    /// A pull request that has been open this long (3 days) is stale.
    public static let defaultStaleAfter: TimeInterval = 3 * 24 * 60 * 60

    public var runningCount: Int
    public var queuedCount: Int
    /// The run that has been running the longest.
    public var longestRunning: Build?
    /// The last ``recentRunsLimit`` finished runs, newest first.
    public var recentRuns: [ActivityEvent]
    /// Pull requests I review and have not voted on, oldest first.
    public var needsMyReview: [PullRequest]
    public var myPullRequestCounts: [PullRequestBucket: Int]
    /// Failed runs first, then blocked pull requests, then stale ones (oldest first).
    public var attention: [AttentionItem]

    public init(
        pipelines: [Build], createdPullRequests: [PullRequest], assignedPullRequests: [PullRequest],
        activity: [ActivityEvent], me: Person, now: Date, staleAfter: TimeInterval = Self.defaultStaleAfter
    ) {
        runningCount = pipelines.count { $0.state == .inProgress }
        queuedCount = pipelines.count { $0.state == .notStarted }
        longestRunning = pipelines.filter { $0.state == .inProgress }
            .min { ($0.startedAt ?? .distantFuture) < ($1.startedAt ?? .distantFuture) }

        recentRuns = Array(
            activity.filter { Self.finishedRunKinds.contains($0.kind) }
                .sorted { $0.date > $1.date }
                .prefix(Self.recentRunsLimit)
        )

        let needsReview = assignedPullRequests
            .filter { !$0.isDraft && $0.reviewers.contains { $0.person.id == me.id && $0.vote == .noVote } }
            .sorted(by: Self.oldestFirst)
        needsMyReview = needsReview

        let buckets = createdPullRequests.map { ($0, PullRequestBucket($0)) }
        myPullRequestCounts = Dictionary(grouping: buckets, by: \.1).mapValues(\.count)

        let blocked = buckets.filter { $0.1 == .blocked }.map(\.0)
        let blockedIDs = Set(blocked.map(\.id))
        let cutoff = now.addingTimeInterval(-staleAfter)
        let stale = (createdPullRequests.filter { !$0.isDraft } + needsReview)
            .filter { !blockedIDs.contains($0.id) && ($0.createdAt ?? .distantFuture) <= cutoff }
            .sorted(by: Self.oldestFirst)

        attention = recentRuns.filter { $0.kind == .buildFailed }.map(AttentionItem.failedRun)
            + blocked.map(AttentionItem.blockedPullRequest)
            + stale.map(AttentionItem.stalePullRequest)
    }

    private static let finishedRunKinds: Set<ActivityKind> = [
        .buildSucceeded, .buildPartiallySucceeded, .buildFailed, .buildCanceled,
    ]

    private static func oldestFirst(_ a: PullRequest, _ b: PullRequest) -> Bool {
        (a.createdAt ?? .distantFuture) < (b.createdAt ?? .distantFuture)
    }
}
