# Task 21 — Google Play Closed Testing Release Checklist

**Application:** Shift Puzzle  
**Package:** `com.shiftpuzzle.game`  
**Version:** `1.0.0+2`  
**Date:** September 28, 2026  

---

## 1. Google Play Quality & Release Gate Table

| Gate Item | Verification Status | Details / Notes |
|---|---|---|
| **Package ID** | **PASS** | `com.shiftpuzzle.game` verified across Gradle, Manifest, and Dart code. |
| **Version Code & Name** | **PASS** | `versionName: 1.0.0`, `versionCode: 2` verified in `pubspec.yaml` and Gradle. |
| **Release Signing** | **READY (TEMPLATE / CI)** / **MANUAL KEY REQUIRED** | Template provided in `android/key.properties.example`; build falls back safely to debug signature when key is not present. Developer must provide production `key.properties`. |
| **Production AdMob Architecture** | **PASS** | Safe `--dart-define=ADMOB_PRODUCTION_MODE=true` architecture verified. Missing production IDs fail safely without falling back to test ads. |
| **Test AdMob Isolation** | **PASS** | Official Google sample IDs used exclusively in test/debug environments; cannot leak into production mode. |
| **Privacy Policy** | **PASS** | Hosted markdown ready at `PRIVACY_POLICY.md`, accurately reflecting AdMob, +5 rescue, local storage, and user rights. |
| **Data Safety Declaration** | **READY FOR CONSOLE ENTRY** | Complete field-by-field matrix documented in `TASK_21_DATA_SAFETY_MATRIX.md`. |
| **Target Audience (13+)** | **READY FOR CONSOLE ENTRY** | Formally justified in `TASK_21_PLAY_CONSOLE_DECLARATIONS.md`; exempt from Families Policy ad network restrictions. |
| **Content Rating (IARC)** | **READY FOR CONSOLE ENTRY** | Questionnaire answers prepared in `TASK_21_PLAY_CONSOLE_DECLARATIONS.md` (expecting PEGI 3 / ESRB Everyone). |
| **Ads Declaration** | **READY FOR CONSOLE ENTRY** | Declared "Contains Ads" with Advertising ID usage documented. |
| **Store Listing Copy** | **READY FOR CONSOLE ENTRY** | Title, 80-char short description, and full description prepared in `TASK_21_STORE_LISTING.md`. |
| **Screenshots (Phone)** | **PENDING SCREEN CAPTURE** | Minimum 2 (recommended 4–5) screenshots must be captured from release build. |
| **Feature Graphic (1024×500)** | **PENDING DESIGN** | 1024×500 PNG/JPEG must be uploaded to Play Console. |
| **Hi-Res App Icon (512×512)** | **PENDING EXPORT** | 512×512 PNG must be exported and uploaded to Play Console. |
| **APK Launcher Icons** | **PASS** | `ic_launcher.png` present across all mipmap densities (`mdpi` to `xxxhdpi`). |
| **Manifest & Permissions** | **PASS** | Minimal permissions: `INTERNET` and `ACCESS_NETWORK_STATE` only. Zero dangerous or runtime permissions. |
| **Orientation Lock** | **PASS** | `android:screenOrientation="portrait"` strictly locked in `AndroidManifest.xml`. |
| **Offline Gameplay** | **PASS** | 100% of puzzle mechanics, solvers, and campaign levels function without internet connectivity. |
| **Full Regression Tests** | **PASS** | **313 / 313 tests passed** with 0 failures. |
| **Static Code Analysis** | **PASS** | `flutter analyze`: 0 errors, 0 warnings. |
| **Release APK Build** | **PASS** | `build/app/outputs/flutter-apk/app-release.apk` (**49 MB**). |
| **Release AAB Build** | **PASS** | `build/app/outputs/bundle/release/app-release.aab` (**51 MB**). |
| **Content Freeze Verification** | **PASS** | 150/150 levels, pars, grids, and targets 100% frozen and identical to Task 18 baseline. |
| **Git Cleanliness** | **PASS** | Clean working tree; zero secrets, keystores, or temporary files tracked in git. |
| **Physical Device Playtest** | **UNVERIFIED** | Host environment had no connected ADB handset; requires sideload sanity test on physical phone. |
| **Live Production AdMob Serving**| **UNVERIFIED** | Requires active store publication and live ad unit IDs. |

---

## 2. Absolute No-Go Conditions Audit

Every release-blocker condition specified in Section 26 was evaluated against the codebase:

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
   **NO.** Completely documented in `TASK_21_DATA_SAFETY_MATRIX.md`.
8. **Missing mandatory store assets?**  
   **YES (PENDING DEVELOPER EXPORT).** 512×512 Icon, 1024×500 Feature Graphic, and screenshots must be uploaded to Play Console.
9. **Gameplay regression or puzzle content modification?**  
   **NO.** 313/313 tests passed. 150/150 levels mathematically frozen.
10. **Release build failure?**  
    **NO.** Both APK and AAB build cleanly with 0 errors.

---

## 3. Final Pre-Submission Developer Action Steps

1. **Keystore:** Create `android/key.properties` with your release keystore path and passwords.
2. **Graphic Assets:** Export the 512×512 App Icon and 1024×500 Feature Graphic, and capture 4 device screenshots.
3. **Build Final Signed AAB:**
   ```bash
   flutter build appbundle --release \
     --dart-define=ADMOB_PRODUCTION_MODE=true \
     --dart-define=ADMOB_REWARDED_ID=ca-app-pub-YOUR_REWARDED_ID \
     --dart-define=ADMOB_INTERSTITIAL_ID=ca-app-pub-YOUR_INTERSTITIAL_ID
   ```
4. **Upload to Play Console:** Go to **Testing > Closed testing**, create a new release, upload `app-release.aab`, and fill out the questionnaires using `TASK_21_PLAY_CONSOLE_DECLARATIONS.md` and `TASK_21_DATA_SAFETY_MATRIX.md`.
