import Observation

/// Which page the main window shows; shared so the menu bar can drive it.
@MainActor @Observable
final class Navigation {
    var selection: Page? = .dashboard
}
