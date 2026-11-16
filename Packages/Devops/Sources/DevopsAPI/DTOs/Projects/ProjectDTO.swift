import Foundation

public struct ProjectDTO: Codable, Sendable, Hashable {
    public var id: String
    public var name: String?
    public var description: String?
    public var state: String?
    public var visibility: String?
    public var url: String?
    public var lastUpdateTime: Date?
    public var revision: Int?

    public init(id: String, name: String? = nil, description: String? = nil, state: String? = nil,
                visibility: String? = nil, url: String? = nil, lastUpdateTime: Date? = nil, revision: Int? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.state = state
        self.visibility = visibility
        self.url = url
        self.lastUpdateTime = lastUpdateTime
        self.revision = revision
    }
}
