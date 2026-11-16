import DevopsClient
import SwiftUI

/// A stage and, when it has any, its jobs. Opens itself while it is running or has failed.
struct BuildStageRow: View {
    let stage: BuildStage
    @State private var isExpanded: Bool

    init(stage: BuildStage) {
        self.stage = stage
        _isExpanded = State(initialValue: stage.status.showsDetails)
    }

    var body: some View {
        if stage.jobs.isEmpty {
            StepLabel(name: stage.name, status: stage.status, startedAt: stage.startedAt, finishedAt: stage.finishedAt)
        } else {
            DisclosureGroup(isExpanded: $isExpanded) {
                ForEach(stage.jobs) { BuildJobRow(job: $0) }
            } label: {
                StepLabel(name: stage.name, status: stage.status, startedAt: stage.startedAt, finishedAt: stage.finishedAt)
                    .font(.subheadline.weight(.semibold))
            }
        }
    }
}

#Preview {
    List(BuildTimeline.preview.stages) { BuildStageRow(stage: $0) }
}
