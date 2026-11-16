import Foundation

public struct PullRequestStatusDTO: RawRepresentable, Codable, Sendable, Hashable {
    public let rawValue: String
    public init(rawValue: String) { self.rawValue = rawValue }

    public static let notSet = Self(rawValue: "notSet")
    public static let active = Self(rawValue: "active")
    public static let abandoned = Self(rawValue: "abandoned")
    public static let completed = Self(rawValue: "completed")
    public static let all = Self(rawValue: "all")
}
