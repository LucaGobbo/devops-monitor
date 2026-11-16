import UserNotifications

/// macOS hides notifications of the frontmost app unless the delegate asks to present them.
final class ForegroundPresenter: NSObject, UNUserNotificationCenterDelegate, Sendable {
    static let shared = ForegroundPresenter()

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .list, .sound]
    }
}
