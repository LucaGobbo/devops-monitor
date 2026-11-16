import Foundation

public enum PullRequestStatus: Sendable, Hashable {
    case active, completed, abandoned, unknown
}
