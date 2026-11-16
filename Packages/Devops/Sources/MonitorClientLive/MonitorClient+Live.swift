import DevopsClient
import Foundation
import MonitorClient

extension MonitorClient {
    /// The real implementation on top of a ``DevopsClient``.
    ///
    /// Polls every ``MonitorSnapshot/pollInterval`` (10 s while a pipeline is active, 60 s otherwise). The first
    /// poll is the baseline and reports no changes. A failed poll is published and polling goes on.
    /// - Parameters:
    ///   - sleep: waits between polls; replace it in tests so they do not wait.
    public static func live(
        client: DevopsClient,
        sleep: @escaping @Sendable (Duration) async throws -> Void = { try await Task.sleep(for: $0) }
    ) -> MonitorClient {
        let trigger = RefreshTrigger()

        /// Waits for `interval`, or until `refreshNow` is called.
        @Sendable func pause(for interval: Duration) async {
            await withTaskGroup(of: Void.self) { group in
                group.addTask { try? await sleep(interval) }
                group.addTask { await trigger.wait() }
                await group.next()
                group.cancelAll()
            }
        }

        return MonitorClient(
            events: { organization, me in
                AsyncStream { continuation in
                    let task = Task {
                        let poller = Poller(client: client, organization: organization, me: me)
                        var previous: MonitorSnapshot?
                        var interval = Duration.seconds(60)
                        while !Task.isCancelled {
                            do {
                                let (snapshot, changes) = try await poller.poll(since: previous)
                                previous = snapshot
                                interval = snapshot.pollInterval
                                continuation.yield(.update(snapshot, changes: changes))
                            } catch {
                                continuation.yield(.failure(error.localizedDescription))
                            }
                            await pause(for: interval)
                        }
                        continuation.finish()
                    }
                    continuation.onTermination = { _ in task.cancel() }
                }
            },
            refreshNow: { trigger.fire() },
            timelines: { organization, project, buildId in
                AsyncStream { continuation in
                    let task = Task {
                        while !Task.isCancelled {
                            // A failed fetch is skipped; the next one may work.
                            if let timeline = try? await client.timeline(organization, project, buildId) {
                                continuation.yield(timeline)
                            }
                            try? await sleep(.seconds(10))
                        }
                        continuation.finish()
                    }
                    continuation.onTermination = { _ in task.cancel() }
                }
            }
        )
    }
}
