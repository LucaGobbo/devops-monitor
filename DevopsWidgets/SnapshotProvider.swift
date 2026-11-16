import SnapshotClient
import SnapshotClientLive
import WidgetKit

struct SnapshotEntry: TimelineEntry {
    let date: Date
    /// `nil` until the app has written its first snapshot.
    let snapshot: WidgetSnapshot?
}

/// Serves the snapshot the app wrote. The app reloads the timelines whenever it writes a new one, so the
/// timeline has a single entry and never expires on its own.
struct SnapshotProvider: TimelineProvider {
    private let client = SnapshotClient.live(groupID: SnapshotClient.appGroupID)

    func placeholder(in context: Context) -> SnapshotEntry {
        SnapshotEntry(date: Date(), snapshot: .preview)
    }

    func getSnapshot(in context: Context, completion: @escaping (SnapshotEntry) -> Void) {
        completion(context.isPreview ? placeholder(in: context) : currentEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SnapshotEntry>) -> Void) {
        completion(Timeline(entries: [currentEntry()], policy: .never))
    }

    private func currentEntry() -> SnapshotEntry {
        SnapshotEntry(date: Date(), snapshot: try? client.load())
    }
}
