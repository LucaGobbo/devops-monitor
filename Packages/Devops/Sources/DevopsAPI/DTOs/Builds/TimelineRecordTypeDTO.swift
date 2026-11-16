import Foundation

public struct TimelineRecordTypeDTO: RawRepresentable, Codable, Sendable, Hashable {
    public let rawValue: String
    public init(rawValue: String) { self.rawValue = rawValue }

    public static let stage = Self(rawValue: "Stage")
    public static let phase = Self(rawValue: "Phase")
    public static let job = Self(rawValue: "Job")
    public static let task = Self(rawValue: "Task")
}
