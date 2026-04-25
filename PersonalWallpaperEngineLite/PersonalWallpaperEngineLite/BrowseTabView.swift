import SwiftUI
import AppKit

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
        .sheet(item: $viewModel.previewPhoto) { photo in
            PhotoPreviewSheet(photo: photo, viewModel: viewModel)
        }
    }
}

// MARK: - Photo Thumbnail

struct PhotoThumbnailView: View {
    let photo: UnsplashPhoto
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
        UnsplashService.shared.downloadImage(urlString: photo.urls.small) { result in
            if case .success(let data) = result, let img = NSImage(data: data) {
                DispatchQueue.main.async { self.image = img }
            }
        }
    }
}

// MARK: - Preview Sheet

struct PhotoPreviewSheet: View {
    let photo: UnsplashPhoto
    @ObservedObject var viewModel: WallpaperViewModel
    @Environment(\.dismiss) var dismiss
    @State private var image: NSImage? = nil
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 12) {
            // Image
            Group {
                if let img = image {
                    Image(nsImage: img)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: 280)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.secondary.opacity(0.1))
                        .frame(height: 200)
                        .overlay(ProgressView())
                }
            }

            if let desc = photo.altDescription ?? photo.description {
                Text(desc)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }

            HStack(spacing: 12) {
                Button("Cancel") { dismiss() }
                    .keyboardShortcut(.cancelAction)

                Button(action: {
                    viewModel.setWallpaper(photo: photo)
                    dismiss()
                }) {
                    HStack {
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
        .padding(16)
        .frame(minWidth: 360)
        .onAppear { loadPreview() }
    }

    private func loadPreview() {
        UnsplashService.shared.downloadImage(urlString: photo.urls.regular) { result in
            if case .success(let data) = result, let img = NSImage(data: data) {
                DispatchQueue.main.async { self.image = img }
            }
        }
    }
}
