import Foundation
import AppKit
import Combine
import ServiceManagement

// MARK: - ViewModel

@MainActor
final class WallpaperViewModel: ObservableObject {

    // MARK: Persisted settings
    @Published var selectedCategories: Set<WallpaperCategory> {
        didSet { saveCategories() }
    }
    @Published var customCategories: [String] {
        didSet { saveCustomCategories() }
    }
    @Published var autoChangeEnabled: Bool {
        didSet {
            UserDefaults.standard.set(autoChangeEnabled, forKey: "auto_change_enabled")
            resetTimer()
        }
    }
    @Published var autoChangeInterval: Int {   // minutes
        didSet {
            UserDefaults.standard.set(autoChangeInterval, forKey: "auto_change_interval")
            resetTimer()
        }
    }
    @Published var launchAtStartup: Bool {
        didSet {
            UserDefaults.standard.set(launchAtStartup, forKey: "launch_at_startup")
            applyLaunchAtStartup()
        }
    }
    @Published var apiKey: String {
        didSet {
            UserDefaults.standard.set(apiKey, forKey: "unsplash_access_key")
        }
    }

    // MARK: Runtime state
    @Published var photos: [UnsplashPhoto] = []
    @Published var isLoading: Bool = false
    @Published var statusMessage: String = "Ready"
    @Published var errorMessage: String? = nil
    @Published var previewPhoto: UnsplashPhoto? = nil
    @Published var currentWallpaperThumbnail: NSImage? = nil
    @Published var nextChangeIn: String = ""

    private var timer: Timer?
    private var countdownTimer: Timer?
    private var nextChangeDate: Date?

    // MARK: Init

    init() {
        let cats = WallpaperViewModel.loadCategories()
        self.selectedCategories = cats.isEmpty ? [.nature] : cats
        self.customCategories = WallpaperViewModel.loadCustomCategories()
        self.autoChangeEnabled = UserDefaults.standard.bool(forKey: "auto_change_enabled")
        let interval = UserDefaults.standard.integer(forKey: "auto_change_interval")
        self.autoChangeInterval = interval == 0 ? 30 : interval
        self.launchAtStartup = UserDefaults.standard.bool(forKey: "launch_at_startup")
        self.apiKey = UserDefaults.standard.string(forKey: "unsplash_access_key") ?? ""

        resetTimer()
    }

    // MARK: - Custom category management

    func addCustomCategory(_ term: String) {
        let cleaned = term.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !cleaned.isEmpty, !customCategories.contains(cleaned) else { return }
        customCategories.append(cleaned)
    }

    func removeCustomCategory(_ term: String) {
        customCategories.removeAll { $0 == term }
    }

    // All active query terms (preset + custom) as strings
    var activeQueryTerms: [String] {
        selectedCategories.map(\.rawValue) + customCategories
    }

    // MARK: - Public actions

    func fetchAndSetRandomWallpaper() {
        let terms = activeQueryTerms
        guard !terms.isEmpty else {
            errorMessage = "Select at least one category."
            return
        }
        isLoading = true
        statusMessage = "Fetching wallpaper…"
        errorMessage = nil

        UnsplashService.shared.fetchRandomPhoto(from: terms) { [weak self] result in
            Task { @MainActor [weak self] in
                guard let self else { return }
                switch result {
                case .success(let photo):
                    self.downloadAndSet(photo: photo)
                case .failure(let error):
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                    self.statusMessage = "Error"
                }
            }
        }
    }

    func loadPhotoGrid() {
        let terms = activeQueryTerms
        guard !terms.isEmpty else { return }
        isLoading = true
        UnsplashService.shared.fetchPhotos(from: terms) { [weak self] result in
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.isLoading = false
                switch result {
                case .success(let photos): self.photos = photos
                case .failure(let error):  self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func setWallpaper(photo: UnsplashPhoto) {
        isLoading = true
        statusMessage = "Downloading…"
        UnsplashService.shared.downloadImage(urlString: photo.urls.full) { [weak self] result in
            Task { @MainActor [weak self] in
                guard let self else { return }
                switch result {
                case .success(let data):
                    let ok = WallpaperSetter.set(imageData: data)
                    self.isLoading = false
                    self.statusMessage = ok ? "Wallpaper set!" : "Failed to set wallpaper"
                    if ok, let img = NSImage(data: data) {
                        self.currentWallpaperThumbnail = img
                    }
                case .failure(let error):
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                    self.statusMessage = "Error"
                }
            }
        }
    }

    // MARK: - Timer

    private func resetTimer() {
        timer?.invalidate()
        countdownTimer?.invalidate()
        timer = nil
        countdownTimer = nil
        nextChangeDate = nil
        nextChangeIn = ""

        guard autoChangeEnabled else { return }
        let interval = TimeInterval(autoChangeInterval * 60)
        nextChangeDate = Date().addingTimeInterval(interval)
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.fetchAndSetRandomWallpaper()
                self?.nextChangeDate = Date().addingTimeInterval(interval)
            }
        }
        startCountdown()
    }

    private func startCountdown() {
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self, let next = self.nextChangeDate else { return }
                let remaining = max(0, next.timeIntervalSinceNow)
                let mins = Int(remaining) / 60
                let secs = Int(remaining) % 60
                self.nextChangeIn = String(format: "%02d:%02d", mins, secs)
            }
        }
    }

    // MARK: - Private helpers

    private func downloadAndSet(photo: UnsplashPhoto) {
        UnsplashService.shared.downloadImage(urlString: photo.urls.full) { [weak self] result in
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.isLoading = false
                switch result {
                case .success(let data):
                    let ok = WallpaperSetter.set(imageData: data)
                    self.statusMessage = ok ? "Wallpaper changed!" : "Failed to set wallpaper"
                    if ok, let img = NSImage(data: data) {
                        self.currentWallpaperThumbnail = img
                    }
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.statusMessage = "Error"
                }
            }
        }
    }

    private func applyLaunchAtStartup() {
        if #available(macOS 13.0, *) {
            do {
                if launchAtStartup {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                // Silently handle — user may need to grant permission manually
            }
        }
    }

    // MARK: - Persistence helpers

    private func saveCategories() {
        let raw = selectedCategories.map(\.rawValue)
        UserDefaults.standard.set(raw, forKey: "selected_categories")
    }

    private static func loadCategories() -> Set<WallpaperCategory> {
        guard let raw = UserDefaults.standard.stringArray(forKey: "selected_categories") else {
            return []
        }
        return Set(raw.compactMap { WallpaperCategory(rawValue: $0) })
    }

    private func saveCustomCategories() {
        UserDefaults.standard.set(customCategories, forKey: "custom_categories")
    }

    private static func loadCustomCategories() -> [String] {
        return UserDefaults.standard.stringArray(forKey: "custom_categories") ?? []
    }
}
