import ActivityTimeline
import DashboardSummary
import SwiftUI

/// One finished run: how it ended, which run, and when.
struct DashboardRunRow: View {
    let event: ActivityEvent

    var body: some View {
        DashboardLinkRow(url: event.url) {
            HStack(spacing: 8) {
                Image(systemName: event.kind.runSymbol).foregroundStyle(event.kind.runTint)
                VStack(alignment: .leading, spacing: 2) {
                    Text(event.title).lineLimit(1)
                    Text(subtitle).font(.caption).foregroundStyle(.secondary).lineLimit(1)
                }
            }
        }
    }

    private var subtitle: String {
        [event.detail, event.date.formatted(.relative(presentation: .named))].compactMap(\.self).joined(separator: " · ")
    }
}

private extension ActivityKind {
    var runSymbol: String {
        switch self {
        case .buildSucceeded: "checkmark.circle.fill"
        case .buildPartiallySucceeded: "exclamationmark.circle.fill"
        case .buildFailed: "xmark.circle.fill"
        default: "slash.circle"
        }
    }

    var runTint: Color {
        switch self {
        case .buildSucceeded: .green
        case .buildPartiallySucceeded: .orange
        case .buildFailed: .red
        default: .secondary
        }
    }
}

#Preview {
    VStack(alignment: .leading) {
        ForEach(DashboardSummary.preview.recentRuns) { DashboardRunRow(event: $0) }
    }
    .padding()
    .frame(width: 320)
}
