import DevopsClient

/// Everything that is open at one moment.
public struct MonitorSnapshot: Sendable, Hashable {
    public var pipelines: [Build]
    public var createdPullRequests: [PullRequest]
    public var assignedPullRequests: [PullRequest]

    public init(pipelines: [Build] = [], createdPullRequests: [PullRequest] = [], assignedPullRequests: [PullRequest] = []) {
        self.pipelines = pipelines
        self.createdPullRequests = createdPullRequests
        // A pull request I created and that is also assigned to me is listed once, under "created".
        let createdIDs = Set(createdPullRequests.map(\.id))
        self.assignedPullRequests = assignedPullRequests.filter { !createdIDs.contains($0.id) }
    }

    /// Poll quickly while a pipeline is queued or running, slowly otherwise.
    public var pollInterval: Duration {
        pipelines.isEmpty ? .seconds(60) : .seconds(10)
    }
}
