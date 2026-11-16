import DevopsClient
import SwiftUI

/// Status icon, name and duration of a stage, job or task.
struct StepLabel: View {
    let name: String
    let status: BuildStepStatus
    let startedAt: Date?
    let finishedAt: Date?

    var body: some View {
        HStack(spacing: 6) {
            StepStatusIcon(status: status)
            Text(name).lineLimit(1)
            Spacer(minLength: 8)
            StepDuration(status: status, startedAt: startedAt, finishedAt: finishedAt)
        }
    }
}

extension BuildStepStatus {
    /// Whether a stage or job should show what is inside it without being asked.
    var showsDetails: Bool {
        switch self {
        case .running, .failed, .succeededWithIssues: true
        case .pending, .succeeded, .canceled, .skipped: false
        }
    }
}

#Preview {
    VStack(alignment: .leading) {
        StepLabel(name: "Run tests", status: .running, startedAt: .now.addingTimeInterval(-75), finishedAt: nil)
        StepLabel(name: "Build", status: .succeeded, startedAt: .now.addingTimeInterval(-200), finishedAt: .now.addingTimeInterval(-20))
        StepLabel(name: "Deploy", status: .pending, startedAt: nil, finishedAt: nil)
    }
    .padding()
}
