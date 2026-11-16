import DevopsClient

extension MergeStrategy {
    /// The names the Azure DevOps web UI uses.
    var title: String {
        switch self {
        case .noFastForward: "Merge (no fast-forward)"
        case .squash: "Squash commit"
        case .rebase: "Rebase and fast-forward"
        case .rebaseMerge: "Semi-linear merge"
        }
    }
}
