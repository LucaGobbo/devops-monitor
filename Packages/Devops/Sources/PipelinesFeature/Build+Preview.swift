import DevopsClient
import Foundation

extension Build {
    /// Sample builds for this module's previews.
    static let previewBuilds: [Build] = [
        Build(
            id: 5, number: "20241101.1", state: .inProgress, pipeline: "CI", project: "Fabrikam", branch: "feature/new",
            requestedBy: Person(id: "1", displayName: "Normal Paulk"), queuedAt: .now.addingTimeInterval(-400),
            startedAt: .now.addingTimeInterval(-300), webURL: URL(string: "https://dev.azure.com/fabrikam")
        ),
        Build(
            id: 4, number: "20241101.0", state: .notStarted, pipeline: "Release", project: "Fabrikam", branch: "main",
            queuedAt: .now.addingTimeInterval(-60)
        ),
    ]
}
