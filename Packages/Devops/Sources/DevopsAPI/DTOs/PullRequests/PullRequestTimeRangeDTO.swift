import Foundation

/// Which date of a pull request `searchCriteria.minTime` applies to.
public struct PullRequestTimeRangeDTO: RawRepresentable, Codable, Sendable, Hashable {
    public let rawValue: String
    public init(rawValue: String) { self.rawValue = rawValue }

    public static let created = Self(rawValue: "created")
    public static let closed = Self(rawValue: "closed")
}
