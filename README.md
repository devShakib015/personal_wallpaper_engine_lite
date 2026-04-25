<div align="center">

<img src="https://img.shields.io/badge/macOS-13.0%2B-black?style=flat&logo=apple&logoColor=white" alt="macOS 13+"/>
<img src="https://img.shields.io/badge/Swift-5.9-orange?style=flat&logo=swift&logoColor=white" alt="Swift 5.9"/>
<img src="https://img.shields.io/badge/SwiftUI-native-blue?style=flat" alt="SwiftUI"/>
<img src="https://img.shields.io/badge/dependencies-none-brightgreen?style=flat" alt="No dependencies"/>
<img src="https://img.shields.io/github/v/release/devshakib/personal-wallpaper-engine-lite?style=flat&label=latest" alt="Latest Release"/>

<br/><br/>

# 🖼 Personal Wallpaper Engine Lite

**A featherweight macOS menubar app that keeps your desktop fresh with beautiful wallpapers from Unsplash — automatically.**

[**⬇ Download Latest DMG**](#-installation) · [Get Unsplash API Key](https://unsplash.com/developers) · [Report a Bug](../../issues) · [Request a Feature](../../issues)

</div>

---

## ✨ Features

| Feature | Details |
|---|---|
| 🖥 **Menubar-only** | Lives quietly in the menu bar. No Dock icon, no window clutter |
| 🏷 **6 Categories** | Nature · City · Minimal · Abstract · Space · Architecture |
| ⚡ **One-click wallpaper** | Fetch & set a new random wallpaper in seconds |
| 🗂 **Browse grid** | Preview a full grid of photos — click any to set it |
| ⏱ **Auto-change timer** | Change wallpaper every 5 / 10 / 15 / 30 / 60 / 120 minutes |
| ⏳ **Countdown** | See exactly how long until the next auto-change |
| 🚀 **Launch at login** | Starts automatically when you log in |
| 🔋 **Minimal resources** | No background polling — CPU & RAM barely register |
| 📦 **Zero dependencies** | Pure Swift + SwiftUI + AppKit, no packages needed |

---

## 📥 Installation

### Option A — Download DMG (Recommended)

1. Go to [**Releases**](../../releases/latest)
2. Download `PersonalWallpaperEngineLite-x.x.x.dmg`
3. Open the DMG, drag **Personal Wallpaper Engine Lite** into **Applications**

   ```
   ┌─────────────────────────────────────────────┐
   │                                             │
   │   [📷 App Icon]  ────────►  [Applications] │
   │                                             │
   └─────────────────────────────────────────────┘
   ```

4. Launch from **Applications** — a 📷 icon appears in your menu bar
5. Click the icon → **Settings** tab → paste your Unsplash Access Key

> **First-launch Gatekeeper warning?**
> Because the app is not notarized, macOS may show a security warning.
> **Right-click** the app in Finder → **Open** → **Open** — you only need to do this once.

### Option B — Build from source

**Prerequisites:** Xcode 15+, macOS 13+

```bash
# Clone
git clone https://github.com/YOUR_USERNAME/personal-wallpaper-engine-lite.git
cd personal-wallpaper-engine-lite

# Open in Xcode
open PersonalWallpaperEngineLite/PersonalWallpaperEngineLite.xcodeproj
```

Press `⌘R` to build and run, or build a local DMG:

```bash
# Install create-dmg for a polished installer window
brew install create-dmg

# Build release DMG — outputs to ./build/
./scripts/build-dmg.sh 1.0.0
```

---

## 🔑 Getting Your Free Unsplash API Key

The app fetches wallpapers from [Unsplash](https://unsplash.com) — a free, high-quality photo platform.

1. Go to [**unsplash.com/developers**](https://unsplash.com/developers)
2. Click **"Your apps"** → **"New Application"**
3. Accept the API guidelines
4. Fill in any name/description (e.g. "My Wallpaper App")
5. Copy your **Access Key** (the long string under "Keys")

   > ⚠️ Copy the **Access Key**, not the Secret Key.

6. In the app → click the menu bar icon → **Settings** → paste it in the "Unsplash API Key" field

The free tier allows **50 requests/hour** — more than enough for personal use.

---

## 🖱 How to Use

### Setting a wallpaper

```
Menu Bar Icon (📷)
    └─► Home tab
            ├─ Select categories (tap chips to toggle on/off)
            └─ Click "Set Random Wallpaper"
```

### Browsing and previewing

```
Menu Bar Icon (📷)
    └─► Browse tab
            ├─ Click "↻" to load a grid of photos
            ├─ Click any thumbnail to open a preview
            └─ Click "Set as Wallpaper" in the preview sheet
```

### Auto-change timer

```
Menu Bar Icon (📷)
    └─► Settings tab
            ├─ Toggle "Enable auto-change" ON
            ├─ Pick an interval (5 min → 2 hours)
            └─ Countdown appears in the Home tab status bar
```

### Launch at login

```
Menu Bar Icon (📷)
    └─► Settings tab
            └─ Toggle "Launch at login" ON
```

---

## 🏗 Architecture

```
PersonalWallpaperEngineLite/
├── PersonalWallpaperEngineLiteApp.swift   @main — no Dock entry
├── AppDelegate.swift                      NSStatusItem + NSPopover
│
├── Models.swift                           Codable Unsplash response types
├── WallpaperCategory.swift                Category enum (6 options)
│
├── UnsplashService.swift                  URLSession API client
│   ├── fetchRandomPhoto()                 Single random photo
│   ├── fetchPhotos()                      Paginated search for Browse grid
│   └── downloadImage()                    Raw image data download
│
├── WallpaperSetter.swift                  NSWorkspace.setDesktopImageURL
│                                          Sets all connected screens
│
├── WallpaperViewModel.swift               @MainActor ObservableObject
│   ├── selectedCategories                 Persisted in UserDefaults
│   ├── autoChangeEnabled / Interval       Persisted in UserDefaults
│   ├── fetchAndSetRandomWallpaper()       Fetch → download → set
│   ├── resetTimer()                       Native Timer.scheduledTimer
│   └── applyLaunchAtStartup()             SMAppService (macOS 13+)
│
├── MenubarPopoverView.swift               Root 340×460 popover (3 tabs)
├── HomeTabView.swift                      Quick-set + category chips
├── BrowseTabView.swift                    LazyVGrid + preview sheet
└── SettingsTabView.swift                  API key + timer + login item
```

---

## ⚙️ CI/CD — Automated Releases

Every version tag push triggers GitHub Actions to:

1. Build a Release `.xcarchive` with `xcodebuild`
2. Package a polished `.dmg` with `create-dmg`
3. Create a GitHub Release with the DMG attached and auto-generated release notes

### Publish a new release

```bash
git tag v1.1.0
git push origin v1.1.0
```

The [Build & Release workflow](.github/workflows/build-release.yml) handles everything else automatically.

You can also trigger a manual build from **Actions → Build & Release DMG → Run workflow**.

---

## 🔐 Privacy & Security

- **No telemetry** — the app never phones home
- **Network:** Only to `api.unsplash.com` and `images.unsplash.com` over HTTPS
- **Local storage:** API key and preferences stored only in `~/Library/Preferences` via `UserDefaults`
- **Temp files:** Wallpaper image written to `NSTemporaryDirectory()`, cleaned up by macOS
- **App Sandbox:** Disabled — required for `NSWorkspace.setDesktopImageURL` to function
- **Input safety:** All API parameters are encoded via `URLComponents` — no raw string interpolation in URLs

---

## 🛠 Troubleshooting

<details>
<summary><strong>"No API key" error on first launch</strong></summary>

Go to **Settings tab** and paste your Unsplash Access Key. The app cannot fetch images without it.
</details>

<details>
<summary><strong>macOS says the app is from an unidentified developer</strong></summary>

The release DMG is unsigned. To open it:
1. **Right-click** the app in Finder
2. Click **Open**
3. Click **Open** in the dialog

You only need to do this once.
</details>

<details>
<summary><strong>Wallpaper doesn't change</strong></summary>

- Ensure at least one category chip is active (highlighted blue)
- Verify your API key is correct and has quota remaining (50 req/hour on free tier)
- Check your internet connection
</details>

<details>
<summary><strong>"Launch at login" toggle has no effect</strong></summary>

macOS 13+ may require manual approval:
**System Settings → General → Login Items** → enable the toggle next to Personal Wallpaper Engine Lite.
</details>

<details>
<summary><strong>Build fails: "No account for team"</strong></summary>

In Xcode → Target → **Signing & Capabilities** → set **Team** to your personal Apple ID (free accounts work fine for local builds).
</details>

---

## 📋 Requirements

| | Minimum |
|---|---|
| macOS | 13.0 Ventura |
| Xcode (to build) | 15.0 |
| Swift | 5.9 |
| Unsplash API key | Free tier |

---

## 🗺 Roadmap

- [ ] App icon design
- [ ] Notarized & signed release
- [ ] Favorite / save wallpapers locally
- [ ] Per-monitor wallpaper (different image per screen)
- [ ] Wallpaper history with undo
- [ ] Custom Unsplash collection support

---

## 📄 License

MIT License — see [LICENSE](LICENSE) for details.

---

<div align="center">

Made with ♥ using SwiftUI · Zero external dependencies · macOS only

[⬆ Back to top](#-personal-wallpaper-engine-lite)

</div>
