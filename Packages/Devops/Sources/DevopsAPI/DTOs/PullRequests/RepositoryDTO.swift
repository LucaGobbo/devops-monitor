import Foundation

public struct RepositoryDTO: Codable, Sendable, Hashable {
    public var id: String
    public var name: String?
    public var webUrl: String?
    public var defaultBranch: String?
    public var project: ProjectRefDTO?

    public init(id: String, name: String? = nil, webUrl: String? = nil,
                defaultBranch: String? = nil, project: ProjectRefDTO? = nil) {
        self.id = id
        self.name = name
        self.webUrl = webUrl
        self.defaultBranch = defaultBranch
        self.project = project
    }
}
