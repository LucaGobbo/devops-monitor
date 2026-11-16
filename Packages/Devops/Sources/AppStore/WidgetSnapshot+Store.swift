import DevopsClient
import Foundation
import SnapshotClient

extension WidgetSnapshot {
    /// The widgets' view of what the store holds. A pull request that is both created by and assigned to the
    /// user appears once, as created.
    init(pipelines: [Build], created: [PullRequest], assigned: [PullRequest], organization: String, now: Date) {
        let createdIDs = Set(created.map(\.id))
        let pullRequests =
            created.map { WidgetPullRequest($0, isCreatedByMe: true, organization: organization) }
            + assigned.filter { !createdIDs.contains($0.id) }
                .map { WidgetPullRequest($0, isCreatedByMe: false, organization: organization) }
        self.init(
            updatedAt: now,
            pullRequests: pullRequests,
            pipelines: pipelines.map { WidgetPipeline($0, organization: organization) }
        )
    }
}

extension WidgetPullRequest {
    init(_ pullRequest: PullRequest, isCreatedByMe: Bool, organization: String) {
        self.init(
            id: pullRequest.id, title: pullRequest.title, repository: pullRequest.repository,
            author: pullRequest.author?.displayName, isCreatedByMe: isCreatedByMe, isDraft: pullRequest.isDraft,
            url: pullRequest.link(in: organization)
        )
    }
}

extension WidgetPipeline {
    init(_ build: Build, organization: String) {
        self.init(
            id: build.id, name: build.pipeline ?? "Pipeline", number: build.number, branch: build.branch,
            isRunning: build.state == .inProgress, startedAt: build.startedAt, url: build.link(in: organization)
        )
    }
}
