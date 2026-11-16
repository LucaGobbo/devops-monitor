import Foundation

public struct Reviewer: Sendable, Hashable {
    public var person: Person
    public var vote: ReviewVote
    public var isRequired: Bool

    public init(person: Person, vote: ReviewVote = .noVote, isRequired: Bool = false) {
        self.person = person
        self.vote = vote
        self.isRequired = isRequired
    }
}
