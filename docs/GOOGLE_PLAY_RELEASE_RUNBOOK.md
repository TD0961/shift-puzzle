# Google Play Release Runbook — Shift Puzzle

**Application:** Shift Puzzle  
**Package:** `com.shiftpuzzle.game`  
**Internal Namespace:** `com.shiftpuzzle.shift_puzzle`  
**Version:** `1.0.0+2` (versionCode: 2, versionName: "1.0.0")  
**Engine:** Flutter 3.47.5 / Flame 1.38.2  
**Target SDK:** 36 (Android 16) | **Min SDK:** 24 (Android 7.0 Nougat)  
**Date:** September 28, 2026  
**Document Purpose:** Complete Step-by-Step Operator Runbook for Google Play Console Submission, Closed Testing, and Production Launch  

---

## 1. Project Identity & Architecture Baseline

* **Genre:** Pure spatial logic puzzle on a 5×5 toroidal (wrap-around) grid.
* **Content:** 150 deterministic handcrafted levels across 15 chapters (84 levels featuring the signature Memory Echo macro replay mechanic).
* **Par Accuracy:** 100% verified across all 150 levels using authoritative bidirectional BFS solver (0 mismatches).
* **Move Budget & Economy:**
  - Standard move budget: `optimalMoves + 3`.
  - Undo Lock: Active at or above `optimalMoves`.
  - Rewarded Extra-Move Rescue: Single-use extension of `+5` moves (`optimalMoves + 8`).
* **Platform & Persistence:**
  - Offline-first architecture.
  - Zero server backend, zero accounts, zero cloud dependencies.
  - On-device sandboxed `SharedPreferences`.

---

## 2. Build Prerequisites & Local Environment

Ensure the following tools are available on the release workstation:
* **Flutter SDK:** 3.47.5 (Channel stable)
* **Dart SDK:** 3.13.4
* **JDK:** OpenJDK 21 LTS (`export JAVA_HOME="/path/to/jdk-21"`)
* **Android SDK:** Platform 36, Build-Tools 36.0.0
* **Keytool:** Standard JDK key utility

---

## 3. Production Signing Architecture (Fail-Closed)

### Fail-Closed Enforcement
The project's Gradle configuration (`android/app/build.gradle.kts`) is configured to **fail closed**:
* If `android/key.properties` is missing, release builds (`bundleRelease` or `assembleRelease`) will terminate with an explicit `GradleException`.
* Silent fallback to debug signing in release builds is prevented by default.
* For local sideload QA testing only, developers can explicitly pass `-PallowInsecureDebugSigning=true` (never for Play Console submission).

### Generation Command
Generate your private release upload keystore (choose a strong password and preserve it safely):
```bash
keytool -genkey -v \
  -keystore android/app/upload-keystore.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias upload
```

### Credentials File (`android/key.properties`)
Create `android/key.properties` (strictly ignored by `.gitignore`):
```properties
storePassword=YOUR_SECURE_STORE_PASSWORD
keyPassword=YOUR_SECURE_KEY_PASSWORD
keyAlias=upload
storeFile=upload-keystore.jks
admobAppId=ca-app-pub-XXXXXXXXXXXXXXXX~AAAAAAAAAA
```

---

## 4. Google Play App Signing Workflow

Google Play uses a dual-key architecture:
1. **Upload Key (Developer Controlled):** The RSA key created in Step 3, used to sign the `.aab` before uploading to Google Play Console.
2. **App Signing Key (Google Managed):** Generated and securely stored within Google's infrastructure, used to sign the final split APKs delivered to user devices.

### Registration Procedure
1. In Play Console, navigate to **Release > Setup > App integrity**.
2. Opt in to **Play App Signing** (recommended: let Google generate and protect the app signing key).
3. The upload key certificate (`upload-keystore.jks`) is automatically registered upon the first successful AAB upload.
4. If the upload key is ever lost, request an upload key reset via Google Play Developer Support.

---

