import AppStore
import DevopsClient
import SwiftUI

/// The content of the menu bar popup: the open pull requests and pipelines, and how many there are.
/// `open` is called when something is tapped, the app decides how to show the main window.
public struct MenuBarView: View {
    @Environment(Store.self) private var store
    let open: (MenuBarDestination) -> Void

    private let limit = 5

    public init(open: @escaping (MenuBarDestination) -> Void) {
        self.open = open
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(summary).font(.headline)

            if store.badgeCount == 0 {
                Text("Nothing open").foregroundStyle(.secondary)
            }

            MenuBarSection(title: "Pull requests", count: store.openPullRequestsCount, onTapTitle: { open(.pullRequests) }) {
                ForEach(pullRequests.prefix(limit)) { pullRequest in
                    MenuBarPullRequestRow(pullRequest: pullRequest) { open(.pullRequests) }
                }
            }

            MenuBarSection(title: "Pipelines", count: store.openPipelinesCount, onTapTitle: { open(.pipelines) }) {
                ForEach(store.pipelines.prefix(limit)) { build in
                    MenuBarPipelineRow(build: build) { open(.pipelines) }
                }
            }
        }
        .padding(12)
        .frame(width: 320)
    }

    private var summary: String {
        store.badgeCount == 1 ? "1 active item" : "\(store.badgeCount) active items"
    }

    /// Created and assigned, newest first, a pull request that is both appears once.
    private var pullRequests: [PullRequest] {
        var seen = Set<Int>()
        return (store.createdPullRequests + store.assignedPullRequests)
            .filter { seen.insert($0.id).inserted }
            .sorted { ($0.createdAt ?? .distantPast) > ($1.createdAt ?? .distantPast) }
    }
}

#Preview {
    @Previewable @State var store = Store.previewValue
    MenuBarView { _ in }
        .environment(store)
        .task { await store.load() }
}
