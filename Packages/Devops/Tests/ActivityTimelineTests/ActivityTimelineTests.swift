import DevopsClient
import Foundation
import Testing
@testable import ActivityTimeline

/// The derivation is a pure function, so every rule is a table row with fixed dates.
struct ActivityTimelineTests {
    private let me = Person(id: "D6245F20-2AF8-44F4-9451-8107CB2767DB", displayName: "Me")
    private let meThreadID = "d6245f202af844f494518107cb2767db"
    private let anna = Person(id: "11111111-1111-1111-1111-111111111111", displayName: "Anna")
    private let since = Date(timeIntervalSince1970: 1_000_000)

    private func at(_ seconds: TimeInterval) -> Date { since.addingTimeInterval(seconds) }

    private func events(
        builds: [Build] = [], pullRequests: [PullRequest] = [], threads: [Int: [PullRequestEvent]] = [:], since: Date? = nil
    ) -> [ActivityEvent] {
        ActivityTimeline.events(
            builds: builds, pullRequests: pullRequests, pullRequestEvents: threads, me: me, organization: "fabrikam",
            since: since ?? self.since
        )
    }

    private func pullRequest(
        id: Int = 1, author: Person? = nil, status: PullRequestStatus = .active, createdAt: Date? = nil, closedAt: Date? = nil
    ) -> PullRequest {
        PullRequest(
            id: id, title: "Add feature", author: author ?? me, repository: "app", project: "Fabrikam",
            createdAt: createdAt, closedAt: closedAt, status: status
        )
    }

    @Test func aBuildYieldsAnEventPerTimeItHas() {
        let build = Build(
            id: 9, number: "20241101.1", state: .failed, pipeline: "CI", project: "Fabrikam", branch: "main",
            queuedAt: at(10), startedAt: at(20), finishedAt: at(30)
        )
        let result = events(builds: [build])
        #expect(result.map(\.kind) == [.buildFailed, .buildStarted, .buildQueued])
        #expect(result.map(\.id) == ["build-9-buildFailed", "build-9-buildStarted", "build-9-buildQueued"])
        #expect(result.allSatisfy { $0.title == "CI 20241101.1" && $0.detail == "main" && $0.itemID == 9 && $0.organization == "fabrikam" })
    }

    @Test(arguments: [
        (BuildState.succeeded, ActivityKind.buildSucceeded),
        (.partiallySucceeded, .buildPartiallySucceeded),
        (.failed, .buildFailed),
        (.canceled, .buildCanceled),
    ])
    func aFinishedBuildIsReportedByItsResult(state: BuildState, kind: ActivityKind) {
        #expect(events(builds: [Build(id: 1, state: state, finishedAt: at(5))]).map(\.kind) == [kind])
    }

    @Test func aRunThatIsStillGoingHasNoFinishEvent() {
        let running = Build(id: 1, state: .inProgress, queuedAt: at(1), startedAt: at(2), finishedAt: at(3))
        #expect(events(builds: [running]).map(\.kind) == [.buildStarted, .buildQueued])
    }

    @Test func aBuildWithoutNameOrNumberIsTitledByItsId() {
        #expect(events(builds: [Build(id: 4, queuedAt: at(1))]).first?.title == "Run 4")
    }

    @Test func myPullRequestIsOpenedAndCompleted() {
        let result = events(pullRequests: [pullRequest(status: .completed, createdAt: at(10), closedAt: at(50))])
        #expect(result.map(\.kind) == [.pullRequestCompleted, .pullRequestOpened])
        #expect(result.map(\.id) == ["pr-1-pullRequestCompleted", "pr-1-pullRequestOpened"])
    }

