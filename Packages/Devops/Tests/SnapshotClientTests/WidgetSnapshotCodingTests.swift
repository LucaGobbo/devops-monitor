import Foundation
import Testing

@testable import SnapshotClient

struct WidgetSnapshotCodingTests {
    @Test func aSnapshotSurvivesJSON() throws {
        let snapshot = WidgetSnapshot.preview
        let data = try JSONEncoder().encode(snapshot)
        #expect(try JSONDecoder().decode(WidgetSnapshot.self, from: data) == snapshot)
    }
}
