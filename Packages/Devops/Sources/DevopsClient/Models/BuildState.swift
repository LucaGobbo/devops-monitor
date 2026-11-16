import Foundation

public enum BuildState: Sendable, Hashable {
    case notStarted, inProgress
    case succeeded, partiallySucceeded, failed, canceled
    case unknown
}
