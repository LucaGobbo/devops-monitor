import AppKit
import MenuBarFeature
import SwiftUI

/// The menu bar popup: opens the main window on the tapped page.
struct MenuBarContent: View {
    @Environment(\.openWindow) private var openWindow
    @Environment(Navigation.self) private var navigation

    var body: some View {
        MenuBarView { destination in
            navigation.selection = switch destination {
            case .pipelines: .pipelines
            case .pullRequests: .pullRequests
            }
            openWindow(id: MyApp.mainWindowID)
            NSApp.activate()
        }
    }
}
