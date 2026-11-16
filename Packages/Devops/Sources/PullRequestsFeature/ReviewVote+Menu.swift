import DevopsClient

extension ReviewVote {
    /// The votes a user can cast from the context menu, in menu order.
    static let menuOptions: [ReviewVote] = [.approved, .approvedWithSuggestions, .waitingForAuthor, .rejected]

    var menuTitle: String {
        switch self {
        case .approved: "Approve"
        case .approvedWithSuggestions: "Approve with Suggestions"
        case .noVote: "Reset Vote"
        case .waitingForAuthor: "Wait for Author"
        case .rejected: "Reject"
        }
    }

    var menuSymbol: String {
        switch self {
        case .approved: "checkmark.circle"
        case .approvedWithSuggestions: "checkmark.circle.badge.questionmark"
        case .noVote: "circle.dashed"
        case .waitingForAuthor: "clock"
        case .rejected: "xmark.circle"
        }
    }
}
