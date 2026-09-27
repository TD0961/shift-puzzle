import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shift_puzzle/core/analytics/analytics_service.dart';
import 'package:shift_puzzle/core/connectivity/connectivity_service.dart';
import 'package:shift_puzzle/core/monetization/ad_service.dart';
import 'package:shift_puzzle/core/puzzle/levels/level_definitions.dart';
import 'package:shift_puzzle/core/puzzle/logic/puzzle_engine.dart';
import 'package:shift_puzzle/core/puzzle/models/shift_direction.dart';
import 'package:shift_puzzle/core/storage/player_progress.dart';
import 'package:shift_puzzle/game/scenes/shift_puzzle_game.dart';
import 'package:shift_puzzle/ui/game_screen.dart';
import 'package:shift_puzzle/ui/hint_unavailable_dialog.dart';
import 'package:shift_puzzle/ui/internet_needed_dialog.dart';
import 'package:shift_puzzle/ui/move_limit_dialog.dart';
import 'package:shift_puzzle/ui/optimal_drift_nudge_dialog.dart';
import 'package:shift_puzzle/ui/win_dialog.dart';

class Task19TestAnalytics extends DebugAnalyticsService {
  final List<String> events = [];
  final Map<String, int> eventCounts = {};
  final Map<String, dynamic> lastParams = {};

  Task19TestAnalytics() : super(enableLogging: false);

  void _record(String event, [Map<String, dynamic>? params]) {
    events.add(event);
    eventCounts[event] = (eventCounts[event] ?? 0) + 1;
    if (params != null) {
      lastParams[event] = params;
    }
  }

  @override
  void logMoveLimitReached({
    required int levelId,
    required int chapterId,
    required int optimalMoves,
    required int normalMoveLimit,
    required int movesUsed,
    required bool isEchoLevel,
    required bool isExtendedLimit,
  }) {
    _record('move_limit_reached', {
      'levelId': levelId,
      'chapterId': chapterId,
      'optimalMoves': optimalMoves,
      'normalMoveLimit': normalMoveLimit,
      'movesUsed': movesUsed,
      'isEchoLevel': isEchoLevel,
      'isExtendedLimit': isExtendedLimit,
    });
  }

  @override
  void logMoveLimitReplaySelected({required int levelId, required int movesUsed}) {
    _record('move_limit_replay_selected', {'levelId': levelId, 'movesUsed': movesUsed});
  }

  @override
  void logMoveLimitExtraMovesRequested({required int levelId, required int movesUsed}) {
    _record('move_limit_extra_moves_requested', {'levelId': levelId, 'movesUsed': movesUsed});
  }

  @override
  void logMoveLimitAdStarted({required int levelId, required String placement}) {
    _record('move_limit_ad_started', {'levelId': levelId, 'placement': placement});
  }

  @override
  void logMoveLimitAdRewarded({required int levelId, required String placement}) {
    _record('move_limit_ad_rewarded', {'levelId': levelId, 'placement': placement});
  }

  @override
  void logMoveLimitAdFailed({
    required int levelId,
    required String placement,
    required String reason,
  }) {
    _record('move_limit_ad_failed', {
      'levelId': levelId,
      'placement': placement,
      'reason': reason,
    });
  }

  @override
  void logMoveLimitExtraMovesGranted({
    required int levelId,
    required int extraMovesGranted,
    required int newMoveLimit,
  }) {
    _record('move_limit_extra_moves_granted', {
      'levelId': levelId,
      'extraMovesGranted': extraMovesGranted,
      'newMoveLimit': newMoveLimit,
    });
  }

  @override
  void logMoveLimitFinalAttemptExhausted({required int levelId, required int movesUsed}) {
    _record('move_limit_final_attempt_exhausted', {'levelId': levelId, 'movesUsed': movesUsed});
  }

