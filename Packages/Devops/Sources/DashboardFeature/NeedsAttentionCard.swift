import DashboardSummary
import SwiftUI

struct NeedsAttentionCard: View {
    let summary: DashboardSummary
    let open: () -> Void

    var body: some View {
        DashboardCard(title: "Needs attention", systemImage: "exclamationmark.triangle", open: open) {
            if summary.attention.isEmpty {
                DashboardEmptyLine(text: "All clear")
            } else {
                ForEach(summary.attention.prefix(6)) { AttentionRow(item: $0) }
                if summary.attention.count > 6 {
                    Text("+\(summary.attention.count - 6) more").font(.caption).foregroundStyle(.secondary)
                }
            }
        }
    }
}

#Preview {
    NeedsAttentionCard(summary: .preview, open: {}).frame(width: 320).padding()
}
