import Foundation
import SnapshotClient
import WidgetKit

extension SnapshotClient {
    /// Stores the snapshot as JSON in the App Group container, which the app and the widget extension share.
    /// `save` asks WidgetKit to reload the widgets afterwards.
    public static func live(groupID: String) -> SnapshotClient {
        let fileURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupID)?
            .appending(path: "widget-snapshot.json")
        return SnapshotClient(
            save: { snapshot in
                guard let fileURL else { throw SnapshotError.noContainer(groupID) }
                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy = .iso8601
                try encoder.encode(snapshot).write(to: fileURL, options: .atomic)
                WidgetCenter.shared.reloadAllTimelines()
            },
            load: {
                guard let fileURL else { throw SnapshotError.noContainer(groupID) }
                guard let data = try? Data(contentsOf: fileURL) else { return nil }
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                return try decoder.decode(WidgetSnapshot.self, from: data)
            }
        )
    }
}

enum SnapshotError: Error {
    case noContainer(String)
}
