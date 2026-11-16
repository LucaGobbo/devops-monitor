import Foundation

/// An open pull request as the widget shows it.
public struct WidgetPullRequest: Sendable, Hashable, Codable, Identifiable {
    public var id: Int
    public var title: String
    public var repository: String?
    public var author: String?
    /// Whether the user created it; otherwise it is assigned to the user for review.
    public var isCreatedByMe: Bool
    public var isDraft: Bool
    public var url: URL?

    public init(
        id: Int, title: String, repository: String? = nil, author: String? = nil,
        isCreatedByMe: Bool = true, isDraft: Bool = false, url: URL? = nil
    ) {
        self.id = id
        self.title = title
        self.repository = repository
        self.author = author
        self.isCreatedByMe = isCreatedByMe
        self.isDraft = isDraft
        self.url = url
    }
}
