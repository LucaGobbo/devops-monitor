import AppStore
import AuthClient
import AuthClientLive
import DevopsClient
import MenuBarFeature
import MonitorClient
import MonitorClientLive
import NotificationClient
import NotificationClientLive
import SettingsFeature
import SnapshotClient
import SnapshotClientLive
import SwiftUI

/// Composition root: the only place that creates clients and the store.
@main struct MyApp: App {
    static let mainWindowID = "main"

    @State private var store: Store
    @State private var navigation = Navigation()
    /// Keeps macOS from throttling (App Nap) the polling while no window is visible.
    private let monitoringActivity: any NSObjectProtocol

    init() {
        let auth = AuthClient.live()
        let client = DevopsClient.live(auth: auth)
        let store = Store(auth: auth, client: client, monitor: .live(client: client), notifications: .live(), snapshots: .live(groupID: SnapshotClient.appGroupID))
        _store = State(initialValue: store)
        monitoringActivity = ProcessInfo.processInfo.beginActivity(
            options: .userInitiatedAllowingIdleSystemSleep, reason: "Monitoring Azure DevOps"
        )
        // Monitoring starts with the app, not with the first window or popup that appears.
        Task { await store.load() }
    }

    var body: some Scene {
        Window("Devops monitor", id: Self.mainWindowID) {
            ContentView()
                .environment(store)
                .environment(navigation)
        }
        .commands {
            CommandGroup(after: .appSettings) {
                Button("Remove Token") { Task { await store.removeToken() } }
                    .disabled(!store.hasToken)
            }
        }

        MenuBarExtra {
            MenuBarContent()
                .environment(store)
                .environment(navigation)
        } label: {
            HStack(spacing: 2) {
                Image(systemName: "arrow.trianglehead.merge")
                if store.badgeCount > 0 { Text("\(store.badgeCount)") }
            }
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView()
                .environment(store)
                .frame(width: 480)
        }
    }
}
