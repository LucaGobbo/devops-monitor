import AppStore
import DevopsClient
import SwiftUI

/// The context menu of a pull request: open it, vote on it, and set or cancel auto-complete.
struct PullRequestContextMenu: View {
    @Environment(Store.self) private var store
    let pullRequest: PullRequest
    let organization: String

    var body: some View {
        if let url = pullRequest.link(in: organization) {
            Link("Open in Browser", destination: url)
        }
        Divider()
        ForEach(ReviewVote.menuOptions, id: \.self) { vote in
            Button(vote.menuTitle, systemImage: vote == currentVote ? "checkmark" : vote.menuSymbol) {
                Task { await store.vote(vote, on: pullRequest) }
            }
            .disabled(vote == currentVote)
        }
        Divider()
        if pullRequest.isAutoCompleteSet {
            Button("Cancel Auto-Complete", systemImage: "xmark.circle") {
                Task { await store.cancelAutoComplete(on: pullRequest) }
            }
        } else {
            Menu("Set Auto-Complete", systemImage: "arrow.trianglehead.merge") {
                ForEach(MergeStrategy.allCases, id: \.self) { strategy in
                    Button(strategy.title) {
                        Task { await store.setAutoComplete(strategy, on: pullRequest) }
                    }
                }
            }
            .disabled(pullRequest.isDraft)
        }
    }

    /// The user's own vote, if they are a reviewer.
    private var currentVote: ReviewVote? {
        guard let me = store.profile?.id else { return nil }
        return pullRequest.reviewers.first { $0.person.id == me }?.vote
    }
}

#Preview {
    @Previewable @State var store = Store.previewValue
    Menu("Pull request") {
        PullRequestContextMenu(pullRequest: DevopsClient.previewPullRequests[0], organization: "fabrikam")
    }
    .environment(store)
    .task { await store.load() }
    .padding()
}
