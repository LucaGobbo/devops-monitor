import Foundation

public struct BuildResultDTO: RawRepresentable, Codable, Sendable, Hashable {
    public let rawValue: String
    public init(rawValue: String) { self.rawValue = rawValue }

    public static let none = Self(rawValue: "none")
    public static let succeeded = Self(rawValue: "succeeded")
    public static let partiallySucceeded = Self(rawValue: "partiallySucceeded")
    public static let failed = Self(rawValue: "failed")
    public static let canceled = Self(rawValue: "canceled")
}
