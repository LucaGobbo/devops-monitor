import Foundation

public struct BuildStage: Sendable, Hashable, Identifiable {
    public var id: String
    public var name: String
    public var status: BuildStepStatus
    public var startedAt: Date?
    public var finishedAt: Date?
    public var jobs: [BuildJob]

    public init(
        id: String, name: String, status: BuildStepStatus, startedAt: Date? = nil, finishedAt: Date? = nil,
        jobs: [BuildJob] = []
    ) {
        self.id = id
        self.name = name
        self.status = status
        self.startedAt = startedAt
        self.finishedAt = finishedAt
        self.jobs = jobs
    }
}
