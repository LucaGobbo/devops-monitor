import DevopsClient
import SwiftUI

/// The stages of a run; `nil` while the timeline is being fetched for the first time.
struct BuildTimelineView: View {
    let timeline: BuildTimeline?

    var body: some View {
        if let timeline {
            if timeline.stages.isEmpty {
                Text("No stages yet").font(.caption).foregroundStyle(.secondary)
            } else {
                ForEach(timeline.stages) { BuildStageRow(stage: $0) }
            }
        } else {
            ProgressView().controlSize(.small)
        }
    }
}

#Preview {
    List {
        BuildTimelineView(timeline: .preview)
        BuildTimelineView(timeline: BuildTimeline())
        BuildTimelineView(timeline: nil)
    }
}
