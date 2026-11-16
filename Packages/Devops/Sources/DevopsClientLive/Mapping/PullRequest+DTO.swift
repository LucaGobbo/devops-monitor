import DevopsAPI
import DevopsClient
import Foundation

extension PullRequest {
    init(_ dto: PullRequestDTO) {
        self.init(
            id: dto.pullRequestId,
            title: dto.title ?? "",
            author: dto.createdBy.map(Person.init),
            repository: dto.repository?.name,
            project: dto.repository?.project?.name,
            sourceBranch: dto.sourceRefName?.removingPrefix("refs/heads/"),
            targetBranch: dto.targetRefName?.removingPrefix("refs/heads/"),
            isDraft: dto.isDraft ?? false,
            createdAt: dto.creationDate,
            closedAt: dto.closedDate,
            reviewers: (dto.reviewers ?? []).filter { $0.isContainer != true }.map(Reviewer.init),
            webURL: dto.repository?.webUrl.flatMap { URL(string: "\($0)/pullrequest/\(dto.pullRequestId)") },
            status: PullRequestStatus(dto.status),
            isAutoCompleteSet: dto.autoCompleteSetBy != nil
        )
    }
}

extension PullRequestStatus {
    init(_ dto: PullRequestStatusDTO?) {
        switch dto {
        case .active: self = .active
        case .completed: self = .completed
        case .abandoned: self = .abandoned
        default: self = .unknown
        }
    }
}
