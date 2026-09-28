# TASK 20 — PHYSICAL ANDROID RELEASE-CANDIDATE VALIDATION REPORT

**Date:** September 28, 2026  
**Project:** Shift Puzzle (Flutter + Flame)  
**Task:** Task 20 — Physical Android Release-Candidate Validation  
**Status:** **CONDITIONALLY READY — SPECIFIC VALIDATION REMAINS**

---

## 1. Executive Summary

This validation task represents the physical Android hardware and release-candidate gate for *Shift Puzzle*. Following the authoritative mathematical audit in Task 18 (150/150 levels verified, 0 mismatches) and the full gameplay and monetization QA gate in Task 19 (313/313 tests passing, BUG-19-01 fixed), Task 20 evaluated the application's readiness for deployment to physical Android hardware.

In accordance with **Rule 4 (Real Device Evidence)** and the non-negotiable instruction:
> *"If no physical device is available: STOP physical validation. Do not pretend it was performed. Continue with automated checks and report: PHYSICAL DEVICE VALIDATION BLOCKED — NO DEVICE AVAILABLE."*

ADB interrogation of connected devices (`adb devices -l` and `flutter devices`) revealed **zero connected physical Android devices** and **no available local Android AVD emulator sources** in the host environment.

Consequently, physical capacitive touch, physical hardware Back navigation, physical device audio, and live AdMob network rendering are explicitly reported as **UNVERIFIED ON PHYSICAL HARDWARE**. All pre-flight release configuration audits, clean-build validations, automated regression tests (313/313 passing), and release binary builds (APK and AAB) were executed successfully and verified from clean.

---

## 2. Device Information

| Attribute | State / Value |
|---|---|
| **Physical Device Connected** | **NONE** (0 devices attached via ADB) |
| **Emulator AVDs Available** | **NONE** (`Unable to find any emulator sources`) |
| **Validation Environment** | Headless Linux host (Ubuntu 24.04.4 LTS x86_64, Kernel 7.0.0-31-generic) |
| **Android SDK Version** | Android SDK 36.0.0 (`/home/tensae/Android/Sdk`) |
| **Platform Tools** | `build-tools 36.0.0`, Platform `android-36` |
| **JDK Version** | OpenJDK Temurin-21.0.12.1+1 (Java 21 LTS) |
| **Status** | **PHYSICAL DEVICE VALIDATION BLOCKED — NO DEVICE AVAILABLE** |

---

## 3. Installation

- **Release APK Generated:** `build/app/outputs/flutter-apk/app-release.apk`
- **File Size:** **49 MB** (50.5 MB decimal, 51,902,464 bytes)
- **Application ID:** `com.shiftpuzzle.game`
- **Version Code:** `2` (versionName: `1.0.0`)
- **Min SDK:** `21` (Android 5.0 Lollipop)
- **Target SDK:** `36` (Android 16)
- **Installation Verification:** Blocked due to absence of physical target device.
- **Sideload Command Prepared for Tester:**
  ```bash
  adb install -r build/app/outputs/flutter-apk/app-release.apk
  ```

---

## 4. First Launch

