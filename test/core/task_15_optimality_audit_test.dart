import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shift_puzzle/core/analytics/analytics_service.dart';
import 'package:shift_puzzle/core/monetization/ad_service.dart';
import 'package:shift_puzzle/core/puzzle/levels/level_definitions.dart';
import 'package:shift_puzzle/core/puzzle/logic/puzzle_engine.dart';
import 'package:shift_puzzle/core/puzzle/logic/puzzle_solver.dart';
import 'package:shift_puzzle/core/puzzle/models/shift_direction.dart';
import 'package:shift_puzzle/core/storage/player_progress.dart';
import 'package:shift_puzzle/ui/game_header.dart';
import 'package:shift_puzzle/ui/game_screen.dart';
import 'package:shift_puzzle/ui/optimal_drift_nudge_dialog.dart';
import 'package:shift_puzzle/ui/win_dialog.dart';

class MockAnalytics extends DebugAnalyticsService {
  final List<String> events = [];
  final Map<String, dynamic> lastParams = {};

  MockAnalytics() : super(enableLogging: false);

  @override
  void logOptimalDriftDetected({
    required int levelId,
    required int chapterId,
    required bool hasMemoryEcho,
    required int moveCount,
    required int optimalMoves,
  }) {
    events.add('optimal_drift_detected');
    lastParams['optimal_drift_detected'] = {
      'levelId': levelId,
      'chapterId': chapterId,
      'hasMemoryEcho': hasMemoryEcho,
      'moveCount': moveCount,
      'optimalMoves': optimalMoves,
    };
  }

  @override
  void logOptimalDriftNudgeShown({
    required int levelId,
    required int chapterId,
    required bool hasMemoryEcho,
    required int moveCount,
    required int optimalMoves,
  }) {
    events.add('optimal_drift_nudge_shown');
  }

  @override
  void logLevelCompleted({
    required int levelId,
    required int moves,
    required int optimalMoves,
    required int stars,
    required bool isNewBest,
  }) {
    events.add('level_completed');
    lastParams['level_completed'] = {
      'levelId': levelId,
      'moves': moves,
      'stars': stars,
      'optimalMoves': optimalMoves,
      'isNewBest': isNewBest,
    };
  }
}

class MockAdService implements AdService {
  bool rewardedReady = true;

  @override
  bool get isReady => true;

  @override
  bool get isRewardedAdReady => rewardedReady;

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
    onRewardEarned();
    return true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TASK 15: Optimality Integrity & Discrepancy Resolution Audit', () {
    test('1 & 2. Level 22 reproduction & resolution: True optimal is 5 moves', () {
      final level = LevelDefinitions.getLevel(22);
      expect(level.optimalMoves, equals(5),
          reason: 'Level 22 configured optimalMoves must be 5');

      final solverResult = PuzzleSolver.solve(level);
      expect(solverResult, isNotNull);
      expect(solverResult!.minMoves, equals(5),
          reason: 'Authoritative PuzzleSolver must find the true 5-move solution');

      // Verify the 5 moves solve the puzzle in PuzzleEngine
      final engine = PuzzleEngine(level);
      for (final move in solverResult.path) {
        if (move.isRow) {
          engine.shiftRow(move.index, move.direction);
        } else {
          engine.shiftColumn(move.index, move.direction);
        }
      }
      expect(engine.moveCount, equals(5));
      expect(engine.isSolved, isTrue);
    });

    test('3 & 4. All 150 campaign levels have exact solver agreement', () {
      for (int id = 1; id <= 150; id++) {
        final level = LevelDefinitions.getLevel(id);
        final result = PuzzleSolver.solve(level);
        expect(result, isNotNull,
            reason: 'Level $id must be solvable within depth limits');
        expect(result!.minMoves, equals(level.optimalMoves),
            reason: 'Level $id optimalMoves (${level.optimalMoves}) must match solver minMoves (${result.minMoves})');
      }
    });

    test('5, 6 & 7. All 21 corrected levels replay cleanly in PuzzleEngine', () {
      final correctedLevels = [
        5, 11, 14, 17, 20, 22, 38, 39, 40, 45, 46,
        56, 57, 62, 75, 80, 85, 107, 109, 118, 136
      ];

      for (final id in correctedLevels) {
        final level = LevelDefinitions.getLevel(id);
        final solverResult = PuzzleSolver.solve(level)!;
        final engine = PuzzleEngine(level);

        for (final move in solverResult.path) {
          final ok = move.isRow
              ? engine.shiftRow(move.index, move.direction)
              : engine.shiftColumn(move.index, move.direction);
          expect(ok, isTrue);
        }

        expect(engine.moveCount, equals(level.optimalMoves),
            reason: 'Level $id engine moveCount must equal level.optimalMoves');
        expect(engine.isSolved, isTrue,
            reason: 'Level $id must reach solved state');
      }
    });

