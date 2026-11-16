import DevopsClient
import Foundation
import SnapshotClient
import Testing

@testable import AppStore

struct WidgetSnapshotTests {
    private let now = Date(timeIntervalSince1970: 1_000)

    @Test func aPullRequestCreatedAndAssignedAppearsOnceAsCreated() {
        let both = PullRequest(id: 1, title: "Both", project: "P")
        let reviewOnly = PullRequest(id: 2, title: "Review me", project: "P")
        let snapshot = WidgetSnapshot(
            pipelines: [], created: [both], assigned: [both, reviewOnly], organization: "fabrikam", now: now
        )
        #expect(snapshot.pullRequests.map(\.id) == [1, 2])
        #expect(snapshot.pullRequests.map(\.isCreatedByMe) == [true, false])
        #expect(snapshot.updatedAt == now)
    }

    @Test func pullRequestsKeepTheirDetailsAndLink() throws {
        let pullRequest = PullRequest(
            id: 7, title: "Add it", author: Person(id: "1", displayName: "Normal Paulk"), repository: "app",
            project: "P", isDraft: true
        )
        let item = try #require(
            WidgetSnapshot(pipelines: [], created: [pullRequest], assigned: [], organization: "fabrikam", now: now).pullRequests.first
        )
        #expect(item.title == "Add it")
        #expect(item.repository == "app")
        #expect(item.author == "Normal Paulk")
        #expect(item.isDraft)
        #expect(item.url?.absoluteString == "https://dev.azure.com/fabrikam/P/_git/app/pullrequest/7")
    }

    @Test func onlyRunningPipelinesAreMarkedRunning() {
        let started = Date(timeIntervalSince1970: 900)
        let snapshot = WidgetSnapshot(
            pipelines: [
                Build(id: 1, number: "1.1", state: .inProgress, pipeline: "CI", project: "P", branch: "main", startedAt: started),
                Build(id: 2, state: .notStarted, project: "P"),
            ],
            created: [], assigned: [], organization: "fabrikam", now: now
        )
        #expect(snapshot.pipelines.map(\.isRunning) == [true, false])
        #expect(snapshot.pipelines[0].name == "CI")
        #expect(snapshot.pipelines[0].startedAt == started)
        #expect(snapshot.pipelines[1].name == "Pipeline")
        #expect(snapshot.pipelines[0].url?.absoluteString == "https://dev.azure.com/fabrikam/P/_build/results?buildId=1")
    }
}
