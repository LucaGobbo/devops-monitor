import DevopsAPI
import DevopsClient
import Foundation

extension BuildTimeline {
    /// Builds the tree from the flat records: Stage > (Phase) > Job > Task, each level sorted by `order`.
    ///
    /// The Phase level is folded away. A pipeline without Stage records (classic pipelines) gets one stage that
    /// holds all its jobs. Records whose parent is missing are dropped.
    init(_ dto: TimelineDTO) {
        let children = Dictionary(grouping: dto.records) { $0.parentId ?? "" }
            .mapValues { $0.sorted(by: Self.inOrder) }

        func jobs(under id: String) -> [TimelineRecordDTO] {
            (children[id] ?? []).flatMap { child -> [TimelineRecordDTO] in
                switch child.type {
                case .job: [child]
                case .phase: jobs(under: child.id)
                default: []
                }
            }
        }
        func job(_ record: TimelineRecordDTO) -> BuildJob {
            BuildJob(
                id: record.id, name: record.name ?? "Job", status: BuildStepStatus(record),
                startedAt: record.startTime, finishedAt: record.finishTime,
                tasks: (children[record.id] ?? []).filter { $0.type == .task }.map {
                    BuildTask(
                        id: $0.id, name: $0.name ?? "Task", status: BuildStepStatus($0),
                        startedAt: $0.startTime, finishedAt: $0.finishTime
                    )
                }
            )
        }

        let stageRecords = dto.records.filter { $0.type == .stage }.sorted(by: Self.inOrder)
        if stageRecords.isEmpty {
            let all = dto.records.filter { $0.type == .job }.sorted(by: Self.inOrder)
            self.init(stages: all.isEmpty ? [] : [
                BuildStage(
                    id: "pipeline", name: "Pipeline",
                    status: all.contains { BuildStepStatus($0).isActive } ? .running : .succeeded,
                    jobs: all.map(job)
                )
            ])
        } else {
            self.init(stages: stageRecords.map {
                BuildStage(
                    id: $0.id, name: $0.name ?? "Stage", status: BuildStepStatus($0),
                    startedAt: $0.startTime, finishedAt: $0.finishTime, jobs: jobs(under: $0.id).map(job)
                )
            })
        }
    }

    private static func inOrder(_ a: TimelineRecordDTO, _ b: TimelineRecordDTO) -> Bool {
        (a.order ?? .max, a.name ?? "") < (b.order ?? .max, b.name ?? "")
    }
}

extension BuildStepStatus {
    init(_ record: TimelineRecordDTO) {
        switch record.state {
        case .pending: self = .pending
        case .inProgress: self = .running
        default:
            switch record.result {
            case .failed: self = .failed
            case .canceled, .abandoned: self = .canceled
            case .skipped: self = .skipped
            case .succeededWithIssues: self = .succeededWithIssues
            default: self = record.state == nil ? .pending : .succeeded
            }
        }
    }
}
