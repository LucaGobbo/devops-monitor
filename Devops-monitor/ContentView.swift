import ActivityFeature
import AppKit
import AppStore
import DashboardFeature
import PipelinesFeature
import ProfileFeature
import PullRequestsFeature
import SettingsFeature
import SwiftUI

enum Page: Hashable, Identifiable {
    var id: Self { self }
    case dashboard
    case pipelines
    case pullRequests
    case activity
    case profile
    case settings
}

struct ContentView: View {
    @Environment(Navigation.self) var navigation
    @Environment(Store.self) var store

    var body: some View {
        @Bindable var navigation = navigation
        NavigationSplitView {

            List(selection: $navigation.selection) {



                if store.hasToken {

                    Section {
                        Label("Dashboard", systemImage: "gauge.with.dots.needle.50percent")
                            .id(Page.dashboard)
                        Label("Pipelines", systemImage: "airplane.departure")
                            .badge(store.openPipelinesCount)
                            .id(Page.pipelines)
                        Label("Pull requests", systemImage: "arrow.trianglehead.merge")
                            .badge(store.openPullRequestsCount)
                            .id(Page.pullRequests)
                        Label("Activity", systemImage: "clock.arrow.circlepath")
                            .id(Page.activity)
                    } header: {
                        Text("Work")
                    }
                }

                Section {
                    if let profile = store.profile {
                        ProfileLabel(person: profile)
                            .id(Page.profile)
                    }
                    Label("Settings", systemImage: "gear")
                        .id(Page.settings)
                } header: {
                    Text("Devops monitor")
                } footer: {
                    VersionView()
                }

            }

            .listStyle(.sidebar)

        } detail: {
            switch navigation.selection {
            case .dashboard:
                DashboardView { destination in
                    navigation.selection = switch destination {
                    case .pipelines: .pipelines
                    case .pullRequests: .pullRequests
                    case .activity: .activity
                    }
                }
            case .pipelines:
                PipelinesView()
            case .pullRequests:
                PullRequestsView()
            case .activity:
                ActivityView()
            case .profile:
                ProfileView()
            case .settings:
                SettingsView()
            case nil:
                ContentUnavailableView("Nothing selected", systemImage: "questionmark.text.page")
            }

        }
        .onChange(of: store.badgeCount, initial: true) { _, count in
            NSApp.dockTile.badgeLabel = count > 0 ? "\(count)" : nil
        }
    }
}

#Preview {
    ContentView()
        .environment(Store.previewValue)
        .environment(Navigation())
}
