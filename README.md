<div align="center">

<img src="https://img.shields.io/badge/macOS-13.0%2B-black?style=flat&logo=apple&logoColor=white" alt="macOS 13+"/>
<img src="https://img.shields.io/badge/Swift-5.9-orange?style=flat&logo=swift&logoColor=white" alt="Swift 5.9"/>
<img src="https://img.shields.io/badge/SwiftUI-native-blue?style=flat" alt="SwiftUI"/>
<img src="https://img.shields.io/badge/Powered%20by-Pexels-05A081?style=flat" alt="Powered by Pexels"/>
<img src="https://img.shields.io/badge/dependencies-none-brightgreen?style=flat" alt="No dependencies"/>
<img src="https://img.shields.io/github/v/release/devShakib015/personal_wallpaper_engine_lite?style=flat&label=latest" alt="Latest Release"/>

<br/><br/>

# 🖼 Personal Wallpaper Engine Lite

**A featherweight macOS menubar app that keeps your desktop fresh with stunning wallpapers — powered by the free Pexels API.**

[**⬇ Download Latest DMG**](../../releases/latest) · [Get Free Pexels API Key](https://www.pexels.com/api/) · [Report a Bug](../../issues) · [Request a Feature](../../issues)

</div>

---

## ✨ Features

| Feature | Details |
|---|---|
| 🖥 **Menubar-only** | Lives quietly in the menu bar — no Dock icon, no window clutter |
| 🏷 **6 Built-in Categories** | Nature · City · Minimal · Abstract · Space · Architecture |
| ✏️ **Custom Categories** | Add any keyword you want — *cyberpunk*, *anime*, *forest rain*, anything |
| ⚡ **One-click wallpaper** | Fetch and set a new random wallpaper in seconds |
| 🗂 **Browse grid** | Preview a scrollable grid of photos, click any to set it |
| ⏱ **Auto-change timer** | Automatically change wallpaper every 5 / 10 / 15 / 30 / 60 / 120 minutes |
| ⏳ **Live countdown** | See exactly how long until the next auto-change |
| 🚀 **Launch at login** | Starts automatically when you log in |
| 🔋 **Minimal resources** | No background polling — barely registers in Activity Monitor |
| 📦 **Zero dependencies** | 100% Swift + SwiftUI + AppKit, no third-party packages |
| 🆓 **Completely free** | Powered by Pexels — free API, no credit card, no rate limits for personal use |

---

## 📥 Installation

### Option A — Download DMG (Recommended)

1. Go to [**Releases**](../../releases/latest)
2. Download `PersonalWallpaperEngineLite-x.x.x.dmg`
3. Open the DMG and drag **Personal Wallpaper Engine Lite** to **Applications**

   ```
   ┌──────────────────────────────────────────────┐
   │                                              │
   │   [ 📷 App ]  ──────────►  [ Applications ] │
   │                                              │
   └──────────────────────────────────────────────┘
   ```

4. Launch from **Applications** — a 📷 icon appears in your menu bar
5. Click the icon → **Settings** tab → paste your Pexels API key

> **First-launch Gatekeeper warning?**
> The app is unsigned (no Apple Developer account needed to distribute).
> **Right-click** the app in Finder → **Open** → **Open** — you only need to do this once.

### Option B — Build from source

**Prerequisites:** Xcode 15+, macOS 13+

```bash
# Clone the repository
git clone https://github.com/devShakib015/personal_wallpaper_engine_lite.git
cd personal_wallpaper_engine_lite

# Open in Xcode
open PersonalWallpaperEngineLite/PersonalWallpaperEngineLite.xcodeproj
```

Press `⌘R` to build and run. Or build a local DMG:

```bash
brew install create-dmg
./scripts/build-dmg.sh 1.2.0
# → outputs to ./build/PersonalWallpaperEngineLite-1.2.0.dmg
```

---

## 🔑 Getting Your Free Pexels API Key

Pexels is completely free — no credit card, no paid tiers.

1. Go to [**pexels.com/api**](https://www.pexels.com/api/)
2. Click **"Get Started"** and create a free account
3. Your API key is shown immediately on the dashboard
4. In the app: click the 📷 menu bar icon → **Settings** → paste the key

That's it. You're ready to go.

---

## 🖱 How to Use

### Set a random wallpaper instantly

```
📷 Menu Bar Icon
  └─► Home tab
        ├─ Toggle category chips (built-in or custom)
        └─ Click "Set Random Wallpaper"
```

### Add a custom category

```
📷 Menu Bar Icon
  └─► Home tab
        ├─ Click the [+] button next to "Categories"
        ├─ Type any keyword: "cyberpunk", "anime", "rainy forest"...
        └─ Press Enter or click "Add"
        
  Custom chips appear with an [×] to remove them anytime.
```

### Browse and pick a specific photo

```
📷 Menu Bar Icon
  └─► Browse tab
        ├─ Click [↻] to load a photo grid
        ├─ Click any thumbnail to preview it
        └─ Click "Set as Wallpaper" in the preview
```

### Auto-change on a schedule

```
📷 Menu Bar Icon
  └─► Settings tab
        ├─ Toggle "Enable auto-change" ON
        ├─ Pick an interval: 5 min / 10 / 15 / 30 / 60 / 120
        └─ A countdown timer appears in the Home tab
```

### Launch at login

```
📷 Menu Bar Icon
  └─► Settings tab
        └─ Toggle "Launch at login" ON
```

---

## 🏗 Architecture

```
PersonalWallpaperEngineLite/
├── PersonalWallpaperEngineLiteApp.swift   @main — accessory app (no Dock icon)
├── AppDelegate.swift                      NSStatusItem + NSPopover setup
│
├── Models.swift                           PexelsPhoto, PhotoSrc (Codable)
├── WallpaperCategory.swift                6 built-in categories with SF Symbols
│
├── UnsplashService.swift                  Pexels API client (URLSession only)
│   ├── fetchRandomPhoto([String])         Random photo from active categories
│   ├── fetchPhotos([String])              Paginated search for Browse grid
│   └── downloadImage(urlString)           Download full-res image data
│
├── WallpaperSetter.swift                  NSWorkspace.setDesktopImageURL
│                                          Applies to all connected screens
│
├── WallpaperViewModel.swift               @MainActor ObservableObject
│   ├── selectedCategories                 Built-in preset chips (UserDefaults)
│   ├── customCategories: [String]         User-defined keywords (UserDefaults)
│   ├── activeQueryTerms                   Merged preset + custom for API
│   ├── autoChangeEnabled / Interval       Timer settings (UserDefaults)
│   ├── fetchAndSetRandomWallpaper()       Full fetch → download → set flow
│   ├── resetTimer()                       Native Timer.scheduledTimer
│   └── applyLaunchAtStartup()             SMAppService (macOS 13+)
│
├── MenubarPopoverView.swift               340×460 popover root (3 tabs)
├── HomeTabView.swift                      Quick-set + category chip grid
├── BrowseTabView.swift                    LazyVGrid + full-screen preview sheet
└── SettingsTabView.swift                  API key · timer · login item · quit
```

---

## ⚙️ CI/CD — Automated Releases

Every version tag triggers the [GitHub Actions workflow](.github/workflows/build-release.yml) to:

1. Archive the app with `xcodebuild`
2. Package a polished `.dmg` installer with `create-dmg`
3. Publish a GitHub Release with the DMG attached and auto-generated changelog

### Publish a new release

```bash
git tag v1.3.0
git push origin v1.3.0
```

The workflow handles everything. You can also trigger a manual build from **Actions → Build & Release DMG → Run workflow**.

---

## 🔐 Privacy & Security

- **No telemetry** — the app never phones home
- **Network access** — only to `api.pexels.com` and `images.pexels.com` over HTTPS
- **Local storage** — API key and all preferences stored in `~/Library/Preferences` via `UserDefaults`
- **Temp files** — wallpaper image written to `NSTemporaryDirectory()`, cleaned up by macOS
- **App Sandbox** — disabled, which is required for `NSWorkspace.setDesktopImageURL` to work outside the Mac App Store
- **URL safety** — all query parameters encoded via `URLComponents`, no raw string interpolation

---

## 🛠 Troubleshooting

<details>
<summary><strong>"Pexels API key is missing" on first launch</strong></summary>

Click the 📷 menu bar icon → **Settings** tab → paste your API key from [pexels.com/api](https://www.pexels.com/api/).
</details>

<details>
<summary><strong>macOS says the app is from an unidentified developer</strong></summary>

The DMG is unsigned. To open it:
1. **Right-click** the app in Finder
2. Click **Open**
3. Click **Open** again in the dialog

You only need to do this once.
</details>

<details>
<summary><strong>Wallpaper doesn't change</strong></summary>

- Make sure at least one category chip is active (highlighted in blue)
- Verify your Pexels API key is correct in the Settings tab
- Check your internet connection
</details>

<details>
<summary><strong>"Launch at login" toggle has no effect</strong></summary>

macOS may require manual approval:
**System Settings → General → Login Items** → enable the toggle next to Personal Wallpaper Engine Lite.
</details>

<details>
<summary><strong>Build fails in Xcode: "No account for team"</strong></summary>

In Xcode → Target → **Signing & Capabilities** → set **Team** to your personal Apple ID (free accounts work for local builds).
</details>

---

## 📋 Requirements

| | Minimum |
|---|---|
| macOS | 13.0 Ventura |
| Xcode (to build) | 15.0 |
| Swift | 5.9 |
| Pexels API key | Free — [pexels.com/api](https://www.pexels.com/api/) |

---

## 🗺 Roadmap

- [ ] App icon design
- [ ] Notarized & signed release
- [ ] Favorite / save wallpapers locally
- [ ] Per-monitor wallpaper (different image per screen)
- [ ] Wallpaper history with undo
- [ ] Custom Pexels collection support

---

## 📄 License

MIT License — see [LICENSE](LICENSE) for details.

---

<div align="center">

Made with ♥ using SwiftUI · Powered by <a href="https://www.pexels.com">Pexels</a> · Zero external dependencies · macOS only

[⬆ Back to top](#-personal-wallpaper-engine-lite)

</div>
