import SnapshotClient
import SwiftUI
import WidgetKit

/// The pipeline widget: queued and running pipeline runs.
public struct PipelinesWidgetView: View {
    let snapshot: WidgetSnapshot?
    @Environment(\.widgetFamily) private var family

    public init(snapshot: WidgetSnapshot?) {
        self.snapshot = snapshot
    }

    public var body: some View {
        if let snapshot, !snapshot.pipelines.isEmpty {
            VStack(alignment: .leading, spacing: 6) {
                Label("Pipelines (\(snapshot.pipelines.count))", systemImage: "play.circle")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                ForEach(snapshot.pipelines.prefix(rowLimit)) { pipeline in
                    if let url = pipeline.url {
                        Link(destination: url) { WidgetPipelineRow(pipeline: pipeline) }
                    } else {
                        WidgetPipelineRow(pipeline: pipeline)
                    }
                }
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            WidgetEmptyState(
                systemImage: snapshot == nil ? "play.circle" : "checkmark.circle",
                message: snapshot == nil ? "Open Devops monitor to load" : "No running pipelines"
            )
        }
    }

    private var rowLimit: Int {
        switch family {
        case .systemSmall: 2
        case .systemMedium: 3
        default: 8
        }
    }
}

#Preview("Populated", as: .systemMedium) {
    PreviewWidget()
} timeline: {
    PreviewEntry(kind: .pipelines, snapshot: .preview)
}

#Preview("Empty", as: .systemSmall) {
    PreviewWidget()
} timeline: {
    PreviewEntry(kind: .pipelines, snapshot: WidgetSnapshot(updatedAt: Date()))
}
