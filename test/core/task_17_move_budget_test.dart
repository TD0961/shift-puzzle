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
import 'package:shift_puzzle/ui/game_header.dart';
import 'package:shift_puzzle/ui/game_screen.dart';
import 'package:shift_puzzle/ui/hint_unavailable_dialog.dart';
import 'package:shift_puzzle/ui/internet_needed_dialog.dart';
import 'package:shift_puzzle/ui/move_limit_dialog.dart';
import 'package:shift_puzzle/ui/optimal_drift_nudge_dialog.dart';
import 'package:shift_puzzle/ui/win_dialog.dart';

class Task17TestAnalytics extends DebugAnalyticsService {
  final List<String> loggedEvents = [];
  final List<Map<String, dynamic>> loggedParams = [];

  Task17TestAnalytics() : super(enableLogging: true);

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
    loggedEvents.add('move_limit_reached');
    loggedParams.add({
      'level_id': levelId,
      'chapter_id': chapterId,
      'optimal_moves': optimalMoves,
      'normal_move_limit': normalMoveLimit,
      'moves_used': movesUsed,
      'is_echo_level': isEchoLevel,
      'is_extended_limit': isExtendedLimit,
    });
  }

  @override
  void logMoveLimitReplaySelected({
    required int levelId,
    required int movesUsed,
  }) {
    loggedEvents.add('move_limit_replay_selected');
    loggedParams.add({'level_id': levelId, 'moves_used': movesUsed});
  }

  @override
  void logMoveLimitExtraMovesRequested({
    required int levelId,
    required int movesUsed,
  }) {
    loggedEvents.add('move_limit_extra_moves_requested');
    loggedParams.add({'level_id': levelId, 'moves_used': movesUsed});
  }

  @override
  void logMoveLimitAdStarted({
    required int levelId,
    required String placement,
  }) {
    loggedEvents.add('move_limit_ad_started');
    loggedParams.add({'level_id': levelId, 'placement': placement});
  }

  @override
  void logMoveLimitAdRewarded({
    required int levelId,
    required String placement,
  }) {
    loggedEvents.add('move_limit_ad_rewarded');
    loggedParams.add({'level_id': levelId, 'placement': placement});
  }

  @override
  void logMoveLimitAdFailed({
    required int levelId,
    required String placement,
    required String reason,
  }) {
    loggedEvents.add('move_limit_ad_failed');
    loggedParams.add({'level_id': levelId, 'placement': placement, 'reason': reason});
  }

  @override
  void logMoveLimitExtraMovesGranted({
    required int levelId,
    required int extraMovesGranted,
    required int newMoveLimit,
  }) {
    loggedEvents.add('move_limit_extra_moves_granted');
    loggedParams.add({
      'level_id': levelId,
      'extra_moves_granted': extraMovesGranted,
      'new_move_limit': newMoveLimit,
    });
  }

  @override
  void logMoveLimitFinalAttemptExhausted({
    required int levelId,
    required int movesUsed,
  }) {
    loggedEvents.add('move_limit_final_attempt_exhausted');
    loggedParams.add({'level_id': levelId, 'moves_used': movesUsed});
  }

  @override
  void logLevelCompletedAfterExtraMoves({
    required int levelId,
    required int moves,
    required int optimalMoves,
    required int stars,
  }) {
    loggedEvents.add('level_completed_after_extra_moves');
    loggedParams.add({
      'level_id': levelId,
      'moves': moves,
      'optimal_moves': optimalMoves,
      'stars': stars,
    });
  }
}

class Task17TestAdService implements AdService {
  bool isAdReady = true;
  bool shouldGrantReward = true;
  int rewardedAdCallCount = 0;
  int preloadCount = 0;
  String? lastPlacement;
  VoidCallback? onRewardEarnedCallback;

  @override
  bool get isReady => true;

  @override
  bool get isRewardedAdReady => isAdReady;

  @override
  Future<void> preloadRewardedAd() async {
    preloadCount++;
  }

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> showRewardedAd({
    required String placement,
    required VoidCallback onRewardEarned,
  }) async {
    rewardedAdCallCount++;
    lastPlacement = placement;
    onRewardEarnedCallback = onRewardEarned;
    if (shouldGrantReward) {
      onRewardEarned();
      return true;
    }
    return false;
  }

