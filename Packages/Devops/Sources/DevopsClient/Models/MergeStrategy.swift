import Foundation

/// How a pull request is merged when it completes.
public enum MergeStrategy: Sendable, Hashable, CaseIterable {
    /// A merge commit.
    case noFastForward
    /// One squashed commit.
    case squash
    /// Rebases the source branch onto the target, then fast-forwards.
    case rebase
    /// Rebases the source branch onto the target, then creates a merge commit.
    case rebaseMerge
}
