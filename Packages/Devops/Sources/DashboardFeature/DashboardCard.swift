import SwiftUI

/// The frame of one dashboard card: a header that leads to the full page, and the card's content.
struct DashboardCard<Content: View>: View {
    let title: LocalizedStringKey
    let systemImage: String
    let open: () -> Void
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button(action: open) {
                HStack {
                    Label(title, systemImage: systemImage).font(.headline)
                    Spacer()
                    Image(systemName: "chevron.right").font(.caption).foregroundStyle(.secondary)
                }
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
            content
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(.background.secondary, in: .rect(cornerRadius: 12))
    }
}

#Preview {
    DashboardCard(title: "Pipelines now", systemImage: "airplane.departure", open: {}) {
        Text("Content")
    }
    .frame(width: 320)
    .padding()
}
