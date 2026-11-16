import SwiftUI

struct WidgetEmptyState: View {
    let systemImage: String
    let message: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: systemImage).font(.title2).foregroundStyle(.secondary)
            Text(message).font(.caption).foregroundStyle(.secondary).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    WidgetEmptyState(systemImage: "checkmark.circle", message: "Nothing running")
        .frame(width: 160, height: 160)
}
