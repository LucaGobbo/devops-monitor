import DevopsClient

extension MonitorClient {
    /// Publishes a single failure and ends, so a test fails on any use it did not expect.
    public static let testValue = MonitorClient(
        events: { _, _ in
            AsyncStream { continuation in
                continuation.yield(.failure("MonitorClient.events is unimplemented"))
                continuation.finish()
            }
        },
        refreshNow: {},
        timelines: { _, _, _ in AsyncStream { $0.finish() } }
    )

    /// Publishes the sample data of `DevopsClient.previewValue` once and ends.
    public static let previewValue = MonitorClient(
        events: { organization, me in
            AsyncStream { continuation in
                Task {
                    let client = DevopsClient.previewValue
                    let snapshot = try? await MonitorSnapshot(
                        pipelines: client.activeBuilds(organization, me),
                        createdPullRequests: client.pullRequests(organization, .createdByMe, me),
                        assignedPullRequests: client.pullRequests(organization, .assignedToMe, me)
                    )
                    continuation.yield(.update(snapshot ?? MonitorSnapshot(), changes: []))
                    continuation.finish()
                }
            }
        },
        refreshNow: {},
        timelines: { _, _, _ in
            AsyncStream { continuation in
                continuation.yield(.preview)
                continuation.finish()
            }
        }
    )
}
