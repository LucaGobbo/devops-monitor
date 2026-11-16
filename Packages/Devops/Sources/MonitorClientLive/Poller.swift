import DevopsClient
import Foundation
import MonitorClient

/// One organization and user: takes snapshots and works out what changed between two of them.
struct Poller: Sendable {
    let client: DevopsClient
    let organization: String
    let me: Person

    /// The current snapshot and, unless this is the baseline (`previous == nil`), the changes since `previous`.
    func poll(since previous: MonitorSnapshot?) async throws -> (snapshot: MonitorSnapshot, changes: [MonitorChange]) {
        async let pipelines = client.activeBuilds(organization, me)
        async let created = client.pullRequests(organization, .createdByMe, me)
        async let assigned = client.pullRequests(organization, .assignedToMe, me)
        let snapshot = try await MonitorSnapshot(pipelines: pipelines, createdPullRequests: created, assignedPullRequests: assigned)
        guard let previous else { return (snapshot, []) }
        return (snapshot, await changes(for: snapshot.departed(since: previous)))
    }

    /// Asks the server how each departed item ended. An item that cannot be looked up is skipped.
    private func changes(for departed: MonitorDeparted) async -> [MonitorChange] {
        await withTaskGroup(of: MonitorChange?.self) { group in
            for pullRequest in departed.pullRequests {
                group.addTask {
                    guard let project = pullRequest.project,
                          let resolved = try? await client.pullRequest(organization, project, pullRequest.id)
                    else { return nil }
                    return MonitorChange(resolved: resolved)
                }
            }
            for build in departed.builds {
                group.addTask {
                    guard let project = build.project,
                          let resolved = try? await client.build(organization, project, build.id)
                    else { return nil }
                    return MonitorChange(resolved: resolved)
                }
            }
            return await group.reduce(into: []) { changes, change in
                if let change { changes.append(change) }
            }
        }
    }
}
