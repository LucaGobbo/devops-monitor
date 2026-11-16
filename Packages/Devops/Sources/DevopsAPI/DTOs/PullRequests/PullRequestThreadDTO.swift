import Foundation

/// A pull request thread. System threads (votes, reviewer changes) have no author-written text; what they are
/// is in `properties` (`CodeReviewThreadType`, ...).
public struct PullRequestThreadDTO: Decodable, Sendable, Hashable {
    public var id: Int
    public var publishedDate: Date?
    public var isDeleted: Bool?
    public var properties: [String: PropertyDTO]?
    public var comments: [CommentDTO]?

    public init(
        id: Int, publishedDate: Date? = nil, isDeleted: Bool? = nil,
        properties: [String: PropertyDTO]? = nil, comments: [CommentDTO]? = nil
    ) {
        self.id = id
        self.publishedDate = publishedDate
        self.isDeleted = isDeleted
        self.properties = properties
        self.comments = comments
    }

    public struct CommentDTO: Decodable, Sendable, Hashable {
        public var author: IdentityDTO?

        public init(author: IdentityDTO? = nil) { self.author = author }
    }
}
