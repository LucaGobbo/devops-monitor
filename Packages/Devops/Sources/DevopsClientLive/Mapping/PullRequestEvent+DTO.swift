import DevopsAPI
import DevopsClient
import Foundation

extension PullRequestEvent {
    /// The event a system thread records; `nil` for comments, deleted threads, other system threads and threads
    /// that lack the properties the event needs.
    init?(_ thread: PullRequestThreadDTO) {
        guard thread.isDeleted != true, let date = thread.publishedDate, let properties = thread.properties else { return nil }
        switch properties["CodeReviewThreadType"]?.value {
        case "VoteUpdate":
            guard let person = properties["CodeReviewVotedByTfId"]?.value,
                  let vote = properties["CodeReviewVoteResult"]?.value.flatMap(Int.init)
            else { return nil }
            let name = thread.comments?.first?.author?.displayName
            self.init(id: thread.id, date: date, kind: .voted(personID: person, name: name, vote: ReviewVote(vote: vote)))
        case "ReviewersUpdate":
            guard let person = properties["CodeReviewReviewersUpdatedAddedTfId"]?.value else { return nil }
            self.init(id: thread.id, date: date, kind: .reviewerAdded(personID: person))
        default:
            return nil
        }
    }
}
