import ActivityTimeline
import SwiftUI

/// A pull request or pipeline run with how it progressed: the latest step on top, the first one at the bottom.
struct ActivityGroupRow: View {
    let group: ActivityGroup

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Label(group.title, systemImage: group.isPullRequest ? "arrow.trianglehead.pull" : "gearshape.2")
                    .font(.headline)
                    .lineLimit(2)
                if let subtitle {
                    Text(subtitle).font(.caption).foregroundStyle(.secondary).lineLimit(1)
                }
            }
            VStack(alignment: .leading, spacing: 0) {
                ForEach(group.events) { event in
                    ActivityStep(event: event, isOldest: event.id == group.events.last?.id)
                }
            }
        }
        .padding(.vertical, 6)
        .contextMenu {
            if let url = group.url {
                Link("Open in Browser", destination: url)
            }
        }
    }

    private var subtitle: String? {
        let text = [group.context, group.project].compactMap(\.self).joined(separator: " · ")
        return text.isEmpty ? nil : text
    }
}

#Preview {
    List(ActivityGroup.grouping(ActivityEvent.samples)) { ActivityGroupRow(group: $0) }
}
