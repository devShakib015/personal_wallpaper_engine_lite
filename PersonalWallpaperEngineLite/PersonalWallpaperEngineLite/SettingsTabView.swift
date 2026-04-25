import SwiftUI

// MARK: - Settings Tab

struct SettingsTabView: View {
    @ObservedObject var viewModel: WallpaperViewModel

    private let intervalOptions = [5, 10, 15, 30, 60, 120]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                // API Key
                settingSection(title: "Pexels API Key") {
                    VStack(alignment: .leading, spacing: 4) {
                        SecureField("Paste your API Key here", text: $viewModel.apiKey)
                            .textFieldStyle(.roundedBorder)
                            .font(.caption)
                        Text("Get a free key at pexels.com/api — it's completely free")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }

                Divider()

                // Auto-change
                settingSection(title: "Auto-Change Wallpaper") {
                    VStack(alignment: .leading, spacing: 8) {
                        Toggle("Enable auto-change", isOn: $viewModel.autoChangeEnabled)
                            .font(.callout)

                        if viewModel.autoChangeEnabled {
                            HStack {
                                Text("Change every")
                                    .font(.callout)
                                Picker("", selection: $viewModel.autoChangeInterval) {
                                    ForEach(intervalOptions, id: \.self) { mins in
                                        Text(minuteLabel(mins)).tag(mins)
                                    }
                                }
                                .labelsHidden()
                                .frame(width: 110)
                            }

                            if !viewModel.nextChangeIn.isEmpty {
                                HStack {
                                    Image(systemName: "timer")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("Next change in \(viewModel.nextChangeIn)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }

                Divider()

                // Startup
                settingSection(title: "System") {
                    Toggle("Launch at login", isOn: $viewModel.launchAtStartup)
                        .font(.callout)
                }

                Divider()

                // Quit
                settingSection(title: "App") {
                    Button(role: .destructive, action: { NSApp.terminate(nil) }) {
                        Label("Quit Wallpaper Engine", systemImage: "power")
                            .font(.callout)
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.red)
                }

                Spacer(minLength: 0)
            }
            .padding(12)
        }
    }

    // MARK: - Helpers

    @ViewBuilder
    private func settingSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
            content()
        }
    }

    private func minuteLabel(_ mins: Int) -> String {
        if mins < 60 {
            return "\(mins) min"
        } else {
            let h = mins / 60
            return h == 1 ? "1 hour" : "\(h) hours"
        }
    }
}