    @Test func myPullRequestCanBeAbandoned() {
        #expect(events(pullRequests: [pullRequest(status: .abandoned, createdAt: at(10), closedAt: at(20))]).map(\.kind)
            == [.pullRequestAbandoned, .pullRequestOpened])
    }

    @Test func anActivePullRequestHasNoEndEvenWithAClosedDate() {
        #expect(events(pullRequests: [pullRequest(createdAt: at(10), closedAt: at(20))]).map(\.kind) == [.pullRequestOpened])
    }

    @Test func aPullRequestOfSomeoneElseIsNeitherOpenedNorCompleted() {
        #expect(events(pullRequests: [pullRequest(author: anna, status: .completed, createdAt: at(10), closedAt: at(20))]).isEmpty)
    }

    @Test func beingAddedAsReviewerIsAnAssignment() {
        let threads = [1: [PullRequestEvent(id: 3, date: at(40), kind: .reviewerAdded(personID: meThreadID))]]
        let result = events(pullRequests: [pullRequest(author: anna)], threads: threads)
        #expect(result.map(\.kind) == [.pullRequestAssigned])
        #expect(result.first?.id == "pr-1-pullRequestAssigned-3")
        #expect(result.first?.date == at(40))
    }

    @Test func someoneElseBeingAddedIsNotMyAssignment() {
        let threads = [1: [PullRequestEvent(id: 3, date: at(40), kind: .reviewerAdded(personID: "aaaabbbbccccddddeeeeffff00001111"))]]
        #expect(events(pullRequests: [pullRequest(author: anna)], threads: threads).isEmpty)
    }

    @Test func aVoteIsAReviewWithWhoAndWhat() {
        let threads = [1: [PullRequestEvent(id: 5, date: at(60), kind: .voted(personID: "x", name: "Anna", vote: .approvedWithSuggestions))]]
        let result = events(pullRequests: [pullRequest()], threads: threads)
        #expect(result.map(\.kind) == [.pullRequestReviewed])
        #expect(result.first?.detail == "Anna approved with suggestions")
        #expect(result.first?.id == "pr-1-pullRequestReviewed-5")
    }

    @Test func aVoteWithoutAnAuthorNameSaysSomeone() {
        let threads = [1: [PullRequestEvent(id: 5, date: at(60), kind: .voted(personID: "x", name: nil, vote: .rejected))]]
        #expect(events(pullRequests: [pullRequest()], threads: threads).first?.detail == "Someone rejected")
    }

    @Test func resettingAVoteIsNotAnEvent() {
        let threads = [1: [PullRequestEvent(id: 5, date: at(60), kind: .voted(personID: "x", name: "Anna", vote: .noVote))]]
        #expect(events(pullRequests: [pullRequest()], threads: threads).isEmpty)
    }

    @Test func twoVotesByTheSamePersonAreTwoEvents() {
        let threads = [1: [
            PullRequestEvent(id: 5, date: at(60), kind: .voted(personID: "x", name: "Anna", vote: .waitingForAuthor)),
            PullRequestEvent(id: 8, date: at(90), kind: .voted(personID: "x", name: "Anna", vote: .approved)),
        ]]
        let result = events(pullRequests: [pullRequest()], threads: threads)
        #expect(result.map(\.id) == ["pr-1-pullRequestReviewed-8", "pr-1-pullRequestReviewed-5"])
    }

    @Test func eventsBeforeTheWindowAreDropped() {
        let old = pullRequest(status: .completed, createdAt: at(-100), closedAt: at(10))
        let threads = [1: [PullRequestEvent(id: 5, date: at(-5), kind: .voted(personID: "x", name: "Anna", vote: .approved))]]
        let build = Build(id: 2, state: .succeeded, queuedAt: at(-50), finishedAt: at(5))
        let result = events(builds: [build], pullRequests: [old], threads: threads)
        #expect(Set(result.map(\.id)) == ["pr-1-pullRequestCompleted", "build-2-buildSucceeded"])
    }

    @Test func aPullRequestListedTwiceIsCountedOnce() {
        // Created by me and assigned to me: it is in both lists.
        let same = pullRequest(createdAt: at(10))
        #expect(events(pullRequests: [same, same]).count == 1)
    }

    @Test func eventsAreSortedNewestFirstWithAStableOrderForTies() {
        let builds = [Build(id: 1, queuedAt: at(10)), Build(id: 2, queuedAt: at(30)), Build(id: 3, queuedAt: at(30))]
        #expect(events(builds: builds).map(\.itemID) == [3, 2, 1])
    }

    @Test func theSameInputGivesTheSameIDs() {
        let builds = [Build(id: 1, state: .succeeded, queuedAt: at(1), startedAt: at(2), finishedAt: at(3))]
        let pullRequests = [pullRequest(createdAt: at(4))]
        #expect(events(builds: builds, pullRequests: pullRequests).map(\.id) == events(builds: builds, pullRequests: pullRequests).map(\.id))
    }
}
