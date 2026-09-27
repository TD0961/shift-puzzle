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
      expect(() => analytics.logHintButtonViewed(5, isStruggling: true), returnsNormally);
      expect(() => analytics.logHintRequested(5), returnsNormally);
      expect(() => analytics.logHintCompleted(5), returnsNormally);
      expect(() => analytics.logHintCancelled(5), returnsNormally);
      expect(() => analytics.logHintFailed(5, 'ad_error'), returnsNormally);
      expect(
        () => analytics.logLevelCompletedWithHint(
          levelId: 5,
          moves: 6,
          optimalMoves: 4,
          stars: 2,
        ),
        returnsNormally,
      );
      expect(() => analytics.logRewardedAdRequested('hint_level_5'), returnsNormally);
      expect(() => analytics.logRewardedAdCompleted('hint_level_5'), returnsNormally);
      expect(() => analytics.logRewardedAdFailed('hint_level_5', 'not_ready'), returnsNormally);
      expect(() => analytics.logHintGranted(5), returnsNormally);
      expect(() => analytics.logHintUsed(5), returnsNormally);
      expect(() => analytics.logInterstitialRequested(12), returnsNormally);
      expect(() => analytics.logInterstitialShown(12), returnsNormally);
      expect(
        () => analytics.logOptimalDriftDetected(
          levelId: 6,
          chapterId: 1,
          hasMemoryEcho: false,
          moveCount: 6,
          optimalMoves: 5,
        ),
        returnsNormally,
      );
      expect(
        () => analytics.logOptimalDriftNudgeShown(
          levelId: 6,
          chapterId: 1,
          hasMemoryEcho: false,
          moveCount: 6,
          optimalMoves: 5,
        ),
        returnsNormally,
      );
      expect(() => analytics.logOptimalDriftKeepSolving(levelId: 6, moveCount: 6), returnsNormally);
      expect(() => analytics.logOptimalDriftHintRequested(levelId: 6, moveCount: 6), returnsNormally);
      expect(
        () => analytics.logOptimalDriftAdStarted(levelId: 6, placement: 'optimal_drift_level_6'),
        returnsNormally,
      );
      expect(
        () => analytics.logOptimalDriftAdRewarded(levelId: 6, placement: 'optimal_drift_level_6'),
        returnsNormally,
      );
      expect(
        () => analytics.logOptimalDriftAdFailed(
          levelId: 6,
          placement: 'optimal_drift_level_6',
          reason: 'timeout',
        ),
        returnsNormally,
      );
      expect(() => analytics.logOptimalDriftHintRevealed(levelId: 6, moveCount: 6), returnsNormally);
      expect(
        () => analytics.logLevelCompletedAfterOptimalDrift(
          levelId: 6,
          moves: 7,
          optimalMoves: 5,
          stars: 2,
        ),
        returnsNormally,
      );

      // Task 16 Telemetry
      expect(() => analytics.logHintNetworkUnavailable(6, source: 'manual_hint'), returnsNormally);
      expect(() => analytics.logHintAdUnavailable(6, source: 'optimal_drift'), returnsNormally);
      expect(() => analytics.logHintAdRetry(6, outcome: 'success', source: 'manual_hint'), returnsNormally);
      expect(() => analytics.logHintAdStarted(6, placement: 'hint_level_6', source: 'manual_hint'), returnsNormally);
      expect(() => analytics.logHintAdRewarded(6, placement: 'hint_level_6', source: 'manual_hint'), returnsNormally);
      expect(() => analytics.logHintAdFailed(6, placement: 'hint_level_6', reason: 'ad_not_completed', source: 'manual_hint'), returnsNormally);
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
