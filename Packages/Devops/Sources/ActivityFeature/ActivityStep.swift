import ActivityTimeline
import SwiftUI

/// One step of an item's progress: its icon, joined by a line to the step before it (the one below).
struct ActivityStep: View {
    let event: ActivityEvent
    let isOldest: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            VStack(spacing: 2) {
                Image(systemName: event.kind.systemImage)
                    .foregroundStyle(event.kind.tint)
                    .font(.title3)
                    .frame(width: 24, height: 24)
                if !isOldest {
                    Rectangle().fill(.quaternary).frame(width: 2).frame(maxHeight: .infinity)
                }
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(event.kind.title)
                if event.kind == .pullRequestReviewed, let detail = event.detail {
                    Text(detail).font(.caption).foregroundStyle(.secondary).lineLimit(1)
                }
            }
            .padding(.bottom, isOldest ? 0 : 10)
            Spacer()
            Text(event.date, format: .dateTime.day().month().hour().minute())
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    VStack(spacing: 0) {
        ActivityStep(event: ActivityEvent.samples[0], isOldest: false)
        ActivityStep(event: ActivityEvent.samples[1], isOldest: true)
    }
    .padding()
}
