#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# build-dmg.sh
# Local build + DMG packaging script for Personal Wallpaper Engine Lite
# Usage: ./scripts/build-dmg.sh [version]
# Example: ./scripts/build-dmg.sh 1.0.0
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

# ── Config ────────────────────────────────────────────────────────────────────
APP_NAME="PersonalWallpaperEngineLite"
BUNDLE_ID="com.devshakib.PersonalWallpaperEngineLite"
PROJECT_PATH="PersonalWallpaperEngineLite/PersonalWallpaperEngineLite.xcodeproj"
SCHEME="PersonalWallpaperEngineLite"
VERSION="${1:-1.0.0}"
BUILD_DIR="$(pwd)/build"
ARCHIVE_PATH="${BUILD_DIR}/${APP_NAME}.xcarchive"
EXPORT_PATH="${BUILD_DIR}/export"
DMG_NAME="${APP_NAME}-${VERSION}.dmg"
DMG_PATH="${BUILD_DIR}/${DMG_NAME}"

# ── Colors ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
info()    { echo -e "${CYAN}▶ $*${NC}"; }
success() { echo -e "${GREEN}✓ $*${NC}"; }
warn()    { echo -e "${YELLOW}⚠ $*${NC}"; }
error()   { echo -e "${RED}✗ $*${NC}"; exit 1; }

# ── Prerequisites ─────────────────────────────────────────────────────────────
command -v xcodebuild >/dev/null 2>&1 || error "Xcode Command Line Tools not found. Run: xcode-select --install"

info "Building Personal Wallpaper Engine Lite v${VERSION}"
echo ""

# ── Clean build dir ───────────────────────────────────────────────────────────
info "Cleaning previous build artifacts…"
rm -rf "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}" "${EXPORT_PATH}"

# ── Archive ───────────────────────────────────────────────────────────────────
info "Archiving with xcodebuild…"
xcodebuild archive \
  -project "${PROJECT_PATH}" \
  -scheme "${SCHEME}" \
  -configuration Release \
  -archivePath "${ARCHIVE_PATH}" \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO \
  MARKETING_VERSION="${VERSION}" \
  | grep -E "^(error:|warning:|Build succeeded|** ARCHIVE)" || true

# Verify archive was created
[[ -d "${ARCHIVE_PATH}" ]] || error "Archive failed — ${ARCHIVE_PATH} not found."
success "Archive created at ${ARCHIVE_PATH}"

# ── Export .app ───────────────────────────────────────────────────────────────
info "Exporting .app from archive…"
cp -R "${ARCHIVE_PATH}/Products/Applications/${APP_NAME}.app" "${EXPORT_PATH}/"
[[ -d "${EXPORT_PATH}/${APP_NAME}.app" ]] || error ".app not found after export."
success ".app exported to ${EXPORT_PATH}/${APP_NAME}.app"

# ── Create DMG ────────────────────────────────────────────────────────────────
info "Creating DMG…"

if command -v create-dmg >/dev/null 2>&1; then
  ICON_PATH="${EXPORT_PATH}/${APP_NAME}.app/Contents/Resources/AppIcon.icns"
  DMG_ARGS=(
    --volname "Personal Wallpaper Engine Lite"
    --window-pos 200 120
    --window-size 600 400
    --icon-size 100
    --icon "${APP_NAME}.app" 170 190
    --hide-extension "${APP_NAME}.app"
    --app-drop-link 430 190
    --no-internet-enable
  )
  if [[ -f "${ICON_PATH}" ]]; then
    DMG_ARGS+=(--volicon "${ICON_PATH}")
  fi
  create-dmg "${DMG_ARGS[@]}" "${DMG_PATH}" "${EXPORT_PATH}/" || {
    warn "create-dmg failed with icon, retrying without volicon…"
    create-dmg \
      --volname "Personal Wallpaper Engine Lite" \
      --window-pos 200 120 \
      --window-size 600 400 \
      --icon-size 100 \
      --icon "${APP_NAME}.app" 170 190 \
      --hide-extension "${APP_NAME}.app" \
      --app-drop-link 430 190 \
      --no-internet-enable \
      "${DMG_PATH}" "${EXPORT_PATH}/"
  }
else
  warn "create-dmg not found — falling back to hdiutil (no drag-to-Applications window)"
  warn "Install create-dmg for a better DMG:  brew install create-dmg"
  TEMP_DMG="${BUILD_DIR}/temp.dmg"
  hdiutil create -volname "Personal Wallpaper Engine Lite" \
    -srcfolder "${EXPORT_PATH}" \
    -ov -format UDZO \
    "${TEMP_DMG}"
  mv "${TEMP_DMG}" "${DMG_PATH}"
fi

[[ -f "${DMG_PATH}" ]] || error "DMG creation failed."
DMG_SIZE=$(du -sh "${DMG_PATH}" | cut -f1)
success "DMG created: ${DMG_PATH} (${DMG_SIZE})"

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}────────────────────────────────────────────────────────${NC}"
echo -e "${GREEN}  Build complete!${NC}"
echo -e "${GREEN}────────────────────────────────────────────────────────${NC}"
echo -e "  Version : ${VERSION}"
echo -e "  DMG     : ${DMG_PATH}"
echo -e "  Size    : ${DMG_SIZE}"
echo ""
echo -e "  To install: open ${DMG_PATH}"
echo -e "${GREEN}────────────────────────────────────────────────────────${NC}"
