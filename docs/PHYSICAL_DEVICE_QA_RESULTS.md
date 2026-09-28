# Shift Puzzle — Physical Android Device QA Results

**Date:** September 28, 2026  
**Application:** Shift Puzzle (`com.shiftpuzzle.game`)  
**Package:** `com.shiftpuzzle.game`  
**Internal Namespace:** `com.shiftpuzzle.shift_puzzle`  
**Target Build:** Version `1.0.0+2` (versionCode: 2, versionName: "1.0.0")  
**Git Commit:** `ea2c8bc`  
**Evaluation Status:** **AUTOMATED CHECKS PASS — PHYSICAL HARDWARE VALIDATION BLOCKED**  

---

## 1. Environment & Device Audit

* **Connected Device Detection:**
  ```text
  $ adb devices -l
  List of devices attached
  (empty)

  $ flutter devices
  Found 2 connected devices:
    Linux (desktop) • linux  • linux-x64      • Ubuntu 24.04.4 LTS
    Chrome (web)    • chrome • web-javascript • Google Chrome 151.0.7922.173

  $ flutter emulators
  Unable to find any emulator sources. Please ensure you have some Android AVD images available.
  ```
* **Hardware Detection Verdict:** **NO PHYSICAL ANDROID DEVICE DETECTED.**
* **Protocol Rule:** In accordance with project policy, physical device checks are strictly marked **BLOCKED / NOT TESTED** and NOT assumed to pass.

---

## 2. Automated Release Candidate Verification Summary

| Check Category | Verification Command | Result | Evidence / Details |
|---|---|---|---|
| **Static Analysis** | `flutter analyze` | **PASS** | 0 errors, 0 warnings, 0 lints in 3.2s. |
| **Automated Test Suite** | `flutter test` | **PASS** | 316 / 316 unit, widget, and policy tests passed in 2m 19s. |
| **Mathematical Solver Par Audit** | `flutter test test/solver/campaign_exact_bfs_audit_test.dart` | **PASS** | 150/150 levels verified against exact bidirectional BFS solver (0 par mismatches). |
| **AdMob Fail-Safe & Policy** | `flutter test test/core/monetization_test.dart` | **PASS** | 14/14 tests passed; production empty unit ID fail-safe verified; Chapter 1 ad-free verified. |
| **Release Signing Fail-Closed** | `./gradlew :app:assembleRelease` | **PASS** | Fails closed with descriptive `GradleException` if `key.properties` is missing. |
| **APK Build (Physical QA)** | `flutter build apk --release -PallowInsecureDebugSigning=true` | **PASS** | R8 shrinking active; ProGuard rules applied; APK compiled successfully. |
| **Launcher Icon Assets** | Asset inspection | **PASS** | High-res 512×512 store icon, adaptive icon XML, and all mipmap densities (mdpi to xxxhdpi) generated. |

---

## 3. Physical Device Verification Results Table

| Area | Status | Evidence / Notes |
|---|---|---|
| **01. Installation** | **BLOCKED** | No physical device connected via USB or Wi-Fi adb. |
| **02. App Launcher Icon** | **BLOCKED (Hardware)** / **PASS (Asset)** | Adaptive icon XML, background, and foreground present in `res/mipmap-*/`; physical rendering on launcher not tested. |
| **03. First Launch** | **BLOCKED** | Requires physical device boot and launch. |
| **04. Orientation Lock** | **PASS (Manifest)** / **BLOCKED (Physical)** | `android:screenOrientation="portrait"` configured in `AndroidManifest.xml`. Physical rotation not tested. |
| **05. Core Touch Controls** | **BLOCKED** | Touch latency and swipe sensitivity require physical screen testing. |
| **06. Rapid Input Queue** | **BLOCKED** | Multi-touch rapid input requires physical screen interaction. |
| **07. Level Progression** | **PASS (Automated)** / **BLOCKED (Physical)** | Verified via automated test suite; physical verification on device blocked. |
| **08. Move Budget & Counter** | **PASS (Automated)** / **BLOCKED (Physical)** | Verified in widget/unit tests (`MoveBudgetTest`); physical verification blocked. |
| **09. Undo Lock** | **PASS (Automated)** / **BLOCKED (Physical)** | Verified in unit tests (`UndoLockTest`); physical verification blocked. |
| **10. Move Limit Dialog** | **PASS (Automated)** / **BLOCKED (Physical)** | Verified in widget tests; physical presentation on device blocked. |
| **11. Extra-Move Rescue (+5)** | **PASS (Automated)** / **BLOCKED (Physical)** | Verified in automated monetization QA; physical ad presentation blocked. |
| **12. Ad Dismissal Safety** | **PASS (Automated)** / **BLOCKED (Physical)** | Single dispatch and `userEarned = false` verified in code and tests. |
| **13. Memory Echo Recording** | **PASS (Automated)** / **BLOCKED (Physical)** | Verified across 84 Echo levels in automated solver audit. |
| **14. Memory Echo Replay** | **PASS (Automated)** / **BLOCKED (Physical)** | Trajectory and zero player move consumption verified in automated tests. |
| **15. Audio & SFX** | **BLOCKED** | Physical speaker / headphone output verification blocked. |
| **16. Haptic Feedback** | **BLOCKED** | Physical vibration motor response verification blocked. |
| **17. Android Hardware Back** | **PASS (Automated)** / **BLOCKED (Physical)** | `PopScope(canPop: false)` on `WinDialog` tested in Task 19 automated tests. |
| **18. App Lifecycle (Suspend)** | **BLOCKED** | OS backgrounding and state preservation require real device. |
| **19. Process Kill & Restore** | **BLOCKED** | Android OS low-memory termination requires physical device testing. |
| **20. Offline Mode (Airplane)** | **PASS (Service)** / **BLOCKED (Physical)** | `ConnectivityService` offline bypass verified; physical radio toggle blocked. |
| **21. Extended Session (30m+)** | **BLOCKED** | Thermal dissipation and progressive memory profiling require hardware. |
| **22. Logcat Runtime Audit** | **BLOCKED** | `adb logcat` monitoring requires active Android runtime connection. |
| **23. Fresh Install Clean State** | **BLOCKED** | Requires hardware uninstallation and reinstallation. |
