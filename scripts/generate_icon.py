#!/usr/bin/env python3
"""Generate app icon for Personal Wallpaper Engine Lite."""

import math
import os
from PIL import Image, ImageDraw, ImageFilter

SIZE = 1024
OUT_DIR = os.path.join(
    os.path.dirname(__file__),
    "../PersonalWallpaperEngineLite/PersonalWallpaperEngineLite/Assets.xcassets/AppIcon.appiconset"
)

# ── Helpers ────────────────────────────────────────────────────────────────────

def lerp_color(c1, c2, t):
    return tuple(int(c1[i] + (c2[i] - c1[i]) * t) for i in range(3))

def add_rounded_mask(img, radius):
    """Apply macOS-style rounded rectangle mask (alpha)."""
    mask = Image.new("L", img.size, 0)
    d = ImageDraw.Draw(mask)
    d.rounded_rectangle([0, 0, img.width, img.height], radius=radius, fill=255)
    img.putalpha(mask)
    return img

# ── Canvas ─────────────────────────────────────────────────────────────────────

img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
draw = ImageDraw.Draw(img)

# Gradient background: deep indigo → rich navy-purple
TOP_COL    = (18, 22, 56)     # deep indigo
MID_COL    = (30, 20, 80)     # rich purple
BOTTOM_COL = (12, 40, 90)     # navy teal

for y in range(SIZE):
    t = y / SIZE
    if t < 0.5:
        col = lerp_color(TOP_COL, MID_COL, t * 2)
    else:
        col = lerp_color(MID_COL, BOTTOM_COL, (t - 0.5) * 2)
    draw.line([(0, y), (SIZE, y)], fill=col + (255,))

# ── Soft glow at the horizon ───────────────────────────────────────────────────
glow_layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
gd = ImageDraw.Draw(glow_layer)

HORIZON = int(SIZE * 0.62)
glow_cx = SIZE // 2
glow_w = int(SIZE * 0.7)
glow_h = int(SIZE * 0.18)

for step in range(40, 0, -1):
    alpha = int(18 * (step / 40))
    r = int(glow_w * step / 40)
    h = int(glow_h * step / 40)
    gd.ellipse(
        [glow_cx - r, HORIZON - h, glow_cx + r, HORIZON + h],
        fill=(120, 160, 255, alpha)
    )

glow_layer = glow_layer.filter(ImageFilter.GaussianBlur(radius=18))
img = Image.alpha_composite(img, glow_layer)
draw = ImageDraw.Draw(img)

# ── Stars ──────────────────────────────────────────────────────────────────────
import random
random.seed(42)
for _ in range(130):
    sx = random.randint(20, SIZE - 20)
    sy = random.randint(20, int(SIZE * 0.52))
    sr = random.choice([1, 1, 1, 2])
    sa = random.randint(100, 220)
    draw.ellipse([sx - sr, sy - sr, sx + sr, sy + sr], fill=(255, 255, 255, sa))

# ── Mountain layers ────────────────────────────────────────────────────────────
def mountain_row(draw, peaks, base_y, col):
    """Draw a mountain silhouette as a filled polygon."""
    pts = [(0, SIZE)]
    for i in range(len(peaks) - 1):
        x1, y1 = peaks[i]
        x2, y2 = peaks[i + 1]
        steps = 6
        for s in range(steps + 1):
            t = s / steps
            mx = x1 + (x2 - x1) * t
            # cosine interpolation for natural peaks
            ct = (1 - math.cos(t * math.pi)) / 2
            my = y1 + (y2 - y1) * ct
            pts.append((int(mx), int(my)))
    pts.append((SIZE, SIZE))
    draw.polygon(pts, fill=col)

# Back mountains (lighter, more distant)
back_peaks = [
    (0, 700), (90, 560), (200, 490), (340, 540), (430, 460),
    (520, 510), (610, 450), (720, 520), (830, 470), (940, 530), (1024, 600)
]
mountain_row(draw, back_peaks, HORIZON, (22, 35, 85, 255))

# Mid mountains
mid_peaks = [
    (0, 780), (60, 640), (160, 570), (280, 620), (380, 540),
    (480, 590), (580, 530), (680, 600), (800, 540), (900, 600), (1024, 680)
]
mountain_row(draw, mid_peaks, HORIZON, (16, 28, 70, 255))

