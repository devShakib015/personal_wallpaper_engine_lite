import SwiftUI
import AppKit

// MARK: - Home Tab

struct HomeTabView: View {
    @ObservedObject var viewModel: WallpaperViewModel
    @State private var newCategoryText: String = ""
    @State private var showAddField: Bool = false
    @FocusState private var addFieldFocused: Bool

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

                // Categories section
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Categories")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Button(action: {
                            showAddField.toggle()
                            if showAddField { addFieldFocused = true }
                            else { newCategoryText = "" }
                        }) {
                            Image(systemName: showAddField ? "xmark.circle.fill" : "plus.circle.fill")
                                .font(.caption)
                                .foregroundColor(showAddField ? .secondary : .accentColor)
                        }
                        .buttonStyle(.plain)
                        .help(showAddField ? "Cancel" : "Add custom category")
                    }

                    // Preset chips
                    FlowLayout(spacing: 6) {
                        ForEach(WallpaperCategory.allCases) { cat in
                            CategoryChip(
                                label: cat.displayName,
                                icon: cat.icon,
                                isSelected: viewModel.selectedCategories.contains(cat),
                                isCustom: false,
                                action: {
                                    if viewModel.selectedCategories.contains(cat) {
                                        if viewModel.activeQueryTerms.count > 1 {
                                            viewModel.selectedCategories.remove(cat)
                                        }
                                    } else {
                                        viewModel.selectedCategories.insert(cat)
                                    }
                                },
                                onDelete: nil
                            )
                        }

                        // Custom chips
                        ForEach(viewModel.customCategories, id: \.self) { term in
                            CategoryChip(
                                label: term.capitalized,
                                icon: "tag",
                                isSelected: true,
                                isCustom: true,
                                action: { viewModel.removeCustomCategory(term) },
                                onDelete: { viewModel.removeCustomCategory(term) }
                            )
                        }
                    }

                    // Inline add field
                    if showAddField {
                        HStack(spacing: 6) {
                            TextField("e.g. cyberpunk, forest, anime…", text: $newCategoryText)
                                .textFieldStyle(.roundedBorder)
                                .font(.caption)
                                .focused($addFieldFocused)
                                .onSubmit { submitCustomCategory() }
                            Button("Add") { submitCustomCategory() }
                                .buttonStyle(.borderedProminent)
                                .controlSize(.small)
                                .disabled(newCategoryText.trimmingCharacters(in: .whitespaces).isEmpty)
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

    private func submitCustomCategory() {
        viewModel.addCustomCategory(newCategoryText)
        newCategoryText = ""
        showAddField = false
        addFieldFocused = false
    }
}

// MARK: - Flow Layout (wraps chips like text)

struct FlowLayout: Layout {
    var spacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        return CGSize(width: maxWidth, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

// MARK: - Category Chip

struct CategoryChip: View {
    let label: String
    let icon: String
    let isSelected: Bool
    let isCustom: Bool
    let action: () -> Void
    let onDelete: (() -> Void)?

    var body: some View {
        Button(action: isCustom ? {} : action) {
            HStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.caption2)
                Text(label)
                    .font(.caption)
                if let onDelete {
                    Button(action: onDelete) {
                        Image(systemName: "xmark")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                    .padding(.leading, 1)
                }
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
