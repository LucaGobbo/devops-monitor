import ActivityTimeline
import SwiftUI

/// The timeline: one entry per pull request or pipeline run, the most recently active first.
struct ActivityList: View {
    let events: [ActivityEvent]
    let isLoading: Bool

    var body: some View {
        List(ActivityGroup.grouping(events)) { ActivityGroupRow(group: $0) }
        .overlay {
            if events.isEmpty {
                if isLoading {
                    ProgressView()
                } else {
                    ContentUnavailableView(
                        "No activity", systemImage: "clock.arrow.circlepath",
                        description: Text("Your pull requests, reviews and pipeline runs of the last 30 days appear here.")
                    )
                }
            }
        }
    }
}

#Preview {
    ActivityList(events: ActivityEvent.samples, isLoading: false)
}

#Preview("Empty") {
    ActivityList(events: [], isLoading: false)
}

#Preview("Loading") {
    ActivityList(events: [], isLoading: true)
}
