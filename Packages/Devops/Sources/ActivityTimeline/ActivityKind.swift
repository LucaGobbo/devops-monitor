/// What happened.
public enum ActivityKind: String, Sendable, Hashable, CaseIterable {
    case pullRequestOpened, pullRequestAssigned, pullRequestReviewed
    case pullRequestCompleted, pullRequestAbandoned
    case buildQueued, buildStarted, buildSucceeded, buildPartiallySucceeded, buildFailed, buildCanceled
}
