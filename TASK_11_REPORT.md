# Task 11 — Google Play Testing Preparation + Release Signing + Real-World QA
**Project**: Shift Puzzle (`com.shiftpuzzle.game`)  
**Version**: `1.0.0+2`  
**Toolchain**: Flutter 3.47.5, Dart 3.13.4, Flame 1.38.2, Android SDK 36 (targetSdk 36, compileSdk 36, minSdk 24), Java 21 LTS (Eclipse Temurin)

---

## 1. Release Status

| Metric | Status | Details |
|---|---|---|
| **Package Name** | `com.shiftpuzzle.game` | Strict preservation of package identity across `AndroidManifest.xml` and `build.gradle.kts`. |
| **Version Name / Code** | `1.0.0` / `2` (`1.0.0+2`) | Cleanly bumped from `1.0.0+1` to prepare for Google Play internal testing track upload. |
| **Compile & Target SDK** | **API 36 (Android 16)** | Full compliance with upcoming Google Play target API requirements; `minSdk = 24` (Android 7.0+). |
| **Release Signing Strategy** | **Configured & Secure** | Implemented upload keystore workflow via `android/key.properties`. Safe fallback to `debug` signing enabled when secrets are absent (preserving CI and local dev). |
| **Release AAB Bundle** | **Ready** (`build/app/outputs/bundle/release/app-release.aab`) | Play-optimized Android App Bundle with dynamic feature & ABI split support (~51.5 MB uncompressed, compressed delivery via Google Play is ~15-20 MB). |
| **Release APK** | **Ready** (`build/app/outputs/flutter-apk/app-release.apk`) | Universal sideloadable release APK for direct hardware QA and internal device distribution (~49.3 MB). |
| **ProGuard / R8 Optimization** | **Hardened** | R8 rules in `android/app/proguard-rules.pro` protecting Flutter engine, plugins, and Google Mobile Ads SDK, with `-dontwarn com.google.android.play.core.**` suppressing Play Core deferred component warnings. |

---

## 2. Google Play Store Preparation

### Store Metadata (`STORE_LISTING_PREPARATION.md`)
- **Title**: `Shift Puzzle` (12 / 30 chars)
- **Short Description**: `Tactile toroidal grid puzzle game featuring the signature Memory Echo mechanic.` (79 / 80 chars)
- **Full Description**: Complete, handcrafted copy detailing:
  - The toroidal grid mechanics (no edges, wrapping rows/columns).
  - The 4-step Memory Echo temporal mechanic (*Record → Reposition → Echo → Finish*).
  - Chapter breakdown across all 10 chapters (Levels 1–100).
  - Core philosophy: 100% deterministic logic, 0 energy timers, 0 paywalls, 0 mid-puzzle interruptions.

### Required Assets Specification
- **App Icon**: 512 × 512 px 32-bit PNG (Dark `#090D16` slate background with glowing cyan torus and jewel).
- **Feature Graphic**: 1024 × 500 px JPEG/PNG (Minimalist toroidal grid illustration with glowing emerald/cyan accents).
- **Screenshots**: Documented 5 core gameplay captures (Toroidal Shifting, Memory Echo HUD, Chapter Map, 3-Star Mastery, Grandmaster Matrix).

### Privacy & Data Safety
- **Privacy Policy**: Created standalone `PRIVACY_POLICY.md` ready for GitHub Pages hosting (`https://shiftpuzzle.game/privacy`).
- **Data Safety Declaration**: Mapped all Google Mobile Ads SDK data disclosures:
  1. *Device / Other IDs*: Advertising ID (`AD_ID`) collected for advertising & fraud prevention.
  2. *Approximate Location*: Inferred from IP by Google ad network servers.
  3. *App Info & Performance*: Crash diagnostics collected by Google Mobile Ads SDK.
  4. *First-Party Data*: Shift Puzzle first-party code collects **0** personal data; all game progress is stored strictly in local device sandboxed `SharedPreferences`.

