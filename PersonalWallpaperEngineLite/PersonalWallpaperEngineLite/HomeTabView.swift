import SwiftUI
import AppKit

// MARK: - Home Tab

struct HomeTabView: View {
    @ObservedObject var viewModel: WallpaperViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {

                // Current wallpaper thumbnail
                if let img = viewModel.currentWallpaperThumbnail {
                    Image(nsImage: img)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                        )
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.secondary.opacity(0.1))
                        .frame(height: 120)
                        .overlay(
                            VStack(spacing: 4) {
                                Image(systemName: "photo")
                                    .font(.title)
                                    .foregroundColor(.secondary)
                                Text("No wallpaper set yet")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        )
                }

                // Status
                HStack {
                    Circle()
                        .fill(viewModel.isLoading ? Color.orange : Color.green)
                        .frame(width: 8, height: 8)
                    Text(viewModel.statusMessage)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    if !viewModel.nextChangeIn.isEmpty {
                        Text("Next: \(viewModel.nextChangeIn)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                // Error
                if let err = viewModel.errorMessage {
                    Text(err)
                        .font(.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                // Active categories chips
                VStack(alignment: .leading, spacing: 6) {
                    Text("Active Categories")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 6) {
                        ForEach(WallpaperCategory.allCases) { cat in
                            CategoryChip(
                                category: cat,
                                isSelected: viewModel.selectedCategories.contains(cat),
                                action: {
                                    if viewModel.selectedCategories.contains(cat) {
                                        if viewModel.selectedCategories.count > 1 {
                                            viewModel.selectedCategories.remove(cat)
                                        }
                                    } else {
                                        viewModel.selectedCategories.insert(cat)
                                    }
                                }
                            )
                        }
                    }
                }

                // Fetch now button
                Button(action: { viewModel.fetchAndSetRandomWallpaper() }) {
                    HStack {
                        if viewModel.isLoading {
                            ProgressView()
                                .scaleEffect(0.7)
                                .frame(width: 16, height: 16)
                        } else {
                            Image(systemName: "arrow.clockwise")
                        }
                        Text("Set Random Wallpaper")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isLoading)

                Spacer(minLength: 0)
            }
            .padding(12)
        }
    }
}

// MARK: - Category Chip

struct CategoryChip: View {
    let category: WallpaperCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: category.icon)
                    .font(.caption2)
                Text(category.displayName)
                    .font(.caption)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(isSelected ? Color.accentColor.opacity(0.2) : Color.secondary.opacity(0.1))
            .foregroundColor(isSelected ? .accentColor : .secondary)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
