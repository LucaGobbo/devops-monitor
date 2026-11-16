import DevopsClient
import SwiftUI

/// Queued / running time of a build; a running build's duration ticks every second.
struct BuildTimes: View {
    let build: Build

    var body: some View {
        if let started = build.startedAt {
            TimelineView(.periodic(from: .now, by: 1)) { context in
                let end = build.finishedAt ?? context.date
                Text("Started \(started.formatted(.relative(presentation: .named))) · \(duration(started, end))")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        } else if let queued = build.queuedAt {
            Text("Queued \(queued.formatted(.relative(presentation: .named)))")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private func duration(_ start: Date, _ end: Date) -> String {
        Duration.seconds(max(0, end.timeIntervalSince(start)))
            .formatted(.units(allowed: [.hours, .minutes, .seconds], width: .narrow, maximumUnitCount: 2))
    }
}

#Preview {
    VStack(alignment: .leading) {
        ForEach(Build.previewBuilds) { BuildTimes(build: $0) }
    }
    .padding()
}
