# Shift Puzzle — Release Candidate Status Document

**Date:** September 28, 2026  
**Evaluation:** Task 24 Release Candidate Preparation & Physical QA Audit  

---

## 1. Project Identity

* **Application Name:** Shift Puzzle  
* **Application Package:** `com.shiftpuzzle.game`  
* **Internal Namespace:** `com.shiftpuzzle.shift_puzzle`  
* **Current Version:** `1.0.0+2` (versionCode: 2, versionName: "1.0.0")  
* **Git Commit:** `193a1ae`  
* **Target Engine:** Flutter 3.47.5 / Flame 1.38.2  

---

## 2. Automated QA Summary

* **Flutter Analyze:** PASS (0 errors, 0 warnings, 0 lints in 4.4s)
* **Automated Test Count:** 316 / 316 tests passing (100%)
* **Level Verification:** 150 / 150 handcrafted campaign levels mathematically verified against exact bidirectional BFS solver par values (0 mismatches, Level 150 verified at 9 moves).
* **Memory Echo Levels:** 84 / 84 levels with active Echo replay verified.
* **Build Artifact Classification:**
  - `build/app/outputs/bundle/release/app-release.aab`: **BUILD ARTIFACT ONLY — PRODUCTION SIGNING NOT CONFIGURED**. Compiled with Android debug key using explicit `-PallowInsecureDebugSigning=true` override. Not Play-upload ready until signed with production upload keystore.
  - `build/app/outputs/flutter-apk/app-release.apk`: Built for local/physical QA testing and sideloading.
  - Gradle fails closed if `android/key.properties` is missing when building without the explicit insecure flag.

---

## 3. Android Platform & Architecture

* **Target SDK:** 36 (Android 16)
* **Minimum SDK:** 24 (Android 7.0 Nougat)
* **Orientation:** Strictly locked to portrait (`android:screenOrientation="portrait"`).
* **Permissions Declared:**
  - `android.permission.INTERNET` (AdMob ad serving)
  - `android.permission.ACCESS_NETWORK_STATE` (Connectivity check before ad calls)
  - Merged dependencies: `com.google.android.gms.permission.AD_ID`, `ACCESS_ADSERVICES_*`, `WAKE_LOCK`.
  - Zero dangerous or invasive runtime permissions requested.
* **Release Signing Pipeline:** Fail-closed architecture enforced in Gradle. Release builds strictly require valid `key.properties` and keystore file; debug signing only allowed via explicit local flag `-PallowInsecureDebugSigning=true`.
* **Launcher Icon:** Custom 5×5 toroidal grid branding deployed with Android Adaptive Icon XML (`mipmap-anydpi-v26`), round icon support, and all raster densities (mdpi to xxxhdpi). Master 512×512 store icon complete.
* **Feature Graphic:** Verified 1024×500 PNG complete (`assets/branding/store/feature_graphic_1024x500.png`).

---

## 4. AdMob Monetization Architecture

* **QA / Test Mode:** Verified using official Google AdMob test ad units (`ca-app-pub-3940256099942544/...`).
* **Production Isolation:** Production mode requires compile-time flag `--dart-define=ADMOB_PRODUCTION_MODE=true` combined with `!kDebugMode`.
* **Empty ID Safety:** Unconfigured production IDs safely evaluate to empty strings and skip ad loading without exceptions or crashes.
* **Test ID Safety Scan:** PASS (Zero test IDs leak into production code path).
* **Player-First Guardrails:** Chapter 1 (Levels 1–10) strictly 100% ad-free; 4-level completion frequency cap; 180s cooldown; offline connectivity guard.

---

## 5. Physical Device QA Audit

* **Device Connection:** None detected (`adb devices -l` and `flutter devices` confirm no connected Android hardware or emulators).
* **Physical Validation Status:** **NOT VERIFIED ON HARDWARE — BLOCKED BY ABSENCE OF CONNECTED DEVICE.**
* **Manual QA Plan Prepared:** Complete 24-step testing checklist prepared in [docs/PHYSICAL_DEVICE_QA_CHECKLIST.md](file:///home/tensae/Desktop/projects/Apps/games/shift-puzzle/docs/PHYSICAL_DEVICE_QA_CHECKLIST.md).

---

## 6. Active Defects

* **P0 (Critical):** 0 active
* **P1 (High):** 0 active
* **P2 (Medium):** 0 active
* **P3 (Low):** 0 active

---

## 7. Real Release Blockers

### P0 Blockers (Before Google Play Closed Test Launch)
1. **Google Play Developer Account Registration:**
   - Registration fee ($25) must be paid and developer identity verified.
2. **Production Upload Keystore & Release Signing:**
   - Developer must generate `upload-keystore.jks` locally and create `android/key.properties` with private credentials.
   - Rebuild production AAB signed with valid upload keystore (**PLAY-UPLOAD READY — VALID UPLOAD KEY**).
3. **Public HTTPS Privacy Policy URL:**
   - [PRIVACY_POLICY.md](file:///home/tensae/Desktop/projects/Apps/games/shift-puzzle/PRIVACY_POLICY.md) must be deployed to a live HTTPS URL (e.g. `https://shiftpuzzle.game/privacy` or GitHub Pages). Current URL test confirms `PUBLIC PRIVACY POLICY — BLOCKED / PENDING HOSTING`.
4. **Phone Screenshots:**
   - Must be captured on real Android hardware or emulator (**SCREENSHOTS — PENDING REAL DEVICE/EMULATOR CAPTURE**). (Note: App Icon 512×512 and Feature Graphic 1024×500 are both complete).

### P1 Blockers (Before Production Rollout)
1. **Live Production AdMob IDs:**
   - Live Android Rewarded and Interstitial Ad Unit IDs must be extracted from Google AdMob Console.
2. **Physical Device QA Verification:**
   - Physical touch latency, hardware back button, haptics, and logcat runtime monitoring must be confirmed on real hardware using the 24-step checklist.
3. **Target Audience Declaration:**
   - Formal declaration in Google Play Console based on factual product characteristics (abstract logic puzzle, non-child-directed).
4. **12-Tester / 14-Day Closed Testing:**
   - If personal account created post-Nov 2023, 12 testers must maintain continuous opt-in for 14 days. Status: **NOT STARTED**.

---

## 8. Remaining Concrete Actions

1. Connect a physical Android phone with USB debugging enabled to execute the 24-step manual QA checklist in [docs/PHYSICAL_DEVICE_QA_CHECKLIST.md](file:///home/tensae/Desktop/projects/Apps/games/shift-puzzle/docs/PHYSICAL_DEVICE_QA_CHECKLIST.md).
2. Generate the production upload keystore (`upload-keystore.jks`) using `keytool`.
3. Create `android/key.properties` containing keystore passwords and AdMob App ID.
4. Host `PRIVACY_POLICY.md` on a publicly accessible HTTPS web host.
5. Capture 4–5 uncompressed screenshots on physical device or emulator.
6. Open the Google Play Developer Account and pay the registration fee.
7. Build production-signed AAB, upload to **Testing > Closed testing**, and recruit at least 12 testers using [docs/CLOSED_TEST_TRACKER.md](file:///home/tensae/Desktop/projects/Apps/games/shift-puzzle/docs/CLOSED_TEST_TRACKER.md).
