import SwiftUI
import AppKit

@main
struct PersonalWallpaperEngineLiteApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // No main window — app lives in the menubar
        Settings {
            EmptyView()
        }
    }
}
