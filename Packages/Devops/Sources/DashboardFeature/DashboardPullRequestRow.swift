import DashboardSummary
import DevopsClient
import SwiftUI

/// One pull request in a card: its title and number, opening it in the browser when tapped.
struct DashboardPullRequestRow: View {
    let pullRequest: PullRequest
    var detail: String?

    var body: some View {
        DashboardLinkRow(url: pullRequest.webURL) {
            VStack(alignment: .leading, spacing: 2) {
                Text(pullRequest.title).lineLimit(1)
                Text(subtitle).font(.caption).foregroundStyle(.secondary).lineLimit(1)
            }
        }
    }

    private var subtitle: String {
        var parts = ["#\(pullRequest.id)"]
        if let repository = pullRequest.repository { parts.append(repository) }
        if let detail { parts.append(detail) }
        return parts.joined(separator: " · ")
    }
}

#Preview {
    DashboardPullRequestRow(pullRequest: DashboardSummary.previewPullRequest, detail: "Open 4 days")
        .padding()
        .frame(width: 320)
}
