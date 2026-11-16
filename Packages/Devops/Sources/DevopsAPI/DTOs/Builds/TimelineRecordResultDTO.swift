import Foundation

public struct TimelineRecordResultDTO: RawRepresentable, Codable, Sendable, Hashable {
    public let rawValue: String
    public init(rawValue: String) { self.rawValue = rawValue }

    public static let succeeded = Self(rawValue: "succeeded")
    public static let succeededWithIssues = Self(rawValue: "succeededWithIssues")
    public static let failed = Self(rawValue: "failed")
    public static let canceled = Self(rawValue: "canceled")
    public static let skipped = Self(rawValue: "skipped")
    public static let abandoned = Self(rawValue: "abandoned")
}
