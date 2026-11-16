import DevopsClient
import Foundation

/// What the activity timeline is derived from, as fetched from the server.
struct ActivitySource: Sendable {
    var builds: [Build] = []
    var pullRequests: [PullRequest] = []
    var pullRequestEvents: [Int: [PullRequestEvent]] = [:]
    /// The first error of the pull requests whose threads could not be read; the others are still complete.
    var threadFailure: String?
}

extension DevopsClient {
    /// Fetches the user's runs and pull requests of the last window, and the system threads of those pull requests.
    ///
    /// - Parameters:
    ///   - openPullRequests: pull requests that are open now; they are included even when they are older than
    ///     `since`, because a review of them is still news.
    ///   - concurrency: how many thread requests run at once.
    /// - Throws: when the runs or the pull request lists cannot be read. A thread that cannot be read is skipped.
    func activitySource(
        organization: String, me: Person, since: Date, openPullRequests: [PullRequest], concurrency: Int = 6
    ) async throws -> ActivitySource {
        async let builds = recentBuilds(organization, me, since)
        async let created = recentPullRequests(organization, .createdByMe, me, since)
        async let assigned = recentPullRequests(organization, .assignedToMe, me, since)
        var seen = Set<Int>()
        let pullRequests = try await (created + assigned + openPullRequests).filter { seen.insert($0.id).inserted }

        var source = ActivitySource(builds: try await builds, pullRequests: pullRequests)
        await withTaskGroup(of: (Int, Result<[PullRequestEvent], any Error>).self) { group in
            var remaining = pullRequests.makeIterator()
            func addNext() {
                guard let pullRequest = remaining.next() else { return }
                group.addTask {
                    (pullRequest.id, await Result { try await self.pullRequestEvents(organization, pullRequest) })
                }
            }
            for _ in 0..<concurrency { addNext() }
            while let (id, result) = await group.next() {
                switch result {
                case .success(let events): source.pullRequestEvents[id] = events
                case .failure(let error): source.threadFailure = source.threadFailure ?? error.localizedDescription
                }
                addNext()
            }
        }
        return source
    }
}
