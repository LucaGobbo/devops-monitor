import SnapshotClient
import SwiftUI
import WidgetKit

/// The pull-request widget: open pull requests created by or assigned to the user.
public struct PullRequestsWidgetView: View {
    let snapshot: WidgetSnapshot?
    @Environment(\.widgetFamily) private var family

    public init(snapshot: WidgetSnapshot?) {
        self.snapshot = snapshot
    }

    public var body: some View {
        if let snapshot, !snapshot.pullRequests.isEmpty {
            VStack(alignment: .leading, spacing: 6) {
                Label("Pull requests (\(snapshot.pullRequests.count))", systemImage: "arrow.trianglehead.merge")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                ForEach(snapshot.pullRequests.prefix(rowLimit)) { pullRequest in
                    if let url = pullRequest.url {
                        Link(destination: url) { WidgetPullRequestRow(pullRequest: pullRequest) }
                    } else {
                        WidgetPullRequestRow(pullRequest: pullRequest)
                    }
                }
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            WidgetEmptyState(
                systemImage: snapshot == nil ? "arrow.trianglehead.merge" : "checkmark.circle",
                message: snapshot == nil ? "Open Devops monitor to load" : "No open pull requests"
            )
        }
    }

    private var rowLimit: Int {
        switch family {
        case .systemSmall: 2
        case .systemMedium: 3
        default: 8
        }
    }
}

#Preview("Populated", as: .systemMedium) {
    PreviewWidget()
} timeline: {
    PreviewEntry(kind: .pullRequests, snapshot: .preview)
}

#Preview("Empty", as: .systemSmall) {
    PreviewWidget()
} timeline: {
    PreviewEntry(kind: .pullRequests, snapshot: WidgetSnapshot(updatedAt: Date()))
}
