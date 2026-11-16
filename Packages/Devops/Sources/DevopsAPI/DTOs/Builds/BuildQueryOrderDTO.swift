import Foundation

public struct BuildQueryOrderDTO: RawRepresentable, Codable, Sendable, Hashable {
    public let rawValue: String
    public init(rawValue: String) { self.rawValue = rawValue }

    public static let finishTimeAscending = Self(rawValue: "finishTimeAscending")
    public static let finishTimeDescending = Self(rawValue: "finishTimeDescending")
    public static let queueTimeDescending = Self(rawValue: "queueTimeDescending")
    public static let queueTimeAscending = Self(rawValue: "queueTimeAscending")
    public static let startTimeDescending = Self(rawValue: "startTimeDescending")
    public static let startTimeAscending = Self(rawValue: "startTimeAscending")
}
