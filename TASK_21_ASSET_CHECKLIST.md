# Task 21 — Google Play Store Graphic Assets Checklist

**Application:** Shift Puzzle  
**Package:** `com.shiftpuzzle.game`  
**Date:** September 28, 2026  

This document audits all visual store listing assets required by Google Play Console, identifies which assets are generated versus pending, and provides exact specifications for store upload.

---

## 1. Asset Audit Summary

| Required Store Asset | Dimensions / Format | Status in Repository | Play Console Requirement |
|---|---|---|---|
| **App Icon (Hi-Res)** | 512 × 512 px, 32-bit PNG, max 1024 KB | **PENDING EXPORT** | **Mandatory** |
| **Feature Graphic** | 1024 × 500 px, JPEG or 24-bit PNG, max 15MB | **PENDING DESIGN** | **Mandatory** |
| **Phone Screenshots** | Min 2 (recommended 4–8), min 1080 px short edge, 9:16 or 16:9 | **PENDING SCREEN CAPTURE** | **Mandatory** (Min 2) |
| **7-inch Tablet Screenshots** | Min 1, 16:9 or 9:16 aspect ratio | **PENDING SCREEN CAPTURE** | Optional / Recommended |
| **10-inch Tablet Screenshots** | Min 1, 16:9 or 9:16 aspect ratio | **PENDING SCREEN CAPTURE** | Optional / Recommended |
| **Launcher App Icon (APK)** | Adaptive / Mipmap (mdpi to xxxhdpi) | **PRESENT** in `res/mipmap-*/` | **Mandatory for APK** |

---

## 2. Detailed Asset Specifications & Guidelines

### A. High-Resolution App Icon (Store Listing Icon)
* **Dimensions:** Exactly `512 × 512` pixels.
* **Format:** 32-bit PNG (with alpha channel permitted, but background must be opaque).
* **Color Depth:** sRGB.
* **Maximum File Size:** 1,024 KB (1 MB).
* **Design Guidelines:**
  - Flat, full-bleed square icon without rounded corners. Google Play applies a 20% squircle mask and drop shadow dynamically in store listings.
  - Recommended design: Dark slate `#090D16` background, glowing cyan geometric ring (`#00E5FF`), and centered neon gem or toroidal loop motif matching the in-game procedural pieces.

### B. Feature Graphic
* **Dimensions:** Exactly `1024 × 500` pixels.
* **Format:** JPEG or 24-bit PNG (no alpha/transparency).
* **Maximum File Size:** 15 MB.
* **Design Guidelines:**
  - Displayed at the top of the Google Play store listing and in store recommendations.
  - Keep all focal elements (title "Shift Puzzle" and central graphic) within the center safe zone (leaving 15% margins on all sides).
  - Minimalist dark aesthetic: deep obsidian/slate background, neon cyan/amber grid accents, and subtle geometric gem icons.
  - **No promotional text** (e.g. "Free", "No. 1 Puzzle", or star rating badges) as this violates current Google Play metadata policies.

### C. Phone Screenshots (Minimum 4 Recommended)
* **Dimensions:** Min 1080 × 1920 px (or 1080 × 2400 px, 9:16 / 20:9 aspect ratio).
* **Format:** JPEG or 24-bit PNG without transparency.
* **Recommended Screenshot Sequence:**
  1. **Screenshot 1 — Core Mechanic:** Level 2 or Level 5 board showing toroidal row/column shift in action with clean HUD and move counter.
     - *Caption:* "SLIDE ROWS & COLUMNS — Boards with no boundaries."
  2. **Screenshot 2 — Memory Echo:** Level 10 or Level 14 showing Memory Echo recording HUD and glowing phantom trajectory arrows.
     - *Caption:* "MASTER MEMORY ECHO — Record movement macros & replay them."
  3. **Screenshot 3 — Campaign Mastery:** Chapter Select screen showing 15 thematic chapters and star achievements.
     - *Caption:* "150 CRAFTED PUZZLES — 15 thematic chapters of spatial logic."
  4. **Screenshot 4 — Move Economy & Minimal Pars:** 3-Star victory dialog comparing moves used against minimal par.
     - *Caption:* "EXACT MINIMAL PARS — Test your logic against verified solutions."
  5. **Screenshot 5 — Non-Forced Assistance:** Hint overlay showing subtle solver directional guidance on the board.
     - *Caption:* "SOLVER-BACKED HINTS — Optional guidance when you need a nudge."

---

## 3. Developer Production Action Items

Before submitting to Google Play Console:
1. Export a crisp 512×512 PNG of the app icon to upload in Play Console **Main Store Listing > App Icon**.
2. Design and export the 1024×500 Feature Graphic.
3. Capture at least 4 high-resolution uncompressed screenshots from an Android device or emulator running the release APK.
4. Upload all graphic assets in Play Console under **Grow > Store presence > Main store listing**.
