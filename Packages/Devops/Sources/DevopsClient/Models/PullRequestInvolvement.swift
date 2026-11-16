public enum PullRequestInvolvement: Sendable, Hashable {
    case createdByMe
    /// Pull requests have no assignee; "assigned to me" means "I am a reviewer".
    case assignedToMe
}
