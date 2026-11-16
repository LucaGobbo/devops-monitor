import DevopsClient
import SwiftUI

struct StepStatusIcon: View {
    let status: BuildStepStatus

    var body: some View {
        Image(systemName: symbol)
            .foregroundStyle(color)
            .help(title)
    }

    private var symbol: String {
        switch status {
        case .pending: "circle.dashed"
        case .running: "play.circle.fill"
        case .succeeded: "checkmark.circle.fill"
        case .succeededWithIssues: "exclamationmark.circle.fill"
        case .failed: "xmark.circle.fill"
        case .canceled: "slash.circle"
        case .skipped: "arrow.right.circle"
        }
    }

    private var color: Color {
        switch status {
        case .pending, .canceled, .skipped: .secondary
        case .running: .blue
        case .succeeded: .green
        case .succeededWithIssues: .orange
        case .failed: .red
        }
    }

    private var title: String {
        switch status {
        case .pending: "Pending"
        case .running: "Running"
        case .succeeded: "Succeeded"
        case .succeededWithIssues: "Succeeded with issues"
        case .failed: "Failed"
        case .canceled: "Canceled"
        case .skipped: "Skipped"
        }
    }
}

#Preview {
    HStack {
        ForEach([BuildStepStatus.pending, .running, .succeeded, .succeededWithIssues, .failed, .canceled, .skipped], id: \.self) {
            StepStatusIcon(status: $0)
        }
    }
    .padding()
}
