import Foundation

/// How a pull request is merged when it completes (`completionOptions.mergeStrategy`).
public struct MergeStrategyDTO: RawRepresentable, Codable, Sendable, Hashable {
    public let rawValue: String
    public init(rawValue: String) { self.rawValue = rawValue }

    public static let noFastForward = Self(rawValue: "noFastForward")
    public static let squash = Self(rawValue: "squash")
    public static let rebase = Self(rawValue: "rebase")
    public static let rebaseMerge = Self(rawValue: "rebaseMerge")
}
