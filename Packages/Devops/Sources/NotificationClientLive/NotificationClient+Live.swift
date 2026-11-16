import NotificationClient
import UserNotifications

extension NotificationClient {
    /// Shows notifications through `UNUserNotificationCenter`, also while the app is in the foreground.
    public static func live() -> NotificationClient {
        NotificationClient(
            requestAuthorization: {
                let center = UNUserNotificationCenter.current()
                center.delegate = ForegroundPresenter.shared
                _ = try? await center.requestAuthorization(options: [.alert, .sound])
            },
            send: { notification in
                let content = UNMutableNotificationContent()
                content.title = notification.title
                if let subtitle = notification.subtitle { content.subtitle = subtitle }
                if let body = notification.body { content.body = body }
                content.sound = .default
                let request = UNNotificationRequest(identifier: notification.id, content: content, trigger: nil)
                try? await UNUserNotificationCenter.current().add(request)
            }
        )
    }
}
