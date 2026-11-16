import SwiftUI

/// A row that opens `url` in the browser, also from its context menu; plain when there is no link.
struct DashboardLinkRow<Content: View>: View {
    let url: URL?
    @ViewBuilder let content: Content

    var body: some View {
        if let url {
            Link(destination: url) { content.frame(maxWidth: .infinity, alignment: .leading) }
                .buttonStyle(.plain)
                .contextMenu { Link("Open in Browser", destination: url) }
        } else {
            content.frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    DashboardLinkRow(url: URL(string: "https://dev.azure.com")) { Text("Open") }.padding()
}
