import SwiftUI

/// A titled group of rows; hidden when `count` is 0.
struct MenuBarSection<Rows: View>: View {
    let title: String
    let count: Int
    let onTapTitle: () -> Void
    @ViewBuilder let rows: Rows

    var body: some View {
        if count > 0 {
            VStack(alignment: .leading, spacing: 2) {
                Button(action: onTapTitle) {
                    Text("\(title) (\(count))")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                rows
            }
        }
    }
}

#Preview {
    MenuBarSection(title: "Pull requests", count: 2, onTapTitle: {}) {
        Text("Row")
    }
    .padding()
}
