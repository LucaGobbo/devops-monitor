import Foundation

public struct LinkDTO: Codable, Sendable, Hashable {
    public var href: String?

    public init(href: String? = nil) { self.href = href }
}
