import Foundation
import Testing

@testable import DevopsClient

struct WebLinkTests {
    @Test func aPullRequestWithoutALinkGetsTheStandardAddress() {
        let pullRequest = PullRequest(id: 22, title: "", repository: "my repo", project: "My Project")
        #expect(pullRequest.link(in: "fabrikam")?.absoluteString
            == "https://dev.azure.com/fabrikam/My%20Project/_git/my%20repo/pullrequest/22")
    }

    @Test func aBuildWithoutALinkGetsTheStandardAddress() {
        let build = Build(id: 5, project: "Fabrikam")
        #expect(build.link(in: "fabrikam")?.absoluteString
            == "https://dev.azure.com/fabrikam/Fabrikam/_build/results?buildId=5")
    }

    @Test func theLinkTheServerGaveWins() {
        let given = URL(string: "https://example.com/pr/1")
        #expect(PullRequest(id: 1, title: "", repository: "r", project: "p", webURL: given).link(in: "o") == given)
        #expect(Build(id: 1, project: "p", webURL: given).link(in: "o") == given)
    }

    @Test func noLinkIsGuessedWhenSomethingIsMissing() {
        #expect(PullRequest(id: 1, title: "", project: "p").link(in: "o") == nil)   // no repository
        #expect(Build(id: 1).link(in: "o") == nil)                                   // no project
        #expect(Build(id: 1, project: "p").link(in: "") == nil)                      // no organization
    }
}
