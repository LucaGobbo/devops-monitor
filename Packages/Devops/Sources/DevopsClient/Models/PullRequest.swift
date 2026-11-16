import Foundation

public struct PullRequest: Sendable, Hashable, Identifiable {
    public var id: Int
    public var title: String
    public var author: Person?
    public var repository: String?
    public var project: String?
    /// Branch names without the `refs/heads/` prefix.
    public var sourceBranch: String?
    public var targetBranch: String?
    public var isDraft: Bool
    public var createdAt: Date?
    /// When it was completed or abandoned; `nil` while it is active.
    public var closedAt: Date?
    public var reviewers: [Reviewer]
    /// Link to the pull request in the Azure DevOps web UI.
    public var webURL: URL?
    public var status: PullRequestStatus
    /// Whether auto-complete is set: the pull request completes by itself once its policies pass.
    public var isAutoCompleteSet: Bool

    public init(
        id: Int, title: String, author: Person? = nil, repository: String? = nil, project: String? = nil,
        sourceBranch: String? = nil, targetBranch: String? = nil, isDraft: Bool = false,
        createdAt: Date? = nil, closedAt: Date? = nil, reviewers: [Reviewer] = [], webURL: URL? = nil,
        status: PullRequestStatus = .active, isAutoCompleteSet: Bool = false
    ) {
        self.id = id
        self.title = title
        self.author = author
        self.repository = repository
        self.project = project
        self.sourceBranch = sourceBranch
        self.targetBranch = targetBranch
        self.isDraft = isDraft
        self.createdAt = createdAt
        self.closedAt = closedAt
        self.reviewers = reviewers
        self.webURL = webURL
        self.status = status
        self.isAutoCompleteSet = isAutoCompleteSet
    }
}
