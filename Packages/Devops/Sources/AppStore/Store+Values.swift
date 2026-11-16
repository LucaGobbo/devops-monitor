import AuthClient
import DevopsClient
import Foundation
import MonitorClient
import NotificationClient
import SnapshotClient

extension Store {
    /// Sample data for SwiftUI previews; call `load()` (e.g. in `.task`) to fill it.
    public static var previewValue: Store {
        let defaults = UserDefaults(suiteName: "preview") ?? .standard
        defaults.set("fabrikam", forKey: "organization")
        return Store(
            auth: .previewValue, client: .previewValue, monitor: .previewValue, notifications: .previewValue,
            snapshots: .previewValue,
            defaults: defaults
        )
    }
}
