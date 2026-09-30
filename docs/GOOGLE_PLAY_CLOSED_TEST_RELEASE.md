# Google Play Closed Testing Release Documentation — Shift Puzzle

**Application:** Shift Puzzle  
**Package:** `com.shiftpuzzle.game`  
**Internal Namespace:** `com.shiftpuzzle.shift_puzzle`  
**Current Version:** `1.0.0+2` (versionCode: 2, versionName: "1.0.0")  
**Engine:** Flutter 3.47.5 / Flame 1.38.2  
**Target SDK:** 36 (Android 16) | **Min SDK:** 24 (Android 7.0 Nougat)  
**Date:** September 28, 2026  
**Document Status:** RELEASE CANDIDATE CLOSED TESTING SPECIFICATION  

---

## 1. Project Identity & Architecture Baseline

* **Game Concept:** Elegant 5×5 toroidal grid spatial logic puzzle with wrap-around shifts.
* **Core Progression:** 150 deterministic handcrafted campaign levels across 15 thematic chapters.
* **Signature Mechanic:** Memory Echo (active across 84 campaign levels), allowing players to record macros, reposition the board, and replay phantom moves without consuming player move budget.
* **Move Economy:** 
  - Standard move budget: `normalMoveLimit = authoritativeOptimalMoves + 3`
  - Undo Lock: Active when `playerMoves >= optimalMoves`
  - Rewarded Extra-Move Rescue: Single-use extension of `+5` moves (`extendedMoveLimit = authoritativeOptimalMoves + 8`)
  - Par Accuracy: 150/150 levels mathematically audited with bidirectional BFS (0 mismatches, Level 150 verified at 9 moves).
* **Network & Storage Architecture:**
  - 100% offline-first gameplay.
  - Zero backend servers, zero account logins, zero cloud dependencies.
  - Local persistence via sandboxed `SharedPreferences`.

---

## 2. Release Build & Execution Matrix

### Development & Local Debug
```bash
flutter run
```
* Uses Google's official AdMob test ad unit IDs.
* Debug signing key used automatically.
* Hot reload and full logging enabled.

### Quality Assurance & Automated Audit
```bash
flutter analyze
flutter test
```
* Validates static analysis (0 warnings / 0 errors).
* Executes all 313 unit, widget, policy, and mathematical BFS audit tests (313/313 passing).

### Sideload Test APK Build (Test Ads / Debug Signing)
```bash
flutter build apk --release
```
* Generates `build/app/outputs/flutter-apk/app-release.apk` (~49 MB).
* Uses debug keystore fallback when `android/key.properties` is absent.

### Production Google Play Release App Bundle (AAB)
```bash
flutter build appbundle --release \
  --dart-define=ADMOB_PRODUCTION_MODE=true \
  --dart-define=ADMOB_REWARDED_ID=ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY \
  --dart-define=ADMOB_INTERSTITIAL_ID=ca-app-pub-XXXXXXXXXXXXXXXX/ZZZZZZZZZZ
```
* Generates `build/app/outputs/bundle/release/app-release.aab` (~51 MB).
* Compiled with R8 code shrinking and ProGuard optimization.
* Injects production AdMob ad unit IDs at compile time.

---

## 3. Production Signing Architecture

Shift Puzzle uses a decoupled, secure release-signing pipeline designed to prevent private keys or passwords from ever entering Git tracking.

### Configuration (`android/app/build.gradle.kts`)
```kotlin
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    defaultConfig {
        applicationId = "com.shiftpuzzle.game"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        val admobAppId = keystoreProperties.getProperty("admobAppId")
            ?: System.getenv("ADMOB_APP_ID")
            ?: "ca-app-pub-3940256099942544~3347511713"
        manifestPlaceholders["admobAppId"] = admobAppId
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

    buildTypes {
        release {
            val storeFilePath = keystoreProperties.getProperty("storeFile")
            val hasCustomKeystore = keystorePropertiesFile.exists() && storeFilePath != null && file(storeFilePath).exists()
            signingConfig = if (hasCustomKeystore) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}
```

### Git Safety
The root `.gitignore` strictly protects all signing assets:
```gitignore
**/android/local.properties
**/android/key.properties
*.jks
*.keystore
*.p12
*.pem
secrets.json
secrets/
.env*
```

