import SnapshotClient
import SwiftUI

struct WidgetPipelineRow: View {
    let pipeline: WidgetPipeline

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: pipeline.isRunning ? "play.circle.fill" : "clock")
                .foregroundStyle(pipeline.isRunning ? Color.blue : Color.secondary)
            VStack(alignment: .leading, spacing: 0) {
                Text(pipeline.name).font(.callout).lineLimit(1)
                Text(subtitle).font(.caption2).foregroundStyle(.secondary).lineLimit(1)
            }
            Spacer(minLength: 0)
            if pipeline.isRunning, let startedAt = pipeline.startedAt {
                Text(startedAt, style: .timer)
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: 48, alignment: .trailing)
            }
        }
    }

    private var subtitle: String {
        [pipeline.number, pipeline.branch].compactMap(\.self).joined(separator: " · ")
    }
}

#Preview {
    WidgetPipelineRow(pipeline: WidgetSnapshot.preview.pipelines[0])
        .padding()
        .frame(width: 300)
}