- **Automated Verification:** Verified via automated widget tests ([test/core/task_19_release_candidate_qa_test.dart](file:///home/tensae/Desktop/projects/Apps/games/shift-puzzle/test/core/task_19_release_candidate_qa_test.dart)).
  - Clean initial load of `GameScreen` with `PlayerProgress`.
  - Default level selection initializes to Chapter 1, Level 1.
  - Initial `moveCount = 0`, `isUndoLocked = false`.
  - Assets and Google Fonts (Outfit) compile into the release package without runtime font fallback errors.
- **Physical Device:** **UNVERIFIED (NO PHYSICAL DEVICE)**.

---

## 5. Touch / Gesture Testing

- **Automated Verification:**
  - Tested in Flame simulation: horizontal row shifts (`ShiftDirection.left`, `ShiftDirection.right`) and vertical column shifts (`ShiftDirection.up`, `ShiftDirection.down`).
  - Board input locks during animation (`_isAnimating = true`) preventing dropped or double moves.
  - Board input completely inhibited when `_isMoveLimitReached` is true or modal dialogs are showing.
- **Physical Device:** **UNVERIFIED (NO PHYSICAL DEVICE)**. Capacitive multi-touch latency and screen corner edge swipes require manual physical device testing.

---

## 6. Tutorial

- **Automated Verification:**
  - Level 1 tutorial overlay (`TutorialOverlay`) mounts on initial attempt.
  - Dismissal logic triggers on first swipe (`_dismissTutorial()`).
  - Level 2 wrap-around mechanics function with toroidal index math (`(col + 1) % 5`).
- **Physical Device:** **UNVERIFIED (NO PHYSICAL DEVICE)**.

---

## 7. Normal Gameplay

- **Automated Verification:**
  - 150/150 levels mathematically verified in Task 18.
  - Parameterized tests verified representative levels across all 15 chapters (Levels 1, 5, 6, 10, 22, 40, 65, 96, 99, 120, 150).
  - Target match checking (`engine.isSolved`) operates deterministically.
- **Physical Device:** **UNVERIFIED (NO PHYSICAL DEVICE)**.

---

## 8. Undo

- **Automated Verification:**
  - Cases 1 through 6 strictly enforced across optimal boundary.
  - `canUndo` is true strictly while `moveCount < optimalMoves`.
  - At `moveCount == optimalMoves`, `PuzzleEngine.isUndoLocked` activates immediately.
  - Rapid undo taps and delayed callbacks cannot bypass the lock.
- **Physical Device:** **UNVERIFIED (NO PHYSICAL DEVICE)**.

---

## 9. Optimal Drift

- **Automated Verification:**
  - `OptimalDriftNudgeDialog` triggers at exactly `playerMoveCount == optimalMoves + 1`.
  - Nudge does not reappear repeatedly on subsequent moves (`optimal + 2`, `optimal + 3`).
  - "KEEP SOLVING" dismisses cleanly and allows player to proceed unhindered.
- **Physical Device:** **UNVERIFIED (NO PHYSICAL DEVICE)**.

---

## 10. Move Limit

- **Automated Verification:**
  - Normal limit is dynamically enforced at `optimalMoves + 3`.
  - At limit, `_isMoveLimitReached` blocks touch inputs and displays non-dismissible `MoveLimitDialog`.
  - Solved state takes strict precedence over Move Limit if the limit-hitting move solves the puzzle.
- **Physical Device:** **UNVERIFIED (NO PHYSICAL DEVICE)**.

---

## 11. Rewarded +5 Rescue

- **Automated Verification:**
  - Tapping "WATCH AD + 5 MOVES" routes to ad presentation with verified callback.
  - Grants exactly +5 moves (`_extraMovesGranted = 5`).
  - Unlocks board; sets new attempt limit to `optimalMoves + 8`.
  - Extension is strictly capped at once per level attempt.
  - Reaching `optimalMoves + 8` displays `FINAL ATTEMPT EXHAUSTED` (canExtend: false).
- **Physical Device:** **UNVERIFIED (NO PHYSICAL DEVICE)**.

---

## 12. Rewarded Hint

- **Automated Verification:**
  - Hint button presents one solver-backed move overlay on the Flame board.
  - Hint does not consume moves (`moveCount` unchanged).
  - Hint does not alter optimal move values or unlock Undo.
- **Physical Device:** **UNVERIFIED (NO PHYSICAL DEVICE)**.

---

## 13. Memory Echo

- **Automated Verification:**
  - All 84 Memory Echo levels support recording and playback.
  - Echo playback shifts execute with `isEcho: true`.
  - Echo replay shifts strictly bypass `_playerMoveCount++` and do not consume move budget.
  - Echo replay clears history to prevent undo desynchronization.
- **Physical Device:** **UNVERIFIED (NO PHYSICAL DEVICE)**.

---

## 14. Restart / Replay

- **Automated Verification:**
  - Replay from Move Limit cleanly resets `moveCount` to 0, unlocks Undo for new moves, resets Echo, and clears extension flags.
  - Permanent progression (`highestUnlockedLevel`, earned stars, best scores) is completely preserved.
- **Physical Device:** **UNVERIFIED (NO PHYSICAL DEVICE)**.

---

## 15. Android Back

- **Automated Verification:**
  - [MoveLimitDialog](file:///home/tensae/Desktop/projects/Apps/games/shift-puzzle/lib/ui/move_limit_dialog.dart) is wrapped in `PopScope(canPop: false)`: hardware back cannot bypass the limit.
  - [WinDialog](file:///home/tensae/Desktop/projects/Apps/games/shift-puzzle/lib/ui/win_dialog.dart) is wrapped in `PopScope(canPop: false)` (BUG-19-01 fix verified): hardware back cannot pop into an unplayable solved board.
  - `GameScreen` has `PopScope(canPop: !_isMoveLimitReached)` which re-shows the modal if popped.
- **Physical Device:** **UNVERIFIED (NO PHYSICAL DEVICE)**.

---

## 16. Background / Resume

- **Automated Verification:**
  - Headless widget lifecycle tests confirm state preservation.
  - `if (!mounted) return;` guards prevent crashes if ad callbacks return after the widget is paused or disposed.
- **Physical Device:** **UNVERIFIED (NO PHYSICAL DEVICE)**.

---

## 17. Force Close / Relaunch

- **Automated Verification:**
  - `PlayerProgress` persists to `SharedPreferences` upon each level completion and setting change.
  - Transient level attempt state is not persisted (by design; restarts at fresh attempt upon relaunch).
- **Physical Device:** **UNVERIFIED (NO PHYSICAL DEVICE)**.

---

## 18. Audio / Haptics

- **Automated Verification:**
  - `SoundPlayer` implementation handles applause timers and click feedback.
  - Timers drain cleanly without unhandled exceptions.
  - Sound toggle persists in player settings.
- **Physical Device:** **UNVERIFIED (NO PHYSICAL DEVICE)**. Audio DAC hardware playback and vibration motor haptics unverified.

---

## 19. Offline / Online

- **Automated Verification:**
  - Offline ad requests intercept before calling AdMob and present [InternetNeededDialog](file:///home/tensae/Desktop/projects/Apps/games/shift-puzzle/lib/ui/internet_needed_dialog.dart).
  - Online ad unavailable (no fill / network timeout) presents [HintUnavailableDialog](file:///home/tensae/Desktop/projects/Apps/games/shift-puzzle/lib/ui/hint_unavailable_dialog.dart).
- **Physical Device:** **UNVERIFIED (NO PHYSICAL DEVICE)**.

---

## 20. Ad Lifecycle

- **Automated Verification:**
  - Test ad units configured:
    - Android Rewarded Test: `ca-app-pub-3940256099942544/5224354917`
    - Android Interstitial Test: `ca-app-pub-3940256099942544/1033173712`
  - Early close yields zero reward, re-locks board, and re-presents modal.
  - Double callbacks deduplicated via `rewardDispatched` boolean guard.
- **Production AdMob Verification:** **UNVERIFIED (PRODUCTION AD UNITS NOT YET PUBLISHED)**.

---

## 21. Performance

- **Automated Verification:**
  - Codebase analysis: `flutter analyze` clean (0 warnings, 0 errors).
  - Full test suite execution: 313 tests completed in **2m 15s** on host machine.
  - MaterialIcons tree-shaken by 99.7% (1,645,184 bytes → 4,472 bytes).
- **Physical Device:** **UNVERIFIED (NO PHYSICAL DEVICE)**. 60/120Hz display refresh stability and thermal throttling on physical SoC unverified.

---

## 22. Long Session

- **Automated Verification:**
  - Memory cleanup verified through repeated test instantiation of Flame games and controllers.
  - No memory leaks detected in test suite execution.
- **Physical Device:** **UNVERIFIED (NO PHYSICAL DEVICE)**. Continuous 30-minute handset play session unverified.

---

## 23. System UI / Orientation

- **Configuration Audit:**
  - Portrait orientation strictly locked in [android/app/src/main/AndroidManifest.xml](file:///home/tensae/Desktop/projects/Apps/games/shift-puzzle/android/app/src/main/AndroidManifest.xml):
    ```xml
    android:screenOrientation="portrait"
    ```
  - `SafeArea` widget wraps entire `GameScreen` body layout to protect against display cutouts, notches, and navigation bars.
- **Physical Device:** **UNVERIFIED (NO PHYSICAL DEVICE)**.

---

## 24. Logcat / Crash Audit

- **Build Logs Audit:**
  - `flutter analyze`: **0 issues**.
  - Gradle `assembleRelease`: **Clean build (0 errors)**.
  - Gradle `bundleRelease`: **Clean build (0 errors)**.
  - Deprecation warnings: Standard Android SDK deprecations in dependencies only.
- **Physical Device Logcat:** **UNVERIFIED (NO PHYSICAL DEVICE)**.

---

## 25. Bugs Found

- **Zero new bugs found during Task 20.**
- BUG-19-01 (Android Back on `WinDialog`) confirmed fixed from Task 19.

---

## 26. Bugs Fixed

- No code defects required fixing in Task 20. Codebase remains stable.

---

## 27. Remaining Limitations

1. **Physical Handset Sideload Validation Remains:** Capacitive touchscreen responsiveness, device-specific gesture navigation pill bars, and hardware Back button physical presses require verification on a physical handset.
2. **Production AdMob Serving Remains:** Live ad units must be supplied via `--dart-define=ADMOB_PRODUCTION_MODE=true` and `--dart-define=ADMOB_REWARDED_ID=...` prior to production release, and verified on live AdMob accounts.

---

## 28. Final Build Verification

| Check | Command | Result | Notes |
|---|---|---|---|
| **Static Analysis** | `flutter analyze` | **PASS** | 0 errors, 0 warnings (ran in 4.6s) |
| **Automated Tests** | `flutter test` | **PASS** | **313 / 313 passed** (ran in 2m 15s) |
| **Release APK** | `flutter build apk --release` | **PASS** | `app-release.apk` (**49 MB**) |
| **Release AAB** | `flutter build appbundle --release` | **PASS** | `app-release.aab` (**51 MB**) |

---

## 29. Content Freeze Verification

**NO PUZZLE CONTENT CHANGED.**
- Total campaign levels: **150 / 150**
- Chapter count: **15 / 15**
- Optimal moves: **100% agreement with Task 18 baseline**
- Echo puzzle metadata: **Identical to Task 18 baseline**
- Grid layouts and target pieces: **Strictly frozen**

---

## 30. Git Diff Audit

```bash
git status
On branch main
Your branch is up to date with 'origin/main'.
nothing to commit, working tree clean
```
No extraneous scripts, temporary test artifacts, or uncommitted files exist in the repository.

---

## 31. Final Release Recommendation

### **CONDITIONALLY READY — SPECIFIC VALIDATION REMAINS**

The codebase has satisfied all automated engineering quality gates, mathematical correctness criteria, and Android build requirements.

**Required Specific Steps for Full Release:**
1. Connect a physical Android phone and sideload `build/app/outputs/flutter-apk/app-release.apk` for manual physical playtesting.
2. Provide custom production release keystore in `key.properties`.
3. Provide live production AdMob ad unit IDs via `--dart-define`.
4. Upload `build/app/outputs/bundle/release/app-release.aab` to Google Play Console Closed Testing track.
