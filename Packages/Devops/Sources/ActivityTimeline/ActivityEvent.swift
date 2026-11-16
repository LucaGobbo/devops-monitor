import Foundation

/// One entry of the timeline: something that happened to a pull request or a pipeline run.
public struct ActivityEvent: Sendable, Hashable, Identifiable {
    /// Deterministic, so the same event has the same id every time the timeline is rebuilt.
    public var id: String
    public var date: Date
    public var organization: String
    public var kind: ActivityKind
    /// The pull request number or the run id.
    public var itemID: Int
    /// The pull request title, or the pipeline name and run number.
    public var title: String
    public var detail: String?
    public var project: String?
    public var url: URL?

    public init(
        id: String, date: Date, organization: String, kind: ActivityKind, itemID: Int, title: String,
        detail: String? = nil, project: String? = nil, url: URL? = nil
    ) {
        self.id = id
        self.date = date
        self.organization = organization
        self.kind = kind
        self.itemID = itemID
        self.title = title
        self.detail = detail
        self.project = project
        self.url = url
    }
}
