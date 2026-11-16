import DevopsClient
import Foundation

/// Builds the activity timeline from what the server holds, so nothing has to be stored on the device.
///
/// Pure: the caller fetches builds, pull requests and their system threads (see `Store.loadActivity()`) and this
/// turns them into events.
public enum ActivityTimeline {
    /// The events in `[since, now]`, newest first.
    ///
    /// - Parameters:
    ///   - builds: the user's runs; each queue, start and finish time becomes an event.
    ///   - pullRequests: the pull requests the user created or reviews. Opened and ended are only reported for
    ///     the ones the user created.
    ///   - pullRequestEvents: the votes and added reviewers of each pull request, by pull request id.
    ///   - me: the user; an added reviewer is "assigned" only when it is them.
    public static func events(
        builds: [Build],
        pullRequests: [PullRequest],
        pullRequestEvents: [Int: [PullRequestEvent]],
        me: Person,
        organization: String,
        since: Date
    ) -> [ActivityEvent] {
        var events = builds.flatMap { buildEvents($0, organization: organization) }
        var seen = Set<Int>()
        for pullRequest in pullRequests where seen.insert(pullRequest.id).inserted {
            events += pullRequestActivity(pullRequest, threads: pullRequestEvents[pullRequest.id] ?? [], me: me, organization: organization)
        }
        return Dictionary(events.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first }).values
            .filter { $0.date >= since }
            .sorted { ($0.date, $0.id) > ($1.date, $1.id) }
    }

    private static func buildEvents(_ build: Build, organization: String) -> [ActivityEvent] {
        var events: [ActivityEvent] = []
        if let date = build.queuedAt { events.append(ActivityEvent(build, .buildQueued, organization: organization, at: date)) }
        if let date = build.startedAt { events.append(ActivityEvent(build, .buildStarted, organization: organization, at: date)) }
        if let date = build.finishedAt, let kind = finishedKind(build.state) {
            events.append(ActivityEvent(build, kind, organization: organization, at: date))
        }
        return events
    }

    private static func finishedKind(_ state: BuildState) -> ActivityKind? {
        switch state {
        case .succeeded: .buildSucceeded
        case .partiallySucceeded: .buildPartiallySucceeded
        case .failed: .buildFailed
        case .canceled: .buildCanceled
        case .notStarted, .inProgress, .unknown: nil
        }
    }

    private static func pullRequestActivity(
        _ pullRequest: PullRequest, threads: [PullRequestEvent], me: Person, organization: String
    ) -> [ActivityEvent] {
        var events: [ActivityEvent] = []
        if let author = pullRequest.author, me.matches(threadID: author.id) {
            if let date = pullRequest.createdAt {
                events.append(ActivityEvent(pullRequest, .pullRequestOpened, organization: organization, at: date))
            }
            if let date = pullRequest.closedAt {
                switch pullRequest.status {
                case .completed: events.append(ActivityEvent(pullRequest, .pullRequestCompleted, organization: organization, at: date))
                case .abandoned: events.append(ActivityEvent(pullRequest, .pullRequestAbandoned, organization: organization, at: date))
                case .active, .unknown: break
                }
            }
        }
        for thread in threads {
            switch thread.kind {
            case .reviewerAdded(let personID) where me.matches(threadID: personID):
                events.append(ActivityEvent(pullRequest, .pullRequestAssigned, thread: thread.id, organization: organization, at: thread.date))
            case .voted(_, let name, let vote) where vote != .noVote:
                events.append(ActivityEvent(
                    pullRequest, .pullRequestReviewed, detail: "\(name ?? "Someone") \(vote.verb)", thread: thread.id,
                    organization: organization, at: thread.date
                ))
            case .reviewerAdded, .voted:
                break
            }
        }
        return events
    }
}

extension ReviewVote {
    fileprivate var verb: String {
        switch self {
        case .approved: "approved"
        case .approvedWithSuggestions: "approved with suggestions"
        case .waitingForAuthor: "is waiting for the author"
        case .rejected: "rejected"
        case .noVote: "has not voted"
        }
    }
}
