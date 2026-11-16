import SwiftUI

/// A big number with a caption under it.
struct DashboardCount: View {
    let value: Int
    let label: LocalizedStringKey
    var tint: Color = .primary

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("\(value)").font(.title.weight(.semibold)).monospacedDigit().foregroundStyle(tint)
            Text(label).font(.caption).foregroundStyle(.secondary)
        }
    }
}

#Preview {
    HStack { DashboardCount(value: 2, label: "Running", tint: .blue); DashboardCount(value: 0, label: "Queued") }.padding()
}
