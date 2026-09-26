import 'package:flutter_test/flutter_test.dart';
import 'package:shift_puzzle/core/analytics/analytics_service.dart';

void main() {
  group('AnalyticsService Telemetry Events', () {
    test('DebugAnalyticsService executes all event loggers without error', () {
      const analytics = DebugAnalyticsService(enableLogging: true);

      expect(() => analytics.logGameStarted(highestUnlockedLevel: 1), returnsNormally);
      expect(() => analytics.logLevelStarted(1), returnsNormally);
      expect(
        () => analytics.logLevelCompleted(
          levelId: 1,
          moves: 1,
          optimalMoves: 1,
          stars: 3,
          isNewBest: true,
        ),
        returnsNormally,
      );
      expect(() => analytics.logLevelRestarted(1), returnsNormally);
      expect(() => analytics.logUndoUsed(1, 2), returnsNormally);
      expect(() => analytics.logEchoRecorded(9, 2), returnsNormally);
      expect(() => analytics.logEchoReplayed(9, 2), returnsNormally);
      expect(() => analytics.logChapterUnlocked(2), returnsNormally);
      expect(() => analytics.logSoundToggled(false), returnsNormally);
      expect(() => analytics.logTutorialStarted(1), returnsNormally);
      expect(() => analytics.logTutorialCompleted(1), returnsNormally);
      expect(() => analytics.logHintOffered(5), returnsNormally);
      expect(() => analytics.logRewardedAdRequested('hint_level_5'), returnsNormally);
      expect(() => analytics.logRewardedAdCompleted('hint_level_5'), returnsNormally);
      expect(() => analytics.logRewardedAdFailed('hint_level_5', 'not_ready'), returnsNormally);
      expect(() => analytics.logHintGranted(5), returnsNormally);
      expect(() => analytics.logHintUsed(5), returnsNormally);
      expect(() => analytics.logInterstitialRequested(12), returnsNormally);
      expect(() => analytics.logInterstitialShown(12), returnsNormally);
    });

    test('DebugAnalyticsService handles disabled logging cleanly', () {
      const analytics = DebugAnalyticsService(enableLogging: false);

      expect(() => analytics.logGameStarted(highestUnlockedLevel: 5), returnsNormally);
      expect(() => analytics.logLevelStarted(5), returnsNormally);
      expect(
        () => analytics.logLevelCompleted(
          levelId: 5,
          moves: 4,
          optimalMoves: 4,
          stars: 3,
          isNewBest: false,
        ),
        returnsNormally,
      );
      expect(() => analytics.logLevelRestarted(5), returnsNormally);
      expect(() => analytics.logUndoUsed(5, 3), returnsNormally);
      expect(() => analytics.logEchoRecorded(10, 3), returnsNormally);
      expect(() => analytics.logEchoReplayed(10, 3), returnsNormally);
      expect(() => analytics.logChapterUnlocked(3), returnsNormally);
      expect(() => analytics.logSoundToggled(true), returnsNormally);
    });
  });
}
