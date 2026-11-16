import SwiftUI
import WidgetFeature
import WidgetKit

struct PullRequestsWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "PullRequestsWidget", provider: SnapshotProvider()) { entry in
            PullRequestsWidgetView(snapshot: entry.snapshot)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Pull requests")
        .description("Your open pull requests and the ones assigned to you.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
