import DashboardSummary
import SwiftUI

struct MyPullRequestsCard: View {
    let summary: DashboardSummary
    let open: () -> Void

    var body: some View {
        DashboardCard(title: "My pull requests", systemImage: "arrow.trianglehead.merge", open: open) {
            let buckets = PullRequestBucket.allCases.filter { summary.myPullRequestCounts[$0, default: 0] > 0 }
            if buckets.isEmpty {
                DashboardEmptyLine(text: "No open pull requests")
            } else {
                ForEach(buckets, id: \.self) { bucket in
                    HStack {
                        Label(bucket.title, systemImage: bucket.symbol).foregroundStyle(bucket.tint)
                        Spacer()
                        Text("\(summary.myPullRequestCounts[bucket, default: 0])").monospacedDigit()
                    }
                }
            }
        }
    }
}

private extension PullRequestBucket {
    var title: LocalizedStringKey {
        switch self {
        case .draft: "Draft"
        case .blocked: "Blocked"
        case .autoComplete: "Auto-complete set"
        case .approved: "Approved"
        case .waitingForReview: "Waiting for review"
        }
    }

    var symbol: String {
        switch self {
        case .draft: "pencil.circle"
        case .blocked: "hand.raised.circle.fill"
        case .autoComplete: "arrow.trianglehead.merge"
        case .approved: "checkmark.circle.fill"
        case .waitingForReview: "hourglass.circle"
        }
    }

    var tint: Color {
        switch self {
        case .draft, .waitingForReview: .secondary
        case .blocked: .red
        case .autoComplete: .blue
        case .approved: .green
        }
    }
}

#Preview {
    MyPullRequestsCard(summary: .preview, open: {}).frame(width: 320).padding()
}
