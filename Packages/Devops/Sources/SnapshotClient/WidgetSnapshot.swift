import Foundation

/// What the widgets show: the open pull requests and the queued or running pipelines at one moment.
/// The app writes it after each poll; the widget extension only reads it.
public struct WidgetSnapshot: Sendable, Hashable, Codable {
    public var updatedAt: Date
    public var pullRequests: [WidgetPullRequest]
    public var pipelines: [WidgetPipeline]

    public init(updatedAt: Date, pullRequests: [WidgetPullRequest] = [], pipelines: [WidgetPipeline] = []) {
        self.updatedAt = updatedAt
        self.pullRequests = pullRequests
        self.pipelines = pipelines
    }
}