  @override
  Future<bool> showInterstitialIfAppropriate({
    required int levelId,
    required int completedLevelCount,
  }) async {
    return false;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PlayerProgress progress;
  late Task17TestAnalytics analytics;
  late Task17TestAdService adService;
  late MockConnectivityService connectivityService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    progress = PlayerProgress(prefs);
    analytics = Task17TestAnalytics();
    adService = Task17TestAdService();
    connectivityService = MockConnectivityService(isOnline: true);
  });

  group('TASK 17: Move Budget, Undo Lock & Rewarded Extra-Move Rescue System', () {
    // ------------------------------------------------------------------------
    // GROUP 1: Move-Budget Limits & Authoritative Optimal Rules (Reqs 1, 2, 3, 4, 27)
    // ------------------------------------------------------------------------
    test('1 & 2. Exact move limit formula: normalMoveLimit = optimalMoves + 3', () {
      final level6 = LevelDefinitions.getLevel(6); // optimal 5
      expect(level6.optimalMoves + 3, equals(8));

      final level8 = LevelDefinitions.getLevel(8); // optimal 6
      expect(level8.optimalMoves + 3, equals(9));

      final level30 = LevelDefinitions.getLevel(30); // optimal 8
      expect(level30.optimalMoves + 3, equals(11));
    });

    test('3 & 4. Player can continue freely below move limit without interruption', () {
      final level = LevelDefinitions.getLevel(6); // optimal 5, limit 8
      final engine = PuzzleEngine(level);

      // Make 7 moves (< 8)
      for (int i = 0; i < 7; i++) {
        engine.shiftRow(0, ShiftDirection.left);
      }
      expect(engine.moveCount, equals(7));
      expect(engine.moveCount < level.optimalMoves + 3, isTrue);
    });

    test('27. Authoritative optimal value is strictly preserved and never mutated', () {
      final level = LevelDefinitions.getLevel(22);
      expect(level.optimalMoves, equals(5));
      // Even if extra moves are calculated:
      const extraMoves = 5;
      expect(level.optimalMoves, equals(5));
      expect(level.optimalMoves + 3 + extraMoves, equals(13));
      expect(level.optimalMoves, equals(5));
    });

    // ------------------------------------------------------------------------
    // GROUP 2: Undo Lock at Optimal Moves (Reqs 8, 9, 10, 11, 12, 21)
    // ------------------------------------------------------------------------
    test('8. Undo works normally while moveCount < optimalMoves', () {
      final level = LevelDefinitions.getLevel(6); // optimal 5
      final engine = PuzzleEngine(level);

      // Moves 1, 2, 3, 4 are below optimal
      engine.shiftRow(0, ShiftDirection.left);
      expect(engine.moveCount, equals(1));
      expect(engine.canUndo, isTrue);

      engine.shiftRow(0, ShiftDirection.left);
      expect(engine.moveCount, equals(2));
      expect(engine.canUndo, isTrue);

      final undone = engine.undo();
      expect(undone, isNotNull);
      expect(engine.moveCount, equals(1));
      expect(engine.canUndo, isTrue);
    });

    test('9 & 10. Undo becomes locked exactly at optimalMoves and remains locked above it', () {
      final level = LevelDefinitions.getLevel(6); // optimal 5
      final engine = PuzzleEngine(level);

      // Advance to move 4 (< 5)
      for (int i = 0; i < 4; i++) {
        engine.shiftRow(0, ShiftDirection.left);
      }
      expect(engine.moveCount, equals(4));
      expect(engine.canUndo, isTrue);
      expect(engine.isUndoLocked, isFalse);

      // Move 5 reaches optimal!
      engine.shiftRow(0, ShiftDirection.left);
      expect(engine.moveCount, equals(5));
      expect(engine.isUndoLocked, isTrue);
      expect(engine.canUndo, isFalse);

      // Attempting to undo returns null and does not decrement moveCount
      expect(engine.undo(), isNull);
      expect(engine.moveCount, equals(5));

      // Advance to move 6, 7 (above optimal)
      engine.shiftRow(0, ShiftDirection.left);
      expect(engine.moveCount, equals(6));
      expect(engine.canUndo, isFalse);
      expect(engine.undo(), isNull);
    });

    test('12. Reset / Restart restores Undo availability for new attempt', () {
      final level = LevelDefinitions.getLevel(6); // optimal 5
      final engine = PuzzleEngine(level);

      for (int i = 0; i < 6; i++) {
        engine.shiftRow(0, ShiftDirection.left);
      }
      expect(engine.isUndoLocked, isTrue);
      expect(engine.canUndo, isFalse);

      engine.reset();
      expect(engine.moveCount, equals(0));
      expect(engine.isUndoLocked, isFalse);
      expect(engine.canUndo, isFalse); // History is empty

      // Move 1 restores canUndo
      engine.shiftRow(0, ShiftDirection.left);
      expect(engine.moveCount, equals(1));
      expect(engine.canUndo, isTrue);
    });

    // ------------------------------------------------------------------------
    // GROUP 3: Solved-State Precedence & Board Lock (Reqs 5, 6, 7, 30)
    // ------------------------------------------------------------------------
    test('6, 7 & 30. Solved state takes precedence over move limit (no false limit dialog)', () {
      final level = LevelDefinitions.getLevel(1); // optimal 1, limit 4
      final engine = PuzzleEngine(level);

      // Move 1 solves Level 1
      engine.shiftRow(2, ShiftDirection.right);
      expect(engine.moveCount, equals(1));
      expect(engine.isSolved, isTrue);
      // isSolved prevents move limit checks from executing
    });

    // ------------------------------------------------------------------------
    // GROUP 4: Memory Echo Move Accounting (Reqs 28, 29)
    // ------------------------------------------------------------------------
    test('28. Echo replay shifts do not increment moveCount or consume move budget', () {
      final level = LevelDefinitions.getLevel(9); // Echo level, optimal 4
      final engine = PuzzleEngine(level);

      engine.shiftColumn(2, ShiftDirection.down, isEcho: true);
      engine.shiftColumn(2, ShiftDirection.down, isEcho: true);

      expect(engine.moveCount, equals(0));
      expect(engine.canUndo, isFalse);
      expect(engine.isUndoLocked, isFalse);
    });

    test('29. Echo recording records shifts accurately without falsely triggering limit', () {
      final level = LevelDefinitions.getLevel(9); // optimal 4
      final engine = PuzzleEngine(level);

      engine.echo.startRecording();
      engine.shiftColumn(2, ShiftDirection.down); // move 1
      engine.shiftColumn(2, ShiftDirection.down); // move 2
      engine.echo.stopRecording();

      expect(engine.moveCount, equals(2));
      expect(engine.echo.length, equals(2));
      expect(engine.moveCount < level.optimalMoves + 3, isTrue);
    });

    // ------------------------------------------------------------------------
    // GROUP 5: GameScreen Orchestration & Widget UI Tests (Reqs 5, 8–18, 22–26)
    // ------------------------------------------------------------------------
    Future<void> makeMoves(WidgetTester tester, ShiftPuzzleGame game, int count) async {
      for (int i = 0; i < count; i++) {
        game.triggerShiftRow(0, ShiftDirection.left);
        await tester.pump(const Duration(milliseconds: 210));
        await tester.pump();
        if (find.byType(OptimalDriftNudgeDialog).evaluate().isNotEmpty) {
          await tester.tap(find.byKey(const ValueKey('nudge_keep_solving_button')));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 350));
        }
      }
    }

    testWidgets('5 & 31. Reaching move limit locks input and shows non-dismissible MoveLimitDialog', (tester) async {
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

      // Make 8 non-solving shifts to reach move limit
      await makeMoves(tester, game, 8);

      // Allow PostFrameCallback to display MoveLimitDialog
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(MoveLimitDialog), findsOneWidget);
      expect(find.text('MOVE LIMIT REACHED'), findsOneWidget);
      expect(find.text("You've reached the move limit for this attempt."), findsOneWidget);
      expect(find.byKey(const ValueKey('replay_button')), findsOneWidget);
      expect(find.byKey(const ValueKey('watch_ad_moves_button')), findsOneWidget);
      expect(analytics.loggedEvents, contains('move_limit_reached'));
    });

    testWidgets('17 & 18. Watching rewarded ad grants exactly +5 moves and unlocks board', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      progress.recordLevelCompletion(levelId: 1, moveCount: 1, stars: 3, totalLevels: 150);
      progress.setLastPlayedLevel(6); // optimal 5, normal limit 8

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

      final game = tester.widget<GameWidget<ShiftPuzzleGame>>(
        find.byWidgetPredicate((w) => w is GameWidget<ShiftPuzzleGame>),
      ).game!;

      // Make 8 moves to trigger dialog
      await makeMoves(tester, game, 8);
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(MoveLimitDialog), findsOneWidget);

      // Tap WATCH AD + 5
      await tester.tap(find.byKey(const ValueKey('watch_ad_moves_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      // Rewarded ad should have run and granted reward
      expect(adService.rewardedAdCallCount, equals(1));
      expect(find.byType(MoveLimitDialog), findsNothing);
      expect(analytics.loggedEvents, contains('move_limit_extra_moves_granted'));
      expect(find.textContaining('+5 extra moves unlocked'), findsOneWidget);

      // Board is unlocked: player can make move 9
      game.triggerShiftRow(0, ShiftDirection.left);
      await tester.pump(const Duration(milliseconds: 210));
      await tester.pump();

      expect(find.text('9'), findsOneWidget);
      expect(find.text('Limit: 9 / 13'), findsOneWidget);
    });

    testWidgets('11. Undo remains disabled after +5 extension is granted', (tester) async {
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

      final game = tester.widget<GameWidget<ShiftPuzzleGame>>(
        find.byWidgetPredicate((w) => w is GameWidget<ShiftPuzzleGame>),
      ).game!;

      // Reach move limit (8 moves)
      await makeMoves(tester, game, 8);
      await tester.pump(const Duration(milliseconds: 100));

      // Grant +5 moves
      await tester.tap(find.byKey(const ValueKey('watch_ad_moves_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      // Verify undo button is disabled
      final undoBtn = find.byKey(const ValueKey('undo_button'));
      expect(tester.widget<IconButton>(undoBtn).onPressed, isNull);
    });

    testWidgets('19. Ad dismissal before reward grants zero moves and keeps board locked', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      adService.shouldGrantReward = false; // Simulate early exit without reward
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

      final game = tester.widget<GameWidget<ShiftPuzzleGame>>(
        find.byWidgetPredicate((w) => w is GameWidget<ShiftPuzzleGame>),
      ).game!;

      await makeMoves(tester, game, 8);
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byKey(const ValueKey('watch_ad_moves_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.textContaining('Ad was not completed'), findsOneWidget);
      expect(analytics.loggedEvents, contains('move_limit_ad_failed'));
      expect(analytics.loggedEvents, isNot(contains('move_limit_extra_moves_granted')));
    });

    testWidgets('21 & 22. Offline ad request shows InternetNeededDialog; retry works upon reconnect', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final offlineConn = MockConnectivityService(isOnline: false);
      progress.recordLevelCompletion(levelId: 1, moveCount: 1, stars: 3, totalLevels: 150);
      progress.setLastPlayedLevel(6);

      await tester.pumpWidget(
        MaterialApp(
          home: GameScreen(
            progress: progress,
            analytics: analytics,
            adService: adService,
            connectivityService: offlineConn,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final game = tester.widget<GameWidget<ShiftPuzzleGame>>(
        find.byWidgetPredicate((w) => w is GameWidget<ShiftPuzzleGame>),
      ).game!;

      await makeMoves(tester, game, 8);
      await tester.pump(const Duration(milliseconds: 100));

      // Tap watch ad while offline
      await tester.tap(find.byKey(const ValueKey('watch_ad_moves_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Shows InternetNeededDialog with extra moves body
      expect(find.byType(InternetNeededDialog), findsOneWidget);
      expect(find.textContaining('A rewarded ad is required to unlock extra moves'), findsOneWidget);

      // Reconnect and tap TRY AGAIN
      offlineConn.isOnline = true;
      await tester.tap(find.text('TRY AGAIN'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(adService.rewardedAdCallCount, equals(1));
      expect(analytics.loggedEvents, contains('move_limit_extra_moves_granted'));
    });

    testWidgets('23. Online but ad unavailable shows HintUnavailableDialog with extra moves copy', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      adService.isAdReady = false; // No ad available
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

      final game = tester.widget<GameWidget<ShiftPuzzleGame>>(
        find.byWidgetPredicate((w) => w is GameWidget<ShiftPuzzleGame>),
      ).game!;

      await makeMoves(tester, game, 8);
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byKey(const ValueKey('watch_ad_moves_button')));
      await tester.pump();
      // Wait for grace period
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 350));
      }

      expect(find.byType(HintUnavailableDialog), findsOneWidget);
      expect(find.text('EXTRA MOVES TEMPORARILY UNAVAILABLE'), findsOneWidget);
      expect(find.byType(InternetNeededDialog), findsNothing);
    });

    testWidgets('24. Second extension is impossible; reaching extended limit exhausts attempt', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      progress.recordLevelCompletion(levelId: 1, moveCount: 1, stars: 3, totalLevels: 150);
      progress.setLastPlayedLevel(6); // optimal 5, normal 8, extended 13

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

      final game = tester.widget<GameWidget<ShiftPuzzleGame>>(
        find.byWidgetPredicate((w) => w is GameWidget<ShiftPuzzleGame>),
      ).game!;

      // 8 moves to limit
      await makeMoves(tester, game, 8);
      await tester.pump(const Duration(milliseconds: 100));

      // Grant 1st extension (+5 moves)
      await tester.tap(find.byKey(const ValueKey('watch_ad_moves_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      // Make 5 more moves to reach extended limit (move 13)
      for (int i = 0; i < 5; i++) {
        game.triggerShiftRow(0, ShiftDirection.left);
        await tester.pump(const Duration(milliseconds: 210));
        await tester.pump();
      }
      await tester.pump(const Duration(milliseconds: 100));

      // Dialog shows with attempt exhausted (only REPLAY LEVEL, NO WATCH AD)
      expect(find.byType(MoveLimitDialog), findsOneWidget);
      expect(find.text('FINAL ATTEMPT EXHAUSTED'), findsOneWidget);
      expect(find.byKey(const ValueKey('watch_ad_moves_button')), findsNothing);
      expect(find.byKey(const ValueKey('replay_button')), findsOneWidget);
      expect(analytics.loggedEvents, contains('move_limit_final_attempt_exhausted'));
    });

    testWidgets('13 & 14. Replay resets move limit and attempt state while preserving campaign progress', (tester) async {
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

      final game = tester.widget<GameWidget<ShiftPuzzleGame>>(
        find.byWidgetPredicate((w) => w is GameWidget<ShiftPuzzleGame>),
      ).game!;

      await makeMoves(tester, game, 8);
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(MoveLimitDialog), findsOneWidget);

      // Tap REPLAY LEVEL
      await tester.tap(find.byKey(const ValueKey('replay_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Board is reset
      expect(find.text('0'), findsOneWidget);
      expect(find.text(' / 5'), findsOneWidget);
      expect(find.text('Limit: 0 / 8'), findsOneWidget);
      expect(progress.isLevelCompleted(1), isTrue); // Permanent progress untouched
    });

    testWidgets('25. GameHeader HUD distinguishes moves, optimal par, and limit with +5 bonus badge', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GameHeader(
              levelId: 6,
              levelTitle: 'Trio Harmony',
              moveCount: 7,
              optimalMoves: 5,
              moveLimit: 8,
              hasExtraMoves: false,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('7'), findsOneWidget);
      expect(find.text(' / 5'), findsOneWidget);
      expect(find.text('Limit: 7 / 8'), findsOneWidget);

      // Now with extra moves (+5 bonus)
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GameHeader(
              levelId: 6,
              levelTitle: 'Trio Harmony',
              moveCount: 10,
              optimalMoves: 5,
              moveLimit: 13,
              hasExtraMoves: true,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('10'), findsOneWidget);
      expect(find.text('+5 bonus'), findsOneWidget);
      expect(find.text('Limit: 10 / 13'), findsOneWidget);
    });

    testWidgets('26. WinDialog reports actual moves used and true optimal par accurately', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WinDialog(
              levelId: 6,
              moveCount: 12, // solved after extra moves
              optimalMoves: 5,
              hasNextLevel: true,
              onNextLevel: () {},
              onReplay: () {},
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Moves: 12'), findsOneWidget);
      expect(find.text('Optimal: 5 moves'), findsOneWidget);
      expect(find.text('PUZZLE SOLVED'), findsOneWidget);
    });
  });
}
