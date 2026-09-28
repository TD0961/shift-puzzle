# Task 21 — Google Play Data Safety Matrix

**Application:** Shift Puzzle  
**Package:** `com.shiftpuzzle.game`  
**Version:** `1.0.0+2`  
**Date:** September 28, 2026  

This document provides the complete, factual Data Safety declaration matrix for the Google Play Console form, covering first-party data practices and all embedded third-party SDKs.

---

## 1. High-Level Data Practice Overview

* **Does your app collect or share any user data?**: **Yes**  
  *(The first-party game code collects 0 personal data, but the integration of Google Mobile Ads SDK collects technical identifiers and diagnostics).*
* **Is all of the user data collected by your app encrypted in transit?**: **Yes**  
  *(All network traffic via Google Mobile Ads utilizes standard TLS / HTTPS encryption).*
* **Do you provide a way for users to request that their data be deleted?**: **Yes**  
  *(Users can reset/delete their Advertising ID directly via Android System Settings under Google > Ads, or manage ad privacy settings in their Google Account).*

---

## 2. Comprehensive SDK Data Safety Matrix

| Data Category | Specific Data Type | Collected? | Shared? | Processing / Storage | Encryption in Transit | Purpose(s) | User Choice | Associated SDK / Service |
|---|---|---|---|---|---|---|---|---|
| **Location** | **Approximate location** (network-based, coarse) | **Yes** | **Yes** | Not stored on device; processed on Google servers | **Yes** (HTTPS) | • Advertising or marketing | Required for ad serving | **Google Mobile Ads (AdMob)** |
| **Personal Info** | Name, Email, Address, Phone, User IDs | **No** | **No** | N/A | N/A | N/A | N/A | *None (Zero First-Party Accounts)* |
| **Financial Info** | Credit card, bank info, purchase history | **No** | **No** | N/A | N/A | N/A | N/A | *None (No IAP, 100% Free Game)* |
| **Health & Fitness** | Medical, exercise data | **No** | **No** | N/A | N/A | N/A | N/A | *None* |
| **Messages** | Emails, SMS, chat messages | **No** | **No** | N/A | N/A | N/A | N/A | *None (Single Player Offline)* |
| **Photos & Videos** | Photos, videos | **No** | **No** | N/A | N/A | N/A | N/A | *None* |
| **Audio Files** | Voice recordings, audio files | **No** | **No** | N/A | N/A | N/A | N/A | *None (Procedural Audio Synth)* |
| **Files & Docs** | User files, documents | **No** | **No** | N/A | N/A | N/A | N/A | *None* |
| **Calendar** | Calendar events | **No** | **No** | N/A | N/A | N/A | N/A | *None* |
| **Contacts** | Contacts, address book | **No** | **No** | N/A | N/A | N/A | N/A | *None* |
| **App Activity** | **App interactions** (ad views, clicks, taps, video completes) | **Yes** | **Yes** | Processed by Google AdMob infrastructure | **Yes** (HTTPS) | • Advertising or marketing<br>• Analytics | Required for ad serving | **Google Mobile Ads (AdMob)** |
| **App Info & Performance** | **Crash logs** & diagnostics | **Yes** | **Yes** | Ephemeral transmission by AdMob SDK on failure | **Yes** (HTTPS) | • Analytics<br>• Fraud prevention & security | Required for ad serving | **Google Mobile Ads (AdMob)** |
| **Device or other IDs** | **Device or other IDs** (Google Advertising ID / Android Ad ID) | **Yes** | **Yes** | Stored on Google servers according to Google policy | **Yes** (HTTPS) | • Advertising or marketing<br>• Fraud prevention & security<br>• Analytics | Required for ad serving (user can reset AAID in OS) | **Google Mobile Ads (AdMob)** |

---

## 3. First-Party Local Storage (SharedPreferences)

The application stores the following data **exclusively in local private application sandboxed storage** (`SharedPreferences`) on the player's handset:

| Stored Property | Purpose | Shared Remotely? | Deletion Method |
|---|---|---|---|
| `completed_levels` (List<int>) | Tracks which of the 150 campaign levels have been completed | **No (Local only)** | Uninstall app or Clear App Data |
| `level_stars_<id>` (int) | Star rating earned (1, 2, or 3 stars) | **No (Local only)** | Uninstall app or Clear App Data |
| `level_best_moves_<id>` (int) | Player's personal best move count | **No (Local only)** | Uninstall app or Clear App Data |
| `highest_unlocked_level` (int) | Highest unlocked level in campaign progression | **No (Local only)** | Uninstall app or Clear App Data |
| `last_played_level` (int) | Resume point for next play session | **No (Local only)** | Uninstall app or Clear App Data |
| `sound_enabled` (bool) | Audio synthesizer preference | **No (Local only)** | Uninstall app or Clear App Data |
| `haptics_enabled` (bool) | Touch haptic vibration preference | **No (Local only)** | Uninstall app or Clear App Data |

*Under Google Play Data Safety guidelines, first-party data that is stored strictly on the local device and never transmitted to an external server or third party is **NOT** classified as "Collected" for Data Safety form purposes.*

---

## 4. Play Console Questionnaire Walkthrough

When completing the Google Play Data Safety form in Play Console, enter the following exact responses:

1. **Data collection and security:**
   - Does your app collect or share any of the required user data types? → **Yes**
   - Is all of the user data collected by your app encrypted in transit? → **Yes**
   - Do you provide a way for users to request that their data be deleted? → **Yes**

2. **Data types declared:**
   - Under **Location**: Check **Approximate location**.
   - Under **App activity**: Check **App interactions**.
   - Under **App info and performance**: Check **Crash logs**, **Diagnostics**.
   - Under **Device or other IDs**: Check **Device or other IDs**.

3. **For each checked data type:**
   - **Is this data collected, shared, or both?** → **Collected and Shared**
   - **Is this data processed ephemerally?** → **No** (except crash telemetry)
   - **Is this data required or optional?** → **Data collection is required** (to display advertisements that support the free game)
   - **Why is this user data collected?** → Select **Advertising or marketing**, **Analytics**, and **Fraud prevention and security**.
