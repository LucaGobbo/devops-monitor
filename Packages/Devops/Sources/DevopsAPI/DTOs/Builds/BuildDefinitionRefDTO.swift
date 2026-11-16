import Foundation

public struct BuildDefinitionRefDTO: Codable, Sendable, Hashable {
    public var id: Int
    public var name: String?
    public var path: String?
    public var url: String?

    public init(id: Int, name: String? = nil, path: String? = nil, url: String? = nil) {
        self.id = id
        self.name = name
        self.path = path
        self.url = url
    }
}
