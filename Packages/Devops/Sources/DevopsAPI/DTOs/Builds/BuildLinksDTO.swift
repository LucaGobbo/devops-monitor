import Foundation

/// The subset of a build's `_links` that is useful to an app (`web` opens the run in the browser).
public struct BuildLinksDTO: Codable, Sendable, Hashable {
    public var web: LinkDTO?
    public var selfLink: LinkDTO?

    public init(web: LinkDTO? = nil, selfLink: LinkDTO? = nil) {
        self.web = web
        self.selfLink = selfLink
    }

    private enum CodingKeys: String, CodingKey {
        case web
        case selfLink = "self"
    }
}
