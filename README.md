# Shift Puzzle

Shift Puzzle is an elegant, tactile grid-based 2D puzzle game built with **Flutter**, **Dart**, and **Flame**. Players shift and wrap rows and columns of a 5×5 toroidal board to manipulate designated geometric puzzle pieces onto matching target cells.

## Technology Stack

* **Framework**: Flutter (v3.47+)
* **Language**: Dart (v3.13+)
* **Game Engine**: Flame (v1.38+)
* **Target Platforms**: Android (API 36), iOS, Web, Desktop (Linux)

## Current Status — 150-Level Release Candidate (Task 12)

Shift Puzzle is a production-hardened, feature-complete Android release candidate:
* **150 Handcrafted Levels**: 15 distinct thematic chapters spanning from introductory spatial shifts to grandmaster temporal puzzles, culminating in Level 150 "The Grand Singularity".
* **Deterministic Solvability**: 100% solver-verified via bidirectional BFS with exact minimal move budgets and zero duplicate board configurations.
* **Signature Feature — Memory Echo**: Explicit `Record -> Stop -> Reposition -> Echo` window enabling players to record movement macros and replay them as automated ghost sequences.
* **Optional Rewarded Ad Hint System**: 100% voluntary, opt-in in-game hint system revealing the next best move derived in runtime from `PuzzleSolver`, supported by Google AdMob rewarded ads with resilient offline fallbacks.
* **First-Session Visual Teaching**: Lightweight, non-blocking animated tutorials on Level 1 ("SWIPE TO SHIFT") and Level 2 ("THE BOARD WRAPS") with persistent completion tracking.
* **Playful UI & Tactile Micro-Interactions**: Tactile spring-like bouncy buttons (`BouncyButton`), celebratory star animations in `WinDialog`, glowing target seating aura, and vibrant chapter badges.
* **AdMob Integration**: Production-ready `AdMobAdService` with strict player-first policies (Chapter 1 100% ad-free, 4-level frequency cap, 3-minute cooldown, zero mid-puzzle ads, zero board banners).
* **Progress Persistence**: Offline-first `PlayerProgress` tracking stars, personal best moves, chapter unlocks, tutorial completion, and audio preferences.
* **Android 16 / API 36 Ready**: Configured with `compileSdk 36` and `targetSdk 36` in compliance with Google Play Store standards.
* **Comprehensive Automated Testing**: 228 automated unit, domain, solver, persistence, monetization, and widget tests passing cleanly with zero static analysis warnings.

## Project Structure

```text
lib/
├── core/
│   ├── analytics/
│   │   └── analytics_service.dart
│   ├── feedback/
│   │   └── game_feedback.dart
│   ├── monetization/
│   │   ├── ad_service.dart
│   │   └── admob_ad_service.dart
│   ├── puzzle/
│   │   ├── levels/
│   │   │   ├── level_definitions.dart
│   │   │   └── puzzle_level.dart
│   │   ├── logic/
│   │   │   ├── memory_echo.dart
│   │   │   ├── puzzle_engine.dart
│   │   │   └── puzzle_solver.dart
│   │   └── models/
│   │       ├── board_position.dart
│   │       ├── echo_status.dart
│   │       ├── piece_type.dart
│   │       ├── puzzle_state.dart
│   │       ├── puzzle_target.dart
│   │       ├── shift_direction.dart
│   │       └── shift_record.dart
│   └── storage/
│       └── player_progress.dart
├── game/
│   ├── components/
│   │   └── piece_renderer.dart
│   └── scenes/
│       └── shift_puzzle_game.dart
├── ui/
│   ├── widgets/
│   │   ├── bouncy_button.dart
│   │   └── tutorial_overlay.dart
│   ├── game_controls.dart
│   ├── game_header.dart
│   ├── game_screen.dart
│   ├── level_select_dialog.dart
│   └── win_dialog.dart
└── main.dart
```

## How to Run

### Web
```bash
flutter run -d chrome
# or build production web bundle:
flutter build web
```

### Desktop (Linux)
```bash
flutter run -d linux
```

### Mobile (Android)
```bash
flutter run
# or build release Android App Bundle (AAB):
flutter build appbundle --release
```

## How to Run Tests

```bash
# Static analysis (zero issues)
flutter analyze

# Full test suite (228 tests passing)
flutter test
```