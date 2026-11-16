import Foundation

public struct MergeStatusDTO: RawRepresentable, Codable, Sendable, Hashable {
    public let rawValue: String
    public init(rawValue: String) { self.rawValue = rawValue }

    public static let notSet = Self(rawValue: "notSet")
    public static let queued = Self(rawValue: "queued")
    public static let conflicts = Self(rawValue: "conflicts")
    public static let succeeded = Self(rawValue: "succeeded")
    public static let rejectedByPolicy = Self(rawValue: "rejectedByPolicy")
    public static let failure = Self(rawValue: "failure")
}
