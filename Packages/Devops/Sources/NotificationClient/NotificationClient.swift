/// Local notifications, as a struct of closures (protocol witness).
///
/// The real implementation is `NotificationClient.live()` in `NotificationClientLive`.
public struct NotificationClient: Sendable {
    /// Asks the user for permission to show notifications (the system only asks once).
    public var requestAuthorization: @Sendable () async -> Void
    /// Shows a notification right away. Does nothing without permission.
    public var send: @Sendable (_ notification: AppNotification) async -> Void

    public init(
        requestAuthorization: @escaping @Sendable () async -> Void,
        send: @escaping @Sendable (_ notification: AppNotification) async -> Void
    ) {
        self.requestAuthorization = requestAuthorization
        self.send = send
    }
}

extension NotificationClient {
    /// Does nothing; tests replace `send` to record what would be shown.
    public static let testValue = NotificationClient(requestAuthorization: {}, send: { _ in })
    /// Does nothing, so previews never show notifications.
    public static let previewValue = NotificationClient(requestAuthorization: {}, send: { _ in })
}
