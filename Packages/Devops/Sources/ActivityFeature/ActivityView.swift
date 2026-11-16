import AppStore
import SwiftUI

public struct ActivityView: View {
    @Environment(Store.self) private var store

    public init() {}

    public var body: some View {
        ActivityList(events: store.activity, isLoading: store.isLoadingActivity)
            .navigationTitle("Activity")
            .task { await store.loadActivity() }
            .toolbar {
                ActivityRefreshButton(isLoading: store.isLoadingActivity) { await store.loadActivity() }
            }
    }
}

#Preview {
    ActivityView()
        .environment(Store.previewValue)
}
