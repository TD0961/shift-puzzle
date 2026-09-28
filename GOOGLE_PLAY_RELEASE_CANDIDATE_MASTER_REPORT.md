# SHIFT PUZZLE — GOOGLE PLAY CLOSED TESTING MASTER RELEASE REPORT

**Project:** Shift Puzzle  
**Stack:** Flutter 3.47.5 / Flame 1.38.2  
**Package:** `com.shiftpuzzle.game`  
**Current Version:** `1.0.0+2` (versionCode: `2`, versionName: `1.0.0`)  
**Campaign Scope:** 150 Handcrafted Levels / 15 Chapters / 84 Memory Echo Levels  
**Baseline Verified:** Tasks 18, 19, 20 & 21  
**Status:** **CONDITIONALLY READY — SPECIFIC RELEASE ITEMS REMAIN**  
**Date:** September 28, 2026  

---

## TABLE OF CONTENTS
1. [Executive Summary & Authoritative Baseline](#1-executive-summary--authoritative-baseline)
2. [Release Readiness Gate Table](#2-release-readiness-gate-table)
3. [Absolute No-Go Conditions Audit](#3-absolute-no-go-conditions-audit)
4. [Package, Build & Version Configuration](#4-package-build--version-configuration)
5. [Production Signing Architecture](#5-production-signing-architecture)
6. [AdMob Architecture & Fail-Safe Test Isolation](#6-admob-architecture--fail-safe-test-isolation)
7. [Store Listing Metadata & Copy](#7-store-listing-metadata--copy)
8. [Store Graphic Assets Specifications & Checklist](#8-store-graphic-assets-specifications--checklist)
9. [Play Console Policy Declarations & IARC Rating](#9-play-console-policy-declarations--iarc-rating)
10. [Google Play Data Safety Form Matrix](#10-google-play-data-safety-form-matrix)
11. [Offline-First Architecture & Economy Preservation](#11-offline-first-architecture--economy-preservation)
12. [Automated Regression & Test Results (313/313)](#12-automated-regression--test-results-313313)
13. [Release Binary Build Verifications (AAB / APK)](#13-release-binary-build-verifications-aab--apk)
14. [Git Cleanliness & Secret Audit](#14-git-cleanliness--secret-audit)
15. [Completed Local Verification vs External/Manual Verification](#15-completed-local-verification-vs-externalmanual-verification)
16. [Developer Step-by-Step Pre-Submission Action Guide](#16-developer-step-by-step-pre-submission-action-guide)

---

## 1. Executive Summary & Authoritative Baseline

This master document unifies all release engineering, compliance, monetization safety, store listing copy, and quality gate audits for deploying *Shift Puzzle* to the Google Play Console Closed Testing track.

### Authoritative Frozen Baselines:
- **Task 18 (Mathematical Integrity):** All 150 campaign levels independently verified using an exact bidirectional BFS solver. 100% agreement between stored and calculated minimal pars; 0 overstated pars; 0 understated pars; 84 Echo levels verified; Level 150 mathematically proven at exactly 9 optimal moves. Content strictly frozen.
- **Task 19 (Gameplay & Monetization QA):** 313 automated tests passed. BUG-19-01 fixed (`PopScope(canPop: false)` on `WinDialog`). Move limit (`optimal + 3`), Undo Lock, Memory Echo, and Rewarded +5 rescue verified under rapid interaction, double-reward protection, and offline/online failure conditions.
- **Task 20 (Release Candidate Validation):** Clean release APK (`50.5 MB`) and AAB (`52.5 MB`) generated. Physical device status explicitly documented as unverified due to lack of connected physical hardware in host environment.
- **Task 21 (Play Store Compliance):** Completed Data Safety matrix, IARC rating questionnaire, Target Audience declarations (13+ general audience, exempt from Families Policy ad restrictions), store copy, and fail-safe AdMob production isolation.

---

## 2. Release Readiness Gate Table

| Quality Gate | Status | Evidence / Notes |
|---|---|---|
| **Package ID** | **PASS** | `com.shiftpuzzle.game` matches across Gradle, Manifest, and Dart. |
| **Version Code & Name** | **PASS** | `versionName: 1.0.0`, `versionCode: 2` verified in `pubspec.yaml` and Gradle. |
| **Release Signing** | **READY (TEMPLATE / CI)** | Configuration in `build.gradle.kts`; developer supplies private `key.properties`. |
| **AdMob Architecture** | **PASS** | Missing production IDs in production mode fail safely without serving test ads. |
| **Test AdMob Isolation** | **PASS** | Test IDs used exclusively in debug/test environments; locked behind compile flags. |
| **Privacy Policy** | **PASS** | Comprehensive policy in `PRIVACY_POLICY.md` reflects AdMob, +5 rescue, and local storage. |
| **Data Safety Matrix** | **PASS (READY)** | Complete field-by-field entry guide documented in Section 10. |
| **Target Audience (13+)** | **PASS (READY)** | 13+ general audience justified; exempt from Families Policy ad restrictions. |
| **Content Rating (IARC)** | **PASS (READY)** | Questionnaire responses verified (expecting PEGI 3 / ESRB Everyone / USK 0). |
| **Ads Declaration** | **PASS (READY)** | Declared "Contains Ads"; Advertising ID usage declared for ad serving & fraud prevention. |
| **Store Listing Copy** | **PASS (READY)** | Title, 80-char short description, and full description prepared in Section 7. |
| **App Icon (512×512)** | **PENDING EXPORT** | Specifications provided; requires developer export before Play Console upload. |
| **Feature Graphic (1024×500)**| **PENDING DESIGN** | Specifications provided; requires developer design before Play Console upload. |
| **Phone Screenshots** | **PENDING CAPTURE** | Minimum 2 (recommended 4–5) screenshots required from release build. |
| **APK Launcher Icons** | **PASS** | `ic_launcher.png` present across all mipmap densities (`mdpi` to `xxxhdpi`). |
| **Manifest & Permissions** | **PASS** | `INTERNET` and `ACCESS_NETWORK_STATE` only. Zero dangerous/runtime permissions. |
| **Orientation Lock** | **PASS** | `android:screenOrientation="portrait"` locked in `AndroidManifest.xml`. |
| **Offline Gameplay** | **PASS** | 100% of levels, mechanics, and local saves function without internet connectivity. |
| **Full Regression Tests** | **PASS** | **313 / 313 tests passed** (0 failures, 0 errors). |
| **Static Code Analysis** | **PASS** | `flutter analyze`: **0 issues** (0 errors, 0 warnings). |
| **Release APK Build** | **PASS** | `build/app/outputs/flutter-apk/app-release.apk` (**49 MB**). |
| **Release AAB Build** | **PASS** | `build/app/outputs/bundle/release/app-release.aab` (**51 MB**). |
| **Content Freeze** | **PASS** | 150/150 levels, pars, grids, and targets strictly frozen. |
| **Git Cleanliness** | **PASS** | Clean working tree; zero keystores, passwords, or secrets tracked in git. |
| **Physical Device Playtest** | **UNVERIFIED** | Sideload sanity playtest on physical handset required prior to public rollout. |
| **Live Production Ad Serving**| **UNVERIFIED** | Requires live production ad unit IDs and Google Play store activation. |

---

## 3. Absolute No-Go Conditions Audit

Every release-blocker condition was evaluated against the repository:

1. **Production AdMob still using test IDs?**  
   **NO.** In production mode (`_isProductionMode == true`), test IDs are strictly disabled. Missing IDs evaluate to empty strings and skip ad loading rather than serving test ads.
2. **Missing production AdMob IDs in repository?**  
   **CONFIRMED INTENTIONAL.** Production IDs are injected at build time via `--dart-define` to keep secrets out of source control.
3. **Production signing unavailable in CI/repo?**  
   **CONFIRMED INTENTIONAL.** Secrets are kept out of git. Signing template provided in `key.properties.example`.
4. **Secrets or keystores committed to Git?**  
   **NO.** Git log and `.gitignore` verified. No `.jks`, `.keystore`, or `key.properties` exist in Git.
5. **Incorrect package ID or version?**  
   **NO.** Package is `com.shiftpuzzle.game`, version is `1.0.0+2`.
6. **Broken or missing privacy policy?**  
   **NO.** `PRIVACY_POLICY.md` is complete, accurate, and reflects current game features.
7. **Unknown Data Safety declarations?**  
   **NO.** Completely documented in Section 10.
8. **Missing mandatory store assets?**  
   **YES (PENDING DEVELOPER EXPORT).** 512×512 Icon, 1024×500 Feature Graphic, and screenshots must be uploaded to Play Console.
9. **Gameplay regression or puzzle content modification?**  
   **NO.** 313/313 tests passed. 150/150 levels mathematically frozen.
10. **Release build failure?**  
    **NO.** Both APK and AAB build cleanly with 0 errors.

---

## 4. Package, Build & Version Configuration

### Identification
- **Application ID:** `com.shiftpuzzle.game`
- **Version Name:** `1.0.0`
- **Version Code:** `2`
- **Minimum SDK:** `21` (Android 5.0 Lollipop)
- **Target SDK:** `36` (Android 16)
- **Compile SDK:** `36`

### Manifest Configuration (`android/app/src/main/AndroidManifest.xml`)
- **Permissions:**
  - `android.permission.INTERNET` (Required by Google Mobile Ads SDK).
  - `android.permission.ACCESS_NETWORK_STATE` (Required to check network state before requesting ads).
  - *Zero runtime / dangerous permissions requested.*
- **Orientation:**
  - `android:screenOrientation="portrait"` locked for consistent gameplay layout.
- **Hardware Acceleration:**
  - `android:hardwareAccelerated="true"` enabled for 60/120 FPS Flame rendering.
- **AdMob App ID:**
  - Configured via manifest placeholder `${admobAppId}` defaulting to Google's safe sample App ID in test environments, or overridden via `key.properties` / `ADMOB_APP_ID` environment variable for production builds.

---

## 5. Production Signing Architecture

### Signing Configuration (`android/app/build.gradle.kts`)
```kotlin
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

signingConfigs {
    create("release") {
        if (keystorePropertiesFile.exists()) {
            keyAlias = keystoreProperties.getProperty("keyAlias")
            keyPassword = keystoreProperties.getProperty("keyPassword")
            val storeFilePath = keystoreProperties.getProperty("storeFile")
            if (storeFilePath != null) {
                storeFile = file(storeFilePath)
            }
            storePassword = keystoreProperties.getProperty("storePassword")
        }
    }
}
```

### Git Exclusion Verification (`.gitignore`)
```gitignore
# Android signing secrets & local properties
**/android/local.properties
**/android/key.properties
*.jks
*.keystore
*.p12
*.pem
secrets.json
```

### Instructions for Developer Keystore Setup
1. Copy `android/key.properties.example` to `android/key.properties`.
2. Generate an upload keystore if not already created:
   ```bash
   keytool -genkey -v -keystore android/app/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
3. Populate `android/key.properties`:
   ```properties
   storePassword=YOUR_KEYSTORE_PASSWORD
   keyPassword=YOUR_KEY_PASSWORD
   keyAlias=upload
   storeFile=upload-keystore.jks
   admobAppId=ca-app-pub-YOUR_ADMOB_APP_ID~XXXXXXXXXX
   ```

---

## 6. AdMob Architecture & Fail-Safe Test Isolation

### Ad Unit IDs
- **Official Google Test IDs (Used in Debug/Testing):**
  - Android Rewarded Test: `ca-app-pub-3940256099942544/5224354917`
  - Android Interstitial Test: `ca-app-pub-3940256099942544/1033173712`
  - iOS Rewarded Test: `ca-app-pub-3940256099942544/1712485313`
  - iOS Interstitial Test: `ca-app-pub-3940256099942544/4411468910`

### Production Switching & Fail-Safe Protection
In `lib/core/monetization/admob_ad_service.dart`:
```dart
  static const String _envInterstitial = String.fromEnvironment('ADMOB_INTERSTITIAL_ID');
  static const String _envRewarded = String.fromEnvironment('ADMOB_REWARDED_ID');
  static const bool _isProductionMode = bool.fromEnvironment('ADMOB_PRODUCTION_MODE', defaultValue: false);

  String get interstitialAdUnitId {
    if (customInterstitialUnitId != null) return customInterstitialUnitId!;
    if (!kDebugMode && _isProductionMode) {
      return _envInterstitial; // Returns empty string if unsupplied
    }
    return defaultTargetPlatform == TargetPlatform.iOS
        ? _iosTestInterstitial
        : _androidTestInterstitial;
  }

  String get rewardedAdUnitId {
    if (customRewardedUnitId != null) return customRewardedUnitId!;
    if (!kDebugMode && _isProductionMode) {
      return _envRewarded; // Returns empty string if unsupplied
    }
    return defaultTargetPlatform == TargetPlatform.iOS
        ? _iosTestRewarded
        : _androidTestRewarded;
  }
```
**Fail-Safe Enforcement:**
If `ADMOB_PRODUCTION_MODE=true` is passed in a release build without supplying `ADMOB_REWARDED_ID`, `rewardedAdUnitId` returns `""` (empty string). Both `_loadRewardedAd()` and `_loadInterstitialAd()` guard against empty IDs:
```dart
    if (rewardedAdUnitId.isEmpty) {
      debugPrint('[AdMobAdService] Rewarded ad unit ID is empty or unconfigured. Skipping load.');
      return;
    }
```
**Result:** The game skips the ad request cleanly, shows the unavailable dialog, and **never** makes an invalid call to Google test units in production.

---

## 7. Store Listing Metadata & Copy

### App Title
```text
Shift Puzzle
```
*(12 / 30 characters)*

### Short Description
```text
Slide rows & columns on a toroidal grid. Master the loop with Memory Echo!
```
*(74 / 80 characters)*

### Full Description
```text
Shift Puzzle is a minimalist spatial logic puzzle game where the board has no boundaries and your past moves return to alter the present.

Slide rows and columns across a 5×5 toroidal grid—pieces that exit one edge seamlessly re-emerge on the opposite side. Plan your paths, coordinate geometric gems, and guide each piece to its matching target in as few moves as possible.

MASTER THE MEMORY ECHO
Discover Shift Puzzle's signature temporal mechanic: Memory Echo.
• Record: Capture a precise sequence of row and column shifts.
• Reposition: Move your pieces into new strategic configurations.
• Echo: Replay your recorded moves as an automated ghost sequence that rearranges the board.
• Finish: Solve complex spatial locks that are impossible through conventional shifts alone.

150 HANDCRAFTED CAMPAIGN LEVELS
Journey through 15 distinct thematic chapters with a steady, rewarding mastery curve:
• Chapter I: The Foundations (Levels 1–10: single & dual-piece basics, toroidal wrapping)
• Chapter II: Temporal Awakening (Levels 11–20: introduction of the Memory Echo mechanic)
• Chapter III: Spatial Matrices (Levels 21–30: parity constraints & synchronized crossings)
• Chapter IV: Complex Machines (Levels 31–40: cyclic permutations & multi-piece coordination)
• Chapter V: Grandmaster (Levels 41–50: deep planning & spatial mastery)
• Chapter VI: Advanced Echo (Levels 51–60: timing chains & displaced returns)
• Chapter VII: Spatial Paradoxes (Levels 61–70: cross-axis dependencies & toroidal loops)
• Chapter VIII: Temporal Machines (Levels 71–80: cascading replay mechanisms)
• Chapter IX: Mastery (Levels 81–90: complex multi-piece routing)
• Chapter X: The Final Shift (Levels 91–100: the first grand culmination)
• Chapter XI: Harmonic Resonance (Levels 101–110: symmetric color topologies & dual balance)
• Chapter XII: Quantum Entanglement (Levels 111–120: coupled axis shifts & parity locks)
• Chapter XIII: The Echo Nexus (Levels 121–130: deep macro planning & phased replays)
• Chapter XIV: Chrono Dynamics (Levels 131–140: strict move budgeting & momentum)
• Chapter XV: The Singularity (Levels 141–150: the ultimate campaign climax culminating in "The Grand Singularity")

KEY FEATURES
• 100% Deterministic Logic: Every level has been mathematically verified with an exact minimal-move par.
• Tactile Controls: Responsive swipe physics with fluid animations and haptic feedback.
• 3-Star Mastery: Compare your solve against the minimal par on every board.
• Player-First Economy: Generous move limits (optimal + 3) allow room for experimentation.
• Optional Rewarded Assistance:
  - Rewarded Hint: Reveal one useful next move when you're searching for an angle.
  - Rewarded +5 Rescue: Add 5 extra moves when reaching the move limit to save a deep run.
• Offline-Friendly: Play the entire 150-level campaign offline with full local progress saving—no accounts or internet connection required for puzzle gameplay.
• Clean & Respectful: No energy bars, no lives, no forced mid-puzzle popups, and no in-board banner ads.

Can you master the toroidal loop and conquer The Grand Singularity?
```
*(2,764 / 4,000 characters)*

### Categorization & Tags
- **Type:** Game
- **Category:** Puzzle
- **Tags:** Puzzle, Brain Games, Logic, Minimalist, Single Player, Offline

---

## 8. Store Graphic Assets Specifications & Checklist

| Asset | Exact Dimensions | Format | Requirements & Guidelines | Status |
|---|---|---|---|---|
| **App Icon** | 512 × 512 px | 32-bit PNG | Flat, square, no rounded corners (Google Play applies 20% squircle mask). Dark slate `#090D16` with cyan ring. Max 1024 KB. | **PENDING EXPORT** |
| **Feature Graphic** | 1024 × 500 px | JPEG or 24-bit PNG | Minimalist obsidian background with cyan/amber grid accents and title "Shift Puzzle". No promotional badges ("Free", "No. 1"). Max 15 MB. | **PENDING DESIGN** |
| **Phone Screenshots** | Min 1080 px short side | 9:16 or 16:9 PNG/JPEG | Min 2, Recommended 4–5 screenshots showing: Toroidal Shifting, Memory Echo, Campaign Map, 3-Star Par Comparison, and Solver Hint. | **PENDING CAPTURE** |
| **Tablet Screenshots** | Min 1080 px short side | 16:9 or 9:16 PNG/JPEG | Optional for closed testing; recommended for tablet store visibility. | **OPTIONAL** |
| **Launcher Icon** | Mipmap sizes | PNG | Already present in `android/app/src/main/res/mipmap-*/ic_launcher.png`. | **PRESENT** |

---

## 9. Play Console Policy Declarations & IARC Rating

### App Access
- **Option Selected:** **All functionality is available without special access restrictions.**
- **Reasoning:** Zero user accounts, zero logins, zero subscriptions. All 150 levels unlock through gameplay.

### Ads Declaration
- **Option Selected:** **Yes, my app contains ads.**
- **Details:** Optional rewarded ads for hints / +5 move rescue; capped level-transition interstitials (after Level 10, 3-min cooldown, 4-level frequency cap).

### Advertising ID (AAID)
- **Option Selected:** **Yes.**
- **Declared Purposes:** Advertising or marketing, Analytics, Fraud prevention and security.

### Target Audience & Families Policy
- **Target Age Groups:** **13–15**, **16–17**, **18 and over**.
- **Could your app unintentionally appeal to children?** → **No.**
- **Reasoning:** Abstract geometric logic aesthetic, technical puzzle nomenclature, dark-mode slate UI. Exempt from Families Policy program restrictions.

### Content Rating (IARC Questionnaire)
- **Violence:** None (0)
- **Fear / Horror:** None (0)
- **Sexuality:** None (0)
- **Profanity / Language:** None (0)
- **Controlled Substances:** None (0)
- **Simulated Gambling:** None (0)
- **User Interactions / Chat:** None (0)
- **In-App Purchases:** None (0)
- **Expected Global Ratings:** **PEGI 3** / **ESRB Everyone** / **USK 0** / **ACB G**.

---

## 10. Google Play Data Safety Form Matrix

| Data Category | Specific Data Type | Collected? | Shared? | Purposes | User Choice | Associated SDK |
|---|---|---|---|---|---|---|
| **Location** | **Approximate location** (coarse) | **Yes** | **Yes** | • Advertising or marketing | Required for ads | **Google Mobile Ads** |
| **App Activity** | **App interactions** (ad views, clicks) | **Yes** | **Yes** | • Advertising or marketing<br>• Analytics | Required for ads | **Google Mobile Ads** |
| **App Info / Diagnostics**| **Crash logs** & diagnostics | **Yes** | **Yes** | • Analytics<br>• Fraud prevention & security | Required for ads | **Google Mobile Ads** |
| **Device or other IDs** | **Device or other IDs** (Advertising ID) | **Yes** | **Yes** | • Advertising or marketing<br>• Fraud prevention & security | Required for ads | **Google Mobile Ads** |
| **All Other Categories** | Personal info, financial, media, contacts | **No** | **No** | N/A | N/A | *Zero First-Party Accounts* |

### First-Party Local Data (`SharedPreferences`)
Game progress (`completed_levels`, `level_stars`, `level_best_moves`, `highest_unlocked_level`, `sound_enabled`) is stored strictly on the local device sandboxed storage. Under Google Play guidelines, data stored strictly on-device without remote transmission is **not** classified as "Collected".

---

## 11. Offline-First Architecture & Economy Preservation

### Offline-First Rules
- **Core Puzzle Gameplay:** 100% offline. Zero network calls, zero accounts, zero cloud dependencies.
- **Offline Hint:** Intercepts before network request and presents `InternetNeededDialog`.
- **Offline +5 Rescue:** Intercepts before network request and presents `InternetNeededDialog`.
- **Online Ad Unavailable:** Shows `HintUnavailableDialog` with retry logic; never gives a false error.

### Move Economy & Reward Rules
- **Move Budget:** Normal limit = `optimalMoves + 3`.
- **Undo Lock:** Active at `playerMoveCount >= optimalMoves` and remains locked through extended moves.
- **Optimal Drift Nudge:** Displays once at `optimalMoves + 1`.
- **Rewarded +5 Rescue:**
  - Active at `optimalMoves + 3` if puzzle is unsolved.
  - Exactly +5 moves added upon verified callback.
  - Attempt limit becomes `optimalMoves + 8`.
  - Exactly one rescue per attempt.
  - Victory precedence: If the move reaching `optimal + 3` or `optimal + 8` solves the puzzle, `WinDialog` takes precedence and `MoveLimitDialog` is never shown.

---

## 12. Automated Regression & Test Results (313/313)

- **Test Suite Results:** `flutter test` executed across all 21 test files:
  - Task 18 Math Audit tests: **10/10 passed** (all 150 levels validated).
  - Task 19 Release Candidate tests: **14/14 passed** (state machine, input lock, Android Back, offline flow).
  - Full Project Suite: **313 / 313 PASSED** (0 failures, 0 errors, 0 skipped).
  - Full suite execution time: **2m 15s**.
- **Static Code Analysis:** `flutter analyze`:
  - **No issues found!** (0 warnings, 0 errors).

---

## 13. Release Binary Build Verifications (AAB / APK)

### Release App Bundle (AAB)
- **Path:** `build/app/outputs/bundle/release/app-release.aab`
- **File Size:** **52.5 MB** (51 MB binary, 53,477,376 bytes)
- **Compilation:** Clean Gradle `bundleRelease` build in **20.7s**.
- **Icon Tree-Shaking:** `MaterialIcons-Regular.otf` tree-shaken by 99.7% (1,645,184 bytes → 4,472 bytes).

### Release APK
- **Path:** `build/app/outputs/flutter-apk/app-release.apk`
- **File Size:** **50.5 MB** (49 MB binary, 51,902,464 bytes)
- **Compilation:** Clean Gradle `assembleRelease` build in **16.2s**.

---

## 14. Git Cleanliness & Secret Audit

- **Git Status:** Clean working tree on `main` branch.
- **Git Commit History:**
  - `1928fd1` Task 21: Google Play Closed Testing Preparation
  - `b5f0584` Task 20: Physical Android Release-Candidate Validation Report
  - `c6895ac` Task 19: Full Gameplay, Monetization & Release-Candidate QA Audit
  - `787f056` Task 18: Authoritative Optimal-Move Integrity Audit for All 150 Levels
- **Secrets Check:**
  - Zero private keystores (`*.jks`, `*.keystore`) committed.
  - Zero passwords or sensitive credentials committed.
  - `android/key.properties` is strictly ignored by `.gitignore`.

---

## 15. Completed Local Verification vs External/Manual Verification

| Scope | Category | Verification Status | Details |
|---|---|---|---|
| **Local** | **150-Level Mathematics** | **100% VERIFIED** | 150/150 exact minimal pars verified via BFS solver (Task 18). |
| **Local** | **Gameplay Regression** | **100% VERIFIED** | 313/313 automated tests passing cleanly. |
| **Local** | **Static Analysis** | **100% VERIFIED** | `flutter analyze` reports 0 issues. |
| **Local** | **Release Builds** | **100% VERIFIED** | Release APK (50.5 MB) and AAB (52.5 MB) compile with 0 errors. |
| **Local** | **AdMob Test Isolation** | **100% VERIFIED** | Fail-safe empty ID protection verified in production mode. |
| **Local** | **Offline Gameplay** | **100% VERIFIED** | Puzzles, progress, and UI operate 100% offline. |
| **Local** | **Git Cleanliness** | **100% VERIFIED** | Zero secrets or temporary artifacts in Git tree. |
| **External** | **Physical Sideload** | **UNVERIFIED** | No physical handset attached via ADB; manual sanity playtest required. |
| **External** | **Production Ad Creative** | **UNVERIFIED** | Live ad rendering requires store publication and live ad unit IDs. |
| **External** | **Release Keystore** | **PENDING DEVELOPER** | Developer must supply local `android/key.properties`. |
| **External** | **Store Graphic Assets** | **PENDING DEVELOPER** | 512×512 Icon, 1024×500 Feature Graphic, and Screenshots require export. |
| **External** | **Play Console Upload** | **READY FOR ENTRY** | Form entries documented in this report. |

---

## 16. Developer Step-by-Step Pre-Submission Action Guide

### Step 1: Create Your Release Keystore (Local Machine)
If you do not have an existing upload keystore, run:
```bash
keytool -genkey -v -keystore android/app/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```
Create `android/key.properties` (never commit this file):
```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=upload-keystore.jks
admobAppId=ca-app-pub-YOUR_ADMOB_APP_ID~XXXXXXXXXX
```

### Step 2: Export Store Graphic Assets
- **App Icon:** Export a `512 × 512` 32-bit PNG (dark slate `#090D16` with cyan ring/gem).
- **Feature Graphic:** Create a `1024 × 500` PNG/JPEG (minimalist dark obsidian with title "Shift Puzzle").
- **Screenshots:** Capture 4–5 screenshots (1080×1920 or 1080×2400) from the release APK.

### Step 3: Build the Signed Production AAB
Execute the production build command with your live AdMob IDs:
```bash
flutter build appbundle --release \
  --dart-define=ADMOB_PRODUCTION_MODE=true \
  --dart-define=ADMOB_REWARDED_ID=ca-app-pub-YOUR_PUBLISHER_ID/YOUR_REWARDED_UNIT_ID \
  --dart-define=ADMOB_INTERSTITIAL_ID=ca-app-pub-YOUR_PUBLISHER_ID/YOUR_INTERSTITIAL_UNIT_ID
```
The output file will be at:
`build/app/outputs/bundle/release/app-release.aab`

### Step 4: Submit to Google Play Console
1. Log in to [Google Play Console](https://play.google.com/console).
2. Create app: **Shift Puzzle** (Game > Puzzle, Free).
3. **App Content & Policy Declarations:**
   - **Privacy Policy:** Link to hosted URL of `PRIVACY_POLICY.md`.
   - **App Access:** Select *All functionality is available without special access restrictions*.
   - **Ads:** Select *Yes, my app contains ads*.
   - **Advertising ID:** Select *Yes* (Advertising or marketing, Analytics, Fraud prevention).
   - **Target Audience:** Select *13–15, 16–17, 18+*. Select *No* to unintentionally appealing to children.
   - **Content Rating (IARC):** Complete questionnaire (all categories None/0; rating: PEGI 3 / ESRB E).
   - **Data Safety:** Complete using the matrix in Section 10 of this report.
4. **Main Store Listing:**
   - Paste Title, Short Description, and Full Description from Section 7.
   - Upload 512×512 Icon, 1024×500 Feature Graphic, and Phone Screenshots.
5. **Closed Testing Track:**
   - Go to **Testing > Closed testing**.
   - Create a new release, upload `app-release.aab`, add release notes, and assign test track users.
   - Submit for review.