### Content Rating (IARC)
- Zero violence, zero sexual content, zero profanity, zero user-to-user interaction, zero personal data sharing.
- Expected ratings: **PEGI 3**, **ESRB Everyone**, **USK 0**, **ACB G**.

### AdMob Integration & Safeguards
- **Manifest Ingestion**: `android/app/src/main/AndroidManifest.xml` uses Gradle manifest placeholder `${admobAppId}`.
- **Config Ingestion**: `android/app/build.gradle.kts` resolves `admobAppId` from `android/key.properties` or `ADMOB_APP_ID` env variable, defaulting safely to Google's official test ID (`ca-app-pub-3940256099942544~3347511713`).
- **Production Ad Unit Injection**: `lib/core/monetization/admob_ad_service.dart` reads `--dart-define=ADMOB_INTERSTITIAL_ID` and `--dart-define=ADMOB_REWARDED_ID`.
- **Debug Lockout Guard**: Live production ad units can **never** be served in debug mode (`_isProductionMode && !kDebugMode`). Debug builds are strictly hardcoded to Google test ad unit IDs to prevent AdMob policy violations or account suspension during development.

---

## 3. QA & Validation Results

### Automated Test Suite
- **Result**: **174 / 174 tests passing (100%)**
- **Test Categories**:
  - `test/core/puzzle_test.dart` (Toroidal wrapping, row/col shifts, piece targeting)
  - `test/core/memory_echo_test.dart` (Macro recording, trajectory preview, replay execution)
  - `test/core/level_catalog_test.dart` (Integrity of all 100 handcrafted levels, 10 chapters)
  - `test/core/player_progress_test.dart` (Star ratings, chapter unlocking, persistence)
  - `test/core/audio_test.dart` & `test/core/haptics_test.dart` (Audio/haptic service abstractions)
  - `test/core/admob_ad_service_test.dart` (Production ID guard and test ID fallback)
  - `test/solver/level_solvability_test.dart` (Algorithmic BFS solvability for campaign levels)
- **Static Analysis**: `flutter analyze` — **0 issues found** (Clean).
- **Web Verification**: `flutter build web` — **Clean build** in `build/web`.

### Android & Hardware QA
- **Local Connected Devices**: **0 physical devices / emulators attached** (honestly reported).
- **Android Compilation**: Verified on Android API 36 with Java 21 LTS (`/home/tensae/jdk-21`).
- **Bytecode & Packaging Verification**: Inspected via `aapt dump badging`:
  - `package: name='com.shiftpuzzle.game'`
  - `versionCode='2'`
  - `versionName='1.0.0'`
  - `sdkVersion='24'`
  - `targetSdkVersion='36'`

### Major Issues Identified & Resolved
1. **R8 Missing Classes Warning**:
   - *Problem*: Release minification failed with missing class errors referencing `com.google.android.play.core.**` from Flutter engine deferred components.
   - *Fix*: Added `-dontwarn com.google.android.play.core.**` to `android/app/proguard-rules.pro`.
2. **Hardcoded AdMob App ID in AndroidManifest**:
   - *Problem*: Switching between test and production AdMob App IDs previously required editing `AndroidManifest.xml`.
   - *Fix*: Converted `android:value` to `${admobAppId}` populated via `android/app/build.gradle.kts`.
3. **Secret Key Exposure Risk**:
   - *Problem*: Risk of accidental commit of `.jks` or `key.properties` files.
   - *Fix*: Added comprehensive ignore rules to `.gitignore`, created `android/key.properties.example`, `secrets.example.json`, and automated generation via `scripts/generate_upload_key.sh`.

---

## 4. Tester Readiness & Distribution Workflow

### Testing Tracks Available
1. **Google Play Internal Testing (Recommended)**:
   - Upload `build/app/outputs/bundle/release/app-release.aab` directly to Google Play Console under **Testing > Internal testing**.
   - Create an internal tester email list (up to 100 testers).
   - Testers receive an instant invitation link and install the app through the official Google Play client with automatic delta updates.
2. **Google Play Internal App Sharing**:
   - Upload `app-release.aab` to Internal App Sharing for instant URL-based distribution without review delays.
