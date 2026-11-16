import AppStore
import SwiftUI

/// A small summary of what is happening with the user's pipelines and pull requests.
public struct DashboardView: View {
    @Environment(Store.self) private var store
    private let open: (DashboardDestination) -> Void

    /// `open` is called when a card's header is tapped, so the app can navigate to that page.
    public init(open: @escaping (DashboardDestination) -> Void) {
        self.open = open
    }

    public var body: some View {
        Group {
            if let summary = store.dashboard {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 320), spacing: 16, alignment: .top)], spacing: 16) {
                        NeedsAttentionCard(summary: summary) { open(.activity) }
                        PipelinesNowCard(summary: summary) { open(.pipelines) }
                        NeedsMyReviewCard(summary: summary) { open(.pullRequests) }
                        MyPullRequestsCard(summary: summary) { open(.pullRequests) }
                        RecentRunsCard(summary: summary) { open(.activity) }
                    }
                    .padding()
                }
            } else {
                ContentUnavailableView("No data yet", systemImage: "gauge.with.dots.needle.0percent")
            }
        }
        .navigationTitle("Dashboard")
        .task { await store.loadActivity() }
        .toolbar {
            if store.isLoadingActivity {
                ProgressView().controlSize(.small)
            } else {
                Button("Refresh", systemImage: "arrow.clockwise") {
                    Task {
                        await store.refresh()
                        await store.loadActivity()
                    }
                }
            }
        }
    }
}

#Preview {
    DashboardView { _ in }
        .environment(Store.previewValue)
        .task {}
}
