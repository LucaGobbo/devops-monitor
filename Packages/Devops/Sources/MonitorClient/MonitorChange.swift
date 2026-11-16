import DevopsClient

/// How a pull request or a pipeline run ended.
public enum MonitorChange: Sendable, Hashable {
    /// A pull request the user created was completed (merged).
    case pullRequestCompleted(PullRequest)
    /// A pull request the user created was abandoned.
    case pullRequestAbandoned(PullRequest)
    /// A pipeline run ended; its state is `.succeeded` or `.failed`.
    case buildFinished(Build)
    /// A pipeline run ended with warnings.
    case buildPartiallySucceeded(Build)
    /// A pipeline run was canceled.
    case buildCanceled(Build)

    /// The change for a pull request that left the open list, if it ended (completed or abandoned).
    public init?(resolved pullRequest: PullRequest) {
        switch pullRequest.status {
        case .completed: self = .pullRequestCompleted(pullRequest)
        case .abandoned: self = .pullRequestAbandoned(pullRequest)
        case .active, .unknown: return nil
        }
    }

    /// The change for a build that left the open list, if it ended.
    public init?(resolved build: Build) {
        switch build.state {
        case .succeeded, .failed: self = .buildFinished(build)
        case .partiallySucceeded: self = .buildPartiallySucceeded(build)
        case .canceled: self = .buildCanceled(build)
        case .notStarted, .inProgress, .unknown: return nil
        }
    }
}
