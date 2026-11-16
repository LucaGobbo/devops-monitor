import Foundation
import Testing


@testable import DevopsAPI

struct DecodingTests {
    private func decode<T: Decodable>(_ type: T.Type, _ json: String) throws -> T {
        try JSONDecoder.devops().decode(T.self, from: Data(json.utf8))
    }

    @Test func pullRequestsDecodeWithReviewersAndVotes() throws {
        let list = try decode(ListResponseDTO<PullRequestDTO>.self, Fixtures.pullRequests).value
        #expect(list.count == 2)

        let first = list[0]
        #expect(first.pullRequestId == 22)
        #expect(first.status == .active)
        #expect(first.mergeStatus == .succeeded)
        #expect(first.createdBy?.displayName == "Normal Paulk")
        #expect(first.repository?.project?.name == "2016_10_31")
        #expect(first.sourceRefName == "refs/heads/npaulk/my_work")

        let reviewers = try #require(first.reviewers)
        #expect(reviewers[0].vote == 10)
        #expect(reviewers[0].isRequired == true)
        #expect(reviewers[1].vote == 0)
        #expect(reviewers[1].isContainer == true)
    }

    @Test func sevenDigitFractionalDateIsParsed() throws {
        let first = try #require(try decode(ListResponseDTO<PullRequestDTO>.self, Fixtures.pullRequests).value.first)
        let expected = try Date.ISO8601FormatStyle(includingFractionalSeconds: true).parse("2016-11-01T16:30:31.665Z")
        #expect(first.creationDate == expected)
    }

    @Test func unknownEnumValuesAndExtraFieldsDoNotBreakDecoding() throws {
        let second = try decode(ListResponseDTO<PullRequestDTO>.self, Fixtures.pullRequests).value[1]
        #expect(second.status?.rawValue == "someFutureStatus")
        #expect(second.status != .active)
        #expect(second.mergeStatus?.rawValue == "brandNew")
        #expect(second.isDraft == true)
        #expect(second.reviewers == nil)
        #expect(second.repository == nil)
    }

    @Test func runningBuildDecodes() throws {
        let build = try #require(try decode(ListResponseDTO<BuildDTO>.self, Fixtures.builds).value.first)
        #expect(build.id == 5)
        #expect(build.status == .inProgress)
        #expect(build.result == nil)
        #expect(build.finishTime == nil)
        #expect(build.queueTime != nil)
        #expect(build.startTime != nil)
        #expect(build.definition?.id == 7)
        #expect(build.requestedFor?.displayName == "Normal Paulk")
        #expect(build.links?.web?.href == "https://dev.azure.com/fabrikam/a7573007/_build/results?buildId=5")
        #expect(build.links?.selfLink?.href?.hasSuffix("/Builds/5") == true)
    }

    @Test func projectsDecode() throws {
        let projects = try decode(ListResponseDTO<ProjectDTO>.self, Fixtures.projects).value
        #expect(projects.map(\.name) == ["Fabrikam-Fiber-TFVC", "Fabrikam-Fiber-Git"])
        #expect(projects[0].state == "wellFormed")
        #expect(projects[0].lastUpdateTime != nil)
        #expect(projects[1].description == nil)
    }

    @Test func connectionDataDecodesAuthenticatedUser() throws {
        let user = try decode(ConnectionDataDTO.self, Fixtures.connectionData).authenticatedUser
        #expect(user.id == "d6245f20-2af8-44f4-9451-8107cb2767db")
        #expect(user.providerDisplayName == "Normal Paulk")
    }

    @Test func timelineDecodesRecordsAndIgnoresWhatItDoesNotKnow() throws {
        let timeline = try decode(TimelineDTO.self, Fixtures.timeline)
        #expect(timeline.records.count == 5)

        let stage = timeline.records[0]
        #expect(stage.type == .stage)
        #expect(stage.name == "Build")
        #expect(stage.state == .completed)
        #expect(stage.result == .succeeded)
        #expect(stage.finishTime != nil)

        let job = timeline.records[2]
        #expect(job.type == .job)
        #expect(job.parentId == "phase-1")
        #expect(job.state == .inProgress)
        #expect(job.result == nil)
        #expect(job.finishTime == nil)

        // A type this app does not model decodes anyway.
        #expect(timeline.records[4].type == TimelineRecordTypeDTO(rawValue: "Checkpoint"))
    }

    @Test func aTimelineWithoutRecordsIsEmpty() throws {
        #expect(try decode(TimelineDTO.self, "{}").records.isEmpty)
    }

    @Test func reviewerWithoutVoteDefaultsToZero() throws {
        let reviewer = try decode(ReviewerDTO.self, #"{"id":"abc","displayName":"X"}"#)
        #expect(reviewer.vote == 0)
    }

    @Test(arguments: [
        "2016-11-01T16:30:31.6655471Z",
        "2016-11-01T16:30:31.665Z",
        "2016-11-01T16:30:31.1Z",
        "2016-11-01T16:30:31.123456789Z",
        "2016-11-01T16:30:31Z",
    ])
    func dateVariantsParse(_ value: String) throws {
        let date = try #require(AzureDate.parse(value))
        let reference = try Date.ISO8601FormatStyle().parse("2016-11-01T16:30:31Z")
        #expect(abs(date.timeIntervalSince(reference)) < 1)
    }

    @Test func garbageDateIsRejected() {
        #expect(AzureDate.parse("not a date") == nil)
        #expect(throws: DecodingError.self) { try decode(ProjectDTO.self, #"{"id":"1","lastUpdateTime":"nope"}"#) }
    }
}