## 5. AdMob Production Configuration & Isolation

### Isolation Rules
* **Development/Debug Builds:** Automatically use Google's official sample ad unit IDs (`ca-app-pub-3940256099942544/...`).
* **Production Builds:** Activated via compile-time Dart define:
  ```bash
  --dart-define=ADMOB_PRODUCTION_MODE=true \
  --dart-define=ADMOB_REWARDED_ID=ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY \
  --dart-define=ADMOB_INTERSTITIAL_ID=ca-app-pub-XXXXXXXXXXXXXXXX/ZZZZZZZZZZ
  ```
* **Empty ID Safety:** If production mode is enabled without ad unit IDs, the service evaluates to empty strings and cleanly skips ad requests without throwing exceptions or crashing. It **never falls back to test IDs in production**.

### Policy Safeguards
* **Chapter 1 (Levels 1–10):** 100% ad-free.
* **Frequency Cap:** Minimum 4 completed levels between interstitial ads.
* **Time Cooldown:** Minimum 180 seconds (3 minutes) between interstitial ads.
* **Offline Handling:** `ConnectivityService` checks network before requesting ads; offline sessions continue smoothly with no loaders or error dialogs.

---

## 6. Privacy Policy Deployment

* **Content:** Complete in [PRIVACY_POLICY.md](file:///home/tensae/Desktop/projects/Apps/games/shift-puzzle/PRIVACY_POLICY.md).
* **Required Hosting:** Must be deployed to a publicly accessible HTTPS URL before submitting to Play Console (e.g. `https://shiftpuzzle.game/privacy` or via GitHub Pages).
* **Core Disclosures:**
  - Zero PII collection by core application.
  - Sandboxed local storage of progress and achievements.
  - AdMob integration disclosed (approximate location, crash/diagnostic logs, and AAID handling).
  - User deletion instructions via Android OS advertising ID reset.
  - Support contact: `support@shiftpuzzle.game`.

---

## 7. Google Play Data Safety Declaration

Enter the following responses in Play Console under **Policy > App content > Data safety**:

1. **Does your app collect or share any of the required user data types?**  
   -> **Yes** (solely via the Google Mobile Ads SDK).
2. **Is all user data collected by your app encrypted in transit?**  
   -> **Yes** (HTTPS/TLS enforced).
3. **Do you provide a way for users to request that their data be deleted?**  
   -> **Yes** (via Android Settings > Google > Ads).
4. **Data Categories Disclosed:**
   * **Location (Approximate):** Collected and shared by AdMob for advertising and analytics.
   * **App Info & Performance (Crash logs, Diagnostics):** Collected and shared by AdMob for diagnostics and fraud prevention.
   * **Device or Other IDs (AAID):** Collected and shared by AdMob for advertising, attribution, and analytics.

---

## 8. Target Audience & Play Console Declaration

### Factual Product Characteristics
* **Genre & Mechanics:** Pure abstract geometric spatial logic puzzle on a 5×5 toroidal grid with mathematical move par optimizations.
* **Aesthetic:** Minimalist dark slate/obsidian palette (`#090D16`), geometric jewel tokens, ambient synthesizer audio.
* **Non-Child-Directed Evidence:** Zero cartoons, zero mascots, zero child-oriented educational positioning, zero toys/juvenile styling.
* **Social Safety:** Zero violence, zero sexual content, zero profanity, zero gambling, zero chat, zero multiplayer, zero user-generated content.
* **Intended Demographic:** General audience (primarily teens and adults).

### Play Console Guidance
* The developer will select the target audience age group in Google Play Console based on the authentic product characteristics.
* Selection options:
  - **Ages 16–17 and 18+**: Reflects general audience focus for adult and older teenage logic puzzle enthusiasts.
  - **Ages 13–15, 16–17, and 18+**: Extends target group to younger secondary-school players.
* *Policy Note:* Declaration must be based on true product design and intended players rather than policy avoidance. If children are included in the target audience, additional Google Play Families Policy requirements apply (certified ad networks, neutral age gate, restricted AAID transmission).

---

## 9. Content Rating (IARC Questionnaire Preparation)

Complete the IARC questionnaire under **Policy > App content > Content rating** using these factual answers:
* **Category:** Game -> Puzzle / Trivia
* **Violence:** No
* **Sexual Content / Nudity:** No
* **Profanity / Crude Language:** No
* **Controlled Substances / Drugs / Alcohol / Tobacco:** No
* **Gambling / Simulated Gambling:** No
* **User Interaction / Social Features:** No (no chat, no multiplayer, no data exchange)
* **Digital Purchases:** No (100% free with ads, no in-app purchases)
* **Contains Ads:** Yes (AdMob rewarded video and interstitials)

> **OFFICIAL CONTENT RATING — TO BE GENERATED BY IARC / GOOGLE PLAY CONSOLE**  
> Rating badges (ESRB, PEGI, USK, etc.) are issued dynamically by IARC upon submission. Do not pre-announce or predict ratings in marketing copy.

---

## 10. Ads Declaration & Permissions

* **Ads Declaration:** Select **Yes, my app contains ads**.
* **Permissions in Final Release:**
  - `android.permission.INTERNET` (AdMob ad delivery)
  - `android.permission.ACCESS_NETWORK_STATE` (Connectivity check before ad request)
  - `com.google.android.gms.permission.AD_ID` (AdMob advertising identifier on Android 13+)
  - `android.permission.ACCESS_ADSERVICES_*` (Android Privacy Sandbox)
  - `android.permission.WAKE_LOCK` (Rendering lock support)

---

## 11. Store Listing Copy & Graphic Assets

### Store Listing Copy
* **App Title:** Shift Puzzle
* **Short Description (78/80 chars):**  
  Master the toroidal grid. Slide rows, loop columns, and master Memory Echo.
* **Full Description:** Verified in [STORE_LISTING_PREPARATION.md](file:///home/tensae/Desktop/projects/Apps/games/shift-puzzle/STORE_LISTING_PREPARATION.md).

### Required Graphic Assets
* **App Icon:** 512 × 512 px, 32-bit PNG (no transparency on background, max 1024 KB).
* **Feature Graphic:** 1024 × 500 px, JPEG or 24-bit PNG (max 15 MB).
* **Phone Screenshots:** Minimum 2, recommended 4–5 uncompressed screenshots (1080×1920 or 1080×2400 px).

---

## 12. Closed Testing Execution (12 Testers / 14 Days)

1. In Play Console, navigate to **Testing > Closed testing**.
2. Create track (or select Alpha track).
3. Under **Testers**, create an email list or link a Google Group.
4. Send the **Join on Android** or **Join on Web** opt-in URL to testers.
5. Track daily opt-in counts and feedback in [docs/CLOSED_TEST_TRACKER.md](file:///home/tensae/Desktop/projects/Apps/games/shift-puzzle/docs/CLOSED_TEST_TRACKER.md).
6. Ensure at least 12 testers remain continuously opted in for the full 14 days.

---

## 13. Production Access Application & Rollout

1. After completing the 14 days with >= 12 opted-in testers, click **Apply for production** in Play Console.
2. Answer Google's production access questions regarding feedback received, bug fixes applied, and release readiness.
3. Upon approval, promote the closed testing release directly to the **Production** track (staged rollout recommended: 10% -> 25% -> 50% -> 100%).

---

## 14. Rollback & Emergency Update Procedure

* **Rollback:** Google Play does not permit reverting to an older versionCode. If a critical issue is discovered, build a new hotfix artifact with an incremented versionCode (e.g. `1.0.1+3`) and release it immediately at 100% rollout.
* **AdMob Kill-Switch:** If ad issues arise, remove the ad unit IDs or set `--dart-define=ADMOB_PRODUCTION_MODE=false` in the hotfix build to immediately disable ads without gameplay disruption.
