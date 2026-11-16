import DashboardSummary

extension Store {
    /// What the dashboard shows, from what is loaded now. `nil` until the user is known. The recent runs
    /// come from ``activity``, so the dashboard asks for ``loadActivity()`` when it appears.
    public var dashboard: DashboardSummary? {
        guard let profile else { return nil }
        return DashboardSummary(
            pipelines: pipelines, createdPullRequests: createdPullRequests, assignedPullRequests: assignedPullRequests,
            activity: activity, me: profile, now: now()
        )
    }
}
