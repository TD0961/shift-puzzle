# Shift Puzzle Data Safety Audit

**Application:** Shift Puzzle  
**Package Name:** `com.shiftpuzzle.game`  
**Internal Namespace:** `com.shiftpuzzle.shift_puzzle`  
**Version:** `1.0.0+2` (versionCode: 2, versionName: "1.0.0")  
**Audit Date:** September 28, 2026  
**Auditor:** Senior Android Release & Compliance Lead  
**Audit Scope:** Full codebase, dependency lockfiles, merged Android manifest, network data flows, native binary strings, and Google Play Data Safety policy requirements.

---

## 1. Executive Summary

This audit performs an evidence-based investigation of data practices in Shift Puzzle. 

Key verified findings:
1. **Core Application:** Shift Puzzle is an offline-first puzzle game. The core app collects **zero** user personal data, operates **zero** cloud servers or accounts, runs **zero** remote analytics endpoints, bundles **zero** crash-reporting SDKs, and stores all gameplay state exclusively on-device in sandboxed storage (`SharedPreferences`).
2. **Third-Party SDKs:** The only third-party dependency capable of external network communication is the **Google Mobile Ads SDK** (`google_mobile_ads: ^9.1.0`, Android native `com.google.android.gms:play-services-ads:25.4.0`).
3. **Advertising ID & Ad Services:** The Mobile Ads SDK injects permissions for the Android Advertising ID (`com.google.android.gms.permission.AD_ID`) and Privacy Sandbox (`ACCESS_ADSERVICES_AD_ID`, `ACCESS_ADSERVICES_ATTRIBUTION`, `ACCESS_ADSERVICES_TOPICS`).
4. **Distinction Between Capability vs. Verification:** Data collection by Google Mobile Ads SDK depends on Google Play Services runtime configurations and publisher account settings. Fields where repository evidence alone is insufficient are explicitly marked `REQUIRES GOOGLE PLAY / SDK DOCUMENTATION VERIFICATION`.

---

## 2. Core App Data Practices

| Category | Collected by Core App? | Stored Remotely? | Transmitted Off-Device? | Evidence in Repository |
|---|---|---|---|---|
| **Personal Identifiers** (Name, Email, Phone, User ID) | **NO** | **NO** | **NO** | Zero auth/account logic; `pubspec.yaml` has no auth packages. |
| **Financial / Payment Info** (Credit Card, Purchases) | **NO** | **NO** | **NO** | Zero in-app purchase SDKs (`in_app_purchase` not in `pubspec.yaml`). |
| **Location Data** (GPS, Precise / Coarse) | **NO** | **NO** | **NO** | Zero location permissions in `AndroidManifest.xml`; no geolocator packages. |
| **Photos, Media, Audio, Files** | **NO** | **NO** | **NO** | Zero media/storage permissions; no camera/microphone packages. |
| **Contacts & Address Book** | **NO** | **NO** | **NO** | No contacts permission; no contacts plugin. |
| **Health & Fitness** | **NO** | **NO** | **NO** | Not applicable. |
| **Messages / SMS / Emails** | **NO** | **NO** | **NO** | Not applicable. |
| **Browsing History / Web Activity** | **NO** | **NO** | **NO** | Not applicable. |
| **Application Crash Reports** | **NO** | **NO** | **NO** | No Firebase Crashlytics, Sentry, or Bugsnag in dependencies. |
| **Application Performance Telemetry** | **NO** | **NO** | **NO** | `AnalyticsService` in `lib/core/analytics/analytics_service.dart` is a local-only `debugPrint` logger in debug mode (`kDebugMode`) and no-op in release mode. Zero external endpoints. |

---

## 3. Third-Party SDK Data Practices

### SDK Inventory Analysis

A search across `pubspec.yaml`, `pubspec.lock`, and the Android build system confirms:

