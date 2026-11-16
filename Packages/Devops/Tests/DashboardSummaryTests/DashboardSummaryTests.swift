import ActivityTimeline
import DevopsClient
import Foundation
import Testing
@testable import DashboardSummary

struct DashboardSummaryTests {
    private let me = Person(id: "me", displayName: "Me")
    private let now = Date(timeIntervalSince1970: 10_000_000)
    private let day: TimeInterval = 24 * 60 * 60

    private func summary(
        pipelines: [Build] = [], created: [PullRequest] = [], assigned: [PullRequest] = [], activity: [ActivityEvent] = []
    ) -> DashboardSummary {
        DashboardSummary(
            pipelines: pipelines, createdPullRequests: created, assignedPullRequests: assigned,
            activity: activity, me: me, now: now
        )
    }

    private func run(_ kind: ActivityKind, id: Int, secondsAgo: TimeInterval = 0) -> ActivityEvent {
        ActivityEvent(
            id: "\(kind.rawValue)-\(id)", date: now.addingTimeInterval(-secondsAgo), organization: "o",
            kind: kind, itemID: id, title: "CI \(id)"
        )
    }

    private func pr(
        _ id: Int, daysOld: Double = 0, draft: Bool = false, autoComplete: Bool = false, reviewers: [Reviewer] = []
    ) -> PullRequest {
        PullRequest(
            id: id, title: "PR \(id)", isDraft: draft, createdAt: now.addingTimeInterval(-daysOld * day),
            reviewers: reviewers, isAutoCompleteSet: autoComplete
        )
    }

    private func reviewer(_ id: String, _ vote: ReviewVote, required: Bool = false) -> Reviewer {
        Reviewer(person: Person(id: id), vote: vote, isRequired: required)
    }

    // MARK: Pipelines now

    @Test func countsRunningAndQueuedRuns() {
        let result = summary(pipelines: [
            Build(id: 1, state: .inProgress), Build(id: 2, state: .inProgress), Build(id: 3, state: .notStarted),
        ])
        #expect(result.runningCount == 2)
        #expect(result.queuedCount == 1)
    }

    @Test func theLongestRunningRunStartedFirst() {
        let result = summary(pipelines: [
            Build(id: 1, state: .inProgress, startedAt: now.addingTimeInterval(-60)),
            Build(id: 2, state: .inProgress, startedAt: now.addingTimeInterval(-600)),
            Build(id: 3, state: .notStarted, queuedAt: now.addingTimeInterval(-6000)),
        ])
        #expect(result.longestRunning?.id == 2)
    }

    @Test func nothingRunningMeansNoLongestRun() {
        #expect(summary(pipelines: [Build(id: 3, state: .notStarted)]).longestRunning == nil)
    }

    // MARK: Recent runs

    @Test func recentRunsAreFinishedRunsNewestFirst() {
        let result = summary(activity: [
            run(.buildQueued, id: 1, secondsAgo: 1), run(.buildSucceeded, id: 2, secondsAgo: 300),
            run(.pullRequestCompleted, id: 3, secondsAgo: 2), run(.buildFailed, id: 4, secondsAgo: 100),
            run(.buildStarted, id: 5, secondsAgo: 3),
        ])
        #expect(result.recentRuns.map(\.itemID) == [4, 2])
    }

    @Test func recentRunsAreCappedAtSeven() {
        let events = (1...10).map { run(.buildSucceeded, id: $0, secondsAgo: TimeInterval($0)) }
        let result = summary(activity: events)
        #expect(result.recentRuns.count == 7)
        #expect(result.recentRuns.map(\.itemID) == Array(1...7))
    }

    // MARK: Needs my review

    @Test func needsMyReviewListsPullRequestsIHaveNotVotedOnOldestFirst() {
        let result = summary(assigned: [
            pr(1, daysOld: 1, reviewers: [reviewer("me", .noVote)]),
            pr(2, daysOld: 5, reviewers: [reviewer("me", .noVote)]),
            pr(3, daysOld: 9, reviewers: [reviewer("me", .approved)]),
            pr(4, daysOld: 9, reviewers: [reviewer("other", .noVote)]),
        ])
        #expect(result.needsMyReview.map(\.id) == [2, 1])
    }

    @Test func needsMyReviewSkipsDrafts() {
        let result = summary(assigned: [pr(1, draft: true, reviewers: [reviewer("me", .noVote)])])
        #expect(result.needsMyReview.isEmpty)
    }

    // MARK: My PRs

