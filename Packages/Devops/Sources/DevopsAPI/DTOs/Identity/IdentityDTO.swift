import Foundation

public struct IdentityDTO: Codable, Sendable, Hashable {
    public var id: String
    public var displayName: String?
    public var uniqueName: String?
    public var imageUrl: String?
    public var isContainer: Bool?

    public init(id: String, displayName: String? = nil, uniqueName: String? = nil,
                imageUrl: String? = nil, isContainer: Bool? = nil) {
        self.id = id
        self.displayName = displayName
        self.uniqueName = uniqueName
        self.imageUrl = imageUrl
        self.isContainer = isContainer
    }
}
