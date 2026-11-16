import ActivityTimeline
import SwiftUI

extension ActivityKind {
    var title: LocalizedStringKey {
        switch self {
        case .pullRequestOpened: "Pull request opened"
        case .pullRequestAssigned: "Assigned to you"
        case .pullRequestReviewed: "Pull request reviewed"
        case .pullRequestCompleted: "Pull request completed"
        case .pullRequestAbandoned: "Pull request abandoned"
        case .buildQueued: "Pipeline queued"
        case .buildStarted: "Pipeline started"
        case .buildSucceeded: "Pipeline succeeded"
        case .buildPartiallySucceeded: "Pipeline partially succeeded"
        case .buildFailed: "Pipeline failed"
        case .buildCanceled: "Pipeline canceled"
        }
    }

    var systemImage: String {
        switch self {
        case .pullRequestOpened: "arrow.trianglehead.pull"
        case .pullRequestAssigned: "person.crop.circle.badge.checkmark"
        case .pullRequestReviewed: "text.bubble"
        case .pullRequestCompleted: "arrow.trianglehead.merge"
        case .pullRequestAbandoned: "xmark.bin"
        case .buildQueued: "clock"
        case .buildStarted: "play.circle"
        case .buildSucceeded: "checkmark.circle"
        case .buildPartiallySucceeded: "exclamationmark.circle"
        case .buildFailed: "xmark.circle"
        case .buildCanceled: "slash.circle"
        }
    }

    var tint: Color {
        switch self {
        case .pullRequestCompleted, .buildSucceeded: .green
        case .buildPartiallySucceeded, .buildQueued: .orange
        case .buildFailed: .red
        case .pullRequestAbandoned, .buildCanceled: .secondary
        case .pullRequestOpened, .pullRequestAssigned, .pullRequestReviewed, .buildStarted: .blue
        }
    }
}
