import AppStore
import DevopsClient
import SwiftUI

/// A titled group of pull request rows; hidden when empty.
struct PullRequestSection: View {
    let title: String
    let pullRequests: [PullRequest]
    let organization: String

    var body: some View {
        if !pullRequests.isEmpty {
            Section {
                ForEach(pullRequests) { PullRequestRow(pullRequest: $0, organization: organization) }
            } header: {
                Text("\(title) (\(pullRequests.count))")
            }
        }
    }
}

#Preview {
    List {
        PullRequestSection(
            title: "Created by me",
            pullRequests: DevopsClient.previewPullRequests,
            organization: "fabrikam"
        )
    }
    .environment(Store.previewValue)
}
