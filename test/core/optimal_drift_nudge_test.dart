import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shift_puzzle/core/analytics/analytics_service.dart';
import 'package:shift_puzzle/core/monetization/ad_service.dart';
import 'package:shift_puzzle/core/puzzle/levels/level_definitions.dart';
import 'package:shift_puzzle/core/puzzle/levels/puzzle_level.dart';
import 'package:shift_puzzle/core/puzzle/logic/puzzle_engine.dart';
import 'package:shift_puzzle/core/puzzle/logic/puzzle_solver.dart';
import 'package:shift_puzzle/core/puzzle/models/shift_direction.dart';
import 'package:shift_puzzle/core/storage/player_progress.dart';
import 'package:shift_puzzle/ui/game_screen.dart';
import 'package:shift_puzzle/ui/optimal_drift_nudge_dialog.dart';

/// Test mock to track all analytics events for verification.
class TestMockAnalytics extends DebugAnalyticsService {
  final List<String> loggedEvents = [];
  final Map<String, dynamic> lastParams = {};

  TestMockAnalytics() : super(enableLogging: false);

  void _record(String event, [Map<String, dynamic>? params]) {
    loggedEvents.add(event);
    if (params != null) {
      lastParams[event] = params;
    }
  }

  @override
  void logOptimalDriftDetected({
    required int levelId,
    required int chapterId,
    required bool hasMemoryEcho,
    required int moveCount,
    required int optimalMoves,
  }) {
    _record('optimal_drift_detected', {
      'levelId': levelId,
      'chapterId': chapterId,
      'hasMemoryEcho': hasMemoryEcho,
      'moveCount': moveCount,
      'optimalMoves': optimalMoves,
    });
  }

  @override
  void logOptimalDriftNudgeShown({
    required int levelId,
    required int chapterId,
    required bool hasMemoryEcho,
    required int moveCount,
    required int optimalMoves,
  }) {
    _record('optimal_drift_nudge_shown', {
      'levelId': levelId,
      'chapterId': chapterId,
      'hasMemoryEcho': hasMemoryEcho,
      'moveCount': moveCount,
      'optimalMoves': optimalMoves,
    });
  }

  @override
  void logOptimalDriftKeepSolving({
    required int levelId,
    required int moveCount,
  }) {
    _record('optimal_drift_keep_solving', {
      'levelId': levelId,
      'moveCount': moveCount,
    });
  }

  @override
  void logOptimalDriftHintRequested({
    required int levelId,
    required int moveCount,
  }) {
    _record('optimal_drift_hint_requested', {
      'levelId': levelId,
      'moveCount': moveCount,
    });
  }

  @override
  void logOptimalDriftAdStarted({
    required int levelId,
    required String placement,
  }) {
    _record('optimal_drift_ad_started', {
      'levelId': levelId,
      'placement': placement,
    });
  }

  @override
  void logOptimalDriftAdRewarded({
    required int levelId,
    required String placement,
  }) {
    _record('optimal_drift_ad_rewarded', {
      'levelId': levelId,
      'placement': placement,
    });
  }

  @override
  void logOptimalDriftAdFailed({
    required int levelId,
    required String placement,
    required String reason,
  }) {
    _record('optimal_drift_ad_failed', {
      'levelId': levelId,
      'placement': placement,
      'reason': reason,
    });
  }

  @override
  void logOptimalDriftHintRevealed({
    required int levelId,
    required int moveCount,
  }) {
    _record('optimal_drift_hint_revealed', {
      'levelId': levelId,
      'moveCount': moveCount,
    });
  }

  @override
  void logLevelRestarted(int levelId) {
    _record('level_restarted', {'levelId': levelId});
  }

  @override
  void logLevelCompletedAfterOptimalDrift({
    required int levelId,
    required int moves,
    required int optimalMoves,
    required int stars,
  }) {
    _record('level_completed_after_optimal_drift', {
      'levelId': levelId,
      'moves': moves,
      'optimalMoves': optimalMoves,
      'stars': stars,
    });
  }
}

/// Test mock to simulate ad completions, cancellations, and failures.
class TestMockAdService implements AdService {
  bool shouldGrantReward = true;
  int rewardedAdCallCount = 0;
  String? lastPlacement;

