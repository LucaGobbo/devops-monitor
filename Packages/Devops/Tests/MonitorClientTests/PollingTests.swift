import DevopsClient
import Foundation
import os
import Testing

@testable import MonitorClient
@testable import MonitorClientLive

struct PollingTests {
    private let me = Person(id: "me")
    private let running = Build(id: 1, state: .inProgress, project: "P")

    /// A `DevopsClient` whose n-th `activeBuilds` call returns `script[n]` (the last one repeats, an error throws).
    private func client(
        script: [Result<[Build], any Error>],
        created: [PullRequest] = [],
        pullRequest: @escaping @Sendable (Int) -> PullRequest = { PullRequest(id: $0, title: "") },
        build: @escaping @Sendable (Int) -> Build = { Build(id: $0, state: .succeeded) }
    ) -> DevopsClient {
        let calls = OSAllocatedUnfairLock(initialState: 0)
        var client = DevopsClient.testValue
        client.activeBuilds = { _, _ in
            let call = calls.withLock { value -> Int in defer { value += 1 }; return value }
            return try script[min(call, script.count - 1)].get()
        }
        client.pullRequests = { _, involvement, _ in involvement == .createdByMe ? created : [] }
        client.pullRequest = { _, _, id in pullRequest(id) }
        client.build = { _, _, id in build(id) }
        return client
    }

    private func collect(_ stream: AsyncStream<MonitorEvent>, _ count: Int) async -> [MonitorEvent] {
        var events: [MonitorEvent] = []
        for await event in stream {
            events.append(event)
            if events.count == count { break }
        }
        return events
    }

    private let instantly: @Sendable (Duration) async throws -> Void = { _ in }

    @Test func firstPollIsABaselineWithoutChanges() async {
        let monitor = MonitorClient.live(client: client(script: [.success([running])]), sleep: instantly)
        let events = await collect(monitor.events("o", me), 1)
        #expect(events == [.update(MonitorSnapshot(pipelines: [running]), changes: [])])
    }

    @Test func aFinishedBuildIsReportedWithItsResolvedState() async {
        let finished = Build(id: 1, number: "7", state: .failed, project: "P")
        let monitor = MonitorClient.live(
            client: client(script: [.success([running]), .success([])], build: { _ in finished }), sleep: instantly
        )
        let events = await collect(monitor.events("o", me), 2)
        #expect(events[1] == .update(MonitorSnapshot(), changes: [.buildFinished(finished)]))
    }

    @Test func aCanceledBuildIsReportedAsCanceled() async {
        let canceled = Build(id: 1, state: .canceled, project: "P")
        let monitor = MonitorClient.live(
            client: client(script: [.success([running]), .success([])], build: { _ in canceled }),
            sleep: instantly
        )
        let events = await collect(monitor.events("o", me), 2)
        #expect(events[1] == .update(MonitorSnapshot(), changes: [.buildCanceled(canceled)]))
    }

    @Test func aCompletedAndAnAbandonedPullRequestAreBothReported() async {
        let completed = PullRequest(id: 1, title: "done", project: "P", status: .completed)
        let abandoned = PullRequest(id: 2, title: "dropped", project: "P", status: .abandoned)
        let open = [PullRequest(id: 1, title: "done", project: "P"), PullRequest(id: 2, title: "dropped", project: "P")]
        let created = OSAllocatedUnfairLock(initialState: open)
        var client = client(script: [.success([])], pullRequest: { $0 == 1 ? completed : abandoned })
        client.pullRequests = { _, involvement, _ in involvement == .createdByMe ? created.withLock { $0 } : [] }
        let stream = MonitorClient.live(client: client, sleep: instantly).events("o", me)

        var iterator = stream.makeAsyncIterator()
        _ = await iterator.next()
        created.withLock { $0 = [] }
        let second = await iterator.next()
        guard case .update(_, let changes)? = second else { Issue.record("expected an update"); return }
        #expect(Set(changes) == [.pullRequestCompleted(completed), .pullRequestAbandoned(abandoned)])
    }

    @Test func aFailedPollIsPublishedAndTheNextSuccessIsTheBaseline() async {
        struct Boom: Error {}
        let monitor = MonitorClient.live(
            client: client(script: [.failure(Boom()), .success([running])]), sleep: instantly
        )
        let events = await collect(monitor.events("o", me), 2)
        guard case .failure = events[0] else { Issue.record("expected a failure first"); return }
        #expect(events[1] == .update(MonitorSnapshot(pipelines: [running]), changes: []))
    }

    @Test func refreshNowPollsWithoutWaitingForTheInterval() async {
        let never: @Sendable (Duration) async throws -> Void = { _ in try await Task.sleep(for: .seconds(3600)) }
        let monitor = MonitorClient.live(client: client(script: [.success([])]), sleep: never)
        var iterator = monitor.events("o", me).makeAsyncIterator()
        _ = await iterator.next()
        await monitor.refreshNow()
        let second = await iterator.next()
        #expect(second == .update(MonitorSnapshot(), changes: []))
    }

    @Test func theFirstPollHappensBeforeAnyWaiting() async {
        let slept = OSAllocatedUnfairLock(initialState: false)
        let sleptBeforeFirstPoll = OSAllocatedUnfairLock<Bool?>(initialState: nil)
        var client = client(script: [.success([])])
        let poll = client.activeBuilds
        client.activeBuilds = { organization, me in
            sleptBeforeFirstPoll.withLock { $0 = $0 ?? slept.withLock { $0 } }
            return try await poll(organization, me)
        }
        let monitor = MonitorClient.live(client: client, sleep: { _ in
            slept.withLock { $0 = true }
            try await Task.sleep(for: .seconds(3600))
        })
        _ = await collect(monitor.events("o", me), 1)
        #expect(sleptBeforeFirstPoll.withLock { $0 } == false)
    }

    @Test func aTimelineIsFetchedRightAwayAndAgainAfterEachInterval() async {
        let calls = OSAllocatedUnfairLock(initialState: 0)
        var client = client(script: [.success([])])
        client.timeline = { _, project, buildId in
            let call = calls.withLock { value -> Int in value += 1; return value }
            return BuildTimeline(stages: [BuildStage(id: "\(project)-\(buildId)-\(call)", name: "", status: .running)])
        }
        let monitor = MonitorClient.live(client: client, sleep: instantly)
        var iterator = monitor.timelines("o", "P", 5).makeAsyncIterator()
        let first = await iterator.next()
        let second = await iterator.next()
        #expect(first?.stages.first?.id == "P-5-1")
        #expect(second?.stages.first?.id == "P-5-2")
    }

    @Test func aFailedTimelineFetchIsSkipped() async {
        struct Boom: Error {}
        let calls = OSAllocatedUnfairLock(initialState: 0)
        var client = client(script: [.success([])])
        client.timeline = { _, _, _ in
            let call = calls.withLock { value -> Int in value += 1; return value }
            if call == 1 { throw Boom() }
            return BuildTimeline(stages: [BuildStage(id: "ok", name: "", status: .running)])
        }
        let monitor = MonitorClient.live(client: client, sleep: instantly)
        var iterator = monitor.timelines("o", "P", 5).makeAsyncIterator()
        #expect(await iterator.next()?.stages.first?.id == "ok")
    }
}
