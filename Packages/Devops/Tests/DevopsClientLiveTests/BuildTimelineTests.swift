import DevopsAPI
import DevopsClient
import Testing

@testable import DevopsClientLive

/// The tree building is the one piece of logic in the mapping layer, so it is worth pinning down.
struct BuildTimelineTests {
    private func record(
        _ id: String, _ type: TimelineRecordTypeDTO, parent: String? = nil, order: Int? = 1,
        state: TimelineRecordStateDTO = .completed, result: TimelineRecordResultDTO? = .succeeded
    ) -> TimelineRecordDTO {
        TimelineRecordDTO(id: id, parentId: parent, type: type, name: id, order: order, state: state, result: result)
    }

    @Test func stagesJobsAndTasksNestAndPhasesAreFoldedAway() {
        let timeline = BuildTimeline(TimelineDTO(records: [
            record("task-b", .task, parent: "job", order: 2),
            record("task-a", .task, parent: "job", order: 1),
            record("job", .job, parent: "phase"),
            record("phase", .phase, parent: "stage"),
            record("stage", .stage),
        ]))
        #expect(timeline.stages.map(\.id) == ["stage"])
        #expect(timeline.stages[0].jobs.map(\.id) == ["job"])
        #expect(timeline.stages[0].jobs[0].tasks.map(\.id) == ["task-a", "task-b"])
    }

    @Test func eachLevelIsSortedByOrder() {
        let timeline = BuildTimeline(TimelineDTO(records: [
            record("deploy", .stage, order: 2),
            record("build", .stage, order: 1),
            record("j2", .job, parent: "build", order: 2),
            record("j1", .job, parent: "build", order: 1),
        ]))
        #expect(timeline.stages.map(\.id) == ["build", "deploy"])
        #expect(timeline.stages[0].jobs.map(\.id) == ["j1", "j2"])
    }

    @Test func aPipelineWithoutStagesGetsOneStageWithAllItsJobs() {
        let timeline = BuildTimeline(TimelineDTO(records: [
            record("phase", .phase),
            record("job", .job, parent: "phase", state: .inProgress, result: nil),
        ]))
        #expect(timeline.stages.count == 1)
        #expect(timeline.stages[0].jobs.map(\.id) == ["job"])
        #expect(timeline.stages[0].status == .running)
    }

    @Test func recordsWithoutAParentAreDroppedAndAnEmptyTimelineHasNoStages() {
        let orphan = BuildTimeline(TimelineDTO(records: [
            record("stage", .stage), record("lost", .task, parent: "missing"),
        ]))
        #expect(orphan.stages[0].jobs.isEmpty)
        #expect(BuildTimeline(TimelineDTO()).stages.isEmpty)
    }

    @Test(arguments: [
        (TimelineRecordStateDTO.pending, TimelineRecordResultDTO?.none, BuildStepStatus.pending),
        (.inProgress, nil, .running),
        (.completed, .succeeded, .succeeded),
        (.completed, .succeededWithIssues, .succeededWithIssues),
        (.completed, .failed, .failed),
        (.completed, .canceled, .canceled),
        (.completed, .abandoned, .canceled),
        (.completed, .skipped, .skipped),
        (.completed, nil, .succeeded),
    ])
    func statusCombinesStateAndResult(state: TimelineRecordStateDTO, result: TimelineRecordResultDTO?, expected: BuildStepStatus) {
        #expect(BuildStepStatus(record("r", .task, state: state, result: result)) == expected)
    }
}
