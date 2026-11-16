import Foundation

/// One page of results plus the token for the next page (`nil` when there are no more).
public struct PageDTO<Item: Sendable & Hashable>: Sendable, Hashable {
    public var items: [Item]
    public var continuationToken: String?

    public init(items: [Item], continuationToken: String? = nil) {
        self.items = items
        self.continuationToken = continuationToken
    }
}
