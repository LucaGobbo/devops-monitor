import Foundation

public struct TimelineRecordStateDTO: RawRepresentable, Codable, Sendable, Hashable {
    public let rawValue: String
    public init(rawValue: String) { self.rawValue = rawValue }

    public static let pending = Self(rawValue: "pending")
    public static let inProgress = Self(rawValue: "inProgress")
    public static let completed = Self(rawValue: "completed")
}
