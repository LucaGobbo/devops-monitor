import DashboardSummary
import DevopsClient
import SwiftUI

/// One thing that needs attention, with the reason.
struct AttentionRow: View {
    let item: AttentionItem

    var body: some View {
        switch item {
        case .failedRun(let event):
            DashboardRunRow(event: event)
        case .blockedPullRequest(let pullRequest):
            DashboardPullRequestRow(pullRequest: pullRequest, detail: String(localized: "Blocked"))
        case .stalePullRequest(let pullRequest):
            DashboardPullRequestRow(pullRequest: pullRequest, detail: Self.openSince(pullRequest))
        }
    }

    private static func openSince(_ pullRequest: PullRequest) -> String? {
        pullRequest.createdAt.map { String(localized: "Open since \($0.formatted(.relative(presentation: .named)))") }
    }
}

#Preview {
    VStack(alignment: .leading) {
        ForEach(DashboardSummary.preview.attention) { AttentionRow(item: $0) }
    }
    .padding()
    .frame(width: 320)
}
