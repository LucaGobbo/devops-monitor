import DashboardSummary
import DevopsClient
import SwiftUI

struct PipelinesNowCard: View {
    let summary: DashboardSummary
    let open: () -> Void

    var body: some View {
        DashboardCard(title: "Pipelines now", systemImage: "airplane.departure", open: open) {
            if summary.runningCount + summary.queuedCount == 0 {
                DashboardEmptyLine(text: "Nothing is running")
            } else {
                HStack(spacing: 24) {
                    DashboardCount(value: summary.runningCount, label: "Running", tint: .blue)
                    DashboardCount(value: summary.queuedCount, label: "Queued", tint: .secondary)
                }
                if let build = summary.longestRunning {
                    DashboardLinkRow(url: build.webURL) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Longest running").font(.caption).foregroundStyle(.secondary)
                            HStack {
                                Text([build.pipeline, build.number].compactMap(\.self).joined(separator: " ")).lineLimit(1)
                                Spacer()
                                if let startedAt = build.startedAt {
                                    Text(startedAt, style: .timer).monospacedDigit().foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    PipelinesNowCard(summary: .preview, open: {}).frame(width: 320).padding()
}
