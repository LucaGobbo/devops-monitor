/// A local notification to show.
public struct AppNotification: Sendable, Hashable {
    /// Notifications with the same id replace each other.
    public var id: String
    public var title: String
    public var subtitle: String?
    public var body: String?

    public init(id: String, title: String, subtitle: String? = nil, body: String? = nil) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.body = body
    }
}