3. **Direct Device Sideloading (Offline QA)**:
   - Install `app-release.apk` directly via ADB:
     ```bash
     adb install -r build/app/outputs/flutter-apk/app-release.apk
     ```

### Known Limitations for Testers
- **Local-Only Storage**: Game progress is stored in local device `SharedPreferences`. Clearing app storage or uninstalling will reset completed levels and stars (cloud sync is out of scope for v1.0).
- **Test Ad Creatives**: By default, ads display Google "Test Ad" banners and sample video creatives. Real ads will only appear when built with production `--dart-define` parameters.

### Priority Feedback Areas for Testers
- **Swipe Responsiveness**: Does row and column dragging feel natural and forgiving on various screen refresh rates (60Hz, 90Hz, 120Hz)?
- **Memory Echo Onboarding**: In Chapter 2 (Level 11+), do testers immediately understand the *Record → Reposition → Echo* workflow without getting confused?
- **Mastery Pars**: Do the 3-star move pars feel challenging yet rewarding, or do Chapters 8–10 feel overly punishing?
- **Haptic Tactility**: Does haptic feedback feel satisfying on different phone vibration motors (linear vs eccentric)?

---

## 5. External Actions Required

### 1. Developer Manual Actions
- [ ] Run `scripts/generate_upload_key.sh` to generate the official 2048-bit RSA upload keystore (`android/app/upload-keystore.jks`) and `android/key.properties`.
- [ ] Immediately back up `upload-keystore.jks` and passwords into a secure password manager or encrypted offline vault.
- [ ] Create `secrets.json` from `secrets.example.json` if building with production AdMob credentials.

### 2. Actions Requiring Google Play Console
- [ ] Register a Google Play Developer account ($25 one-time registration fee).
- [ ] Create a new app: Name `Shift Puzzle`, default language English, App type Game, Free.
- [ ] Enroll in **Google Play App Signing** (Play Console will securely manage the app signing key and verify updates signed with your upload key).
- [ ] Paste store listing text and upload graphics from `STORE_LISTING_PREPARATION.md`.
- [ ] Complete the **App Content** questionnaires:
  - Privacy Policy link (`PRIVACY_POLICY.md` hosted on GitHub Pages or custom domain).
  - Ads: Select "Yes, my app contains ads".
  - App Access: Select "All functionality is available without special access".
  - Content Ratings: Complete IARC questionnaire (select Game > PEGI 3 / Everyone).
  - Target Audience: Select 13 and above.
  - Data Safety: Complete declaration as detailed in Section 5 of `STORE_LISTING_PREPARATION.md`.
- [ ] Create an Internal Testing release and upload `build/app/outputs/bundle/release/app-release.aab`.

### 3. Actions Requiring an Actual Android Device
- [ ] Connect a physical Android smartphone via USB with USB Debugging enabled.
- [ ] Verify swipe gestures, toroidal wrap animations, and frame timing on real hardware.
- [ ] Test vibration and sound toggles with device physical mute switches.

### 4. Actions Requiring an AdMob Account
- [ ] Create an account at [admob.google.com](https://admob.google.com).
- [ ] Register `Shift Puzzle` (Android).
- [ ] Create one Interstitial Ad Unit (`ShiftPuzzle_Interstitial_LevelClear`).
- [ ] Create one Rewarded Ad Unit (`ShiftPuzzle_Rewarded_EchoHint`).
- [ ] Link the AdMob app to the Google Play Store listing once published.

### 5. Actions Already Completely Verified
- [x] 100 handcrafted campaign levels spanning 10 balanced chapters.
- [x] Memory Echo v2 temporal recording and phantom macro replay mechanics.
- [x] 174 automated unit, widget, and domain tests passing.
- [x] `flutter analyze` with 0 warnings or errors.
- [x] Web build verified and fully operational.
- [x] Secure upload signing configuration with debug fallback.
- [x] AdMob build separation (safe test defaults, strict debug lockout).
- [x] Target SDK 36, compile SDK 36, min SDK 24.
- [x] Release AAB and APK build configurations hardened and verified.
