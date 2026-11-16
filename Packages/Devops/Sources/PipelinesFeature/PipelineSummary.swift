import DevopsClient
import SwiftUI

/// What a run looks like when collapsed: name, number, state, where it runs and for how long.
struct PipelineSummary: View {
    let build: Build
    let organization: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                Text(build.pipeline ?? "Pipeline").font(.headline).lineLimit(1)
                if let number = build.number {
                    Text(number).font(.subheadline.monospaced()).foregroundStyle(.secondary)
                }
                Spacer()
                BuildStateBadge(state: build.state)
            }
            Text(subtitle).font(.caption).foregroundStyle(.secondary).lineLimit(1)
            BuildTimes(build: build)
        }
        .padding(.vertical, 2)
        .contextMenu {
            if let url = build.link(in: organization) {
                Link("Open in Browser", destination: url)
            }
        }
    }

    private var subtitle: String {
        var parts: [String] = []
        if let project = build.project { parts.append(project) }
        if let branch = build.branch { parts.append(branch) }
        if let name = build.requestedBy?.displayName { parts.append(name) }
        return parts.joined(separator: " · ")
    }
}

#Preview {
    List(Build.previewBuilds) { PipelineSummary(build: $0, organization: "fabrikam") }
}
