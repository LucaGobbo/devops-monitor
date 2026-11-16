import SnapshotClient
import SwiftUI

struct WidgetPullRequestRow: View {
    let pullRequest: WidgetPullRequest

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: pullRequest.isCreatedByMe ? "arrow.trianglehead.merge" : "person.crop.circle.badge.clock")
                .foregroundStyle(pullRequest.isDraft ? Color.secondary : Color.accentColor)
            VStack(alignment: .leading, spacing: 0) {
                Text(pullRequest.title).font(.callout).lineLimit(1)
                Text(subtitle).font(.caption2).foregroundStyle(.secondary).lineLimit(1)
            }
            Spacer(minLength: 0)
        }
    }

    private var subtitle: String {
        [pullRequest.isDraft ? "Draft" : nil, pullRequest.repository, pullRequest.isCreatedByMe ? nil : pullRequest.author]
            .compactMap(\.self).joined(separator: " · ")
    }
}

#Preview {
    WidgetPullRequestRow(pullRequest: WidgetSnapshot.preview.pullRequests[0])
        .padding()
        .frame(width: 300)
}