### Release Keystore Generation Instructions (For Developer)
To generate the production upload keystore in your local secure environment:
```bash
keytool -genkey -v \
  -keystore android/app/upload-keystore.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias upload
```
Create `android/key.properties` (never commit this file):
```properties
storePassword=YOUR_SECURE_STORE_PASSWORD
keyPassword=YOUR_SECURE_KEY_PASSWORD
keyAlias=upload
storeFile=upload-keystore.jks
admobAppId=ca-app-pub-XXXXXXXXXXXXXXXX~AAAAAAAAAA
```

> **CRITICAL SECURITY NOTE:** Keystore backup is mandatory. If the upload keystore is lost before Google Play App Signing is configured or registered, app updates cannot be published without contacting Google Play Developer Support. Never commit or share keystore passwords.

---

## 4. AdMob Monetization & Policy Architecture

### Environment Isolation
* **Development / Test Builds:** Automatically use official Google AdMob test ad unit IDs:
  - Rewarded Android Test ID: `ca-app-pub-3940256099942544/5224354917`
  - Interstitial Android Test ID: `ca-app-pub-3940256099942544/1033173712`
  - Application Test ID: `ca-app-pub-3940256099942544~3347511713`
* **Production Builds:** Activated via compile-time flag `--dart-define=ADMOB_PRODUCTION_MODE=true` combined with `!kDebugMode`.
* **Missing Production IDs Behavior:** Evaluates to empty string `""`. Both `_loadInterstitialAd()` and `_loadRewardedAd()` explicitly guard against empty strings by skipping ad requests. The app **never falls back to test IDs in production**, and never crashes.
* **Offline-First Safeguard:** Ad loading checks `ConnectivityService`. If offline, ad requests are cleanly bypassed, allowing offline solving without infinite loaders or timeouts.

### Reward Integrity Verification
* **Double-Click Protection:** UI sets `_isRequestingAd = true` during request cycles, preventing multi-tap race conditions.
* **Single Dispatch:** Uses `rewardDispatched` boolean guard to ensure the reward callback executes exactly once upon successful completion.
* **Dismissal Without Completion:** If an ad is dismissed before the reward callback or fails to present, `userEarned` remains `false`. No moves or hints are awarded, and a feedback SnackBar informs the player.

### Placement & Trigger Guardrails
1. **Interstitial Ad Placement (`lib/ui/game_screen.dart:381`):**
   - Triggered exclusively when tapping "Next Level" on the `WinDialog`.
   - **Chapter 1 Protection:** Levels 1–10 are 100% ad-free.
   - **Frequency Cap:** Minimum 4 completed levels between interstitials.
   - **Cooldown Interval:** Minimum 180 seconds (3 minutes) between interstitials.
   - Never shown on app launch, inside menus, or during active board manipulation.
2. **Rewarded Hint Placement (`lib/ui/game_screen.dart:800`):**
   - Triggered only by explicit tap on the Hint button or Optimal Drift Nudge action.
3. **Rewarded +5 Move Rescue Placement (`lib/ui/game_screen.dart:1131`):**
   - Triggered only when the player exhausts the normal move limit (`optimalMoves + 3`) and explicitly chooses "+5 Moves (Watch Ad)" on the Move Limit Dialog.
   - Single-use per level attempt.

---

## 5. Privacy Policy Verification

* **Hosting Document:** `PRIVACY_POLICY.md` (root repository).
* **Configured Target URL:** `https://shiftpuzzle.game/privacy`
* **Connectivity Audit:** Public DNS / HTTP resolution test indicates the target domain is not yet active on the public web.
* **Required Action:** The developer must host the contents of `PRIVACY_POLICY.md` at a publicly accessible HTTPS URL (e.g. GitHub Pages, personal developer website, or public gist) before submitting for Play Console review.
* **Disclosures Verified:**
  - Zero PII collection by core app.
  - Zero cloud servers or analytics tracking.
  - Local storage of level progress and star data.
  - Google AdMob integration disclosed, including Advertising ID (AAID) and approximate location handling.
  - User rights to reset AAID in Android settings.
  - Support contact email: `support@shiftpuzzle.game`.

---

## 6. Google Play Data Safety Declaration