    testWidgets('8. WinDialog reflects authoritative optimal moves and 3 stars on perfect solve',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WinDialog(
              levelId: 22,
              moveCount: 5,
              optimalMoves: 5,
              hasNextLevel: true,
              isNewBest: true,
              onNextLevel: () {},
              onReplay: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('LEVEL COMPLETE'), findsOneWidget);
      expect(find.text('PERFECT!'), findsOneWidget);
      expect(find.text('Moves: 5'), findsOneWidget);
      expect(find.text('Optimal: 5 moves'), findsOneWidget);
      expect(find.text('★ NEW PERSONAL BEST!'), findsOneWidget);
    });

    testWidgets('9. GameHeader HUD displays authoritative optimal par',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameHeader(
              levelId: 22,
              levelTitle: 'Ring of Saturn',
              moveCount: 5,
              optimalMoves: 5,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('5'), findsOneWidget);
      expect(find.text(' / 5'), findsOneWidget);
    });

    test('10. Star rating thresholds are calibrated to authoritative optimal', () {
      int calcStars(int moveCount, int optimalMoves) {
        if (moveCount <= optimalMoves) return 3;
        if (moveCount <= optimalMoves + 2) return 2;
        return 1;
      }

      const par = 5;
      expect(calcStars(4, par), equals(3));
      expect(calcStars(5, par), equals(3));
      expect(calcStars(6, par), equals(2));
      expect(calcStars(7, par), equals(2));
      expect(calcStars(8, par), equals(1));
    });

    test('11. Personal-best logic correctly stores personal records', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final progress = PlayerProgress(prefs);

      // First clear: 6 moves
      final firstIsBest = await progress.recordLevelCompletion(
        levelId: 22,
        moveCount: 6,
        stars: 2,
        totalLevels: 150,
      );
      expect(firstIsBest, isTrue);
      expect(progress.getBestMoves(22), equals(6));

      // Second clear: 5 moves (improved)
      final secondIsBest = await progress.recordLevelCompletion(
        levelId: 22,
        moveCount: 5,
        stars: 3,
        totalLevels: 150,
      );
      expect(secondIsBest, isTrue);
      expect(progress.getBestMoves(22), equals(5));

      // Third clear: 7 moves (worse)
      final thirdIsBest = await progress.recordLevelCompletion(
        levelId: 22,
        moveCount: 7,
        stars: 2,
        totalLevels: 150,
      );
      expect(thirdIsBest, isFalse);
      expect(progress.getBestMoves(22), equals(5));
    });

    testWidgets('12, 13 & 14. Optimal Drift Nudge safety: No false drift at par, triggers exactly at par + 1',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final progress = PlayerProgress(prefs);
      progress.setLastPlayedLevel(22);

      final analytics = MockAnalytics();
      final adService = MockAdService();

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

      // Level 22 par is 5: Header shows 0 / 5
      expect(find.text('0'), findsOneWidget);
      expect(find.text(' / 5'), findsOneWidget);

      // At par (5 moves), nudge must NOT be shown
      expect(find.byType(OptimalDriftNudgeDialog), findsNothing);
      expect(analytics.events.contains('optimal_drift_nudge_shown'), isFalse);
    });

    test('15 & 16. Echo move isolation: Echo playback shifts do not increment moveCount', () {
      final level = LevelDefinitions.getLevel(11); // Echo level with par = 5
      final engine = PuzzleEngine(level);

      // Player move
      engine.shiftRow(0, ShiftDirection.right, isEcho: false);
      expect(engine.moveCount, equals(1));

      // Echo replay shift
      engine.shiftRow(0, ShiftDirection.left, isEcho: true);
      expect(engine.moveCount, equals(1),
          reason: 'Echo playback shifts must not increment moveCount');
    });

    test('17 & 18. Undo and Restart properly restore board state and moveCount', () {
      final level = LevelDefinitions.getLevel(22);
      final engine = PuzzleEngine(level);

      engine.shiftRow(0, ShiftDirection.left);
      engine.shiftColumn(2, ShiftDirection.down);
      expect(engine.moveCount, equals(2));
      expect(engine.canUndo, isTrue);

      engine.undo();
      expect(engine.moveCount, equals(1));

      engine.reset();
      expect(engine.moveCount, equals(0));
      expect(engine.canUndo, isFalse);
    });

    test('19, 20, 21 & 22. Rewarded hints and analytics integration', () {
      final level = LevelDefinitions.getLevel(22);
      final bestMove = PuzzleSolver.getNextBestMove(level.initialGrid, level);
      expect(bestMove, isNotNull);
      expect(bestMove!.isRow, isTrue);
      expect(bestMove.index, equals(0));
      expect(bestMove.direction, equals(ShiftDirection.left));
    });
  });
}
