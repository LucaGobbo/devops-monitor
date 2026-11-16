import DashboardSummary
import SwiftUI

struct RecentRunsCard: View {
    let summary: DashboardSummary
    let open: () -> Void

    var body: some View {
        DashboardCard(title: "Recent runs", systemImage: "clock.arrow.circlepath", open: open) {
            if summary.recentRuns.isEmpty {
                DashboardEmptyLine(text: "No finished runs yet")
            } else {
                ForEach(summary.recentRuns) { DashboardRunRow(event: $0) }
            }
        }
    }
}

#Preview {
    RecentRunsCard(summary: .preview, open: {}).frame(width: 320).padding()
}
