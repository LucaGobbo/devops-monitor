import Foundation

/// A queued or running pipeline run as the widget shows it.
public struct WidgetPipeline: Sendable, Hashable, Codable, Identifiable {
    public var id: Int
    public var name: String
    public var number: String?
    public var branch: String?
    /// `false` while it is still queued.
    public var isRunning: Bool
    public var startedAt: Date?
    public var url: URL?

    public init(
        id: Int, name: String, number: String? = nil, branch: String? = nil,
        isRunning: Bool = true, startedAt: Date? = nil, url: URL? = nil
    ) {
        self.id = id
        self.name = name
        self.number = number
        self.branch = branch
        self.isRunning = isRunning
        self.startedAt = startedAt
        self.url = url
    }
}
