import Foundation

public struct BuildStatusDTO: RawRepresentable, Codable, Sendable, Hashable {
    public let rawValue: String
    public init(rawValue: String) { self.rawValue = rawValue }

    public static let none = Self(rawValue: "none")
    public static let inProgress = Self(rawValue: "inProgress")
    public static let completed = Self(rawValue: "completed")
    public static let cancelling = Self(rawValue: "cancelling")
    public static let postponed = Self(rawValue: "postponed")
    public static let notStarted = Self(rawValue: "notStarted")
    public static let all = Self(rawValue: "all")
}
