import DevopsClient
import SwiftUI

/// How long a step took; while it runs the duration ticks every second. Shows nothing before it started.
struct StepDuration: View {
    let status: BuildStepStatus
    let startedAt: Date?
    let finishedAt: Date?

    var body: some View {
        if let startedAt {
            if let finishedAt {
                text(from: startedAt, to: finishedAt)
            } else if status == .running {
                TimelineView(.periodic(from: .now, by: 1)) { context in
                    text(from: startedAt, to: context.date)
                }
            }
        }
    }

    private func text(from start: Date, to end: Date) -> some View {
        Text(Duration.seconds(max(0, end.timeIntervalSince(start)))
            .formatted(.units(allowed: [.hours, .minutes, .seconds], width: .narrow, maximumUnitCount: 2)))
            .font(.caption.monospacedDigit())
            .foregroundStyle(.secondary)
    }
}

#Preview {
    VStack(alignment: .trailing) {
        StepDuration(status: .running, startedAt: .now.addingTimeInterval(-75), finishedAt: nil)
        StepDuration(status: .succeeded, startedAt: .now.addingTimeInterval(-200), finishedAt: .now.addingTimeInterval(-20))
        StepDuration(status: .pending, startedAt: nil, finishedAt: nil)
    }
    .padding()
}
