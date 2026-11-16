import DevopsClient

/// Polls Azure DevOps and publishes what is open and what changed, as a struct of closures (protocol witness).
///
/// The real implementation is `MonitorClient.live(client:)` in `MonitorClientLive`.
public struct MonitorClient: Sendable {
    /// A stream that polls while it is being iterated and stops when the iteration ends or is cancelled.
    /// The first event is the baseline: it carries no changes.
    public var events: @Sendable (_ organization: String, _ me: Person) -> AsyncStream<MonitorEvent>
    /// Polls right now; the result arrives on the running stream. Does nothing when no stream is running.
    public var refreshNow: @Sendable () async -> Void
    /// The stages, jobs and tasks of one run: fetched right away and again every 10 seconds, for as long as the
    /// stream is being iterated. Use it only for a run the user is looking at.
    public var timelines: @Sendable (_ organization: String, _ project: String, _ buildId: Int) -> AsyncStream<BuildTimeline>

    public init(
        events: @escaping @Sendable (_ organization: String, _ me: Person) -> AsyncStream<MonitorEvent>,
        refreshNow: @escaping @Sendable () async -> Void,
        timelines: @escaping @Sendable (_ organization: String, _ project: String, _ buildId: Int) -> AsyncStream<BuildTimeline>
    ) {
        self.events = events
        self.refreshNow = refreshNow
        self.timelines = timelines
    }
}
