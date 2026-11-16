import AppStore
import DevopsClient
import SwiftUI

public struct PullRequestsView: View {
    @Environment(Store.self) private var store

    public init() {}

    public var body: some View {
        List {
            PullRequestSection(title: "Created by me", pullRequests: store.createdPullRequests, organization: store.organization)
            PullRequestSection(title: "Assigned to me", pullRequests: store.assignedPullRequests, organization: store.organization)
        }
        .overlay {
            if store.createdPullRequests.isEmpty && store.assignedPullRequests.isEmpty {
                ContentUnavailableView("No open pull requests", systemImage: "arrow.trianglehead.merge")
            }
        }
        .navigationTitle("Pull requests")
        .refreshable {
            await store.refresh()
        }
    }
}

#Preview {
    @Previewable @State var store = Store.previewValue
    PullRequestsView()
        .environment(store)
        .task { await store.load() }
}
