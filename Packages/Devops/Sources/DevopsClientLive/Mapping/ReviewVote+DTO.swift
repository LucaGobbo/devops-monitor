import DevopsAPI
import DevopsClient
import Foundation

extension ReviewVote {
    /// Azure DevOps votes: 10 approved, 5 approved with suggestions, 0 no vote, -5 waiting for author, -10 rejected.
    init(vote: Int) {
        switch vote {
        case 10: self = .approved
        case 5: self = .approvedWithSuggestions
        case -5: self = .waitingForAuthor
        case -10: self = .rejected
        default: self = .noVote
        }
    }
}

extension ReviewVote {
    /// The Azure DevOps vote value, the inverse of ``init(vote:)``.
    var value: Int {
        switch self {
        case .approved: 10
        case .approvedWithSuggestions: 5
        case .noVote: 0
        case .waitingForAuthor: -5
        case .rejected: -10
        }
    }
}
