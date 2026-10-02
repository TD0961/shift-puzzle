import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shift_puzzle/core/storage/player_progress.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PlayerProgress Persistence', () {
    late PlayerProgress progress;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      progress = PlayerProgress(prefs);
    });

    test('default initial state: level 1 unlocked, 0 stars, sound on', () {
      expect(progress.highestUnlockedLevel, equals(1));
      expect(progress.lastPlayedLevel, equals(1));
      expect(progress.isLevelUnlocked(1), isTrue);
      expect(progress.isLevelUnlocked(2), isFalse);
      expect(progress.isLevelCompleted(1), isFalse);
      expect(progress.getBestMoves(1), isNull);
      expect(progress.getStars(1), equals(0));
      expect(progress.isSoundEnabled, isTrue);
    });

    test('completing a level unlocks next level and saves best moves & stars', () async {
      final isNewBest = await progress.recordLevelCompletion(
        levelId: 1,
        moveCount: 3,
        stars: 2,
        totalLevels: 11,
      );

      expect(isNewBest, isTrue);
      expect(progress.isLevelCompleted(1), isTrue);
      expect(progress.highestUnlockedLevel, equals(2));
      expect(progress.isLevelUnlocked(2), isTrue);
      expect(progress.getBestMoves(1), equals(3));
      expect(progress.getStars(1), equals(2));

      // Replaying with better result (1 move, 3 stars)
      final improved = await progress.recordLevelCompletion(
        levelId: 1,
        moveCount: 1,
        stars: 3,
        totalLevels: 11,
      );

      expect(improved, isTrue);
      expect(progress.getBestMoves(1), equals(1));
      expect(progress.getStars(1), equals(3));

      // Replaying with worse result (4 moves, 1 star) does not overwrite best
      final worse = await progress.recordLevelCompletion(
        levelId: 1,
        moveCount: 4,
        stars: 1,
        totalLevels: 11,
      );

      expect(worse, isFalse);
      expect(progress.getBestMoves(1), equals(1));
      expect(progress.getStars(1), equals(3));
    });

    test('completing final level (150) does not unlock non-existent level 151', () async {
      await progress.recordLevelCompletion(
        levelId: 150,
        moveCount: 8,
        stars: 3,
        totalLevels: 150,
      );

      expect(progress.highestUnlockedLevel, equals(1));
      expect(progress.isLevelCompleted(150), isTrue);
    });

    test('tutorial completion persists correctly', () async {
      expect(progress.isTutorialCompleted, isFalse);
      await progress.setTutorialCompleted();
      expect(progress.isTutorialCompleted, isTrue);
    });

    test('last played level and sound toggling persist accurately', () async {
      await progress.setLastPlayedLevel(5);
      expect(progress.lastPlayedLevel, equals(5));

      await progress.setSoundEnabled(false);
      expect(progress.isSoundEnabled, isFalse);

      await progress.setSoundEnabled(true);
      expect(progress.isSoundEnabled, isTrue);
    });

    test('hardened against corrupted, out-of-bounds, or legacy types', () async {
      SharedPreferences.setMockInitialValues({
        'sp_highest_unlocked': 999, // out of bounds
        'sp_last_played': -5, // invalid negative
        'sp_completed_levels': ['1', '5', '999', 'invalid', '150'],
        'sp_best_moves': '{"1": 4, "2": "5", "3": 6.0}', // mixed types
        'sp_stars': 'corrupted json string',
      });
      final prefs = await SharedPreferences.getInstance();
      final hardened = PlayerProgress(prefs);

      // Clamped to [1, 150]
      expect(hardened.highestUnlockedLevel, equals(150));
      expect(hardened.lastPlayedLevel, equals(1));

      // Completed levels filters out invalid strings and >150
      expect(hardened.completedLevels, containsAll([1, 5, 150]));
      expect(hardened.completedLevels.contains(999), isFalse);

      // Best moves safely parses numeric strings and doubles
      expect(hardened.getBestMoves(1), equals(4));
      expect(hardened.getBestMoves(2), equals(5));
      expect(hardened.getBestMoves(3), equals(6));

      // Corrupted JSON returns safe default (0 stars, no crash)
      expect(hardened.getStars(1), equals(0));
    });

    test('anonymous installationId persists and generates RFC 4122 v4 UUID without PII', () {
      final id1 = progress.installationId;
      expect(id1, isNotEmpty);
      // Verify standard UUID format 8-4-4-4-12
      final uuidRegex = RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$');
      expect(uuidRegex.hasMatch(id1), isTrue);

      // Same instance returns identical persisted ID
      final id2 = progress.installationId;
      expect(id2, equals(id1));
    });

    test('session counter and isFirstLaunch evaluate and increment accurately', () async {
      expect(progress.sessionCount, equals(0));
      expect(progress.isFirstLaunch, isTrue);

      final s1 = await progress.incrementSessionCount();
      expect(s1, equals(1));
      expect(progress.sessionCount, equals(1));
      expect(progress.isFirstLaunch, isTrue);

      final s2 = await progress.incrementSessionCount();
      expect(s2, equals(2));
      expect(progress.sessionCount, equals(2));
      expect(progress.isFirstLaunch, isFalse);
    });

    test('acquisition source defaults to direct and persists updates', () async {
      expect(progress.acquisitionSource, equals('direct'));

      await progress.setAcquisitionSource('tiktok');
      expect(progress.acquisitionSource, equals('tiktok'));

      await progress.setAcquisitionSource('youtube');
      expect(progress.acquisitionSource, equals('youtube'));
    });

    test('resetAll cleanses session, installation, and tutorial markers', () async {
      await progress.incrementSessionCount();
      await progress.setAcquisitionSource('telegram');
      await progress.setTutorialCompleted();

      expect(progress.sessionCount, greaterThan(0));
      expect(progress.isTutorialCompleted, isTrue);

      await progress.resetAll();

      expect(progress.sessionCount, equals(0));
      expect(progress.isFirstLaunch, isTrue);
      expect(progress.acquisitionSource, equals('direct'));
      expect(progress.isTutorialCompleted, isFalse);
    });
  });
}