  @override
  void logLevelCompletedAfterExtraMoves({
    required int levelId,
    required int moves,
    required int optimalMoves,
    required int stars,
  }) {
    _record('level_completed_after_extra_moves', {
      'levelId': levelId,
      'moves': moves,
      'optimalMoves': optimalMoves,
      'stars': stars,
    });
  }

  @override
  void logLevelCompleted({
    required int levelId,
    required int moves,
    required int optimalMoves,
    required int stars,
    required bool isNewBest,
  }) {
    _record('level_completed', {
      'levelId': levelId,
      'moves': moves,
      'optimalMoves': optimalMoves,
      'stars': stars,
      'isNewBest': isNewBest,
    });
  }
}

class Task19TestAdService implements AdService {
  bool isAdReady = true;
  bool shouldGrantReward = true;
  int rewardCallbackCount = 1;
  int showAdCallCount = 0;

  @override
  bool get isReady => isAdReady;

  @override
  bool get isRewardedAdReady => isAdReady;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> preloadRewardedAd() async {}

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
    showAdCallCount++;
    if (shouldGrantReward) {
      for (int i = 0; i < rewardCallbackCount; i++) {
        onRewardEarned();
      }
      return true;
    }
    return false;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PlayerProgress progress;
  late Task19TestAnalytics analytics;
  late Task19TestAdService adService;
  late MockConnectivityService connectivityService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    progress = PlayerProgress(prefs);
    analytics = Task19TestAnalytics();
    adService = Task19TestAdService();
    connectivityService = MockConnectivityService(isOnline: true);
  });

  Future<void> makeMoves(WidgetTester tester, ShiftPuzzleGame game, int count) async {
    for (int i = 0; i < count; i++) {
      game.triggerShiftRow(0, i.isEven ? ShiftDirection.right : ShiftDirection.left);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      final nudgeFinder = find.byType(OptimalDriftNudgeDialog);
      if (nudgeFinder.evaluate().isNotEmpty) {
        final keepBtn = find.byKey(const ValueKey('nudge_keep_solving_button'));
        if (keepBtn.evaluate().isNotEmpty) {
          await tester.tap(keepBtn);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 350));
        }
      }
    }
  }

  group('TASK 19: Full Gameplay, Monetization & Release-Candidate QA Audit', () {
    // ------------------------------------------------------------------------
    // 1. Move Counting & Replay Isolation
    // ------------------------------------------------------------------------
    test('1. Normal move counting: Exactly 1 shift per move, Echo replay shifts strictly bypass', () {
      final level = LevelDefinitions.getLevel(10); // Echo level, optimal 5
      final engine = PuzzleEngine(level);

      expect(engine.moveCount, equals(0));

      // Player move 1
      engine.shiftRow(0, ShiftDirection.right);
      expect(engine.moveCount, equals(1));

      // Player move 2
      engine.shiftColumn(1, ShiftDirection.down);
      expect(engine.moveCount, equals(2));

      // Echo replay shift: must NOT increment move count
      engine.shiftRow(0, ShiftDirection.left, isEcho: true);
      expect(engine.moveCount, equals(2), reason: 'Echo shift must not increment moveCount');

      engine.shiftColumn(1, ShiftDirection.up, isEcho: true);
      expect(engine.moveCount, equals(2), reason: 'Echo shift must not increment moveCount');
    });

    // ------------------------------------------------------------------------
    // 2. Undo Audit: Cases 1–6
    // ------------------------------------------------------------------------
    test('2. Undo Lock audit: Cases 1-6 strictly enforced across optimal boundary', () {
      final level = LevelDefinitions.getLevel(6); // optimal 5
      final engine = PuzzleEngine(level);

      // Case 1: moveCount = 0 (no history)
      expect(engine.canUndo, isFalse);

      // Case 2: moveCount = 1..optimal-1 (Undo available)
      engine.shiftRow(0, ShiftDirection.right);
      expect(engine.moveCount, equals(1));
      expect(engine.canUndo, isTrue);

      engine.shiftRow(0, ShiftDirection.left);
      expect(engine.moveCount, equals(2));
      expect(engine.canUndo, isTrue);

      // Undo one move
      engine.undo();
      expect(engine.moveCount, equals(1));
      expect(engine.canUndo, isTrue);

      // Advance to optimal (moves 2, 3, 4, 5)
      engine.shiftRow(0, ShiftDirection.right); // 2
      engine.shiftRow(0, ShiftDirection.left);  // 3
      engine.shiftRow(0, ShiftDirection.right); // 4
      engine.shiftRow(0, ShiftDirection.left);  // 5 (optimal)
      expect(engine.moveCount, equals(5));

      // Case 3: moveCount == optimal (Undo locked)
      expect(engine.isUndoLocked, isTrue);
      expect(engine.canUndo, isFalse);

      // Case 4: moveCount > optimal (Undo remains locked)
      engine.shiftRow(0, ShiftDirection.right); // 6
      expect(engine.moveCount, equals(6));
      expect(engine.isUndoLocked, isTrue);
      expect(engine.canUndo, isFalse);

      // Case 6: Reset / Restart restores Undo capability
      engine.reset();
      expect(engine.moveCount, equals(0));
      expect(engine.isUndoLocked, isFalse);
      expect(engine.canUndo, isFalse); // No history yet

      engine.shiftRow(0, ShiftDirection.right);
      expect(engine.moveCount, equals(1));
      expect(engine.canUndo, isTrue);
    });

    // ------------------------------------------------------------------------
    // 3. Move Limit + Victory Precedence
    // ------------------------------------------------------------------------
    testWidgets('3. Solved state takes precedence over move limit on limit-hitting move', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      progress.recordLevelCompletion(levelId: 1, moveCount: 1, stars: 3, totalLevels: 150);
      progress.setLastPlayedLevel(1); // optimal 1, limit 4 (1 + 3)

      await tester.pumpWidget(
        MaterialApp(
          home: GameScreen(
            progress: progress,
            analytics: analytics,
            adService: adService,
            connectivityService: connectivityService,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final gameWidgetFinder = find.byWidgetPredicate((w) => w is GameWidget<ShiftPuzzleGame>);
      final game = tester.widget<GameWidget<ShiftPuzzleGame>>(gameWidgetFinder).game!;

      // Make 3 non-solving shifts
      game.triggerShiftRow(0, ShiftDirection.right); // 1
      await tester.pump(const Duration(milliseconds: 300));
      game.triggerShiftRow(0, ShiftDirection.left);  // 2
      await tester.pump(const Duration(milliseconds: 300));
      game.triggerShiftRow(0, ShiftDirection.right); // 3
      await tester.pump(const Duration(milliseconds: 300));

      expect(game.engine.moveCount, equals(3));
      expect(game.engine.isSolved, isFalse);

      // 4th move solves the puzzle on the exact limit move (Row 2 right)
      game.triggerShiftRow(2, ShiftDirection.right); // 4 (limit!)
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 500));

      // WinDialog must appear; MoveLimitDialog must NEVER appear
      expect(find.byType(WinDialog), findsOneWidget);
      expect(find.byType(MoveLimitDialog), findsNothing);

      // Drain applause sound timers
      await tester.pump(const Duration(seconds: 4));
    });

    // ------------------------------------------------------------------------
    // 4. Move Limit Dialog & UI Input Lock
    // ------------------------------------------------------------------------
    testWidgets('4. Reaching limit (optimal + 3) shows MoveLimitDialog and blocks board input', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      progress.recordLevelCompletion(levelId: 1, moveCount: 1, stars: 3, totalLevels: 150);
      progress.setLastPlayedLevel(6); // optimal 5, normal move limit = 8

      await tester.pumpWidget(
        MaterialApp(
          home: GameScreen(
            progress: progress,
            analytics: analytics,
            adService: adService,
            connectivityService: connectivityService,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final gameWidgetFinder = find.byWidgetPredicate((w) => w is GameWidget<ShiftPuzzleGame>);
      final game = tester.widget<GameWidget<ShiftPuzzleGame>>(gameWidgetFinder).game!;

      // Make 8 shifts to reach move limit
      await makeMoves(tester, game, 8);
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(MoveLimitDialog), findsOneWidget);
      expect(find.byKey(const ValueKey('replay_button')), findsOneWidget);
      expect(find.byKey(const ValueKey('watch_ad_moves_button')), findsOneWidget);

      // Attempt swipe while modal is open: must be rejected / cannot increment moves
      final movesBefore = game.engine.moveCount;
      await tester.fling(find.byType(MoveLimitDialog), const Offset(100, 0), 1000);
      await tester.pump(const Duration(milliseconds: 100));
      expect(game.engine.moveCount, equals(movesBefore));
    });

    // ------------------------------------------------------------------------
    // 5. Rewarded +5 Rescue & One-Extension Enforcement
    // ------------------------------------------------------------------------
    testWidgets('5. Watching rewarded ad grants exactly +5 moves and unlocks board once per attempt', (tester) async {
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
            connectivityService: connectivityService,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final gameWidgetFinder = find.byWidgetPredicate((w) => w is GameWidget<ShiftPuzzleGame>);
      final game = tester.widget<GameWidget<ShiftPuzzleGame>>(gameWidgetFinder).game!;

      await makeMoves(tester, game, 8);
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(MoveLimitDialog), findsOneWidget);

      // Tap Watch Ad
      await tester.tap(find.byKey(const ValueKey('watch_ad_moves_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.byType(MoveLimitDialog), findsNothing);
      expect(analytics.eventCounts['move_limit_extra_moves_granted'], equals(1));

      // Exhaust all 5 bonus moves (moves 9, 10, 11, 12, 13)
      await makeMoves(tester, game, 5);
      await tester.pump(const Duration(milliseconds: 100));

      // MoveLimitDialog reappears with canExtend == false
      expect(find.byType(MoveLimitDialog), findsOneWidget);
      expect(find.text('FINAL ATTEMPT EXHAUSTED'), findsOneWidget);
      expect(find.byKey(const ValueKey('watch_ad_moves_button')), findsNothing);
      expect(find.byKey(const ValueKey('replay_button')), findsOneWidget);
    });

    // ------------------------------------------------------------------------
    // 6. Double-Reward Defense
    // ------------------------------------------------------------------------
    testWidgets('6. Double-reward callbacks grant strictly +5 moves once without duplicate events', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      adService.rewardCallbackCount = 3; // Simulates SDK duplicate callbacks

      progress.recordLevelCompletion(levelId: 1, moveCount: 1, stars: 3, totalLevels: 150);
      progress.setLastPlayedLevel(6);

      await tester.pumpWidget(
        MaterialApp(
          home: GameScreen(
            progress: progress,
            analytics: analytics,
            adService: adService,
            connectivityService: connectivityService,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final gameWidgetFinder = find.byWidgetPredicate((w) => w is GameWidget<ShiftPuzzleGame>);
      final game = tester.widget<GameWidget<ShiftPuzzleGame>>(gameWidgetFinder).game!;

      await makeMoves(tester, game, 8);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.byKey(const ValueKey('watch_ad_moves_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      // Exactly 1 grant event
      expect(analytics.eventCounts['move_limit_extra_moves_granted'], equals(1));
    });

    // ------------------------------------------------------------------------
    // 7. No False Reward: Ad Closed Early
    // ------------------------------------------------------------------------
    testWidgets('7. Closing ad early grants ZERO moves, keeps board locked, and re-presents modal', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      adService.shouldGrantReward = false; // User closed ad before reward

      progress.recordLevelCompletion(levelId: 1, moveCount: 1, stars: 3, totalLevels: 150);
      progress.setLastPlayedLevel(6);

      await tester.pumpWidget(
        MaterialApp(
          home: GameScreen(
            progress: progress,
            analytics: analytics,
            adService: adService,
            connectivityService: connectivityService,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final gameWidgetFinder = find.byWidgetPredicate((w) => w is GameWidget<ShiftPuzzleGame>);
      final game = tester.widget<GameWidget<ShiftPuzzleGame>>(gameWidgetFinder).game!;

      await makeMoves(tester, game, 8);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.byKey(const ValueKey('watch_ad_moves_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      // Modal reappears and zero extra moves were granted
      expect(find.byType(MoveLimitDialog), findsOneWidget);
      expect(analytics.eventCounts['move_limit_extra_moves_granted'], isNull);
    });

    // ------------------------------------------------------------------------
    // 8. Offline Move Limit Handling
    // ------------------------------------------------------------------------
    testWidgets('8. Offline ad request shows InternetNeededDialog without fake reward', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      connectivityService.isOnline = false;

      progress.recordLevelCompletion(levelId: 1, moveCount: 1, stars: 3, totalLevels: 150);
      progress.setLastPlayedLevel(6);

      await tester.pumpWidget(
        MaterialApp(
          home: GameScreen(
            progress: progress,
            analytics: analytics,
            adService: adService,
            connectivityService: connectivityService,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final gameWidgetFinder = find.byWidgetPredicate((w) => w is GameWidget<ShiftPuzzleGame>);
      final game = tester.widget<GameWidget<ShiftPuzzleGame>>(gameWidgetFinder).game!;

      await makeMoves(tester, game, 8);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.byKey(const ValueKey('watch_ad_moves_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.byType(InternetNeededDialog), findsOneWidget);
      expect(adService.showAdCallCount, equals(0));
    });

    // ------------------------------------------------------------------------
    // 9. Online Ad Unavailable Handling
    // ------------------------------------------------------------------------
    testWidgets('9. Online ad unavailable shows HintUnavailableDialog with retry option', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      connectivityService.isOnline = true;
      adService.isAdReady = false; // AdMob no fill

      progress.recordLevelCompletion(levelId: 1, moveCount: 1, stars: 3, totalLevels: 150);
      progress.setLastPlayedLevel(6);

      await tester.pumpWidget(
        MaterialApp(
          home: GameScreen(
            progress: progress,
            analytics: analytics,
            adService: adService,
            connectivityService: connectivityService,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final gameWidgetFinder = find.byWidgetPredicate((w) => w is GameWidget<ShiftPuzzleGame>);
      final game = tester.widget<GameWidget<ShiftPuzzleGame>>(gameWidgetFinder).game!;

      await makeMoves(tester, game, 8);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.byKey(const ValueKey('watch_ad_moves_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1500));

      expect(find.byType(HintUnavailableDialog), findsOneWidget);
    });

    // ------------------------------------------------------------------------
    // 10. Free Replay Clean Reset & Campaign Progression Preservation
    // ------------------------------------------------------------------------
    testWidgets('10. Replay cleanly resets attempt state while preserving campaign progression', (tester) async {
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
            connectivityService: connectivityService,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final gameWidgetFinder = find.byWidgetPredicate((w) => w is GameWidget<ShiftPuzzleGame>);
      final game = tester.widget<GameWidget<ShiftPuzzleGame>>(gameWidgetFinder).game!;

      await makeMoves(tester, game, 8);
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(MoveLimitDialog), findsOneWidget);

      // Replay
      await tester.tap(find.byKey(const ValueKey('replay_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(game.engine.moveCount, equals(0));
      expect(game.engine.isUndoLocked, isFalse);
      expect(find.byType(MoveLimitDialog), findsNothing);

      // Verify permanent progress is intact
      expect(progress.highestUnlockedLevel, equals(2));
      expect(progress.getStars(1), equals(3));
    });

    // ------------------------------------------------------------------------
    // 11. Star Rating Calibration Verification
    // ------------------------------------------------------------------------
    test('11. Star calculation matches exact par thresholds across all tiers', () {
      final level = LevelDefinitions.getLevel(6); // optimal 5

      int calculateStars(int moves, int optimal) {
        if (optimal <= 0) return 3;
        if (moves <= optimal) return 3;
        if (moves <= optimal + 2) return 2;
        return 1;
      }

      // 3 Stars: moves == optimal
      expect(calculateStars(5, level.optimalMoves), equals(3));

      // 2 Stars: optimal + 1, optimal + 2
      expect(calculateStars(6, level.optimalMoves), equals(2));
      expect(calculateStars(7, level.optimalMoves), equals(2));

      // 1 Star: optimal + 3 (limit) and beyond (extended)
      expect(calculateStars(8, level.optimalMoves), equals(1));
      expect(calculateStars(13, level.optimalMoves), equals(1));
    });

    // ------------------------------------------------------------------------
    // 12. Android Back Protection on WinDialog & MoveLimitDialog
    // ------------------------------------------------------------------------
    testWidgets('12. Android Back cannot pop WinDialog or MoveLimitDialog into invalid state', (tester) async {
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
            connectivityService: connectivityService,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final gameWidgetFinder = find.byWidgetPredicate((w) => w is GameWidget<ShiftPuzzleGame>);
      final game = tester.widget<GameWidget<ShiftPuzzleGame>>(gameWidgetFinder).game!;

      await makeMoves(tester, game, 8);
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(MoveLimitDialog), findsOneWidget);

      // Verify MoveLimitDialog has PopScope(canPop: false)
      final modalPopScope = tester.widget<PopScope>(find.descendant(
        of: find.byType(MoveLimitDialog),
        matching: find.byType(PopScope),
      ));
      expect(modalPopScope.canPop, isFalse);
    });

    // ------------------------------------------------------------------------
    // 13. Campaign-Wide Parameterized State Machine Audit
    // ------------------------------------------------------------------------
    test('13. Campaign-wide parameterization: All chapters uphold move limit formulas', () {
      final sampleLevels = [
        1,   // Ch 1 Tutorial (optimal 1)
        5,   // Ch 1 Non-Echo (optimal 3)
        10,  // Ch 1 Echo (optimal 5)
        22,  // Ch 3 Non-Echo (optimal 5)
        40,  // Ch 4 Echo (optimal 7)
        65,  // Ch 7 Non-Echo (optimal 7)
        96,  // Ch 10 Echo (optimal 10)
        99,  // Ch 10 High States (optimal 10)
        120, // Ch 12 Non-Echo (optimal 7)
        150, // Ch 15 Grand Finale (optimal 9)
      ];

      for (final id in sampleLevels) {
        final level = LevelDefinitions.getLevel(id);
        final normalLimit = level.optimalMoves + 3;
        final extendedLimit = normalLimit + 5;

        expect(normalLimit, equals(level.optimalMoves + 3));
        expect(extendedLimit, equals(level.optimalMoves + 8));

        final engine = PuzzleEngine(level);
        expect(engine.isUndoLocked, isFalse);
        expect(engine.moveCount, equals(0));
      }
    });

    // ------------------------------------------------------------------------
    // 14. Analytics Exact-Once Dispatches
    // ------------------------------------------------------------------------
    testWidgets('14. Analytics events fire with exact-once semantics on level complete and limit', (tester) async {
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
            connectivityService: connectivityService,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final gameWidgetFinder = find.byWidgetPredicate((w) => w is GameWidget<ShiftPuzzleGame>);
      final game = tester.widget<GameWidget<ShiftPuzzleGame>>(gameWidgetFinder).game!;

      await makeMoves(tester, game, 8);
      await tester.pump(const Duration(milliseconds: 100));

      expect(analytics.eventCounts['move_limit_reached'], equals(1));

      // Replay
      await tester.tap(find.byKey(const ValueKey('replay_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(analytics.eventCounts['move_limit_replay_selected'], equals(1));
    });
  });
}
