import Foundation
import Testing
@testable import DevopsAPI

/// The query parameters the activity timeline adds to the pull request and build lists, and the threads request.
struct ActivityRequestTests {
    private let since = Date(timeIntervalSince1970: 1_700_000_000) // 2023-11-14T22:13:20Z

    private func parts(_ request: URLRequest) throws -> (components: URLComponents, query: [String: String]) {
        let url = try #require(request.url)
        let components = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false))
        let query = Dictionary(uniqueKeysWithValues: (components.queryItems ?? []).map { ($0.name, $0.value ?? "") })
        return (components, query)
    }

    @Test func pullRequestsCreatedSince() throws {
        let (_, query) = try parts(pullRequestsRequest(
            organization: "o", project: "p", creatorId: "me", status: .all, minTime: since, queryTimeRange: .created,
            apiVersion: "7.1"
        ))
        #expect(query["searchCriteria.status"] == "all")
        #expect(query["searchCriteria.minTime"] == "2023-11-14T22:13:20Z")
        #expect(query["searchCriteria.queryTimeRangeType"] == "created")
    }

    @Test func pullRequestsClosedSince() throws {
        let (_, query) = try parts(pullRequestsRequest(
            organization: "o", project: "p", reviewerId: "me", status: .all, minTime: since, queryTimeRange: .closed,
            apiVersion: "7.1"
        ))
        #expect(query["searchCriteria.queryTimeRangeType"] == "closed")
        #expect(query["searchCriteria.reviewerId"] == "me")
    }

    @Test func pullRequestsWithoutTimeRangeSendNeitherParameter() throws {
        let (_, query) = try parts(pullRequestsRequest(organization: "o", project: "p", apiVersion: "7.1"))
        #expect(query["searchCriteria.minTime"] == nil)
        #expect(query["searchCriteria.queryTimeRangeType"] == nil)
    }

    @Test func buildsInATimeRange() throws {
        let (_, query) = try parts(buildsRequest(
            organization: "o", project: "p", queryOrder: .queueTimeDescending, minTime: since,
            maxTime: since.addingTimeInterval(3600), apiVersion: "7.1"
        ))
        #expect(query["minTime"] == "2023-11-14T22:13:20Z")
        #expect(query["maxTime"] == "2023-11-14T23:13:20Z")
        #expect(query["queryOrder"] == "queueTimeDescending")
    }

    @Test func threadsArePathsUnderTheRepository() throws {
        let (components, query) = try parts(pullRequestThreadsRequest(
            organization: "o", project: "My Project", repository: "my repo", pullRequestId: 22, apiVersion: "7.1"
        ))
        #expect(components.percentEncodedPath == "/o/My%20Project/_apis/git/repositories/my%20repo/pullRequests/22/threads")
        #expect(query == ["api-version": "7.1"])
    }
}
