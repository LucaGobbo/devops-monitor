import AppStore
import DevopsClient
import SwiftUI

public struct PipelinesView: View {
    @Environment(Store.self) private var store

    public init() {}

    public var body: some View {
        List(store.pipelines) { PipelineRow(build: $0, organization: store.organization) }
        .overlay {
            if store.pipelines.isEmpty {
                ContentUnavailableView("No running pipelines", systemImage: "airplane.departure")
            }
        }
        .navigationTitle("Pipelines")
        .refreshable {
            await store.refresh()
        }
    }
}

#Preview {
    @Previewable @State var store = Store.previewValue
    PipelinesView()
        .environment(store)
        .task { await store.load() }
}
