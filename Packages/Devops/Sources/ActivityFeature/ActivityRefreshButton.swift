import SwiftUI

/// Reloads the timeline; shows a spinner while it loads.
struct ActivityRefreshButton: View {
    let isLoading: Bool
    let action: () async -> Void

    var body: some View {
        if isLoading {
            ProgressView().controlSize(.small)
        } else {
            Button("Refresh", systemImage: "arrow.clockwise") { Task { await action() } }
        }
    }
}

#Preview {
    HStack {
        ActivityRefreshButton(isLoading: false) {}
        ActivityRefreshButton(isLoading: true) {}
    }
    .padding()
}
