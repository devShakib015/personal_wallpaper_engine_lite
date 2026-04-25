import SwiftUI
import AppKit

// MARK: - Preview Panel Controller

private final class PreviewPanelController: NSObject, NSWindowDelegate {
    static let shared = PreviewPanelController()
    private var panel: NSPanel?
    private weak var currentViewModel: WallpaperViewModel?

    func open(photo: PexelsPhoto, viewModel: WallpaperViewModel) {
        panel?.close()
        currentViewModel = viewModel

        let onDismiss = { [weak self, weak viewModel] in
            Task { @MainActor in viewModel?.previewPhoto = nil }
            self?.panel?.close()
            self?.panel = nil
        }
        let content = PhotoPreviewContent(photo: photo, viewModel: viewModel, onDismiss: onDismiss)
        let hosting = NSHostingController(rootView: content)

        let newPanel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 820, height: 580),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        newPanel.title = photo.alt ?? "Photo Preview"
        newPanel.isReleasedWhenClosed = false
        newPanel.minSize = NSSize(width: 500, height: 380)
        newPanel.contentViewController = hosting
        newPanel.delegate = self
        newPanel.center()
        newPanel.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        panel = newPanel
    }

    func close() {
        panel?.close()
        panel = nil
    }

    // Called when user clicks the panel's X button
    func windowWillClose(_ notification: Notification) {
        let vm = currentViewModel
        Task { @MainActor in vm?.previewPhoto = nil }
        panel = nil
        currentViewModel = nil
    }
}

// MARK: - Browse Tab (photo grid + preview)

struct BrowseTabView: View {
    @ObservedObject var viewModel: WallpaperViewModel
    private let columns = [GridItem(.adaptive(minimum: 90), spacing: 4)]

    var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            HStack {
                Text("Browse Wallpapers")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Button(action: { viewModel.loadPhotoGrid() }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.caption)
                }
                .buttonStyle(.plain)
                .disabled(viewModel.isLoading)
            }
            .padding(.horizontal, 12)
            .padding(.top, 8)
            .padding(.bottom, 4)

            Divider()

            if viewModel.photos.isEmpty {
                Spacer()
                VStack(spacing: 8) {
                    Image(systemName: "photo.stack")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text("Tap refresh to load wallpapers")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Button("Load Photos") { viewModel.loadPhotoGrid() }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                }
                Spacer()
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 4) {
                        ForEach(viewModel.photos) { photo in
                            PhotoThumbnailView(photo: photo) {
                                viewModel.previewPhoto = photo
                            }
                        }
                    }
                    .padding(4)
                }
            }
        }
        .onChange(of: viewModel.previewPhoto?.id) { newID in
            if let photo = viewModel.previewPhoto {
                PreviewPanelController.shared.open(photo: photo, viewModel: viewModel)
            } else {
                PreviewPanelController.shared.close()
            }
        }
        .onDisappear {
            PreviewPanelController.shared.close()
            viewModel.previewPhoto = nil
        }
    }
}

// MARK: - Photo Thumbnail

struct PhotoThumbnailView: View {
    let photo: PexelsPhoto
    let onTap: () -> Void
    @State private var image: NSImage? = nil

    var body: some View {
        Button(action: onTap) {
            Group {
                if let img = image {
                    Image(nsImage: img)
                        .resizable()
                        .aspectRatio(16/9, contentMode: .fill)
                } else {
                    Rectangle()
                        .fill(Color.secondary.opacity(0.15))
                        .aspectRatio(16/9, contentMode: .fill)
                        .overlay(ProgressView().scaleEffect(0.5))
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 4))
        }
        .buttonStyle(.plain)
        .onAppear { loadThumb() }
    }

    private func loadThumb() {
        guard image == nil else { return }
        UnsplashService.shared.downloadImage(urlString: photo.src.small) { result in
            if case .success(let data) = result, let img = NSImage(data: data) {
                DispatchQueue.main.async { self.image = img }
            }
        }
    }
}

// MARK: - Photo Preview Content (rendered in floating NSPanel)

struct PhotoPreviewContent: View {
    let photo: PexelsPhoto
    @ObservedObject var viewModel: WallpaperViewModel
    let onDismiss: () -> Void
    @State private var image: NSImage? = nil

    var body: some View {
        VStack(spacing: 12) {
            Group {
                if let img = image {
                    Image(nsImage: img)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.secondary.opacity(0.1))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .overlay(ProgressView())
                }
            }

            // Alt text + clickable Pexels link
            VStack(spacing: 4) {
                if let desc = photo.alt, !desc.isEmpty {
                    Text(desc)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
                if let pageURL = URL(string: photo.url) {
                    Button(action: { NSWorkspace.shared.open(pageURL) }) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.up.right.square")
                                .font(.caption2)
                            Text(photo.url)
                                .font(.caption2)
                                .lineLimit(1)
                                .truncationMode(.middle)
                        }
                        .foregroundColor(.accentColor)
                    }
                    .buttonStyle(.plain)
                    .help("Open on Pexels")
                }
            }

            HStack(spacing: 12) {
                Button("Close") { onDismiss() }
                    .keyboardShortcut(.cancelAction)

                Spacer()

                Text("📷 \(photo.photographer)")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Button(action: {
                    viewModel.setWallpaper(photo: photo)
                    onDismiss()
                }) {
                    HStack(spacing: 6) {
                        if viewModel.isLoading {
                            ProgressView().scaleEffect(0.7).frame(width: 14, height: 14)
                        }
                        Text("Set as Wallpaper")
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isLoading)
            }
        }
        .padding(20)
        .frame(minWidth: 500, minHeight: 380)
        .onAppear { loadPreview() }
    }

    private func loadPreview() {
        UnsplashService.shared.downloadImage(urlString: photo.src.large2x) { result in
            if case .success(let data) = result, let img = NSImage(data: data) {
                DispatchQueue.main.async { self.image = img }
            }
        }
    }
}
