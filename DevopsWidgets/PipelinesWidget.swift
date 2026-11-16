import SwiftUI
import WidgetFeature
import WidgetKit

struct PipelinesWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "PipelinesWidget", provider: SnapshotProvider()) { entry in
            PipelinesWidgetView(snapshot: entry.snapshot)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Pipelines")
        .description("Your queued and running pipelines.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
