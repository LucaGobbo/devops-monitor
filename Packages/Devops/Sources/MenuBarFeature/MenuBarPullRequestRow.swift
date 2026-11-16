import DevopsClient
import SwiftUI

struct MenuBarPullRequestRow: View {
    let pullRequest: PullRequest
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "arrow.trianglehead.merge").foregroundStyle(.secondary)
                VStack(alignment: .leading, spacing: 0) {
                    Text(pullRequest.title).lineLimit(1)
                    Text(subtitle).font(.caption).foregroundStyle(.secondary).lineLimit(1)
                }
                Spacer(minLength: 0)
            }
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }

    private var subtitle: String {
        [pullRequest.repository, pullRequest.author?.displayName].compactMap(\.self).joined(separator: " · ")
    }
}

#Preview {
    MenuBarPullRequestRow(
        pullRequest: PullRequest(id: 1, title: "Add the new feature", author: Person(id: "1", displayName: "Normal Paulk"), repository: "app"),
        action: {}
    )
    .padding()
    .frame(width: 320)
}
