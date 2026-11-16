import DevopsClient
import Foundation

extension ActivityEvent {
    /// An event about a pull request. `thread` tells apart events of the same kind on one pull request
    /// (two reviewers voting, a second review by the same person).
    init(
        _ pullRequest: PullRequest, _ kind: ActivityKind, detail: String? = nil, thread: Int? = nil,
        organization: String, at date: Date
    ) {
        let suffix = thread.map { "-\($0)" } ?? ""
        self.init(
            id: "pr-\(pullRequest.id)-\(kind.rawValue)\(suffix)", date: date, organization: organization, kind: kind,
            itemID: pullRequest.id, title: pullRequest.title, detail: detail ?? pullRequest.repository,
            project: pullRequest.project, url: pullRequest.webURL
        )
    }
}
