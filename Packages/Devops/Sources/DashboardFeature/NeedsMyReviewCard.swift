import DashboardSummary
import SwiftUI

struct NeedsMyReviewCard: View {
    let summary: DashboardSummary
    let open: () -> Void

    var body: some View {
        DashboardCard(title: "Needs my review", systemImage: "text.bubble", open: open) {
            if summary.needsMyReview.isEmpty {
                DashboardEmptyLine(text: "Nothing to review")
            } else {
                ForEach(summary.needsMyReview.prefix(5)) { pullRequest in
                    DashboardPullRequestRow(
                        pullRequest: pullRequest,
                        detail: pullRequest.createdAt?.formatted(.relative(presentation: .named))
                    )
                }
                if summary.needsMyReview.count > 5 {
                    Text("+\(summary.needsMyReview.count - 5) more").font(.caption).foregroundStyle(.secondary)
                }
            }
        }
    }
}

#Preview {
    NeedsMyReviewCard(summary: .preview, open: {}).frame(width: 320).padding()
}