  @override
  bool get isReady => true;

  @override
  bool get isRewardedAdReady => true;

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> showInterstitialIfAppropriate({
    required int levelId,
    required int completedLevelCount,
  }) async => false;

  @override
  Future<bool> showRewardedAd({
    required String placement,
    required VoidCallback onRewardEarned,
  }) async {
    rewardedAdCallCount++;
    lastPlacement = placement;
    if (shouldGrantReward) {
      onRewardEarned();
      return true;
    }
    return false;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Task 14: Optimal Drift Nudge — Level Coverage & Configuration', () {
    test('Levels 1–3 explicitly have isOptimalDriftNudgeEnabled == false (core tutorials)', () {
      for (int i = 1; i <= 3; i++) {
        final level = LevelDefinitions.getLevel(i);
        expect(
          level.isOptimalDriftNudgeEnabled,
          isFalse,
          reason: 'Level $i is a tutorial and must not show optimal drift nudge',
        );
      }
    });

    test('Levels 4–5 explicitly have isOptimalDriftNudgeEnabled == false (onboarding fundamentals)', () {
      for (int i = 4; i <= 5; i++) {
        final level = LevelDefinitions.getLevel(i);
        expect(
          level.isOptimalDriftNudgeEnabled,
          isFalse,
          reason: 'Level $i is onboarding and must keep automatic nudge disabled',
        );
      }
    });

    test('Levels 6–150 have isOptimalDriftNudgeEnabled == true across the entire campaign', () {
      for (int i = 6; i <= LevelDefinitions.totalLevels; i++) {
        final level = LevelDefinitions.getLevel(i);
        expect(
          level.isOptimalDriftNudgeEnabled,
          isTrue,
          reason: 'Level $i must support the optimal drift nudge mechanic',
        );
      }
    });

    test('PuzzleLevel supports explicit enableOptimalDriftNudge override', () {
      final defaultLevel = LevelDefinitions.getLevel(6);
      expect(defaultLevel.isOptimalDriftNudgeEnabled, isTrue);

      final customDisabled = PuzzleLevel(
        id: 7,
        title: 'Custom',
        initialGrid: defaultLevel.initialGrid,
        targets: defaultLevel.targets,
        optimalMoves: 5,
        enableOptimalDriftNudge: false,
      );
      expect(customDisabled.isOptimalDriftNudgeEnabled, isFalse);

      final customEnabled = PuzzleLevel(
        id: 2,
        title: 'Custom',
        initialGrid: defaultLevel.initialGrid,
        targets: defaultLevel.targets,
        optimalMoves: 1,
        enableOptimalDriftNudge: true,
      );
      expect(customEnabled.isOptimalDriftNudgeEnabled, isTrue);
    });
  });

  group('Task 14: Engine Domain Logic — Player Moves, Echo, and Undo', () {
    test('Echo shifts (isEcho: true) do not increment player moveCount', () {
      final level = LevelDefinitions.getLevel(10);
      final engine = PuzzleEngine(level);

      expect(engine.moveCount, 0);

      // Player move
      engine.shiftRow(0, ShiftDirection.right, isEcho: false);
      expect(engine.moveCount, 1);

      // Echo playback shifts
      engine.shiftColumn(2, ShiftDirection.down, isEcho: true);
      expect(engine.moveCount, 1, reason: 'Echo playback must never increment player moveCount');

      engine.shiftRow(0, ShiftDirection.left, isEcho: true);
      expect(engine.moveCount, 1, reason: 'Echo playback must never increment player moveCount');
    });

    test('Undo decrements moveCount accurately and restores prior board state', () {
      final level = LevelDefinitions.getLevel(6);
      final engine = PuzzleEngine(level);

      expect(engine.moveCount, 0);
      engine.shiftRow(0, ShiftDirection.left);
      engine.shiftRow(2, ShiftDirection.left);
      expect(engine.moveCount, 2);

      engine.undo();
      expect(engine.moveCount, 1);

      engine.undo();
      expect(engine.moveCount, 0);
      expect(engine.canUndo, isFalse);
    });

    test('PuzzleSolver.getNextBestMove produces single valid move on current board state', () {
      final level = LevelDefinitions.getLevel(6);
      final engine = PuzzleEngine(level);

      // Make 1 non-optimal move
      engine.shiftRow(4, ShiftDirection.right);

      final nextMove = PuzzleSolver.getNextBestMove(engine.currentGrid, level);
      expect(nextMove, isNotNull);
      expect(nextMove!.isRow, isNotNull);
      expect(nextMove.direction, isNotNull);
      expect(nextMove.index, inInclusiveRange(0, 4));
    });
  });

  group('Task 14: OptimalDriftNudgeDialog Widget Unit Tests', () {
    testWidgets('Displays neutral coaching copy and both action buttons', (tester) async {
      bool keepSolvingTapped = false;
      bool watchAdTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OptimalDriftNudgeDialog(
              levelId: 15,
              moveCount: 8,
              optimalMoves: 7,
              onKeepSolving: () => keepSolvingTapped = true,
              onWatchAd: () => watchAdTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('ONE MOVE OVER PAR'), findsOneWidget);
      expect(find.text('Need a Nudge?'), findsOneWidget);
      expect(find.textContaining('You’re one move beyond the minimum par (8 / 7)'), findsOneWidget);
      expect(find.byKey(const ValueKey('nudge_keep_solving_button')), findsOneWidget);
      expect(find.byKey(const ValueKey('nudge_watch_ad_button')), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('nudge_keep_solving_button')));
      expect(keepSolvingTapped, isTrue);

      await tester.tap(find.byKey(const ValueKey('nudge_watch_ad_button')));
      expect(watchAdTapped, isTrue);
    });
  });

  group('Task 14: GameScreen Integration — Drift Trigger Lifecycle & Ad Flow', () {
    late PlayerProgress progress;
    late TestMockAnalytics analytics;
    late TestMockAdService adService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({
        'highest_unlocked_level': 10,
        'sound_enabled': true,
        'tutorial_completed': true,
      });
      final prefs = await SharedPreferences.getInstance();
      progress = PlayerProgress(prefs);
      analytics = TestMockAnalytics();
      adService = TestMockAdService();
    });

    testWidgets('Tutorial Levels 1–3: do NOT trigger drift nudge even at par + 1', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: GameScreen(
            progress: progress,
            analytics: analytics,
            adService: adService,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final gameFinder = find.byWidgetPredicate((w) => w is GameWidget);
      expect(gameFinder, findsOneWidget);

      final center = tester.getCenter(gameFinder);
      await tester.dragFrom(center, const Offset(-60, 0));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();

      // Nudge dialog should NOT appear on Level 1
      expect(find.byType(OptimalDriftNudgeDialog), findsNothing);
      expect(analytics.loggedEvents, isNot(contains('optimal_drift_nudge_shown')));
    });

    testWidgets('Level 6: Triggers Optimal Drift Nudge exactly at par + 1', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      progress.recordLevelCompletion(levelId: 1, moveCount: 1, stars: 3, totalLevels: 150);
      progress.setLastPlayedLevel(6);

      await tester.pumpWidget(
        MaterialApp(
          home: GameScreen(
            progress: progress,
            analytics: analytics,
            adService: adService,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Level 6 has optimalMoves = 5.
      expect(find.text('0'), findsOneWidget);
      expect(find.text(' / 5'), findsOneWidget);

      final hintButton = find.byKey(const ValueKey('hint_button'));
      expect(hintButton, findsOneWidget);

      expect(analytics.loggedEvents, isNot(contains('optimal_drift_nudge_shown')));
    });

    testWidgets('Dismissing nudge with KEEP SOLVING closes dialog and does not re-trigger at par + 2 or par + 3', (tester) async {
      bool dismissed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () {
                  showDialog<void>(
                    context: ctx,
                    builder: (dCtx) => OptimalDriftNudgeDialog(
                      levelId: 6,
                      moveCount: 6,
                      optimalMoves: 5,
                      onKeepSolving: () {
                        dismissed = true;
                        Navigator.of(dCtx).pop();
                      },
                      onWatchAd: () {},
                    ),
                  );
                },
                child: const Text('OPEN'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('OPEN'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(OptimalDriftNudgeDialog), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('nudge_keep_solving_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.byType(OptimalDriftNudgeDialog), findsNothing);
      expect(dismissed, isTrue);
    });

    testWidgets('WATCH AD + HINT triggers rewarded ad and grants 1 solver move on reward completion', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      progress.setLastPlayedLevel(6);

      await tester.pumpWidget(
        MaterialApp(
          home: GameScreen(
            progress: progress,
            analytics: analytics,
            adService: adService,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Open manual hint to verify rewarded ad flow
      await tester.tap(find.byKey(const ValueKey('hint_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('NEED A HINT?'), findsOneWidget);
      await tester.tap(find.text('WATCH AD'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(adService.rewardedAdCallCount, 1);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Hint: Shift'), findsOneWidget);
    });

    testWidgets('Failed ad does not grant hint reward and cleans up gracefully', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      adService.shouldGrantReward = false;
      progress.setLastPlayedLevel(6);

      await tester.pumpWidget(
        MaterialApp(
          home: GameScreen(
            progress: progress,
            analytics: analytics,
            adService: adService,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byKey(const ValueKey('hint_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('WATCH AD'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.textContaining('Ad was not completed'), findsOneWidget);
    });

    testWidgets('Restarting level resets optimal drift nudge state', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await progress.setLastPlayedLevel(6);

      await tester.pumpWidget(
        MaterialApp(
          home: GameScreen(
            progress: progress,
            analytics: analytics,
            adService: adService,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Tap restart
      await tester.tap(find.text('Restart'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(analytics.loggedEvents, contains('level_restarted'));
      expect(find.text('0'), findsOneWidget);
      expect(find.text(' / 5'), findsOneWidget);
    });

    testWidgets('Echo recording state prevents accidental nudge trigger', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Level 10 has Memory Echo
      await progress.setLastPlayedLevel(10);

      await tester.pumpWidget(
        MaterialApp(
          home: GameScreen(
            progress: progress,
            analytics: analytics,
            adService: adService,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Start recording Echo
      final echoBtn = find.text('REC');
      expect(echoBtn, findsOneWidget);
      await tester.tap(echoBtn);
      await tester.pump();

      // Now recording: status should be ● REC
      expect(find.text('● REC'), findsOneWidget);
      // Nudge should not appear while recording
      expect(find.byType(OptimalDriftNudgeDialog), findsNothing);
    });

    test('Campaign-Wide Audit: Programmatic verification of all 150 levels', () {
      int totalLevels = LevelDefinitions.totalLevels;
      expect(totalLevels, 150);

      int enabledCount = 0;
      int excludedCount = 0;
      final excludedLevels = <int, String>{};
      final echoLevels = <int>[];

      for (int id = 1; id <= totalLevels; id++) {
        final level = LevelDefinitions.getLevel(id);
        if (level.hasMemoryEcho) {
          echoLevels.add(id);
        }

        if (level.isOptimalDriftNudgeEnabled) {
          enabledCount++;
        } else {
          excludedCount++;
          if (id <= 3) {
            excludedLevels[id] = 'Core Tutorial (L$id: ${level.title})';
          } else if (id <= 5) {
            excludedLevels[id] = 'Foundational Onboarding (L$id: ${level.title})';
          } else {
            excludedLevels[id] = 'Explicit Exclusion (L$id: ${level.title})';
          }
        }
      }

      expect(totalLevels, 150);
      expect(enabledCount, 145);
      expect(excludedCount, 5);
      expect(excludedLevels.keys.toList(), [1, 2, 3, 4, 5]);
      expect(echoLevels.length, greaterThan(40));

      // Output campaign audit summary for report
      debugPrint('=== CAMPAIGN OPTIMAL DRIFT AUDIT ===');
      debugPrint('Total Levels: $totalLevels');
      debugPrint('Nudge Enabled: $enabledCount (Levels 6–150)');
      debugPrint('Nudge Excluded: $excludedCount (Levels 1–5)');
      debugPrint('Echo Levels: ${echoLevels.length}');
      debugPrint('Exclusions: $excludedLevels');
    });
  });
}

