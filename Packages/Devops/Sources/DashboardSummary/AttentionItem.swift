import ActivityTimeline
import DevopsClient

/// Something the user should look at.
public enum AttentionItem: Sendable, Hashable, Identifiable {
    case failedRun(ActivityEvent)
    case blockedPullRequest(PullRequest)
    case stalePullRequest(PullRequest)

    public var id: String {
        switch self {
        case .failedRun(let event): "run-\(event.itemID)"
        case .blockedPullRequest(let pullRequest), .stalePullRequest(let pullRequest): "pr-\(pullRequest.id)"
        }
    }
}
