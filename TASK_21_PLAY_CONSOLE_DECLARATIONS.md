# Task 21 — Google Play Console Declarations & Questionnaires

**Application:** Shift Puzzle  
**Package Name:** `com.shiftpuzzle.game`  
**Version:** `1.0.0+2`  
**Date:** September 28, 2026  

This document provides the exact answers, evidence, and rationale for all mandatory Google Play Console policy declarations and questionnaire sections.

---

## 1. App Access (Special Access)

* **Question:** Does your app have restricted access (e.g. login credentials, two-factor authentication, membership)?
* **Selected Option:** **All functionality is available without special access restrictions.**
* **Factual Evidence:**
  - Shift Puzzle operates completely offline-first with zero accounts, zero authentication, and zero paywalls.
  - All 150 campaign levels unlock naturally through in-game gameplay progression.
  - Google Play app review testers require no login credentials, test accounts, demo codes, or API access keys to review the entire application.

---

## 2. Ads Declaration

* **Question:** Does your app contain advertisements?
* **Selected Option:** **Yes, my app contains ads.**
* **Factual Evidence:**
  - Integrates Google Mobile Ads (`google_mobile_ads: ^9.1.0`).
  - Contains optional rewarded ads (for an in-game hint or a single-use +5 move rescue at the move limit).
  - Contains capped interstitial ads (strictly between completed levels starting from Chapter 2 / Level 11 onwards, respecting a 3-minute cooldown and a 4-level frequency cap).
  - Contains zero in-board banner ads.

---

## 3. Advertising ID (AAID) Declaration

* **Question:** Does your app use advertising ID?
* **Selected Option:** **Yes.**
* **Purposes Selected:**
  - **Advertising or marketing:** Google Mobile Ads SDK uses the Google Play services Advertising ID (AAID) to serve personalized or contextual advertisements and enforce frequency capping.
  - **Analytics:** To measure ad performance and view counts.
  - **Fraud prevention and security:** Google AdMob uses device identifiers to detect and prevent invalid ad traffic and bot clicks.
* **Factual Evidence:**
  - Android SDK target is `targetSdk = 36` (Android 16).
  - Google Mobile Ads SDK transitively declares `com.google.android.gms.permission.AD_ID`.

---

## 4. Target Audience and Content (Age Rating & Families Policy)

### Age Group Selection
* **Selected Target Age Groups:**
  - [ ] Under 5
  - [ ] 6–8
  - [ ] 9–12
  - [x] **13–15**
  - [x] **16–17**
  - [x] **18 and over**

### Appeal to Children Assessment
* **Question:** Could your store listing unintentionally appeal to children?
* **Selected Option:** **No.**
* **Factual Evidence & Reasoning:**
  - **Visual Design:** Minimalist, sleek geometric dark-mode aesthetic (`#090D16` slate background, neon geometric polygons, clean technical typography). No cartoon characters, anthropomorphic animals, childish voices, or primary-color toy themes.
  - **Gameplay:** Pure abstract mathematical toroidal shift puzzles involving parity constraints, cyclic permutations, and Memory Echo macro planning.
  - **Marketing Assets:** Store graphics, icons, and descriptions emphasize "spatial logic", "minimalist design", and "toroidal wrapping", targeting teenage and adult puzzle enthusiasts.
  - **Families Policy Exemption:** Because the declared audience is strictly 13 and older and does not unintentionally appeal to children, the app is not subject to the Google Play Families Policy program requirements (such as Designed for Families ad network restrictions).

---

## 5. Content Rating (IARC Questionnaire)

**Category:** Game — Puzzle / Strategy

| Questionnaire Category | Response | Factual Evidence |
|---|---|---|
| **Violence** | **None** | Abstract geometric shapes moving on a grid. No depictions of violence, injury, weapons, or conflict. |
| **Fear / Horror** | **None** | No scary elements, jump scares, or horror imagery. |
| **Sexuality** | **None** | No sexual themes, nudity, or suggestive content. |
| **Simulated Gambling** | **None** | No casino mechanics, slot machines, roulette, betting, or card games with wagered real/virtual currency. |
| **Language / Profanity** | **None** | All text is clinical, editorial puzzle instructions and UI labels. |
| **Controlled Substances** | **None** | No references to alcohol, tobacco, narcotics, or illegal drugs. |
| **Miscellaneous / User Interaction** | **No** | No user-generated content, no in-app chat, no voice communication, no location sharing with other users. |
| **In-App Purchases** | **No** | Zero in-app billing (`in_app_purchase` is not in `pubspec.yaml`). All content is free. |

### Expected Global Content Ratings:
- **IARC:** 3+ / Everyone
- **ESRB:** Everyone (E)
- **PEGI:** PEGI 3
- **USK:** USK 0
- **ClassInd:** Livre (General Audience)
- **ACB:** General (G)

---

## 6. App Category & Contact Information

* **App Category:** Games > Puzzle
* **Secondary Category / Tags:** Brain Games, Minimalist, Logic, Offline
* **Developer Email:** `support@shiftpuzzle.game`
* **Website:** `https://shiftpuzzle.game` (or project repository / landing page)
* **Privacy Policy URL:** Hosted URL pointing to `PRIVACY_POLICY.md` content

---

## 7. Mandatory Policy Declarations (Standard Google Play Checklist)

| Policy Area | Declaration | Notes |
|---|---|---|
| **News Apps** | **No** | The app is not a news app. |
| **COVID-19 Apps** | **No** | The app is not a COVID-19 contact tracing or status app. |
| **Data Safety** | **Declared** | See `TASK_21_DATA_SAFETY_MATRIX.md`. |
| **Financial Features** | **None** | Does not provide financial services or cryptocurrency trading. |
| **Government Apps** | **No** | Not affiliated with or providing government services. |
| **Health Apps** | **No** | Not a medical or health-tracking app. |
| **Forecasting / Weather** | **No** | Does not provide weather forecasting. |
| **Background Location** | **No** | Does not request any location permissions. |
| **Foreground Service** | **No** | Does not request or declare any foreground services. |
| **All Files Access (MANAGE_EXTERNAL_STORAGE)** | **No** | Does not request storage permissions; uses sandboxed internal app storage only. |
| **SMS / Call Log Permissions** | **No** | Does not request telephony or SMS permissions. |
