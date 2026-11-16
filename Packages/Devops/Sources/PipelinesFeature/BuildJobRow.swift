import DevopsClient
import SwiftUI

/// A job and, when it has any, its tasks. Opens itself while it is running or has failed.
struct BuildJobRow: View {
    let job: BuildJob
    @State private var isExpanded: Bool

    init(job: BuildJob) {
        self.job = job
        _isExpanded = State(initialValue: job.status.showsDetails)
    }

    var body: some View {
        if job.tasks.isEmpty {
            StepLabel(name: job.name, status: job.status, startedAt: job.startedAt, finishedAt: job.finishedAt)
        } else {
            DisclosureGroup(isExpanded: $isExpanded) {
                ForEach(job.tasks) {
                    StepLabel(name: $0.name, status: $0.status, startedAt: $0.startedAt, finishedAt: $0.finishedAt)
                        .font(.caption)
                }
            } label: {
                StepLabel(name: job.name, status: job.status, startedAt: job.startedAt, finishedAt: job.finishedAt)
            }
        }
    }
}

#Preview {
    List(BuildTimeline.preview.stages[1].jobs) { BuildJobRow(job: $0) }
}
