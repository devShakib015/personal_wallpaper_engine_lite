import SwiftUI

// MARK: - Menubar Popover Root View

struct MenubarPopoverView: View {
    @ObservedObject var viewModel: WallpaperViewModel
    @State private var selectedTab: Tab = .home

    enum Tab { case home, browse, settings }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView

            Divider()

            // Tab content
            Group {
                switch selectedTab {
                case .home:     HomeTabView(viewModel: viewModel)
                case .browse:   BrowseTabView(viewModel: viewModel)
                case .settings: SettingsTabView(viewModel: viewModel)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Divider()

            // Bottom tab bar
            tabBar
        }
        .frame(width: 340, height: 460)
        .background(Color(NSColor.windowBackgroundColor))
    }

    // MARK: - Header

    private var headerView: some View {
        HStack {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.title3)
                .foregroundColor(.accentColor)
            Text("Wallpaper Engine Lite")
                .font(.headline)
            Spacer()
            Button(action: { NSApp.terminate(nil) }) {
                Image(systemName: "power")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            .help("Quit")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    // MARK: - Tab Bar

    private var tabBar: some View {
        HStack {
            tabButton("Home", icon: "house", tab: .home)
            tabButton("Browse", icon: "photo.stack", tab: .browse)
            tabButton("Settings", icon: "gearshape", tab: .settings)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
    }

    private func tabButton(_ title: String, icon: String, tab: Tab) -> some View {
        Button(action: { selectedTab = tab }) {
            VStack(spacing: 2) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                Text(title)
                    .font(.caption2)
            }
            .frame(maxWidth: .infinity)
            .foregroundColor(selectedTab == tab ? .accentColor : .secondary)
        }
        .buttonStyle(.plain)
    }
}
