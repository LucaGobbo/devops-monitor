import ActivityTimeline
import Foundation

extension ActivityEvent {
    static func sample(
        _ kind: ActivityKind, title: String, detail: String? = nil, item: Int, minutesAgo: Int
    ) -> ActivityEvent {
        ActivityEvent(
            id: "\(kind.rawValue)-\(item)-\(minutesAgo)", date: Date(timeIntervalSinceNow: -TimeInterval(minutesAgo * 60)),
            organization: "fabrikam", kind: kind, itemID: item, title: title, detail: detail, project: "Fabrikam"
        )
    }

    static let samples: [ActivityEvent] = [
        .sample(.buildFailed, title: "CI 20241101.3", detail: "main", item: 9, minutesAgo: 5),
        .sample(.buildStarted, title: "CI 20241101.3", detail: "main", item: 9, minutesAgo: 12),
        .sample(.buildQueued, title: "CI 20241101.3", detail: "main", item: 9, minutesAgo: 14),
        .sample(.pullRequestCompleted, title: "Add the new feature", detail: "app", item: 22, minutesAgo: 40),
        .sample(.pullRequestReviewed, title: "Add the new feature", detail: "Reviewer One approved", item: 22, minutesAgo: 90),
        .sample(.pullRequestOpened, title: "Add the new feature", detail: "app", item: 22, minutesAgo: 600),
        .sample(.pullRequestAssigned, title: "Fix flaky test", detail: "app", item: 21, minutesAgo: 3000),
    ]
}