Based on Google Play Developer Policy and the Google Mobile Ads SDK (^9.1.0):

| Data Type | Collected? | Shared? | Purpose | Optional? | Encrypted in Transit? | Deletion Mechanism |
|---|---|---|---|---|---|---|
| **Location (Approximate)** | Yes (by AdMob SDK) | Yes (with AdMob) | Advertising & Marketing, Analytics | No (automated by SDK) | Yes (HTTPS / TLS) | Managed via Google ad settings |
| **Personal Info (Name, Email, etc.)** | **No** | **No** | N/A | N/A | N/A | No user data stored |
| **Financial / Payment Info** | **No** | **No** | N/A | N/A | N/A | No in-app purchases |
| **App Performance (Crash logs, Diagnostics)** | Yes (by AdMob SDK) | Yes (with AdMob) | Analytics, Diagnostics, Fraud Prevention | No | Yes (HTTPS / TLS) | Managed by SDK |
| **Device or other IDs (AAID)** | Yes (by AdMob SDK) | Yes (with AdMob) | Advertising & Marketing, Analytics, Fraud Prevention | No | Yes (HTTPS / TLS) | Reset/Delete via Android Settings > Google > Ads |

* **Data Encryption:** All transmission by Google Mobile Ads SDK uses HTTPS/TLS.
* **Local Game Data:** Progress is stored exclusively on-device in sandboxed app storage and deleted upon app uninstall or clearing cache.

---

## 7. Target Audience Factual Assessment & Play Console Review

### Factual Game Characteristics
* **Genre:** Abstract geometric combinatorial spatial logic puzzle on a 5×5 toroidal grid.
* **Visual Presentation:** Deep obsidian palette (`#090D16`), geometric tiles, neon accent rings, mathematical par counters.
* **Child-Directed Elements:** Zero cartoons, zero mascots, zero child-oriented educational positioning, zero toys/juvenile themes.
* **Social & Age-Sensitive Features:** Zero violence, zero sexual content, zero profanity, zero gambling, zero chat, zero multiplayer, zero user-generated content.
* **Mechanics & Cognitive Demand:** Toroidal coordinate wrapping, multi-piece parity alignment, and multi-step macro planning (Memory Echo) geared toward logic puzzle enthusiasts.
* **Monetization:** Google AdMob non-intrusive rewarded video and interstitial ads.

### Intended Audience Assessment
* **Demographic Classification:** General Audience (primarily teens and adults interested in mathematical logic puzzles). The game is not child-directed.
* **Developer Play Console Declaration:**
  - The developer will select the target age group in Google Play Console based on the authentic intended audience of the product.
  - Selecting **Ages 16–17 and 18+** or **Ages 13–15, 16–17, and 18+** should reflect the factual intended audience rather than an attempt to bypass policy frameworks.
  - Note: Selecting an audience that includes children or young teens imposes specific Google Play Families Policy obligations (e.g. certified ad networks, neutral age gating, restricted AAID processing). Selecting 16+ does not eliminate regulatory duties if an app intentionally targets children. The developer's declaration must strictly align with actual marketing and product presentation.

---

## 8. Content Rating (IARC Questionnaire Preparation)

Factual answers for the International Age Rating Coalition (IARC) questionnaire:
* **Category:** Game -> Puzzle / Trivia
* **Violence:** No
* **Sexual Content / Nudity:** No
* **Profanity / Crude Humor:** No
* **Controlled Substances / Alcohol / Tobacco / Drugs:** No
* **Gambling / Simulated Gambling:** No
* **User Interaction / Social Features:** No (no chat, no multiplayer, no location sharing, no user exchange)
* **Digital Purchases:** No (100% free with ads, no in-app purchases)
* **Contains Advertisements:** Yes (AdMob rewarded video and interstitials)

> **OFFICIAL CONTENT RATING — TO BE GENERATED BY IARC / GOOGLE PLAY CONSOLE**  
> Rating certificates (e.g., ESRB, PEGI, USK, ACB) will be generated automatically upon questionnaire completion in Google Play Console. No specific rating is pre-assumed or predicted.

---

## 9. Android Permissions Audit

Manifest (`android/app/src/main/AndroidManifest.xml`) and APK inspection:

