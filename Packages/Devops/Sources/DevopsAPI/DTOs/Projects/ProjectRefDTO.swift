import Foundation

public struct ProjectRefDTO: Codable, Sendable, Hashable {
    public var id: String
    public var name: String?

    public init(id: String, name: String? = nil) {
        self.id = id
        self.name = name
    }
}
