import DevopsAPI
import DevopsClient
import Foundation
import Testing
@testable import DevopsClientLive

/// Pure mapping: a system thread in, the event it records out.
struct PullRequestEventTests {
    private let date = Date(timeIntervalSince1970: 1_700_000_000)

    private func thread(
        id: Int = 7, isDeleted: Bool? = false, published: Bool = true, _ properties: [String: String]?, author: String? = nil
    ) -> PullRequestThreadDTO {
        PullRequestThreadDTO(
            id: id, publishedDate: published ? date : nil, isDeleted: isDeleted,
            properties: properties?.mapValues { PropertyDTO(type: "System.String", value: $0) },
            comments: author.map { [.init(author: IdentityDTO(id: "x", displayName: $0))] }
        )
    }

    @Test func aVoteUpdateBecomesAVotedEvent() {
        let event = PullRequestEvent(thread(
            ["CodeReviewThreadType": "VoteUpdate", "CodeReviewVoteResult": "-5", "CodeReviewVotedByTfId": "abc123"],
            author: "Anna"
        ))
        #expect(event == PullRequestEvent(id: 7, date: date, kind: .voted(personID: "abc123", name: "Anna", vote: .waitingForAuthor)))
    }

    @Test func aReviewersUpdateBecomesAReviewerAddedEvent() {
        let event = PullRequestEvent(thread(
            id: 8, ["CodeReviewThreadType": "ReviewersUpdate", "CodeReviewReviewersUpdatedAddedTfId": "abc123"]
        ))
        #expect(event == PullRequestEvent(id: 8, date: date, kind: .reviewerAdded(personID: "abc123")))
    }

    @Test func threadsThatRecordNothingWeKnowAreSkipped() {
        let vote = ["CodeReviewThreadType": "VoteUpdate", "CodeReviewVoteResult": "10", "CodeReviewVotedByTfId": "abc"]
        #expect(PullRequestEvent(thread(nil)) == nil) // a plain comment thread
        #expect(PullRequestEvent(thread(isDeleted: true, vote)) == nil)
        #expect(PullRequestEvent(thread(published: false, vote)) == nil)
        #expect(PullRequestEvent(thread(["CodeReviewThreadType": "RefUpdate"])) == nil)
        #expect(PullRequestEvent(thread(["CodeReviewThreadType": "VoteUpdate", "CodeReviewVoteResult": "10"])) == nil) // no voter
        #expect(PullRequestEvent(thread(["CodeReviewThreadType": "VoteUpdate", "CodeReviewVotedByTfId": "abc"])) == nil) // no vote
        #expect(PullRequestEvent(thread(["CodeReviewThreadType": "ReviewersUpdate"])) == nil) // nobody added
    }

    @Test func aPersonMatchesAThreadIDWithoutDashesInAnyCase() {
        let me = Person(id: "D6245F20-2AF8-44F4-9451-8107CB2767DB")
        #expect(me.matches(threadID: "d6245f202af844f494518107cb2767db"))
        #expect(!me.matches(threadID: "aaaabbbbccccddddeeeeffff00001111"))
    }
}