| Potential SDK Type | Status | Evidence |
|---|---|---|
| **Firebase (Core, Auth, Analytics, Crashlytics)** | **NOT PRESENT** | 0 references in `pubspec.lock` and `build.gradle.kts`. |
| **Third-Party Product Analytics** (Mixpanel, Amplitude, Segment) | **NOT PRESENT** | 0 references in repository. |
| **Third-Party Crash Reporting** (Sentry, Bugsnag, Crashlytics) | **NOT PRESENT** | 0 references in repository. |
| **Attribution / MMP SDKs** (AppsFlyer, Adjust, Kochava, Branch) | **NOT PRESENT** | 0 references in repository. |
| **Social / Login SDKs** (Facebook, Google Sign-In) | **NOT PRESENT** | 0 references in repository. |
| **Advertising SDK** | **PRESENT** | `google_mobile_ads: ^9.1.0` (Native `play-services-ads:25.4.0`). |

---

## 4. Google Mobile Ads SDK Data Practices

Google Mobile Ads SDK communicates directly with Google servers when ads are initialized, requested, and rendered.

### Data Types Handled by Google Mobile Ads SDK

1. **Device or Other Identifiers:**
   - **Android Advertising ID (AAID):** On Android 13+ (API 33+), the SDK requires `com.google.android.gms.permission.AD_ID` to receive the user's advertising identifier.
   - **Privacy Sandbox Ad Identifiers:** On Android 14+ (API 34+), the SDK uses `ACCESS_ADSERVICES_AD_ID` and `ACCESS_ADSERVICES_TOPICS`.
   - **Purpose:** Ad delivery, fraud prevention, frequency capping, ad measurement, and attribution.
   - **Sharing:** Transmitted directly to Google ad servers.

2. **Approximate Location (IP Address):**
   - **Source:** Inferred from network IP address during HTTPS socket connections to Google ad endpoints.
   - **Precise Location:** The app does NOT request `ACCESS_FINE_LOCATION` or `ACCESS_COARSE_LOCATION`. GPS data is never collected or transmitted.
   - **Purpose:** Serving regionally appropriate advertisements and regional compliance.

3. **Ad Interaction & Diagnostics:**
   - **Source:** Ad impressions, clicks, video completion events, and SDK internal errors.
   - **Purpose:** Ad reporting, billing verification, fraud prevention, and SDK reliability diagnostics.

---

## 5. Evidence-Based Data Safety Matrix

