# Shift Puzzle — Physical Android Device QA Bug Log

**Application:** Shift Puzzle  
**Package:** `com.shiftpuzzle.game`  
**Current Build:** Version `1.0.0+2` (Build 2)  
**Tracking Period:** Pre-Play Store Physical QA  

---

## 1. Defect Classification Standard

* **P0 — Critical Release Blocker:** Application crash on launch, game-breaking state corruption, inability to advance levels, or critical policy violation.
* **P1 — High Severity:** Broken monetization reward callback, physical back-key trap, or major UI rendering defect on specific aspect ratios.
* **P2 — Medium Severity:** Minor visual glitch, audio clipping on specific devices, or non-blocking animation stutter.
* **P3 — Low Severity / Cosmetic:** Minor spacing discrepancy or copy improvement suggestion.

---

## 2. Active Defect Log

| Defect ID | Severity | Device Model | Android OS | Build Version | Summary & Reproduction Steps | Expected Result | Actual Result | Status | Resolution |
|---|---|---|---|---|---|---|---|---|---|
| *None* | — | — | — | — | No defects discovered in current automated QA or static audits. | — | — | — | — |

---

## 3. Historical Resolved Release Issues

### BUG-19-01 (Resolved in Task 19)
* **Severity:** P1 (High)
* **Component:** `WinDialog` Navigation / Android Hardware Back Button
* **Root Cause:** Android system back button on the victory modal dialog popped the underlying `GameScreen` route rather than dismissing the dialog or advancing to next level.
* **Fix Applied:** Wrapped `WinDialog` in `PopScope(canPop: false)` to intercept system back navigation and keep the player in the victory state until an explicit action ("Next Level" or "Replay") is chosen.
* **Verification:** Automated widget test added; verified in 316-test suite.

### SEC-23-01 (Resolved in Task 23)
* **Severity:** P0 (Release Architecture Blocker)
* **Component:** Android Gradle Release Signing (`android/app/build.gradle.kts`)
* **Root Cause:** In the previous release configuration, if `android/key.properties` was missing, the Gradle release build silently fell back to debug signing (`signingConfigs.debug`), creating a severe risk of uploading an invalid debug-signed binary to Google Play.
* **Fix Applied:** Implemented a fail-closed release signing validation check in `build.gradle.kts` that terminates with an explicit `GradleException` if `key.properties` or keystore credentials are missing, while providing `-PallowInsecureDebugSigning=true` for local QA only.
* **Verification:** Verified via `./gradlew :app:assembleRelease` (failed closed with descriptive error) and `-PallowInsecureDebugSigning=true` (assembled cleanly).

### ASSET-24-01 (Resolved in Task 24)
* **Severity:** P0 (Store & Brand Blocker)
* **Component:** Application Launcher Icon & Brand Identity
* **Root Cause:** The Android resources in `android/app/src/main/res/` contained only the default Flutter template icon, with no adaptive icon XML, no round icon, and no 512×512 Google Play Store master asset.
* **Fix Applied:** Designed and deployed custom 5×5 toroidal grid Shift Puzzle icon assets: generated 512×512 master store icon, adaptive icon foreground/background layers, `mipmap-anydpi-v26` adaptive XML, `android:roundIcon` manifest binding, and all raster mipmap densities (mdpi to xxxhdpi).
* **Verification:** Verified via Python image inspection, `flutter analyze`, and release APK packaging inspection.
