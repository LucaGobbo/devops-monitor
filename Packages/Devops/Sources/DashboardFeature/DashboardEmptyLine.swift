import SwiftUI

/// What a card says when it has nothing to list.
struct DashboardEmptyLine: View {
    let text: LocalizedStringKey

    var body: some View {
        Text(text).font(.callout).foregroundStyle(.secondary)
    }
}

#Preview {
    DashboardEmptyLine(text: "Nothing to review").padding()
}
