# TASK 21 — GOOGLE PLAY CLOSED TESTING PREPARATION REPORT

**Date:** September 28, 2026  
**Project:** Shift Puzzle (Flutter + Flame)  
**Package:** `com.shiftpuzzle.game`  
**Current Version:** `1.0.0+2`  
**Task:** Task 21 — Google Play Closed Testing Preparation  
**Status:** **CONDITIONALLY READY — SPECIFIC RELEASE ITEMS REMAIN**  

---

## 1. Executive Summary

This report establishes the complete Google Play Closed Testing release-candidate preparation for *Shift Puzzle*. Building upon the frozen mathematical baseline from Task 18 (150/150 levels proven exact), the full gameplay/monetization audit from Task 19 (313/313 tests passed, BUG-19-01 fixed), and the release build validations from Task 20, Task 21 prepares the operational, compliance, store listing, and security architecture required for Google Play Console submission.

In strict compliance with the core directives:
- **No Puzzle Content Modified:** 150/150 levels, pars, grids, and targets remain strictly frozen.
- **No Mechanics Redesigned:** Move budgets (`optimal + 3`), Undo Lock, Memory Echo, and Rewarded +5 rescue remain unchanged.
- **Zero Secrets Committed:** No keystores, passwords, or private production AdMob IDs exist in the repository.
- **Fail-Safe Ad Architecture:** Updated [lib/core/monetization/admob_ad_service.dart](file:///home/tensae/Desktop/projects/Apps/games/shift-puzzle/lib/core/monetization/admob_ad_service.dart) so that in production release mode (`ADMOB_PRODUCTION_MODE=true`), missing production ad unit IDs fail safely by skipping ad requests rather than silently serving Google test ads.
- **100% Regression Verified:** Full automated test suite passes with **313 / 313 clean tests** and **0 static analysis issues**.
- **Release Binaries Ready:** Fresh Release AAB (`52.5 MB` / `51 MB` binary) and Release APK (`50.5 MB` / `49 MB` binary) compiled cleanly.

---

## 2. Current Release Baseline

| Component | Status / Baseline | Verified Source |
|---|---|---|
| **Authoritative Campaign** | 150 levels / 15 chapters / 84 Echo levels | Task 18 Report (`TASK_18_OPTIMAL_MOVE_INTEGRITY_REPORT.md`) |
| **Par Integrity** | 150/150 exact minimal pars (Level 150 verified at 9 moves) | Exact Bidirectional BFS Solver |
| **Move Economy** | Normal limit: `optimal + 3`; Extended limit: `optimal + 8` | Task 17 & 19 QA Gate |
| **Automated Tests** | **313 / 313 passing** (100% pass rate) | `flutter test` |
| **Static Code Quality** | **0 issues** (0 errors, 0 warnings) | `flutter analyze` |
| **Web Build** | **PASSED** (clean bundle in `build/web/`) | `flutter build web` |
| **Android Release APK** | **PASSED** (`build/app/outputs/flutter-apk/app-release.apk`) | `flutter build apk --release` |
| **Android Release AAB** | **PASSED** (`build/app/outputs/bundle/release/app-release.aab`) | `flutter build appbundle --release` |

---

## 3. Package & Version Audit

- **Application ID:** `com.shiftpuzzle.game` (verified in `android/app/build.gradle.kts` and `AndroidManifest.xml`).
- **Version Name:** `1.0.0` (verified in `pubspec.yaml` and Gradle).
- **Version Code:** `2` (verified in `pubspec.yaml` and Gradle).
- **Target SDK:** `36` (Android 16, latest standard).
- **Compile SDK:** `36`.
- **Min SDK:** `21` (Android 5.0 Lollipop — supports 99.5%+ of active Android devices).
- **Evaluation:** **PASS**. Configuration strictly matches store expectations.

---

## 4. Signing Audit

- **Signing Architecture:** Defined in `android/app/build.gradle.kts`:
  - Dynamically loads `android/key.properties` if present on the local machine.
  - Falls back to `debug` signing if `key.properties` or the keystore file does not exist, enabling local development and CI testing without bundling private keys.
- **Git Security:**
  - `key.properties`, `*.jks`, and `*.keystore` are strictly excluded in `.gitignore`.
  - Zero private credentials, keystores, or certificates exist in the Git tree.
- **Template Available:** [android/key.properties.example](file:///home/tensae/Desktop/projects/Apps/games/shift-puzzle/android/key.properties.example) provides the exact template required for developers to supply their upload keystore.
- **Evaluation:** **READY (TEMPLATE / CI)** — Developer must supply local `android/key.properties` for production store signing.

---

## 5. AdMob Audit

- **Ad Units in Codebase:**
  - **Official Google Sample / Test Ad Unit IDs (Used in Debug & Test Mode):**
    - Android Rewarded Test: `ca-app-pub-3940256099942544/5224354917`
    - Android Interstitial Test: `ca-app-pub-3940256099942544/1033173712`
    - iOS Rewarded Test: `ca-app-pub-3940256099942544/1712485313`
    - iOS Interstitial Test: `ca-app-pub-3940256099942544/4411468910`
- **Production Injection:**
  - Production IDs are injected at build time via `--dart-define`:
    - `--dart-define=ADMOB_PRODUCTION_MODE=true`
    - `--dart-define=ADMOB_REWARDED_ID=ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY`
    - `--dart-define=ADMOB_INTERSTITIAL_ID=ca-app-pub-XXXXXXXXXXXXXXXX/ZZZZZZZZZZ`
- **Fail-Safe Missing ID Protection:**
  - In [lib/core/monetization/admob_ad_service.dart](file:///home/tensae/Desktop/projects/Apps/games/shift-puzzle/lib/core/monetization/admob_ad_service.dart), if `ADMOB_PRODUCTION_MODE=true` is enabled in release mode but production IDs are not supplied, the service returns empty strings and skips ad loads. It **never** silently falls back to test IDs in production.
- **Evaluation:** **PASS**. Clean isolation between test and production advertising environments.

---

## 6. Privacy Audit

- **Policy Document:** Updated and verified in [PRIVACY_POLICY.md](file:///home/tensae/Desktop/projects/Apps/games/shift-puzzle/PRIVACY_POLICY.md).
- **Key Disclosures:**
  - Discloses Google Mobile Ads (AdMob) integration.
  - Explains technical identifiers processed by Google (Advertising ID, diagnostics, approximate location from IP).
  - Explicitly documents both rewarded ad opportunities: optional in-game hints and the single-use +5 move rescue at the move limit.
  - Discloses natural level-transition interstitials (with 3-minute cooldown, 4-level frequency cap, and Chapter 1 ad-free guarantee).
  - Reaffirms that 100% of game progress and scores are stored locally in device `SharedPreferences`.
  - Explains how players can reset or opt out of Advertising ID in Android settings.
- **Evaluation:** **PASS**. Accurately mirrors production code.

---

## 7. Data Safety Matrix Summary

Documented in detail in [TASK_21_DATA_SAFETY_MATRIX.md](file:///home/tensae/Desktop/projects/Apps/games/shift-puzzle/TASK_21_DATA_SAFETY_MATRIX.md):
- **First-Party Data:** 0 personal data collected, stored, or transmitted.
- **Third-Party Data (Google Mobile Ads SDK):**
  - *Location:* Approximate location (coarse, inferred by Google ad servers).
  - *App Activity:* App interactions (ad views, impressions, clicks).
  - *App Info & Performance:* Crash logs and diagnostic telemetry.
  - *Device or other IDs:* Google Advertising ID (AAID).
- **Encryption:** All transit encrypted via HTTPS / TLS.
- **User Deletion:** Handled via Google account ad privacy controls and Android device AAID reset.
- **Evaluation:** **READY FOR CONSOLE ENTRY**.

---

## 8. Target Audience & Families Policy

Documented in [TASK_21_PLAY_CONSOLE_DECLARATIONS.md](file:///home/tensae/Desktop/projects/Apps/games/shift-puzzle/TASK_21_PLAY_CONSOLE_DECLARATIONS.md):
- **Declared Target Age Groups:** **13–15, 16–17, 18 and over**.
- **Child Appeal:** Does **not** unintentionally appeal to children under 13 (minimalist dark slate aesthetic, abstract geometric logic, mature spatial puzzles).
- **Families Policy Program:** Exempt from Google Play Families Policy ad network restrictions.
- **Evaluation:** **READY FOR CONSOLE ENTRY**.

---

## 9. Content Rating (IARC)

- **Violence:** None (0).
- **Fear / Horror:** None (0).
- **Sexuality:** None (0).
- **Profanity / Language:** None (0).
- **Controlled Substances:** None (0).
- **Simulated Gambling:** None (0).
- **User Interactions / Chat:** None (0).
- **In-App Purchases:** None (0).
- **Expected Global Ratings:** **PEGI 3** / **ESRB Everyone** / **USK 0** / **ACB G**.
- **Evaluation:** **READY FOR CONSOLE ENTRY**.

---

## 10. Advertising Declaration

- **"Contains Ads":** Declared **Yes**.
- **Advertising ID Usage:** Declared **Yes** for advertising/marketing, analytics, and fraud prevention.
- **Evaluation:** **READY FOR CONSOLE ENTRY**.

---

## 11. Store Listing Copy

Documented in [TASK_21_STORE_LISTING.md](file:///home/tensae/Desktop/projects/Apps/games/shift-puzzle/TASK_21_STORE_LISTING.md):
- **Title:** `Shift Puzzle` (12 / 30 characters).
- **Short Description:** `Slide rows & columns on a toroidal grid. Master the loop with Memory Echo!` (74 / 80 characters).
- **Full Description:** Comprehensive, editorial copy covering the 5×5 grid, toroidal wrapping, Memory Echo macro mechanic, 15 chapters, 150 handcrafted levels, minimal pars, and offline-first respect for player time. No misleading claims.
- **Evaluation:** **READY FOR CONSOLE ENTRY**.

---

## 12. Store Assets Audit

Documented in [TASK_21_ASSET_CHECKLIST.md](file:///home/tensae/Desktop/projects/Apps/games/shift-puzzle/TASK_21_ASSET_CHECKLIST.md):
- **Launcher Icons (APK):** Generated and present in `android/app/src/main/res/mipmap-*/`.
- **Play Store High-Res Icon (512×512):** Requires developer export before store submission.
- **Feature Graphic (1024×500):** Requires developer design/export before store submission.
- **Phone Screenshots (Min 2, Recommended 4–5):** Requires device/emulator capture from release build.
- **Evaluation:** **PENDING DEVELOPER EXPORT** (documented with exact specifications).

---

## 13. Manifest & Permissions Audit

Inspected [android/app/src/main/AndroidManifest.xml](file:///home/tensae/Desktop/projects/Apps/games/shift-puzzle/android/app/src/main/AndroidManifest.xml):
- **Permissions Declared:**
  1. `android.permission.INTERNET` (Required for Google Mobile Ads SDK).
  2. `android.permission.ACCESS_NETWORK_STATE` (Required for connectivity checking before requesting ads).
- **Zero Dangerous Permissions:** No location, storage, camera, microphone, contacts, or SMS permissions.
- **App Configuration:**
  - `android:screenOrientation="portrait"` locked.
  - `hardwareAccelerated="true"` enabled for smooth Flame rendering.
- **Evaluation:** **PASS**. Minimalist, compliant permissions footprint.

---

## 14. Offline Architecture

- **Offline-First Guarantee:**
  - The complete 150-level campaign, puzzles, solvers, and game loop run 100% offline.
  - Zero remote API calls, account logins, or server sync required for core gameplay.
- **Monetization Isolation:**
  - Offline Hint request → Intercepts cleanly and shows [InternetNeededDialog](file:///home/tensae/Desktop/projects/Apps/games/shift-puzzle/lib/ui/internet_needed_dialog.dart).
  - Offline +5 rescue request → Intercepts cleanly and shows `InternetNeededDialog`.
  - Online ad unavailable → Shows [HintUnavailableDialog](file:///home/tensae/Desktop/projects/Apps/games/shift-puzzle/lib/ui/hint_unavailable_dialog.dart).
- **Evaluation:** **PASS**. Verified by automated tests.

---

## 15. Gameplay Regression

- **Regression Test Suite:** Executed `flutter test` across all 21 test files.
- **Result:** **313 / 313 tests passed** (0 failures, 0 errors, 0 skipped).
- **Evaluation:** **PASS**.

---

## 16. Content Integrity

- **Levels Audited:** 150 / 150 campaign levels verified.
- **Optimal Moves:** 100% match with Task 18 mathematical solver baseline.
- **Echo Metadata:** 84 Echo levels verified.
- **Evaluation:** **PASS**. Content freeze strictly maintained.

---

## 17. Build Verification

- **Static Analysis:** `flutter analyze` → **0 issues** (ran in 5.8s).
- **Release App Bundle (AAB):**
  - Path: `build/app/outputs/bundle/release/app-release.aab`
  - Size: **52.5 MB** (51 MB binary)
  - Compilation: Clean (Ran in 94.6s)
- **Release APK:**
  - Path: `build/app/outputs/flutter-apk/app-release.apk`
  - Size: **50.5 MB** (49 MB binary)
  - Compilation: Clean (Ran in 16.2s)
- **Evaluation:** **PASS**.

---

## 18. Git & Secret Audit

- **Untracked / Modified Files:** Only intentional release documentation and fail-safe ad enhancements.
- **Secrets Check:** Zero `.jks`, `.keystore`, `key.properties`, private tokens, or credentials committed.
- **Evaluation:** **PASS**.

---

## 19. Remaining Manual Steps for Developer

The following actions must be performed outside the repository:

1. **Provide Upload Keystore:**
   - Copy `android/key.properties.example` to `android/key.properties`.
   - Point `storeFile` to your secure release keystore (`.jks`) and set passwords.
2. **Export Visual Store Assets:**
   - Export 512×512 App Icon PNG.
   - Design 1024×500 Feature Graphic PNG/JPEG.
   - Capture at least 4 phone screenshots (1080×1920 or 1080×2400) from the release build.
3. **Build Final Production Signed AAB:**
   ```bash
   flutter build appbundle --release \
     --dart-define=ADMOB_PRODUCTION_MODE=true \
     --dart-define=ADMOB_REWARDED_ID=ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY \
     --dart-define=ADMOB_INTERSTITIAL_ID=ca-app-pub-XXXXXXXXXXXXXXXX/ZZZZZZZZZZ
   ```
4. **Google Play Console Actions:**
   - Create a new app listing for `Shift Puzzle` under `com.shiftpuzzle.game`.
   - Enter copy from `TASK_21_STORE_LISTING.md`.
   - Complete Data Safety using `TASK_21_DATA_SAFETY_MATRIX.md`.
   - Complete App Content questionnaires using `TASK_21_PLAY_CONSOLE_DECLARATIONS.md`.
   - Create a release in **Closed testing**, upload `app-release.aab`, and invite initial testers.

---

## 20. Final Status

### **CONDITIONALLY READY — SPECIFIC RELEASE ITEMS REMAIN**

All engineering quality gates, regression suites, manifest compliance audits, and build pipelines have completed successfully. External submission to Google Play Console remains pending the developer's upload keystore and graphic asset export.

---

## 21. Exact Next Actions

1. Review and commit the Task 21 compliance and documentation suite.
2. Prepare the 3 graphic store assets (512×512 Icon, 1024×500 Feature Graphic, Screenshots).
3. Generate local release signature and perform final upload to Play Console Closed Testing track.
