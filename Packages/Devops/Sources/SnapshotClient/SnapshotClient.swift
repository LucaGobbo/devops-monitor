/// Hands the latest ``WidgetSnapshot`` from the app to the widgets, as a struct of closures (protocol witness).
///
/// The real implementation is `SnapshotClient.live(groupID:)` in `SnapshotClientLive`.
public struct SnapshotClient: Sendable {
    /// Stores the snapshot and asks the widgets to reload.
    public var save: @Sendable (_ snapshot: WidgetSnapshot) async throws -> Void
    /// The stored snapshot, or `nil` when the app has not written one yet.
    public var load: @Sendable () throws -> WidgetSnapshot?

    public init(
        save: @escaping @Sendable (_ snapshot: WidgetSnapshot) async throws -> Void,
        load: @escaping @Sendable () throws -> WidgetSnapshot?
    ) {
        self.save = save
        self.load = load
    }
}
