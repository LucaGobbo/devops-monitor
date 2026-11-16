import Foundation
import Testing
@testable import ActivityTimeline

struct ActivityGroupTests {
    private func event(_ kind: ActivityKind, item: Int, at seconds: TimeInterval, title: String = "T", detail: String? = nil) -> ActivityEvent {
        ActivityEvent(
            id: "\(kind.rawValue)-\(item)-\(seconds)", date: Date(timeIntervalSince1970: seconds), organization: "o",
            kind: kind, itemID: item, title: title, detail: detail, project: "P"
        )
    }

    @Test func eventsOfOneItemShareAGroupNewestFirst() {
        let groups = ActivityGroup.grouping([
            event(.pullRequestOpened, item: 1, at: 10), event(.pullRequestCompleted, item: 1, at: 30), event(.pullRequestReviewed, item: 1, at: 20),
        ])
        #expect(groups.count == 1)
        #expect(groups[0].events.map(\.kind) == [.pullRequestCompleted, .pullRequestReviewed, .pullRequestOpened])
        #expect(groups[0].id == "pr-1")
    }

    @Test func aPullRequestAndARunWithTheSameNumberAreDifferentItems() {
        let groups = ActivityGroup.grouping([event(.pullRequestOpened, item: 5, at: 1), event(.buildQueued, item: 5, at: 2)])
        #expect(Set(groups.map(\.id)) == ["pr-5", "build-5"])
        #expect(groups.map(\.isPullRequest) == [false, true])
    }

    @Test func groupsAreOrderedByTheirNewestEvent() {
        let groups = ActivityGroup.grouping([
            event(.buildQueued, item: 1, at: 5), event(.buildSucceeded, item: 1, at: 50),
            event(.pullRequestOpened, item: 2, at: 20),
        ])
        #expect(groups.map(\.id) == ["build-1", "pr-2"])
    }

    @Test func theTitleIsTheNewestOnesAndTheContextSkipsWhoVoted() {
        let group = ActivityGroup.grouping([
            event(.pullRequestOpened, item: 1, at: 10, title: "Old title", detail: "app"),
            event(.pullRequestReviewed, item: 1, at: 20, title: "New title", detail: "Anna approved"),
        ])[0]
        #expect(group.title == "New title")
        #expect(group.context == "app")
    }
}
