import DevopsClient
import MonitorClient
import NotificationClient

extension AppNotification {
    /// The notification that tells the user about `change`; `nil` for a change that only goes to the timeline
    /// (abandoned, canceled and partially succeeded).
    init?(_ change: MonitorChange) {
        switch change {
        case .buildFinished(let build):
            let succeeded = build.state == .succeeded
            self.init(
                id: "build-\(build.id)",
                title: succeeded ? "Pipeline succeeded" : "Pipeline failed",
                subtitle: [build.pipeline, build.number].compactMap(\.self).joined(separator: " "),
                body: [build.project, build.branch].compactMap(\.self).joined(separator: " · ")
            )
        case .pullRequestCompleted(let pullRequest):
            self.init(
                id: "pull-request-\(pullRequest.id)",
                title: "Pull request completed",
                subtitle: "#\(pullRequest.id) \(pullRequest.title)",
                body: [pullRequest.project, pullRequest.repository].compactMap(\.self).joined(separator: " / ")
            )
        case .pullRequestAbandoned, .buildPartiallySucceeded, .buildCanceled:
            return nil
        }
    }
}
