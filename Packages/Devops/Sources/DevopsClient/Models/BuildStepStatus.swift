import Foundation

/// How a stage, job or task of a run is doing.
public enum BuildStepStatus: Sendable, Hashable {
    case pending, running
    case succeeded, succeededWithIssues, failed, canceled, skipped

    /// Running, or about to.
    public var isActive: Bool { self == .pending || self == .running }
}
