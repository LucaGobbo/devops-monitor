import Foundation

/// The events of one pull request or one pipeline run, newest first: how that item progressed.
public struct ActivityGroup: Sendable, Hashable, Identifiable {
    /// `pr-<number>` or `build-<id>`.
    public var id: String
    /// Newest first, never empty.
    public var events: [ActivityEvent]

    public var isPullRequest: Bool { events[0].kind.isPullRequest }
    /// The title of the newest event, so a renamed pull request shows its current title.
    public var title: String { events[0].title }
    public var project: String? { events.lazy.compactMap(\.project).first }
    public var url: URL? { events.lazy.compactMap(\.url).first }
    /// When the item last moved; groups are ordered by it.
    public var date: Date { events[0].date }

    /// The repository or branch, from the newest event that carries one; a review's detail is who voted instead.
    public var context: String? {
        events.lazy.filter { $0.kind != .pullRequestReviewed }.compactMap(\.detail).first
    }

    /// Groups `events` by pull request / run; the groups and the events in them are newest first.
    public static func grouping(_ events: [ActivityEvent]) -> [ActivityGroup] {
        Dictionary(grouping: events) { "\($0.kind.isPullRequest ? "pr" : "build")-\($0.itemID)" }
            .map { ActivityGroup(id: $0.key, events: $0.value.sorted { ($0.date, $0.id) > ($1.date, $1.id) }) }
            .sorted { ($0.date, $0.id) > ($1.date, $1.id) }
    }
}

extension ActivityKind {
    public var isPullRequest: Bool {
        switch self {
        case .pullRequestOpened, .pullRequestAssigned, .pullRequestReviewed, .pullRequestCompleted, .pullRequestAbandoned: true
        case .buildQueued, .buildStarted, .buildSucceeded, .buildPartiallySucceeded, .buildFailed, .buildCanceled: false
        }
    }
}
