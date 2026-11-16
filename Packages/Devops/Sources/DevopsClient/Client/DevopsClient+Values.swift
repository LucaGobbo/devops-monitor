import Foundation

extension DevopsClient {
    /// Every endpoint throws ``DevopsClientError/unimplemented(_:)``, so a test fails on any call it did not expect.
    public static let testValue = DevopsClient(
        currentUser: { _ in throw DevopsClientError.unimplemented("currentUser") },
        pullRequests: { _, _, _ in throw DevopsClientError.unimplemented("pullRequests") },
        recentPullRequests: { _, _, _, _ in throw DevopsClientError.unimplemented("recentPullRequests") },
        recentBuilds: { _, _, _ in throw DevopsClientError.unimplemented("recentBuilds") },
        pullRequestEvents: { _, _ in throw DevopsClientError.unimplemented("pullRequestEvents") },
        activeBuilds: { _, _ in throw DevopsClientError.unimplemented("activeBuilds") },
        pullRequest: { _, _, _ in throw DevopsClientError.unimplemented("pullRequest") },
        build: { _, _, _ in throw DevopsClientError.unimplemented("build") },
        timeline: { _, _, _ in throw DevopsClientError.unimplemented("timeline") },
        vote: { _, _, _, _ in throw DevopsClientError.unimplemented("vote") },
        setAutoComplete: { _, _, _, _ in throw DevopsClientError.unimplemented("setAutoComplete") },
        cancelAutoComplete: { _, _ in throw DevopsClientError.unimplemented("cancelAutoComplete") }
    )

    /// Canned sample data for SwiftUI previews and demos.
    public static let previewValue = DevopsClient(
        currentUser: { _ in Person(id: "preview-user", displayName: "Normal Paulk") },
        pullRequests: { _, _, _ in
            [
                PullRequest(
                    id: 22, title: "Add the new feature", author: Person(id: "preview-user", displayName: "Normal Paulk"),
                    repository: "app", project: "Fabrikam", sourceBranch: "feature/new", targetBranch: "main",
                    reviewers: [Reviewer(person: Person(id: "reviewer-1", displayName: "Reviewer One"), vote: .approved, isRequired: true)]
                ),
                PullRequest(id: 21, title: "Fix flaky test", isDraft: true),
            ]
        },
        recentPullRequests: { _, _, _, _ in [] },
        recentBuilds: { _, _, _ in [] },
        pullRequestEvents: { _, _ in [] },
        activeBuilds: { _, _ in
            [Build(id: 5, number: "20241101.1", state: .inProgress, pipeline: "CI", project: "Fabrikam", branch: "main")]
        },
        pullRequest: { _, _, id in PullRequest(id: id, title: "Add the new feature", status: .completed) },
        build: { _, _, id in Build(id: id, number: "20241101.1", state: .succeeded, pipeline: "CI", project: "Fabrikam") },
        timeline: { _, _, _ in .preview },
        vote: { _, _, _, _ in },
        setAutoComplete: { _, _, _, _ in },
        cancelAutoComplete: { _, _ in }
    )
}
