import Foundation
import Testing
@testable import DevopsAPI

/// Pure functions: query in, `URLRequest` out.
struct RequestTests {
    private func parts(_ request: URLRequest) throws -> (components: URLComponents, query: [String: String]) {
        let url = try #require(request.url)
        let components = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false))
        let query = Dictionary(uniqueKeysWithValues: (components.queryItems ?? []).map { ($0.name, $0.value ?? "") })
        return (components, query)
    }

    @Test func pullRequests() throws {
        let request = try pullRequestsRequest(
            organization: "fabrikam", project: "My Project", reviewerId: "me-id", top: 50, skip: 10, apiVersion: "7.1"
        )

        let (components, query) = try parts(request)
        #expect(components.host == "dev.azure.com")
        #expect(components.percentEncodedPath == "/fabrikam/My%20Project/_apis/git/pullrequests")
        #expect(query == [
            "searchCriteria.reviewerId": "me-id",
            "searchCriteria.status": "active",
            "$top": "50",
            "$skip": "10",
            "api-version": "7.1",
        ])
        #expect(request.httpMethod == "GET")
        #expect(request.value(forHTTPHeaderField: "Accept") == "application/json")
    }

    @Test func pullRequestsCreatorAndStatus() throws {
        let (_, query) = try parts(pullRequestsRequest(organization: "o", project: "p", creatorId: "c", status: .all, apiVersion: "7.1"))
        #expect(query["searchCriteria.creatorId"] == "c")
        #expect(query["searchCriteria.status"] == "all")
        #expect(query["searchCriteria.reviewerId"] == nil)
        #expect(query["$top"] == nil)
    }

    @Test func builds() throws {
        let request = try buildsRequest(
            organization: "fabrikam", project: "Proj", status: .inProgress, requestedFor: "user-id",
            definitions: [1, 2], queryOrder: .queueTimeDescending, top: 10, continuationToken: "a+b/c==",
            apiVersion: "7.1"
        )

        let (components, query) = try parts(request)
        #expect(components.percentEncodedPath == "/fabrikam/Proj/_apis/build/builds")
        #expect(query["statusFilter"] == "inProgress")
        #expect(query["requestedFor"] == "user-id")
        #expect(query["definitions"] == "1,2")
        #expect(query["queryOrder"] == "queueTimeDescending")
        #expect(query["continuationToken"] == "a+b/c==")
        // Strict encoding: '+' must not survive as a (space-meaning) plus sign; '$' stays literal in names.
        #expect(components.percentEncodedQuery?.contains("continuationToken=a%2Bb%2Fc%3D%3D") == true)
        #expect(components.percentEncodedQuery?.contains("$top=10") == true)
    }

    @Test func buildsWithoutFiltersOnlyCarryTheApiVersion() throws {
        let (_, query) = try parts(buildsRequest(organization: "o", project: "p", apiVersion: "7.1"))
        #expect(query == ["api-version": "7.1"])
    }

    @Test func projects() throws {
        let (components, query) = try parts(projectsRequest(organization: "fabrikam", top: 5, skip: 0, apiVersion: "7.1"))
        #expect(components.host == "dev.azure.com")
        #expect(components.percentEncodedPath == "/fabrikam/_apis/projects")
        #expect(query == ["$top": "5", "$skip": "0", "api-version": "7.1"])
    }

    @Test func connectionDataIsOrganizationScopedAndPreview() throws {
        let (components, query) = try parts(connectionDataRequest(organization: "fabrikam"))
        #expect(components.host == "dev.azure.com")
        #expect(components.percentEncodedPath == "/fabrikam/_apis/connectionData")
        #expect(query == ["api-version": "7.1-preview.1"])
    }

    @Test func pullRequestAndBuildByIdArePathsUnderTheProject() throws {
        let pullRequest = try parts(pullRequestRequest(organization: "o", project: "My Project", id: 22, apiVersion: "7.1"))
        #expect(pullRequest.components.percentEncodedPath == "/o/My%20Project/_apis/git/pullrequests/22")
        #expect(pullRequest.query == ["api-version": "7.1"])

        let build = try parts(buildRequest(organization: "o", project: "p", id: 5, apiVersion: "7.1"))
        #expect(build.components.percentEncodedPath == "/o/p/_apis/build/builds/5")
        #expect(build.query == ["api-version": "7.1"])
    }

    @Test func timelineIsAPathUnderTheBuild() throws {
        let (components, query) = try parts(timelineRequest(organization: "o", project: "My Project", buildId: 5, apiVersion: "7.1"))
        #expect(components.percentEncodedPath == "/o/My%20Project/_apis/build/builds/5/timeline")
        #expect(query == ["api-version": "7.1"])
    }

    @Test func setVoteIsAPutOnTheReviewer() throws {
        let request = try setVoteRequest(
            organization: "o", project: "My Project", repository: "my repo", pullRequestId: 22,
            reviewerId: "me-id", vote: -5, apiVersion: "7.1"
        )

        let (components, query) = try parts(request)
        #expect(components.percentEncodedPath == "/o/My%20Project/_apis/git/repositories/my%20repo/pullRequests/22/reviewers/me-id")
        #expect(query == ["api-version": "7.1"])
        #expect(request.httpMethod == "PUT")
        #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
        #expect(request.httpBody.map { String(decoding: $0, as: UTF8.self) } == #"{"vote":-5}"#)
    }

    @Test func setAutoCompleteIsAPatchWithTheStrategy() throws {
        let update = PullRequestUpdateDTO(autoCompleteSetBy: IdentityDTO(id: "me-id"), completionOptions: CompletionOptionsDTO(mergeStrategy: .squash))
        let request = try setAutoCompleteRequest(
            organization: "o", project: "p", repository: "r", pullRequestId: 22, update: update, apiVersion: "7.1"
        )

        let (components, _) = try parts(request)
        #expect(components.percentEncodedPath == "/o/p/_apis/git/repositories/r/pullRequests/22")
        #expect(request.httpMethod == "PATCH")
        #expect(request.httpBody.map { String(decoding: $0, as: UTF8.self) }
            == #"{"autoCompleteSetBy":{"id":"me-id"},"completionOptions":{"mergeStrategy":"squash"}}"#)
    }

    @Test func cancellingAutoCompleteSendsTheEmptyIdentityAndNoOptions() throws {
        let update = PullRequestUpdateDTO(autoCompleteSetBy: IdentityDTO(id: PullRequestUpdateDTO.noIdentity))
        let request = try setAutoCompleteRequest(
            organization: "o", project: "p", repository: "r", pullRequestId: 22, update: update, apiVersion: "7.1"
        )

        #expect(request.httpBody.map { String(decoding: $0, as: UTF8.self) }
            == #"{"autoCompleteSetBy":{"id":"00000000-0000-0000-0000-000000000000"}}"#)
    }

    @Test func apiVersionIsUsedAsGiven() throws {
        let (_, query) = try parts(projectsRequest(organization: "o", apiVersion: "7.2-preview.2"))
        #expect(query["api-version"] == "7.2-preview.2")
    }
}
