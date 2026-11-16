import DevopsClient

/// Where one of my pull requests stands. Each one is in exactly one bucket; the first rule that matches wins.
public enum PullRequestBucket: Sendable, Hashable, CaseIterable {
    case draft, blocked, autoComplete, approved, waitingForReview

    public init(_ pullRequest: PullRequest) {
        let votes = pullRequest.reviewers.map(\.vote)
        if pullRequest.isDraft {
            self = .draft
        } else if votes.contains(where: { $0 == .rejected || $0 == .waitingForAuthor }) {
            self = .blocked
        } else if pullRequest.isAutoCompleteSet {
            self = .autoComplete
        } else if Self.isApproved(pullRequest.reviewers) {
            self = .approved
        } else {
            self = .waitingForReview
        }
    }

    /// At least one approval, and every required reviewer approved.
    private static func isApproved(_ reviewers: [Reviewer]) -> Bool {
        func approves(_ reviewer: Reviewer) -> Bool { reviewer.vote == .approved || reviewer.vote == .approvedWithSuggestions }
        return reviewers.contains(where: approves) && reviewers.filter(\.isRequired).allSatisfy(approves)
    }
}
