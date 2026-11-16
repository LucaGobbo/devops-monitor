import Foundation

/// The completion options sent when setting auto-complete.
public struct CompletionOptionsDTO: Codable, Sendable, Hashable {
    public var mergeStrategy: MergeStrategyDTO

    public init(mergeStrategy: MergeStrategyDTO) {
        self.mergeStrategy = mergeStrategy
    }
}
