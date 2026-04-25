import SwiftUI
import AppKit

@main
struct PersonalWallpaperEngineLiteApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // Menubar-only app — no windows. Using a hidden WindowGroup with
        // handlesExternalEvents to satisfy SwiftUI's requirement for at least
        // one scene, while preventing any window from ever appearing.
        WindowGroup {
            EmptyView().frame(width: 0, height: 0)
        }
        .defaultSize(width: 0, height: 0)
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .commandsRemoved()
    }
}