# Front mountains (darkest)
front_peaks = [
    (0, SIZE), (0, 820), (100, 740), (200, 800), (300, 720),
    (420, 770), (520, 700), (640, 760), (760, 690), (880, 750), (1024, 800), (1024, SIZE)
]
draw.polygon(front_peaks, fill=(10, 18, 50, 255))

# ── Photo frame card ───────────────────────────────────────────────────────────
# Floating white card representing a photo/wallpaper
CX, CY = SIZE // 2, int(SIZE * 0.40)
CW, CH = int(SIZE * 0.48), int(SIZE * 0.36)
CR = 28  # corner radius

# Drop shadow
shadow_layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
sd = ImageDraw.Draw(shadow_layer)
for i in range(18, 0, -1):
    sa = int(80 * (i / 18) ** 2)
    sd.rounded_rectangle(
        [CX - CW // 2 - i * 2, CY - CH // 2 - i * 2 + 10,
         CX + CW // 2 + i * 2, CY + CH // 2 + i * 2 + 10],
        radius=CR + i, fill=(0, 0, 0, sa)
    )
shadow_layer = shadow_layer.filter(ImageFilter.GaussianBlur(radius=10))
img = Image.alpha_composite(img, shadow_layer)
draw = ImageDraw.Draw(img)

# White card
draw.rounded_rectangle(
    [CX - CW // 2, CY - CH // 2, CX + CW // 2, CY + CH // 2],
    radius=CR, fill=(255, 255, 255, 240)
)

# Photo thumbnail inside card (gradient fill)
PX1 = CX - CW // 2 + 28
PY1 = CY - CH // 2 + 28
PX2 = CX + CW // 2 - 28
PY2 = CY + CH // 2 - 70
PR = 12

thumb = Image.new("RGBA", (PX2 - PX1, PY2 - PY1), (0, 0, 0, 0))
td = ImageDraw.Draw(thumb)
for y in range(thumb.height):
    t = y / thumb.height
    col = lerp_color((100, 160, 240), (60, 100, 200), t)
    td.line([(0, y), (thumb.width, y)], fill=col + (255,))

# Mountains inside thumbnail
tm_peaks = [
    (0, thumb.height), (0, int(thumb.height * 0.55)),
    (int(thumb.width * 0.2), int(thumb.height * 0.35)),
    (int(thumb.width * 0.4), int(thumb.height * 0.45)),
    (int(thumb.width * 0.55), int(thumb.height * 0.28)),
    (int(thumb.width * 0.75), int(thumb.height * 0.42)),
    (thumb.width, int(thumb.height * 0.50)),
    (thumb.width, thumb.height)
]
td.polygon(tm_peaks, fill=(30, 50, 140, 255))

# Mask thumb with rounded rect
tmask = Image.new("L", thumb.size, 0)
tmd = ImageDraw.Draw(tmask)
tmd.rounded_rectangle([0, 0, thumb.width, thumb.height], radius=PR, fill=255)
thumb.putalpha(tmask)
img.paste(thumb, (PX1, PY1), thumb)

draw = ImageDraw.Draw(img)

# Metadata lines below thumbnail (simulate text bars)
bar_y = PY2 + 14
bar_x = PX1
bar_col = (200, 200, 210, 255)

draw.rounded_rectangle([bar_x, bar_y, bar_x + int((PX2 - PX1) * 0.65), bar_y + 10], radius=5, fill=bar_col)
draw.rounded_rectangle([bar_x, bar_y + 18, bar_x + int((PX2 - PX1) * 0.42), bar_y + 26], radius=5, fill=(220, 220, 230, 200))

# ── Round corners (macOS icon style) ─────────────────────────────────────────
CORNER_RADIUS = int(SIZE * 0.225)
img = add_rounded_mask(img, CORNER_RADIUS)

# ── Output all required sizes ─────────────────────────────────────────────────
SIZES = [16, 32, 64, 128, 256, 512, 1024]

os.makedirs(OUT_DIR, exist_ok=True)

for s in SIZES:
    resized = img.resize((s, s), Image.LANCZOS)
    fname = f"icon_{s}x{s}.png"
    resized.save(os.path.join(OUT_DIR, fname), "PNG")
    print(f"  ✓  {fname}")

print(f"\nAll icons written to:\n  {OUT_DIR}")
