import DevopsClient
import SwiftUI

struct BuildStateBadge: View {
    let state: BuildState

    var body: some View {
        Label(state.title, systemImage: state.symbol)
            .font(.caption.weight(.medium))
            .foregroundStyle(state.color)
    }
}

private extension BuildState {
    var title: String {
        switch self {
        case .notStarted: "Queued"
        case .inProgress: "Running"
        case .succeeded: "Succeeded"
        case .partiallySucceeded: "Partially succeeded"
        case .failed: "Failed"
        case .canceled: "Canceled"
        case .unknown: "Unknown"
        }
    }

    var symbol: String {
        switch self {
        case .notStarted: "clock"
        case .inProgress: "play.circle.fill"
        case .succeeded: "checkmark.circle.fill"
        case .partiallySucceeded: "exclamationmark.circle.fill"
        case .failed: "xmark.circle.fill"
        case .canceled: "slash.circle"
        case .unknown: "questionmark.circle"
        }
    }

    var color: Color {
        switch self {
        case .notStarted, .canceled, .unknown: .secondary
        case .inProgress: .blue
        case .succeeded: .green
        case .partiallySucceeded: .orange
        case .failed: .red
        }
    }
}

#Preview {
    VStack(alignment: .leading) {
        ForEach([BuildState.notStarted, .inProgress, .succeeded, .partiallySucceeded, .failed, .canceled, .unknown], id: \.self) {
            BuildStateBadge(state: $0)
        }
    }
    .padding()
}
