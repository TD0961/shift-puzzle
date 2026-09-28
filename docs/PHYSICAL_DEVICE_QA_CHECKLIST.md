# Shift Puzzle — Physical Android Device QA Checklist

**Document Purpose:** Standard Operating Procedure and Manual Verification Checklist for Physical Android Hardware QA  
**Package:** `com.shiftpuzzle.game`  
**Application:** Shift Puzzle  

---

## 1. Device Profile (To be recorded per physical device)

* **Device Hardware / Model:** ________________________
* **Manufacturer:** ________________________
* **Android OS Version:** ________________________
* **Android API Level:** ________________________ (Must be >= 24)
* **CPU / ABI Architecture:** ________________________ (e.g., arm64-v8a)
* **Screen Resolution:** ________________________ (e.g., 1080×2400)
* **Screen Density / DPI:** ________________________ (e.g., 420 dpi)
* **Form Factor:** Phone / Small Tablet / Large Tablet

---

## 2. Build Under Test (QA Candidate)

* **Target APK Path:** `build/app/outputs/flutter-apk/app-release.apk`
* **Package Name:** `com.shiftpuzzle.game`
* **Version Name:** `1.0.0`
* **Version Code:** `2`
* **Git Commit SHA:** `ea2c8bc`
* **Build Type:** Physical QA Release Candidate (`allowInsecureDebugSigning=true` for sideload QA)
* **AdMob Configuration:** Official Google Test IDs (Safe QA Mode)
* **APK SHA-256 Digest:** *(Computed upon build completion)*

---

## 3. Physical Test Execution Matrix

| # | Test Area | Verification Procedure | Expected Result | Status (PASS / FAIL / NOT TESTED / N/A) | Notes / Observations |
|---|---|---|---|---|---|
| **01** | **Installation** | Sideload via `adb install -r <apk>`. | Installs without parse errors, signature conflicts, or permission blocks. | NOT TESTED | Hardware connection required. |
| **02** | **App Launcher Icon** | Inspect app icon on home screen and app drawer. | Shift Puzzle 5×5 toroidal icon renders sharp, centered, properly masked (adaptive), no Flutter default icon. | NOT TESTED | Hardware connection required. |
| **03** | **First Launch** | Tap icon to launch from cold state. | Splash screen displays `#090D16`, smooth transition to main game header; 0 crashes, no black screen. | NOT TESTED | Hardware connection required. |
| **04** | **Orientation Lock** | Physically rotate device 90° and 180° in both directions. | Game strictly remains in portrait orientation; layout does not skew or reset. | NOT TESTED | Hardware connection required. |
| **05** | **Core Touch & Shifts** | Swipe and tap rows and columns across 5×5 board. | Immediate responsive toroidal shift; row/col wraps seamlessly across edges; smooth Flame animation. | NOT TESTED | Hardware connection required. |
| **06** | **Rapid Repeated Input** | Rapidly tap row/column shift controls 5+ times in 1 second. | Game queue handles inputs stably; pieces do not desynchronize or glitch out of grid bounds. | NOT TESTED | Hardware connection required. |
| **07** | **Level Completion** | Solve Level 1 and Level 2. | Target match detected; victory fanfare; stars awarded; WinDialog opens cleanly with score/par comparison. | NOT TESTED | Hardware connection required. |
| **08** | **Move Budget & Counter** | Make moves on Level 3 or 4; observe HUD. | Move counter increments 1 per shift; par indicator displayed; drift nudge triggers if off optimal path. | NOT TESTED | Hardware connection required. |
| **09** | **Undo Lock** | Make moves below optimal par; then reach and exceed par. | Undo active below par; Undo firmly locked at and above optimal par; tooltips/visual state reflect lock. | NOT TESTED | Hardware connection required. |
| **10** | **Move Limit Trigger** | Exhaust `authoritativeOptimalMoves + 3` moves. | Move limit dialog appears; provides options for "+5 Moves (Watch Ad)" and "Replay Level". | NOT TESTED | Hardware connection required. |
| **11** | **Extra-Move Rescue (+5)** | Tap "+5 Moves (Watch Ad)" on Move Limit dialog. | Rewarded video ad plays; upon completion, exactly +5 moves added; limit becomes `par + 8`; offered once only. | NOT TESTED | Hardware connection required. |
| **12** | **Ad Early Dismissal** | Tap rescue ad and close/skip immediately before reward callback. | No moves granted; player notified via SnackBar; move limit dialog reopens safely. | NOT TESTED | Hardware connection required. |
| **13** | **Memory Echo Recording** | Enter an Echo level (e.g. Level 11); tap Record. | Pulsing record indicator; shift pieces; tap Stop; ghost trajectory arrows display planned sequence. | NOT TESTED | Hardware connection required. |
| **14** | **Memory Echo Replay** | Reposition board; tap Replay Echo. | Ghost moves execute recorded macro sequence; echo moves DO NOT count as player moves; solves puzzle. | NOT TESTED | Hardware connection required. |
| **15** | **Audio & SFX** | Play with sound on; test shift clicks, victory chord. | Crisp audio sync; no clipping or buzzing; mute toggle in header silences all game audio instantly. | NOT TESTED | Hardware connection required. |
| **16** | **Haptic Feedback** | Perform shifts and win puzzle. | Subtle haptic pulse on valid shifts and victory; no continuous or stuck vibration motor. | NOT TESTED | Hardware connection required. |
| **17** | **Android Hardware Back** | Press physical/gesture Back in gameplay and on dialogs. | WinDialog does NOT pop underlying game screen (`PopScope(canPop: false)` works); menus navigate back cleanly. | NOT TESTED | Hardware connection required. |
| **18** | **App Lifecycle (Suspend)** | Press Home during level; launch another app; return. | Game resumes exactly at current board state and move count; audio resumes; no crash. | NOT TESTED | Hardware connection required. |
| **19** | **Process Kill & Restore** | Force-stop app in Android Settings; relaunch. | Level unlocks, stars, and audio settings persist intact from `SharedPreferences`. | NOT TESTED | Hardware connection required. |
| **20** | **Offline Airplane Mode** | Enable Airplane mode (Wi-Fi and mobile data OFF); play. | App launches; campaign fully playable; hints/ads show graceful unavailable dialog without crashing. | NOT TESTED | Hardware connection required. |
| **21** | **Online Transition** | Disable Airplane mode while game is running; tap Hint. | Network connection detected; rewarded ad preloads and becomes available for watching. | NOT TESTED | Hardware connection required. |
| **22** | **Extended Session (30m+)** | Play continuously through 10+ levels over 30 minutes. | Frame rate remains solid (60 FPS); no device thermal runaway; no progressive memory leak in `dumpsys`. | NOT TESTED | Hardware connection required. |
| **23** | **Logcat Runtime Audit** | Run `adb logcat` during extended gameplay session. | Zero `FATAL EXCEPTION`, zero `ANR`, zero `FlutterError`, zero unhandled platform exceptions. | NOT TESTED | Hardware connection required. |
| **24** | **Fresh Install & Clean State** | Uninstall app; reinstall via `adb install`; launch. | Initial level unlocked (Level 1); clean 0-star state; tutorial overlay appears on Level 1. | NOT TESTED | Hardware connection required. |

---

## 4. QA Sign-Off

* **Tester Name / Lead:** ________________________
* **Date Tested:** ________________________
* **Final Verdict:** PASS / FAIL / BLOCKED
* **Blocking Defects Identified:** ________________________