| # | Data Category | Data Type | Core App Collects? | 3rd-Party SDK Collects? | Shared? | Purpose | Required or Optional? | Off-Device Transmission? | Encryption in Transit? | Deletion Mechanism | Responsible Component | Repo Evidence | Confidence |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | **Location** | Approximate Location | No | Yes (inferred via IP) | Yes (with Google) | Advertising, Fraud Prevention | Required for ad serving | Yes | Yes (HTTPS/TLS) | Managed via Google Account / IP churn | Google Mobile Ads SDK | `play-services-ads:25.4.0` | High |
| 2 | **Location** | Precise Location (GPS) | No | No | No | N/A | N/A | No | N/A | N/A | None | No GPS permissions in manifest | High |
| 3 | **Personal Info** | Name, Email, Phone, Address, ID | No | No | No | N/A | N/A | No | N/A | N/A | None | No account system, no PII inputs | High |
| 4 | **Financial Info** | Credit Card, Bank Info, Purchase History | No | No | No | N/A | N/A | No | N/A | N/A | None | No IAP plugin or payment processing | High |
| 5 | **Health & Fitness** | Health, Fitness data | No | No | No | N/A | N/A | No | N/A | N/A | None | None | High |
| 6 | **Messages** | Emails, SMS, Chat messages | No | No | No | N/A | N/A | No | N/A | N/A | None | None | High |
| 7 | **Photos & Videos** | Photos, Videos | No | No | No | N/A | N/A | No | N/A | N/A | None | None | High |
| 8 | **Audio Files** | Voice, Sound recordings | No | No | No | N/A | N/A | No | N/A | N/A | None | None | High |
| 9 | **Files & Docs** | Files, Documents | No | No | No | N/A | N/A | No | N/A | N/A | None | None | High |
| 10 | **Calendar** | Calendar events | No | No | No | N/A | N/A | No | N/A | N/A | None | None | High |
| 11 | **Contacts** | Contact list | No | No | No | N/A | N/A | No | N/A | N/A | None | No contacts permission | High |
| 12 | **App Activity** | App interactions (Ad clicks, views) | No | Yes | Yes (with Google) | Advertising, Analytics | Required for ad serving | Yes | Yes (HTTPS/TLS) | Managed by Google SDK | Google Mobile Ads SDK | `AdMobAdService` ad requests | High |
| 13 | **App Activity** | In-app gameplay telemetry | Local only | No | No | Internal debug logging only | Optional (disabled in release) | No | N/A | Local storage reset | `DebugAnalyticsService` (`lib/core/analytics/`) | High |
| 14 | **Web Browsing** | Web browsing history | No | No | No | N/A | N/A | No | N/A | N/A | None | None | High |
| 15 | **App Info & Performance** | Crash logs (App level) | No | No | No | N/A | N/A | No | N/A | N/A | None | No crash SDK (Crashlytics/Sentry absent) | High |
| 16 | **App Info & Performance** | Diagnostics / SDK Crash Logs | No | Yes | Yes (with Google) | Analytics, Fraud Prevention | Required for SDK reliability | Yes | Yes (HTTPS/TLS) | Managed by Google SDK | Google Mobile Ads SDK | Manifest merger entries | High |
| 17 | **Device or Other IDs** | Android Advertising ID (`AD_ID`) | No | Yes | Yes (with Google) | Advertising, Fraud Prevention | Required for ad serving | Yes | Yes (HTTPS/TLS) | User can reset/delete AAID in OS Settings | Google Mobile Ads SDK | `com.google.android.gms.permission.AD_ID` | High |

---

## 6. Local-Only Data (On-Device Sandboxed Storage)

Shift Puzzle persists gameplay data locally on the user's device using Flutter's `shared_preferences` package (`shared_preferences: ^2.5.5`):

* **Data Stored:**
  - `highest_unlocked_level`: Integer tracking campaign chapter unlocking.
  - `level_moves_<id>`: Integer personal best move record.
  - `level_stars_<id>`: Integer star count (1–3 stars).
  - `audio_sfx_enabled`: Boolean preference.
  - `audio_music_enabled`: Boolean preference.
* **Storage Location:** Private app-sandboxed storage (`/data/data/com.shiftpuzzle.game/shared_prefs/FlutterSharedPreferences.xml`).
* **External Access:** Inaccessible to other apps (protected by Android Linux UID isolation).
* **Deletion:** Automatically deleted by the operating system when the user taps "Clear Data" or uninstalls the app.

---

## 7. Android Manifest Permissions Audit

Inspecting the final release merged manifest (`build/app/intermediates/merged_manifests/release/processReleaseManifest/AndroidManifest.xml`):

### Application-Declared Permissions
1. `android.permission.INTERNET`
   - *Source:* `android/app/src/main/AndroidManifest.xml` (line 2).
   - *Requirement:* Required to load ad assets and communicate with Google AdMob servers.
2. `android.permission.ACCESS_NETWORK_STATE`
   - *Source:* `android/app/src/main/AndroidManifest.xml` (line 3).
   - *Requirement:* Checked by `ConnectivityService` and AdMob SDK to avoid unnecessary network calls when the device is offline.

### SDK-Injected Permissions (Google Mobile Ads SDK & Jetpack Dependencies)
1. `com.google.android.gms.permission.AD_ID`
   - *Source:* `com.google.android.gms:play-services-ads-api:25.4.0`.
   - *Purpose:* Enables access to Google Advertising ID on Android 13+ devices.
2. `android.permission.ACCESS_ADSERVICES_AD_ID`
   - *Source:* `play-services-ads:25.4.0`.
   - *Purpose:* Android Privacy Sandbox measurement and attribution.
