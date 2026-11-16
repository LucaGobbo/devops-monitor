import AppStore
import DevopsClient
import SwiftUI

/// A run that expands into its stages, jobs and tasks. The timeline is only fetched while the row is expanded.
struct PipelineRow: View {
    @Environment(Store.self) private var store
    @State private var isExpanded = false

    let build: Build
    let organization: String

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            BuildTimelineView(timeline: store.timelines[build.id])
        } label: {
            PipelineSummary(build: build, organization: organization)
        }
        // Restarts when the row is expanded or collapsed; collapsing, or the run finishing, cancels the watch.
        .task(id: isExpanded) {
            if isExpanded { await store.watchTimeline(of: build) }
        }
    }
}

#Preview {
    @Previewable @State var store = Store.previewValue
    List(Build.previewBuilds) { PipelineRow(build: $0, organization: "fabrikam") }
        .environment(store)
}
