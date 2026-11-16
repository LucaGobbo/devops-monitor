import Foundation

public struct PullRequestDTO: Codable, Sendable, Hashable {
    public var pullRequestId: Int
    public var title: String?
    public var description: String?
    public var status: PullRequestStatusDTO?
    public var isDraft: Bool?
    public var mergeStatus: MergeStatusDTO?
    public var createdBy: IdentityDTO?
    public var creationDate: Date?
    public var closedDate: Date?
    public var sourceRefName: String?
    public var targetRefName: String?
    public var repository: RepositoryDTO?
    public var reviewers: [ReviewerDTO]?
    public var url: String?
    /// Who set auto-complete; absent when auto-complete is not set.
    public var autoCompleteSetBy: IdentityDTO?

    public init(pullRequestId: Int, title: String? = nil, description: String? = nil,
                status: PullRequestStatusDTO? = nil, isDraft: Bool? = nil, mergeStatus: MergeStatusDTO? = nil,
                createdBy: IdentityDTO? = nil, creationDate: Date? = nil, closedDate: Date? = nil,
                sourceRefName: String? = nil, targetRefName: String? = nil, repository: RepositoryDTO? = nil,
                reviewers: [ReviewerDTO]? = nil, url: String? = nil, autoCompleteSetBy: IdentityDTO? = nil) {
        self.pullRequestId = pullRequestId
        self.title = title
        self.description = description
        self.status = status
        self.isDraft = isDraft
        self.mergeStatus = mergeStatus
        self.createdBy = createdBy
        self.creationDate = creationDate
        self.closedDate = closedDate
        self.sourceRefName = sourceRefName
        self.targetRefName = targetRefName
        self.repository = repository
        self.reviewers = reviewers
        self.url = url
        self.autoCompleteSetBy = autoCompleteSetBy
    }
}
