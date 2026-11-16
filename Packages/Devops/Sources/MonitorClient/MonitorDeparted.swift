import DevopsClient

/// Items that were open in the previous snapshot and are not any more: how they ended is still unknown.
///
/// Only pull requests the user created are tracked; an assigned pull request that leaves the list is not interesting.
public struct MonitorDeparted: Sendable, Hashable {
    public var pullRequests: [PullRequest]
    public var builds: [Build]

    public init(pullRequests: [PullRequest] = [], builds: [Build] = []) {
        self.pullRequests = pullRequests
        self.builds = builds
    }

    public var isEmpty: Bool { pullRequests.isEmpty && builds.isEmpty }
}

extension MonitorSnapshot {
    /// What was open in `previous` and is not open in this snapshot.
    public func departed(since previous: MonitorSnapshot) -> MonitorDeparted {
        let openBuilds = Set(pipelines.map(\.id))
        let openPullRequests = Set(createdPullRequests.map(\.id))
        return MonitorDeparted(
            pullRequests: previous.createdPullRequests.filter { !openPullRequests.contains($0.id) },
            builds: previous.pipelines.filter { !openBuilds.contains($0.id) }
        )
    }
}
