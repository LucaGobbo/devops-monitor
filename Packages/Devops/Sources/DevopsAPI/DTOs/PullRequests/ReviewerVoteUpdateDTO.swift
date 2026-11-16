import Foundation

/// The body of the request that sets a reviewer's vote.
public struct ReviewerVoteUpdateDTO: Codable, Sendable, Hashable {
    /// 10 approved, 5 approved with suggestions, 0 no vote, -5 waiting for author, -10 rejected.
    public var vote: Int

    public init(vote: Int) {
        self.vote = vote
    }
}
