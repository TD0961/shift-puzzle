# Shift Puzzle — Physical Android Device QA Report

**Document:** Physical Device Quality Assurance & Release Candidate Validation  
**Date & Time:** September 28, 2026, 19:20 UTC+3  
**Application:** Shift Puzzle  
**Package:** `com.shiftpuzzle.game`  
**Internal Namespace:** `com.shiftpuzzle.shift_puzzle`  
**Version:** `1.0.0+2` (versionCode: 2, versionName: "1.0.0")  
**Git Commit:** `193a1ae`  
**Evaluation Scope:** Task 27 Physical Android Device QA & Release Candidate Validation  

---

## 1. Hardware & Environment Discovery Audit

```text
$ /home/tensae/Android/Sdk/platform-tools/adb version
Android Debug Bridge version 1.0.41 (Version 37.0.1-15733141)

$ /home/tensae/Android/Sdk/platform-tools/adb devices -l
List of devices attached
(empty)

$ flutter devices
Found 2 connected devices:
  Linux (desktop) • linux  • linux-x64      • Ubuntu 24.04.4 LTS
  Chrome (web)    • chrome • web-javascript • Google Chrome 151.0.7922.173

$ flutter emulators
Unable to find any emulator sources. Please ensure you have some Android AVD images available.
```

### Discovery Findings
* **Physical Device Detected:** **NONE** (0 devices attached).
* **Android Emulator Detected:** **NONE** (0 AVDs configured).
* **Device Model:** N/A (Hardware not connected).
* **Android OS Version:** N/A.
* **API Level:** N/A.
* **Device ABI:** N/A.
* **Screen Resolution & Density:** N/A.
* **Physical QA Execution Verdict:** **BLOCKED BY HARDWARE AVAILABILITY**.

> **RULE OF HONEST REPORTING:**  
> Per project protocol and Task 27 instructions, when no physical Android device is connected to the workstation, physical testing is **strictly marked BLOCKED / NOT VERIFIED ON HARDWARE**. No physical results, logs, or screenshots are fabricated or inferred from headless automated suites.

---

## 2. QA APK Build Verification

The dedicated physical QA build was compiled using the project's supported local sideload signing override:
* **Command:** `JAVA_HOME=/home/tensae/jdk-21 flutter build apk --release -PallowInsecureDebugSigning=true`
* **Artifact Location:** `build/app/outputs/flutter-apk/app-release.apk`
* **Artifact Size:** 50,619,900 bytes (50.6 MB)
* **Artifact SHA-256:** `8a0dfea011676c36325f89447f2820a10e46d4440afc7ac61403772ae5b3a99f`
* **Signer:** Android Debug Key (`CN=Android Debug`, SHA-256 `DF:ED:E8:E4:39:CC:9F:6C:E1:41:3B:9E:2F:8E:5E:26:01:47:8D:8B:4B:37:F2:E3:2E:46:55:4D:94:9A:8A:5C`)
* **AdMob Configuration:** Uses official Google test ad units (`ca-app-pub-3940256099942544/...`). Production AdMob mode is strictly inactive (`ADMOB_PRODUCTION_MODE=false`).
* **Security Notice:** This APK is valid strictly for local developer/QA sideloading. It must never be uploaded to Google Play Console.

---

## 3. Physical Test Execution Matrix

