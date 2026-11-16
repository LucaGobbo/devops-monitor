import Foundation

/// A pipeline run.
public struct Build: Sendable, Hashable, Identifiable {
    public var id: Int
    public var number: String?
    public var state: BuildState
    public var pipeline: String?
    public var project: String?
    public var branch: String?
    public var requestedBy: Person?
    public var queuedAt: Date?
    public var startedAt: Date?
    public var finishedAt: Date?
    /// Link to the run in the Azure DevOps web UI.
    public var webURL: URL?

    public init(
        id: Int, number: String? = nil, state: BuildState = .unknown, pipeline: String? = nil, project: String? = nil,
        branch: String? = nil, requestedBy: Person? = nil, queuedAt: Date? = nil, startedAt: Date? = nil,
        finishedAt: Date? = nil, webURL: URL? = nil
    ) {
        self.id = id
        self.number = number
        self.state = state
        self.pipeline = pipeline
        self.project = project
        self.branch = branch
        self.requestedBy = requestedBy
        self.queuedAt = queuedAt
        self.startedAt = startedAt
        self.finishedAt = finishedAt
        self.webURL = webURL
    }
}
