import Foundation
import Testing
@testable import DevopsAPI

struct ThreadDecodingTests {
    private func threads(_ json: String) throws -> [PullRequestThreadDTO] {
        try JSONDecoder.devops().decode(ListResponseDTO<PullRequestThreadDTO>.self, from: Data(json.utf8)).value
    }

    private let sample = #"""
    {
      "count": 3,
      "value": [
        {
          "pullRequestThreadContext": null,
          "id": 7,
          "publishedDate": "2024-05-02T09:15:00.1234567Z",
          "properties": {
            "CodeReviewThreadType": { "$type": "System.String", "$value": "VoteUpdate" },
            "CodeReviewVoteResult": { "$type": "System.String", "$value": "10" },
            "CodeReviewVotedByTfId": { "$type": "System.String", "$value": "d6245f202af844f494518107cb2767db" }
          },
          "comments": [
            { "id": 1, "author": { "id": "d6245f20-2af8-44f4-9451-8107cb2767db", "displayName": "Normal Paulk" }, "commentType": "system" }
          ],
          "isDeleted": false
        },
        {
          "id": 8,
          "publishedDate": "2024-05-02T10:00:00Z",
          "properties": {
            "CodeReviewThreadType": { "$type": "System.String", "$value": "ReviewersUpdate" },
            "CodeReviewReviewersUpdatedNumAdded": { "$type": "System.Int32", "$value": 1 },
            "CodeReviewReviewersUpdatedAddedTfId": { "$type": "System.String", "$value": "aaaabbbbccccddddeeeeffff00001111" }
          },
          "isDeleted": false
        },
        { "id": 9, "publishedDate": "2024-05-02T11:00:00Z", "comments": [], "isDeleted": true, "somethingNew": 1 }
      ]
    }
    """#

    @Test func systemThreadsDecodeWithTheirProperties() throws {
        let list = try threads(sample)
        #expect(list.count == 3)

        let vote = list[0]
        #expect(vote.id == 7)
        #expect(vote.properties?["CodeReviewThreadType"]?.value == "VoteUpdate")
        #expect(vote.properties?["CodeReviewVoteResult"]?.value == "10")
        #expect(vote.properties?["CodeReviewVotedByTfId"]?.type == "System.String")
        #expect(vote.comments?.first?.author?.displayName == "Normal Paulk")
        #expect(vote.publishedDate == (try Date.ISO8601FormatStyle(includingFractionalSeconds: true).parse("2024-05-02T09:15:00.123Z")))
    }

    @Test func numericPropertyValuesAreKeptAsText() throws {
        let added = try threads(sample)[1]
        #expect(added.properties?["CodeReviewReviewersUpdatedNumAdded"]?.value == "1")
    }

    @Test func threadsWithoutPropertiesOrWithUnknownFieldsStillDecode() throws {
        let deleted = try threads(sample)[2]
        #expect(deleted.properties == nil)
        #expect(deleted.isDeleted == true)
    }
}
