// swift-tools-version: 6.4

import PackageDescription

let approachableConcurrency: [SwiftSetting] = [.enableUpcomingFeature("ApproachableConcurrency")]

let package = Package(
    name: "Devops",
    platforms: [.macOS(.v26)],
    products: [
        .library(name: "DevopsAPI", targets: ["DevopsAPI"]),
        .library(name: "DevopsClient", targets: ["DevopsClient"]),
        .library(name: "DevopsClientLive", targets: ["DevopsClientLive"]),
        .library(name: "AuthClient", targets: ["AuthClient"]),
        .library(name: "AuthClientLive", targets: ["AuthClientLive"]),
        .library(name: "AppStore", targets: ["AppStore"]),
        .library(name: "MonitorClient", targets: ["MonitorClient"]),
        .library(name: "MonitorClientLive", targets: ["MonitorClientLive"]),
        .library(name: "ActivityTimeline", targets: ["ActivityTimeline"]),
        .library(name: "ActivityFeature", targets: ["ActivityFeature"]),
        .library(name: "DashboardSummary", targets: ["DashboardSummary"]),
        .library(name: "DashboardFeature", targets: ["DashboardFeature"]),
        .library(name: "SnapshotClient", targets: ["SnapshotClient"]),
        .library(name: "SnapshotClientLive", targets: ["SnapshotClientLive"]),
        .library(name: "WidgetFeature", targets: ["WidgetFeature"]),
        .library(name: "NotificationClient", targets: ["NotificationClient"]),
        .library(name: "NotificationClientLive", targets: ["NotificationClientLive"]),
        .library(name: "MenuBarFeature", targets: ["MenuBarFeature"]),
        .library(name: "ProfileFeature", targets: ["ProfileFeature"]),
        .library(name: "SettingsFeature", targets: ["SettingsFeature"]),
        .library(name: "PipelinesFeature", targets: ["PipelinesFeature"]),
        .library(name: "PullRequestsFeature", targets: ["PullRequestsFeature"]),
    ],
    targets: [
        // The Azure DevOps REST API: DTOs, request building, transport, middleware, decoding.
        .target(name: "DevopsAPI", swiftSettings: approachableConcurrency),
        // Interface for the app: domain models and `DevopsClient` (struct of closures). Knows nothing about DTOs.
        .target(name: "DevopsClient", swiftSettings: approachableConcurrency),
        // Implements `DevopsClient` on top of `DevopsAPI`: DTO -> domain mapping.
        .target(name: "DevopsClientLive", dependencies: ["DevopsAPI", "DevopsClient"], swiftSettings: approachableConcurrency),
        // Interface for the stored personal access token.
        .target(name: "AuthClient", swiftSettings: approachableConcurrency),
        // Keychain-backed `AuthClient`.
        .target(name: "AuthClientLive", dependencies: ["AuthClient"], swiftSettings: approachableConcurrency),
        // The activity timeline derived from what the server holds: event values and the pure derivation.
        .target(name: "ActivityTimeline", dependencies: ["DevopsClient"], swiftSettings: approachableConcurrency),
        // What the dashboard shows (counts, recent runs, what needs attention), derived purely from data the app holds.
        .target(name: "DashboardSummary", dependencies: ["ActivityTimeline", "DevopsClient"], swiftSettings: approachableConcurrency),
        // Interface for polling Azure DevOps and reporting what changed (`AsyncStream` of events), plus the pure diffing.
        .target(name: "MonitorClient", dependencies: ["DevopsClient"], swiftSettings: approachableConcurrency),
        // Polls through a `DevopsClient`, remembers the baseline and resolves how finished items ended.
        .target(name: "MonitorClientLive", dependencies: ["DevopsClient", "MonitorClient"], swiftSettings: approachableConcurrency),
        // Interface for handing the latest open pull requests and pipelines to the widgets.
        .target(name: "SnapshotClient", swiftSettings: approachableConcurrency),
        // App Group file implementation; reloads the widgets after each save.
        .target(name: "SnapshotClientLive", dependencies: ["SnapshotClient"], swiftSettings: approachableConcurrency),
        // Views of the pull-request and pipeline widgets.
        .target(name: "WidgetFeature", dependencies: ["SnapshotClient"], swiftSettings: approachableConcurrency),
        // Interface for local notifications.
        .target(name: "NotificationClient", swiftSettings: approachableConcurrency),
        // `UNUserNotificationCenter`-backed `NotificationClient`.
        .target(name: "NotificationClientLive", dependencies: ["NotificationClient"], swiftSettings: approachableConcurrency),
        // All app state (token, organization, profile, pipelines, pull requests) and `refresh()`. Sits above the features.
        .target(name: "AppStore", dependencies: ["ActivityTimeline", "AuthClient", "DashboardSummary", "DevopsClient", "MonitorClient", "NotificationClient", "SnapshotClient"], swiftSettings: approachableConcurrency),
        // Features depend on `AppStore` and interface modules only; the app is the composition root.
        .target(name: "ActivityFeature", dependencies: ["ActivityTimeline", "AppStore"], swiftSettings: approachableConcurrency),
        .target(name: "DashboardFeature", dependencies: ["ActivityTimeline", "AppStore", "DashboardSummary", "DevopsClient"], swiftSettings: approachableConcurrency),
        .target(name: "MenuBarFeature", dependencies: ["AppStore", "DevopsClient"], swiftSettings: approachableConcurrency),
        .target(name: "ProfileFeature", dependencies: ["AppStore", "DevopsClient"], swiftSettings: approachableConcurrency),
        .target(name: "SettingsFeature", dependencies: ["AppStore"], swiftSettings: approachableConcurrency),
        .target(name: "PipelinesFeature", dependencies: ["AppStore", "DevopsClient"], swiftSettings: approachableConcurrency),
        .target(name: "PullRequestsFeature", dependencies: ["AppStore"], swiftSettings: approachableConcurrency),
        .testTarget(name: "AppStoreTests", dependencies: ["ActivityTimeline", "AppStore", "AuthClient", "DevopsClient", "MonitorClient", "NotificationClient", "SnapshotClient"], swiftSettings: approachableConcurrency),
        .testTarget(name: "DashboardSummaryTests", dependencies: ["DashboardSummary", "ActivityTimeline", "DevopsClient"], swiftSettings: approachableConcurrency),
        .testTarget(name: "SnapshotClientTests", dependencies: ["SnapshotClient"], swiftSettings: approachableConcurrency),
        .testTarget(name: "MonitorClientTests", dependencies: ["MonitorClient", "MonitorClientLive", "DevopsClient"], swiftSettings: approachableConcurrency),
        .testTarget(name: "ActivityTimelineTests", dependencies: ["ActivityTimeline", "DevopsClient"], swiftSettings: approachableConcurrency),
        .testTarget(name: "DevopsClientTests", dependencies: ["DevopsClient"], swiftSettings: approachableConcurrency),
        .testTarget(name: "DevopsClientLiveTests", dependencies: ["DevopsClientLive", "DevopsAPI", "DevopsClient"], swiftSettings: approachableConcurrency),
        .testTarget(name: "DevopsAPITests", dependencies: ["DevopsAPI"], swiftSettings: approachableConcurrency),
    ]
)
