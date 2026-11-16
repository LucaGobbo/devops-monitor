import Foundation

public struct Person: Sendable, Hashable, Identifiable {
    public var id: String
    public var displayName: String?

    public init(id: String, displayName: String? = nil) {
        self.id = id
        self.displayName = displayName
    }
}
