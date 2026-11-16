import Foundation

/// A pull request reviewer: an identity plus their vote.
public struct ReviewerDTO: Codable, Sendable, Hashable {
    public var id: String
    public var displayName: String?
    public var uniqueName: String?
    public var imageUrl: String?
    public var isContainer: Bool?
    /// 10 approved, 5 approved with suggestions, 0 no vote, -5 waiting for author, -10 rejected.
    public var vote: Int
    public var isRequired: Bool?
    public var hasDeclined: Bool?
    public var isFlagged: Bool?

    public init(id: String, displayName: String? = nil, uniqueName: String? = nil, imageUrl: String? = nil,
                isContainer: Bool? = nil, vote: Int = 0, isRequired: Bool? = nil,
                hasDeclined: Bool? = nil, isFlagged: Bool? = nil) {
        self.id = id
        self.displayName = displayName
        self.uniqueName = uniqueName
        self.imageUrl = imageUrl
        self.isContainer = isContainer
        self.vote = vote
        self.isRequired = isRequired
        self.hasDeclined = hasDeclined
        self.isFlagged = isFlagged
    }

    private enum CodingKeys: String, CodingKey {
        case id, displayName, uniqueName, imageUrl, isContainer, vote, isRequired, hasDeclined, isFlagged
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        displayName = try container.decodeIfPresent(String.self, forKey: .displayName)
        uniqueName = try container.decodeIfPresent(String.self, forKey: .uniqueName)
        imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        isContainer = try container.decodeIfPresent(Bool.self, forKey: .isContainer)
        vote = try container.decodeIfPresent(Int.self, forKey: .vote) ?? 0
        isRequired = try container.decodeIfPresent(Bool.self, forKey: .isRequired)
        hasDeclined = try container.decodeIfPresent(Bool.self, forKey: .hasDeclined)
        isFlagged = try container.decodeIfPresent(Bool.self, forKey: .isFlagged)
    }
}