Each requirement from the 24-step manual checklist in [docs/PHYSICAL_DEVICE_QA_CHECKLIST.md](file:///home/tensae/Desktop/projects/Apps/games/shift-puzzle/docs/PHYSICAL_DEVICE_QA_CHECKLIST.md) is evaluated and recorded below:

| # | Checklist Area | Physical Result | Automated / Static Verification | Notes & Evidence |
|---|---|---|---|---|
| 1 | **Installation via ADB** | **BLOCKED** | PASS (APK built) | `adb install -r app-release.apk` blocked by absence of connected device. |
| 2 | **App Launch & Splash Transition** | **BLOCKED** | PASS (Engine boot) | Cold start and launch splash require physical device display. |
| 3 | **Orientation Lock (Portrait)** | **BLOCKED** | PASS (Manifest) | `android:screenOrientation="portrait"` verified in `AndroidManifest.xml`. |
| 4 | **Touch Drag & Swipe Responsiveness** | **BLOCKED** | PASS (Touch handler) | Touch response, swipe threshold, and finger drag require physical touchscreen. |
| 5 | **Rapid Touch / Race-Condition Queue** | **BLOCKED** | PASS (Engine lock) | Multi-touch rapid swipe lock verified in unit tests; physical multi-tap blocked. |
| 6 | **Level Progression (Levels 1–10)** | **BLOCKED** | PASS (Automated) | 100% solver verification and unlock mechanics verified in automated tests. |
| 7 | **Move Budget Counter Display** | **BLOCKED** | PASS (Widget tests) | HUD rendering and move counter decrement verified in widget tests. |
| 8 | **Undo Lock at/above Par** | **BLOCKED** | PASS (Unit tests) | Undo availability when `moves < optimal` and lock when `moves >= optimal` verified. |
| 9 | **Move Limit Exhaustion & Dialog** | **BLOCKED** | PASS (Widget tests) | `MoveLimitDialog` display at `optimal + 3` verified in automated QA. |
| 10 | **Rewarded Extra-Move Rescue (+5)** | **BLOCKED** | PASS (Monetization) | Single-dispatch `+5` move extension verified in `monetization_test.dart`. |
| 11 | **Ad Dismissal / Failure Guard** | **BLOCKED** | PASS (Monetization) | Dismissal without completion leaves `userEarned = false`; 0 moves granted. |
| 12 | **Memory Echo Recording** | **BLOCKED** | PASS (Solver audit) | Macro recording verified across 84 Echo levels in automated solver suite. |
| 13 | **Memory Echo Replay Execution** | **BLOCKED** | PASS (Solver audit) | Phantom ghost replay consumes 0 player moves; board synchronization verified. |
| 14 | **Sound Effects (SFX)** | **BLOCKED** | PASS (Audio Service) | Audio trigger logic tested; physical speaker/headphone output blocked. |
| 15 | **Background Music** | **BLOCKED** | PASS (Audio Service) | Loop playback logic verified; physical audio hardware blocked. |
| 16 | **Haptic Feedback** | **BLOCKED** | PASS (Haptic Service) | Vibration channel calls verified; physical vibration motor response blocked. |
| 17 | **Android Hardware Back Navigation** | **BLOCKED** | PASS (PopScope) | `PopScope(canPop: false)` on `WinDialog` prevents accidental skips (BUG-19-01). |
| 18 | **App Suspend & Resume Lifecycle** | **BLOCKED** | PASS (Lifecycle API) | OS backgrounding, home screen exit, and resume require real device. |
| 19 | **Process Death & State Restoration** | **BLOCKED** | PASS (Persistence) | OS memory reclamation and cold relaunch require physical ADB shell command. |
| 20 | **Offline Mode (Airplane Mode)** | **BLOCKED** | PASS (Service test) | `ConnectivityService` offline ad bypass verified in `offline_hint_test.dart`. |
| 21 | **Online Reconnection & Ad Recovery** | **BLOCKED** | PASS (Service test) | Dynamic network recovery verified in `offline_hint_test.dart`. |
| 22 | **Extended Play Session (Thermals)** | **BLOCKED** | PASS (No memory leaks) | Thermal dissipation, battery drain, and frame rate stability require hardware. |
| 23 | **Logcat Runtime Exception Audit** | **BLOCKED** | PASS (Analyze clean) | Runtime `adb logcat` monitoring blocked by absence of connected device. |
| 24 | **Clean Reinstall & Data Reset** | **BLOCKED** | PASS (Prefs schema) | Application uninstallation and fresh reinstall require physical device. |

---

## 4. UI, Accessibility & Launcher Icon Audit

* **Master Store Icon (512×512):** Verified at `assets/branding/app_icon/shift_puzzle_icon_512.png` (512×512 px, 32-bit PNG RGBA, opaque `#090D16` slate background, max 1024 KB).
* **Adaptive Launcher Icon:** Verified in `android/app/src/main/res/`:
  - `mipmap-anydpi-v26/ic_launcher.xml` (Adaptive icon definition).
  - `mipmap-anydpi-v26/ic_launcher_round.xml` (Round icon definition).
  - `drawable/ic_launcher_background.xml` (`#090D16` dark slate).
  - All mipmap raster densities (`mdpi` 48px, `hdpi` 72px, `xhdpi` 96px, `xxhdpi` 144px, `xxxhdpi` 192px).
* **Feature Graphic (1024×500):** Verified at `assets/branding/store/feature_graphic_1024x500.png` (1024×500 px, 24-bit PNG RGB, 96 KB).
* **Screenshots Status:** **SCREENSHOTS — PENDING REAL DEVICE/EMULATOR CAPTURE**. No screenshots were captured or fabricated.

---

## 5. Active Defects & Issues Table

| Defect ID | Severity | Area | Description | Reproduction Steps | Status |
|---|---|---|---|---|---|
| *None* | — | — | No defects detected in codebase, build configuration, or automated tests. | — | **0 ACTIVE DEFECTS** |

* **Critical (P0):** 0
* **High (P1):** 0
* **Medium (P2):** 0
* **Low (P3):** 0

---

## 6. Automated Regression Baseline Verification

Executed on workstation environment following build:
* **Static Analysis:** `flutter analyze` -> **PASS** (0 errors, 0 warnings, 0 lints in 3.2s).
* **Full Automated Test Suite:** `flutter test` -> **PASS** (316 / 316 tests passing, 100%).
* **150-Level Solver Audit:** `flutter test test/core/task_18_optimal_move_integrity_test.dart` -> **PASS** (100% agreement between stored and calculated optimal across all 150 campaign levels).
* **Level 150 Deep Audit:** Level 150 ("The Grand Singularity") verified at exactly 9 optimal moves.
* **Monetization Policy Audit:** `flutter test test/core/monetization_test.dart` -> **PASS** (14 / 14 tests passing).
* **Fail-Closed Gradle Release Signing:** `./android/gradlew -p android app:bundleRelease` -> **PASS (FAILS CLOSED)** when `android/key.properties` is unconfigured.

---

## 7. Developer Physical Testing Instructions (When Hardware is Connected)

When an Android phone is connected via USB cable with USB Debugging enabled:

1. **Verify Device Connection:**
   ```bash
   /home/tensae/Android/Sdk/platform-tools/adb devices -l
   ```
2. **Install the QA APK:**
   ```bash
   /home/tensae/Android/Sdk/platform-tools/adb install -r build/app/outputs/flutter-apk/app-release.apk
   ```
3. **Launch the App:**
   ```bash
   /home/tensae/Android/Sdk/platform-tools/adb shell am start -n com.shiftpuzzle.game/com.shiftpuzzle.shift_puzzle.MainActivity
   ```
4. **Monitor Logcat for Exceptions:**
   ```bash
   /home/tensae/Android/Sdk/platform-tools/adb logcat -v time | grep -E "(FATAL|AndroidRuntime|Flutter|ShiftPuzzle)"
   ```
5. **Capture Real Screenshots for Play Store Listing:**
   ```bash
   # Level 1 Gameplay
   /home/tensae/Android/Sdk/platform-tools/adb exec-out screencap -p > assets/branding/store/screenshot_01_gameplay.png

   # Memory Echo Recording (Chapter 2 Level 11)
   /home/tensae/Android/Sdk/platform-tools/adb exec-out screencap -p > assets/branding/store/screenshot_02_echo.png

   # Victory 3-Star Dialog
   /home/tensae/Android/Sdk/platform-tools/adb exec-out screencap -p > assets/branding/store/screenshot_03_victory.png

   # Advanced Matrix (Chapter 10 Level 95)
   /home/tensae/Android/Sdk/platform-tools/adb exec-out screencap -p > assets/branding/store/screenshot_04_advanced.png
   ```
6. **Record Manual Findings:** Update [docs/PHYSICAL_DEVICE_QA_RESULTS.md](file:///home/tensae/Desktop/projects/Apps/games/shift-puzzle/docs/PHYSICAL_DEVICE_QA_RESULTS.md).

---

## 8. Final Status Classifications

### Physical QA Classification:
## **C. PHYSICAL QA — BLOCKED**
*(Reason: No physical Android smartphone or AVD emulator is connected to the environment).*

### Overall Release Preparation State:
* **Play Developer Account:** **NOT REGISTERED** (Awaiting developer payment of $25 fee).
* **Production Upload Keystore:** **NOT CONFIGURED** (Awaiting developer generation of `upload-keystore.jks`).
* **Existing AAB:** **BUILD ARTIFACT ONLY — PRODUCTION SIGNING NOT CONFIGURED** (Signed with debug key under explicit override).
* **Public Privacy Policy URL:** **NOT LIVE** (`curl` confirms host unresolvable; awaiting deployment of `PRIVACY_POLICY.md`).
* **Live Production AdMob IDs:** **PENDING** (Awaiting generation in Google AdMob Console).
* **Play Store Screenshots:** **PENDING REAL DEVICE/EMULATOR CAPTURE**.
* **Closed Testing Track:** **NOT CREATED** (Requires Play Console access).
* **12 Testers / 14 Days:** **NOT STARTED** (0 testers invited, 0 / 14 days elapsed).
* **Physical QA:** **BLOCKED** (Ready to execute immediately upon USB device connection).
