# Shift Puzzle — Google Play Closed Testing 14-Day Tracker & Tester Management

**Application:** Shift Puzzle  
**Package:** `com.shiftpuzzle.game`  
**Current Track:** Closed Testing (Alpha)  
**Required Opted-in Testers:** Minimum 12 continuous testers  
**Mandatory Testing Duration:** Minimum 14 continuous days  
**Target Release Artifact:** `build/app/outputs/bundle/release/app-release.aab` (Version `1.0.0+2`)  
**Feedback Mechanism:** `support@shiftpuzzle.game` and Play Store Closed Beta Feedback  

---

## 1. Regulatory Context (Google Play Policy)

For personal Google Play Developer accounts registered on or after **November 13, 2023**, Google requires developers to run a closed test with at least **12 testers continuously opted in for at least 14 days** before applying for production access. 

* **Critical Rule:** If any tester opts out and the active count drops below 12, the 14-day clock may be paused or reset by Google Play.
* **Goal:** Maintain at least 15–20 recruited testers to provide a safe buffer above the 12-tester threshold.

---

## 2. Tester Roster & Management Roster

> *Note: In compliance with project privacy guidelines, real tester emails must never be committed to Git. Fill in this roster locally.*

| Tester ID | Tester Email (Private) | Opt-in Status | Device Model | Android OS | Join Date | Last Active | Feedback Submitted | Open Issues |
|---|---|---|---|---|---|---|---|---|
| T-01 | [tester01@example.com] | PENDING INVITE | — | — | — | — | None | None |
| T-02 | [tester02@example.com] | PENDING INVITE | — | — | — | — | None | None |
| T-03 | [tester03@example.com] | PENDING INVITE | — | — | — | — | None | None |
| T-04 | [tester04@example.com] | PENDING INVITE | — | — | — | — | None | None |
| T-05 | [tester05@example.com] | PENDING INVITE | — | — | — | — | None | None |
| T-06 | [tester06@example.com] | PENDING INVITE | — | — | — | — | None | None |
| T-07 | [tester07@example.com] | PENDING INVITE | — | — | — | — | None | None |
| T-08 | [tester08@example.com] | PENDING INVITE | — | — | — | — | None | None |
| T-09 | [tester09@example.com] | PENDING INVITE | — | — | — | — | None | None |
| T-10 | [tester10@example.com] | PENDING INVITE | — | — | — | — | None | None |
| T-11 | [tester11@example.com] | PENDING INVITE | — | — | — | — | None | None |
| T-12 | [tester12@example.com] | PENDING INVITE | — | — | — | — | None | None |
| T-13 (Buffer) | [tester13@example.com] | PENDING INVITE | — | — | — | — | None | None |
| T-14 (Buffer) | [tester14@example.com] | PENDING INVITE | — | — | — | — | None | None |
| T-15 (Buffer) | [tester15@example.com] | PENDING INVITE | — | — | — | — | None | None |

---

## 3. 14-Day Continuous Opt-In Log

* **Target Closed Test Launch Date:** YYYY-MM-DD  
* **Estimated 14-Day Completion Date:** YYYY-MM-DD  

| Day | Date | Required Count | Confirmed Opted-in | Active Testers | New Feedback | Crashes / ANRs | Build Version | Release Notes / Actions Taken |
|---|---|---|---|---|---|---|---|---|
| **Day 1** | — | 12 | 0 | 0 | None | 0 | 1.0.0+2 | Rollout AAB to closed track; send opt-in links to roster. |
| **Day 2** | — | 12 | 0 | 0 | None | 0 | 1.0.0+2 | Verify initial downloads and Chapter 1 onboarding flow. |
| **Day 3** | — | 12 | 0 | 0 | None | 0 | 1.0.0+2 | Monitor Move Budget & Undo Lock observations. |
| **Day 4** | — | 12 | 0 | 0 | None | 0 | 1.0.0+2 | Review Chapter 2–4 progress and difficulty pacing. |
| **Day 5** | — | 12 | 0 | 0 | None | 0 | 1.0.0+2 | Review opt-in count to ensure no drops below 12. |
| **Day 6** | — | 12 | 0 | 0 | None | 0 | 1.0.0+2 | Inspect Memory Echo recording and trajectory preview reports. |
| **Day 7** | — | 12 | 0 | 0 | None | 0 | 1.0.0+2 | Mid-point audit: verify Play Console opt-in statistics. |
| **Day 8** | — | 12 | 0 | 0 | None | 0 | 1.0.0+2 | Review Rewarded Hint and +5 Extra-Move Rescue interactions. |
| **Day 9** | — | 12 | 0 | 0 | None | 0 | 1.0.0+2 | Verify offline-to-online transitions and ad fallbacks. |
| **Day 10** | — | 12 | 0 | 0 | None | 0 | 1.0.0+2 | Inspect lifecycle transitions (backgrounding, phone calls). |
| **Day 11** | — | 12 | 0 | 0 | None | 0 | 1.0.0+2 | Audit long play sessions for frame drops or thermal comfort. |
| **Day 12** | — | 12 | 0 | 0 | None | 0 | 1.0.0+2 | Test physical back button and dialog escape handling. |
| **Day 13** | — | 12 | 0 | 0 | None | 0 | 1.0.0+2 | Final regression verification across all chapters. |
| **Day 14** | — | 12 | 0 | 0 | None | 0 | 1.0.0+2 | 14-day completion review; prepare Production Access Application. |

---

## 4. Defect Classification & Incident Log

| Defect ID | Severity (P0–P3) | Reporter | Component | Description & Steps | Status | Resolution Build |
|---|---|---|---|---|---|---|
| *None* | — | — | — | No defects currently reported. | — | — |

### Severity Scale:
* **P0 — Critical Release Blocker:** App crash on launch, game-breaking state corruption, inability to advance levels, or critical policy violation.
* **P1 — High Severity:** Broken monetization reward callback, physical back-key trap, or major UI rendering defect on specific aspect ratios.
* **P2 — Medium Severity:** Minor visual glitch, audio clipping on specific devices, or non-blocking animation stutter.
* **P3 — Low Severity / Cosmetic:** Minor spacing discrepancy or copy improvement suggestion.
