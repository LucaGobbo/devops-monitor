import Foundation

public enum ReviewVote: Sendable, Hashable {
    case approved, approvedWithSuggestions, noVote, waitingForAuthor, rejected
}
