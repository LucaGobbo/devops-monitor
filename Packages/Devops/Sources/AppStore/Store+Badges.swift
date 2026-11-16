import DevopsClient

extension Store {
    /// Running or queued pipelines.
    public var openPipelinesCount: Int { pipelines.count }

    /// Open pull requests that are created by or assigned to the user; one that is both counts once.
    public var openPullRequestsCount: Int {
        Set((createdPullRequests + assignedPullRequests).map(\.id)).count
    }

    /// Everything that is open: what the app's Dock badge shows.
    public var badgeCount: Int { openPipelinesCount + openPullRequestsCount }
}
