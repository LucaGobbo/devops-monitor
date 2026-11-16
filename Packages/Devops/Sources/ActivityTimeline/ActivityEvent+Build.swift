import DevopsClient
import Foundation

extension ActivityEvent {
    /// An event about a pipeline run.
    init(_ build: Build, _ kind: ActivityKind, organization: String, at date: Date) {
        let name = [build.pipeline, build.number].compactMap(\.self).joined(separator: " ")
        self.init(
            id: "build-\(build.id)-\(kind.rawValue)", date: date, organization: organization, kind: kind,
            itemID: build.id, title: name.isEmpty ? "Run \(build.id)" : name, detail: build.branch,
            project: build.project, url: build.webURL
        )
    }
}