| Permission | Source | Justification / Release Status |
|---|---|---|
| `android.permission.INTERNET` | Declared in Manifest | Required for Google Mobile Ads SDK network ad requests. |
| `android.permission.ACCESS_NETWORK_STATE` | Declared in Manifest | Required by `ConnectivityService` and AdMob to verify online state before loading ads. |
| `com.google.android.gms.permission.AD_ID` | Merged from AdMob SDK | Standard advertising identifier permission required for ad attribution on Android 13+. |
| `android.permission.ACCESS_ADSERVICES_*` | Merged from AdMob SDK | Privacy Sandbox APIs for ad measurement and topics. |
| `android.permission.WAKE_LOCK` | Merged from AndroidX | Standard lock screen / rendering support. |
| `DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION` | Merged from AndroidX Core | Security permission for internal broadcast receivers. |

**Verdict:** 0 unnecessary or dangerous permissions. All declared permissions are minimal, standard, and required.

---

## 10. Store Graphic Assets Checklist

| Asset | Specifications | Current Status | Action Required |
|---|---|---|---|
| **App Icon (Hi-Res)** | 512 × 512 px, 32-bit PNG, max 1024 KB | **Pending Final Export** | Export high-res game icon featuring obsidian background, cyan ring, and centered gem. |
| **Feature Graphic** | 1024 × 500 px, JPEG/PNG, max 15 MB | **Pending Design** | Create widescreen banner with Shift Puzzle logo and neon grid artwork (no promo badges). |
| **Phone Screenshots** | Min 2, rec 4–5, min 1080px short edge | **Pending Capture** | Capture 4–5 uncompressed screenshots from release APK (Gameplay, Memory Echo, Chapter Select, Pars, Win Screen). |

---

## 11. Physical Android Device Validation Audit

* **Device Connection Status:**
  - `adb devices -l`: Empty (no physical Android devices detected).
  - `flutter devices`: Only Linux desktop and Chrome web available.
  - `flutter emulators`: No local Android AVD images configured.
* **Audit Determination:**
  - **PHYSICAL DEVICE VALIDATION BLOCKED — NO DEVICE AVAILABLE**
  - Per project policy, physical touch response, hardware back button, device haptics, battery thermal behavior, and logcat runtime monitoring are marked **NOT VERIFIED ON PHYSICAL HARDWARE**.
  - Software emulation and headless tests confirm 313/313 tests pass and APK/AAB build successfully.

---

## 12. Google Play Closed Testing Configuration (12 Testers / 14 Days)

### Regulatory Rule
For personal developer accounts created after **November 13, 2023**, Google Play requires:
1. Minimum **12 testers** opted in.
2. Testers must remain opted in continuously for **at least 14 days**.
3. Closed testing must be conducted before applying for production access.

*(Note: Organization accounts with a valid DUNS number or personal accounts created prior to Nov 13, 2023 are exempt from this mandatory 14-day hold, but closed testing remains strongly recommended).*

### Closed Testing Setup Steps
1. In Google Play Console, navigate to **Testing > Closed testing**.
2. Click **Create track** (or use the default Alpha track).
3. Under **Testers**, create an email list or link a Google Group (e.g. `shift-puzzle-testers@googlegroups.com`).
4. Copy the **Join on Android** and **Join on Web** opt-in links to distribute to your recruited testers.
5. Create a new release, upload `build/app/outputs/bundle/release/app-release.aab`, and rollout to 100% of the closed testing track.

---

## 13. Closed Tester 14-Day Test Plan

| Phase | Days | Focus Areas | Action Items |
|---|---|---|---|
| **Phase 1** | Days 1–2 | Onboarding & Core Controls | Clean install from Play Store opt-in link; verify launch, splash screen, and Chapter 1 (Levels 1–10); test row/col wrapping shifts. |
| **Phase 2** | Days 3–5 | Move Budget & Par Mechanics | Progress through Chapters 2–4; observe move counter HUD, par indicator, and Undo Lock at or after par; test Optimal Drift Nudge. |
| **Phase 3** | Days 6–8 | Memory Echo Mechanics | Play Echo levels (beginning in Chapter 2); test Record -> Stop -> Reposition -> Echo Replay; verify echo moves do not consume player budget. |
| **Phase 4** | Days 9–10 | Monetization & Offline Flow | Test Rewarded Hint and +5 Extra-Move Rescue; verify ads load when online and fail gracefully when offline; verify no duplicate rewards. |
| **Phase 5** | Days 11–12 | Lifecycle, Audio & Hardware | Test backgrounding, resuming, phone calls, screen lock/unlock; verify music/SFX toggles; verify physical Android Back button in gameplay and WinDialog. |
| **Phase 6** | Days 13–14 | Extended Play & Regression | Continuous play across higher chapters; check frame rate stability, memory usage, and thermal comfort; submit final feedback. |

