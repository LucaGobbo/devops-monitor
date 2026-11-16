/// What the monitor publishes after every poll.
public enum MonitorEvent: Sendable, Hashable {
    /// The current state. `changes` (how items ended) is empty for the first snapshot (the baseline), so starting
    /// the app is silent.
    case update(MonitorSnapshot, changes: [MonitorChange])
    /// A poll failed; the monitor keeps polling.
    case failure(String)
}
