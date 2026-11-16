import Foundation

extension SnapshotClient {
    /// Stores nothing and has nothing to load; tests replace `save` to record what would be written.
    public static let testValue = SnapshotClient(save: { _ in }, load: { nil })

    /// Sample pull requests and pipelines, so widget previews have something to show.
    public static let previewValue = SnapshotClient(save: { _ in }, load: { .preview })
}

extension WidgetSnapshot {
    /// Sample data for previews.
    public static let preview = WidgetSnapshot(
        updatedAt: Date(),
        pullRequests: [
            WidgetPullRequest(id: 101, title: "Add the new onboarding flow", repository: "app", author: "Normal Paulk", isCreatedByMe: false),
            WidgetPullRequest(id: 102, title: "Fix crash when the token expires", repository: "app", author: "Me"),
            WidgetPullRequest(id: 103, title: "Draft: refactor networking", repository: "core", author: "Me", isDraft: true),
        ],
        pipelines: [
            WidgetPipeline(id: 1, name: "CI", number: "20241101.3", branch: "main", startedAt: Date().addingTimeInterval(-240)),
            WidgetPipeline(id: 2, name: "Release", number: "20241101.4", branch: "release/1.2", isRunning: false),
        ]
    )
}

extension SnapshotClient {
    /// The App Group shared by the app and the widget extension. Must match the group in both targets' entitlements.
    public static let appGroupID = "group.com.lagoonpixel.Devopsmonitor"
}
