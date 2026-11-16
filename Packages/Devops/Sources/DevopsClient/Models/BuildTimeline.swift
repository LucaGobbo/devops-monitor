import Foundation

/// The stages of a run, each with its jobs and their tasks. Empty while a run has not started.
public struct BuildTimeline: Sendable, Hashable {
    public var stages: [BuildStage]

    public init(stages: [BuildStage] = []) { self.stages = stages }
}

extension BuildTimeline {
    /// Sample data for previews: a finished stage, and a running stage with a running job.
    public static let preview = BuildTimeline(stages: [
        BuildStage(
            id: "s1", name: "Build", status: .succeeded,
            startedAt: .now.addingTimeInterval(-300), finishedAt: .now.addingTimeInterval(-120),
            jobs: [
                BuildJob(
                    id: "j1", name: "Compile", status: .succeeded,
                    startedAt: .now.addingTimeInterval(-300), finishedAt: .now.addingTimeInterval(-120),
                    tasks: [
                        BuildTask(id: "t1", name: "Checkout", status: .succeeded, startedAt: .now.addingTimeInterval(-300), finishedAt: .now.addingTimeInterval(-290)),
                        BuildTask(id: "t2", name: "Build", status: .succeeded, startedAt: .now.addingTimeInterval(-290), finishedAt: .now.addingTimeInterval(-120)),
                    ]
                )
            ]
        ),
        BuildStage(
            id: "s2", name: "Test", status: .running, startedAt: .now.addingTimeInterval(-120),
            jobs: [
                BuildJob(
                    id: "j2", name: "Unit tests", status: .running, startedAt: .now.addingTimeInterval(-120),
                    tasks: [
                        BuildTask(id: "t3", name: "Run tests", status: .running, startedAt: .now.addingTimeInterval(-60)),
                        BuildTask(id: "t4", name: "Publish results", status: .pending),
                    ]
                ),
                BuildJob(id: "j3", name: "UI tests", status: .pending),
            ]
        ),
        BuildStage(id: "s3", name: "Deploy", status: .pending),
    ])
}
