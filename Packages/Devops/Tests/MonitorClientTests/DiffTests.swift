import DevopsClient
import Testing

@testable import MonitorClient

struct DiffTests {
    private let running = Build(id: 1, state: .inProgress)
    private let queued = Build(id: 2, state: .notStarted)
    private func pullRequest(_ id: Int, _ status: PullRequestStatus = .active) -> PullRequest {
        PullRequest(id: id, title: "PR \(id)", status: status)
    }

    @Test func nothingDepartsWhenNothingChanged() {
        let snapshot = MonitorSnapshot(pipelines: [running], createdPullRequests: [pullRequest(1)])
        #expect(snapshot.departed(since: snapshot).isEmpty)
    }

    @Test func newItemsAreNotDeparted() {
        let before = MonitorSnapshot()
        let after = MonitorSnapshot(pipelines: [running], createdPullRequests: [pullRequest(1)])
        #expect(after.departed(since: before).isEmpty)
    }

    @Test func buildsAndCreatedPullRequestsThatLeaveTheListDepart() {
        let before = MonitorSnapshot(pipelines: [running, queued], createdPullRequests: [pullRequest(1), pullRequest(2)])
        let after = MonitorSnapshot(pipelines: [queued], createdPullRequests: [pullRequest(2)])
        let departed = after.departed(since: before)
        #expect(departed.builds.map(\.id) == [1])
        #expect(departed.pullRequests.map(\.id) == [1])
    }

    @Test func aPullRequestCreatedByMeIsNotAlsoListedAsAssigned() {
        let snapshot = MonitorSnapshot(createdPullRequests: [pullRequest(1)], assignedPullRequests: [pullRequest(1), pullRequest(2)])
        #expect(snapshot.assignedPullRequests.map(\.id) == [2])
    }

    @Test func assignedPullRequestsAreNotTracked() {
        let before = MonitorSnapshot(assignedPullRequests: [pullRequest(7)])
        #expect(MonitorSnapshot().departed(since: before).isEmpty)
    }

    @Test(arguments: [(PullRequestStatus.completed, true), (.abandoned, true), (.active, false), (.unknown, false)])
    func onlyEndedPullRequestsAreReported(status: PullRequestStatus, reported: Bool) {
        #expect((MonitorChange(resolved: pullRequest(1, status)) != nil) == reported)
    }

    @Test(arguments: [
        (BuildState.succeeded, true), (.failed, true), (.canceled, true), (.partiallySucceeded, true),
        (.inProgress, false), (.notStarted, false), (.unknown, false),
    ])
    func onlyEndedBuildsAreReported(state: BuildState, reported: Bool) {
        #expect((MonitorChange(resolved: Build(id: 1, state: state)) != nil) == reported)
    }

    @Test func eachEndingHasItsOwnChange() {
        #expect(MonitorChange(resolved: pullRequest(1, .abandoned)) == .pullRequestAbandoned(pullRequest(1, .abandoned)))
        #expect(MonitorChange(resolved: Build(id: 1, state: .canceled)) == .buildCanceled(Build(id: 1, state: .canceled)))
        #expect(
            MonitorChange(resolved: Build(id: 1, state: .partiallySucceeded))
                == .buildPartiallySucceeded(Build(id: 1, state: .partiallySucceeded))
        )
    }

    @Test func pollsFastOnlyWhileAPipelineIsActive() {
        #expect(MonitorSnapshot().pollInterval == .seconds(60))
        #expect(MonitorSnapshot(pipelines: [running]).pollInterval == .seconds(10))
    }
}