---

## 14. Tester Feedback Channel & Bug Reporting Template

### Primary Feedback Channels
* **Email:** `support@shiftpuzzle.game`
* **Google Play Feedback:** Testers can provide private feedback directly on the Google Play Store listing page while enrolled in closed testing.

### Bug Reporting Template
```markdown
### Shift Puzzle Closed Beta Bug Report

* **Tester Name / ID:**
* **Device Model:** (e.g., Google Pixel 8, Samsung Galaxy S23)
* **Android OS Version:** (e.g., Android 14 / One UI 6)
* **App Version:** 1.0.0+2 (Build 2)
* **Level ID / Chapter:** (e.g., Level 24, Chapter 3)
* **Network Status:** (Wi-Fi / Mobile Data / Airplane Mode)

**Bug Summary:**
[Brief 1-sentence description of the issue]

**Steps to Reproduce:**
1. Open Level X...
2. Perform row shift...
3. Tap Memory Echo replay...

**Expected Result:**
[What should happen]

**Actual Result:**
[What actually happened]

**Frequency:** (Always / Often / Rarely / Once)
**Screenshots / Screen Recording:** [Attach if available]
```

---

## 15. Release Blocker Classification

### P0 — BLOCKS CLOSED TEST LAUNCH
1. **Production Upload Keystore & Release Signing:**
   - *Status:* Configured in Gradle, but requires developer to generate `upload-keystore.jks` and supply `android/key.properties` with private credentials. Current build uses Android Debug key.
2. **Public HTTPS Privacy Policy URL:**
   - *Status:* Content complete in `PRIVACY_POLICY.md`, but target URL `https://shiftpuzzle.game/privacy` does not yet resolve on the public web.
3. **Mandatory Store Listing Graphics:**
   - *Status:* High-res App Icon (512×512) and Feature Graphic (1024×500) must be exported and uploaded to Play Console.

### P1 — MUST COMPLETE BEFORE OPEN TESTING / PRODUCTION LAUNCH
1. **Production AdMob Ad Unit IDs:**
   - *Status:* Architecture isolated via compile-time `--dart-define`. Developer must provide live production IDs from Google AdMob console for release build.
2. **Physical Device Runtime Validation:**
   - *Status:* Blocked by absence of physical hardware. Must be performed on actual Android devices during the 14-day closed testing period.
3. **Target Audience Confirmation:**
   - *Status:* Developer will declare target audience in Google Play Console based on factual product characteristics (abstract logic puzzle, non-child-directed).
4. **Tester Recruitment (12 Testers / 14 Days):**
   - *Status:* If developer account is personal (post-Nov 2023), 12 testers must be invited and maintain opt-in for 14 continuous days. Official closed testing has NOT started.

### P2 — NON-BLOCKING IMPROVEMENTS
1. Custom tablet screenshots (7-inch and 10-inch) for optimized tablet store presentation.
2. Direct GitHub Pages hosting automated deployment for privacy policy.

---

## 16. Final Release Status Determination

### Status: **CONDITIONALLY READY FOR CLOSED TESTING**

**Summary:**  
The Shift Puzzle codebase is mathematically and technically sound: 150/150 campaign levels have exact verified BFS solutions, 313/313 automated tests pass, `flutter analyze` reports 0 issues, R8 ProGuard shrinking is active, and both release APK and AAB build cleanly. Production AdMob isolation and Gradle signing pipelines are fully wired. Launching the Google Play Closed Test track is conditioned solely on the developer completing the external account prerequisites: generating the upload keystore, hosting the privacy policy, uploading the store graphic assets, and inviting 12 closed testers.
