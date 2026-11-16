import DevopsClient
import Foundation

extension DevopsClient {
    /// Sample pull requests for this module's previews.
    static let previewPullRequests: [PullRequest] = [
        PullRequest(
            id: 22, title: "Add the new feature", author: Person(id: "1", displayName: "Normal Paulk"),
            repository: "app", project: "Fabrikam", sourceBranch: "feature/new", targetBranch: "main",
            createdAt: .now.addingTimeInterval(-7200),
            reviewers: [
                Reviewer(person: Person(id: "2", displayName: "Reviewer One"), vote: .approved, isRequired: true),
                Reviewer(person: Person(id: "3", displayName: "Reviewer Two"), vote: .noVote),
            ],
            webURL: URL(string: "https://dev.azure.com/fabrikam")
        ),
        PullRequest(id: 21, title: "Fix flaky test", isDraft: true),
    ]
}
