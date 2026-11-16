import DevopsClient
import SwiftUI

struct MenuBarPipelineRow: View {
    let build: Build
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: build.state == .inProgress ? "play.circle.fill" : "clock")
                    .foregroundStyle(build.state == .inProgress ? .blue : .secondary)
                VStack(alignment: .leading, spacing: 0) {
                    Text(build.pipeline ?? "Pipeline").lineLimit(1)
                    Text(subtitle).font(.caption).foregroundStyle(.secondary).lineLimit(1)
                }
                Spacer(minLength: 0)
            }
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }

    private var subtitle: String {
        [build.number, build.branch].compactMap(\.self).joined(separator: " · ")
    }
}

#Preview {
    MenuBarPipelineRow(
        build: Build(id: 1, number: "20241101.1", state: .inProgress, pipeline: "CI", branch: "main"),
        action: {}
    )
    .padding()
    .frame(width: 320)
}
