import AppStore
import DevopsClient
import SwiftUI

struct PullRequestRow: View {
    let pullRequest: PullRequest
    let organization: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Text(pullRequest.title).font(.headline).lineLimit(2)
                if pullRequest.isDraft {
                    Text("Draft")
                        .font(.caption2.weight(.semibold))
                        .padding(.horizontal, 5)
                        .background(.quaternary, in: .capsule)
                }
                Spacer()
                ReviewerVotes(reviewers: pullRequest.reviewers)
            }
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
            if let branches {
                Text(branches)
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 2)
        .contextMenu {
            PullRequestContextMenu(pullRequest: pullRequest, organization: organization)
        }
    }

    private var subtitle: String {
        var parts = ["#\(pullRequest.id)"]
        if let project = pullRequest.project, let repository = pullRequest.repository {
            parts.append("\(project) / \(repository)")
        } else if let repository = pullRequest.repository {
            parts.append(repository)
        }
        if let author = pullRequest.author?.displayName { parts.append(author) }
        if let createdAt = pullRequest.createdAt {
            parts.append(createdAt.formatted(.relative(presentation: .named)))
        }
        return parts.joined(separator: " · ")
    }

    private var branches: String? {
        guard let source = pullRequest.sourceBranch, let target = pullRequest.targetBranch else { return nil }
        return "\(source) → \(target)"
    }
}

#Preview {
    List(DevopsClient.previewPullRequests) { PullRequestRow(pullRequest: $0, organization: "fabrikam") }
        .environment(Store.previewValue)
}
