import ActivityTimeline
import DashboardSummary
import DevopsClient
import Foundation

extension DashboardSummary {
    static let previewMe = Person(id: "me", displayName: "Me")

    static let previewPullRequest = PullRequest(
        id: 22, title: "Add the new feature", repository: "app", createdAt: .now.addingTimeInterval(-4 * 86_400),
        reviewers: [Reviewer(person: previewMe, vote: .noVote)], webURL: URL(string: "https://dev.azure.com/fabrikam")
    )

    /// Sample data for this module's previews.
    static let preview = DashboardSummary(
        pipelines: [
            Build(id: 5, number: "20241101.1", state: .inProgress, pipeline: "CI", startedAt: .now.addingTimeInterval(-300)),
            Build(id: 4, state: .notStarted, pipeline: "Release"),
        ],
        createdPullRequests: [
            PullRequest(id: 30, title: "Draft work", isDraft: true),
            PullRequest(
                id: 31, title: "Refactor client", repository: "app", createdAt: .now.addingTimeInterval(-5 * 86_400),
                reviewers: [Reviewer(person: Person(id: "2"), vote: .rejected)]
            ),
            PullRequest(id: 32, title: "Fix flaky test", reviewers: [Reviewer(person: Person(id: "2"), vote: .approved)]),
        ],
        assignedPullRequests: [previewPullRequest],
        activity: [
            event(.buildFailed, id: 9, title: "CI 20241101.3", minutesAgo: 5),
            event(.buildSucceeded, id: 8, title: "CI 20241101.2", minutesAgo: 60),
            event(.buildPartiallySucceeded, id: 7, title: "Release 20241031.1", minutesAgo: 600),
            event(.buildCanceled, id: 6, title: "CI 20241031.4", minutesAgo: 900),
        ],
        me: previewMe, now: .now
    )

    private static func event(_ kind: ActivityKind, id: Int, title: String, minutesAgo: Int) -> ActivityEvent {
        ActivityEvent(
            id: "\(kind.rawValue)-\(id)", date: .now.addingTimeInterval(-TimeInterval(minutesAgo * 60)),
            organization: "fabrikam", kind: kind, itemID: id, title: title, detail: "main"
        )
    }
}
