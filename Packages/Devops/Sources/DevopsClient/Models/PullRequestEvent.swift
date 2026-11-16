import Foundation

/// Something the server recorded on a pull request: a reviewer voted, or one was added.
public struct PullRequestEvent: Sendable, Hashable, Identifiable {
    /// The thread the server recorded it in; unique within one pull request.
    public var id: Int
    public var date: Date
    public var kind: Kind

    public enum Kind: Sendable, Hashable {
        /// `personID` is the 32-character form the threads use; compare it with ``Person/matches(threadID:)``.
        case voted(personID: String, name: String?, vote: ReviewVote)
        case reviewerAdded(personID: String)
    }

    public init(id: Int, date: Date, kind: Kind) {
        self.id = id
        self.date = date
        self.kind = kind
    }
}