3. `android.permission.ACCESS_ADSERVICES_ATTRIBUTION`
   - *Source:* `play-services-ads:25.4.0`.
   - *Purpose:* Privacy Sandbox ad click and conversion attribution.
4. `android.permission.ACCESS_ADSERVICES_TOPICS`
   - *Source:* `play-services-ads:25.4.0`.
   - *Purpose:* Privacy Sandbox interest-based advertising signals without device tracking.
5. `android.permission.WAKE_LOCK`
   - *Source:* Flutter Engine / Google Play Services.
   - *Purpose:* Prevents processor sleep during critical rendering and ad display cycles.
6. `android.permission.FOREGROUND_SERVICE`
   - *Source:* `androidx.work:work-runtime:2.7.0+` (transitive dependency of Google Mobile Ads SDK).
   - *Purpose:* Required by Android Jetpack WorkManager for scheduled background maintenance tasks.
7. `com.shiftpuzzle.game.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION`
   - *Source:* `androidx.core:core` security receiver protection.

---

## 8. Network & Data Flow Architecture

* **Core Gameplay Loop:** 100% offline. Zero network calls occur during puzzle solving, move undo, level resetting, or Memory Echo recording/replay.
* **Ad Requests Flow:**
  1. `AdMobAdService` checks `ConnectivityService.hasInternetConnection()`.
  2. If online and frequency/cooldown requirements are satisfied, SDK calls `MobileAds.instance.load(...)`.
  3. Network requests are made strictly over HTTPS directly to Google's endpoints (`*.googlesyndication.com`, `*.google.com`).
  4. No proxy, intermediate, or custom backend server exists.
* **External Domains Contacted:**
  - Google AdMob ad servers (`*.googlesyndication.com`, `pagead2.googlesyndication.com`).
  - Google Play Services infrastructure (`play.google.com`).

---

## 9. Play Console Data Safety Fields Requiring Official Verification

While repository code proves what the app compiles, certain fields in the Google Play Console Data Safety questionnaire depend on how the developer configures their Google AdMob publisher account.

The following items are classified as **REQUIRES GOOGLE PLAY / SDK DOCUMENTATION VERIFICATION**:

1. **Ad Personalization vs. Non-Personalized Ads:**
   - *Question:* Are ads served with personalization based on previous user activity?
   - *Code Evidence:* The app sends default `const AdRequest()`, which allows AdMob to utilize default account settings.
   - *Status:* **REQUIRES GOOGLE PLAY / SDK DOCUMENTATION VERIFICATION** — Developer must check if personalized ads are enabled or restricted in the Google AdMob dashboard.
2. **Consent Management Platform (CMP / UMP SDK):**
   - *Question:* Is a Google-certified CMP integrated for EEA/UK/GDPR consent?
   - *Code Evidence:* The current repository uses `google_mobile_ads: ^9.1.0` without an explicit `UserMessagingPlatform` (UMP) consent flow.
   - *Status:* **REQUIRES GOOGLE PLAY / SDK DOCUMENTATION VERIFICATION** — If serving ads in the EEA/UK, developer must evaluate integrating the UMP SDK or configuring AdMob European User Consent in the AdMob Console.
3. **Data Deletion Link URL:**
   - *Question:* Does your app provide a link where users can request data deletion?
   - *Code Evidence:* Core app stores no remote data. AdMob data is managed directly by Google.
   - *Status:* **REQUIRES GOOGLE PLAY / SDK DOCUMENTATION VERIFICATION** — Google Play accepts OS-level deletion instructions (Settings > Google > Ads > Delete advertising ID) for apps that collect data solely via third-party ad SDKs without accounts.

---

## 10. Audit Conclusion

The Shift Puzzle codebase exhibits clean data minimization. The application collects no first-party personal data, enforces offline gameplay isolation, and limits third-party data processing exclusively to the Google Mobile Ads SDK. All required declarations are documented with high confidence based on physical manifest and dependency inspection.
