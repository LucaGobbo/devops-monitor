import SnapshotClient
import SwiftUI
import WidgetKit

/// Lets the views' `#Preview`s render in a real widget family. Not part of the shipped widgets.
struct PreviewEntry: TimelineEntry {
    enum Kind { case pullRequests, pipelines }
    let date = Date()
    let kind: Kind
    let snapshot: WidgetSnapshot?
}

struct PreviewWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "preview", provider: PreviewProvider()) { entry in
            switch entry.kind {
            case .pullRequests: PullRequestsWidgetView(snapshot: entry.snapshot)
            case .pipelines: PipelinesWidgetView(snapshot: entry.snapshot)
            }
        }
    }
}

private struct PreviewProvider: TimelineProvider {
    func placeholder(in context: Context) -> PreviewEntry { PreviewEntry(kind: .pullRequests, snapshot: .preview) }
    func getSnapshot(in context: Context, completion: @escaping (PreviewEntry) -> Void) { completion(placeholder(in: context)) }
    func getTimeline(in context: Context, completion: @escaping (Timeline<PreviewEntry>) -> Void) {
        completion(Timeline(entries: [placeholder(in: context)], policy: .never))
    }
}
