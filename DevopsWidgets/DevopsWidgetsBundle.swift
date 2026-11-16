import SwiftUI
import WidgetKit

@main
struct DevopsWidgetsBundle: WidgetBundle {
    var body: some Widget {
        PullRequestsWidget()
        PipelinesWidget()
    }
}