    @Test func eachBucketRule() {
        #expect(PullRequestBucket(pr(1, draft: true)) == .draft)
        #expect(PullRequestBucket(pr(1, reviewers: [reviewer("a", .rejected)])) == .blocked)
        #expect(PullRequestBucket(pr(1, reviewers: [reviewer("a", .waitingForAuthor)])) == .blocked)
        #expect(PullRequestBucket(pr(1, autoComplete: true)) == .autoComplete)
        #expect(PullRequestBucket(pr(1, reviewers: [reviewer("a", .approved)])) == .approved)
        #expect(PullRequestBucket(pr(1, reviewers: [reviewer("a", .approvedWithSuggestions)])) == .approved)
        #expect(PullRequestBucket(pr(1, reviewers: [reviewer("a", .noVote)])) == .waitingForReview)
        #expect(PullRequestBucket(pr(1)) == .waitingForReview)
    }

    @Test func aRequiredReviewerWithoutApprovalKeepsItWaiting() {
        let waiting = pr(1, reviewers: [reviewer("a", .approved), reviewer("b", .noVote, required: true)])
        #expect(PullRequestBucket(waiting) == .waitingForReview)
    }

    @Test func precedenceIsDraftThenBlockedThenAutoComplete() {
        #expect(PullRequestBucket(pr(1, draft: true, autoComplete: true, reviewers: [reviewer("a", .rejected)])) == .draft)
        #expect(PullRequestBucket(pr(1, autoComplete: true, reviewers: [reviewer("a", .rejected)])) == .blocked)
        #expect(PullRequestBucket(pr(1, autoComplete: true, reviewers: [reviewer("a", .approved)])) == .autoComplete)
    }

    @Test func countsMyPullRequestsPerBucket() {
        let result = summary(created: [
            pr(1, draft: true), pr(2), pr(3), pr(4, reviewers: [reviewer("a", .approved)]),
        ])
        #expect(result.myPullRequestCounts == [.draft: 1, .waitingForReview: 2, .approved: 1])
    }

    // MARK: Needs attention

    @Test func aFailedRunNeedsAttentionButACanceledOneDoesNot() {
        let result = summary(activity: [run(.buildFailed, id: 1), run(.buildCanceled, id: 2)])
        #expect(result.attention.map(\.id) == ["run-1"])
    }

    @Test func aBlockedPullRequestNeedsAttention() {
        let result = summary(created: [pr(1, reviewers: [reviewer("a", .rejected)])])
        #expect(result.attention == [.blockedPullRequest(pr(1, reviewers: [reviewer("a", .rejected)]))])
    }

    @Test func aPullRequestIsStaleFromThreeDays() {
        let fresh = summary(created: [pr(1, daysOld: 2.99)])
        let stale = summary(created: [pr(1, daysOld: 3)])
        #expect(fresh.attention.isEmpty)
        #expect(stale.attention.map(\.id) == ["pr-1"])
    }

    @Test func draftsAreNeverStale() {
        #expect(summary(created: [pr(1, daysOld: 30, draft: true)]).attention.isEmpty)
    }

    @Test func aStalePullRequestWaitingForMyReviewNeedsAttention() {
        let result = summary(assigned: [pr(1, daysOld: 4, reviewers: [reviewer("me", .noVote)])])
        #expect(result.attention.map(\.id) == ["pr-1"])
    }

    @Test func aBlockedStalePullRequestIsListedOnce() {
        let result = summary(created: [pr(1, daysOld: 10, reviewers: [reviewer("a", .rejected)])])
        #expect(result.attention.count == 1)
        guard case .blockedPullRequest = result.attention[0] else {
            Issue.record("expected a blocked pull request")
            return
        }
    }

    @Test func attentionIsOrderedFailedRunsThenBlockedThenStaleOldestFirst() {
        let result = summary(
            created: [pr(1, daysOld: 4), pr(2, reviewers: [reviewer("a", .waitingForAuthor)]), pr(3, daysOld: 8)],
            activity: [run(.buildFailed, id: 9)]
        )
        #expect(result.attention.map(\.id) == ["run-9", "pr-2", "pr-3", "pr-1"])
    }

    @Test func everythingEmptyGivesAnEmptySummary() {
        let result = summary()
        #expect(result.runningCount == 0 && result.queuedCount == 0)
        #expect(result.longestRunning == nil)
        #expect(result.recentRuns.isEmpty && result.needsMyReview.isEmpty && result.attention.isEmpty)
        #expect(result.myPullRequestCounts.isEmpty)
    }
}
