import AppKit

// MARK: - Wallpaper Setter using NSWorkspace

enum WallpaperSetter {

    /// Sets the given image file URL as desktop wallpaper on all connected screens.
    @discardableResult
    static func set(imageData: Data) -> Bool {
        // Write to a temp file
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("wpe_wallpaper.jpg")

        do {
            try imageData.write(to: fileURL, options: .atomic)
        } catch {
            return false
        }

        return set(fileURL: fileURL)
    }

    @discardableResult
    static func set(fileURL: URL) -> Bool {
        let workspace = NSWorkspace.shared
        let screens = NSScreen.screens
        var success = true
        for screen in screens {
            do {
                try workspace.setDesktopImageURL(
                    fileURL,
                    for: screen,
                    options: [.imageScaling: NSImageScaling.scaleProportionallyUpOrDown.rawValue,
                              .allowClipping: true]
                )
            } catch {
                success = false
            }
        }
        return success
    }
}
