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
      expect(() => analytics.logRewardedAdLoaded('hint_level_5'), returnsNormally);
      expect(() => analytics.logRewardedAdShown('hint_level_5'), returnsNormally);
      expect(() => analytics.logRewardedAdCompleted('hint_level_5'), returnsNormally);
      expect(() => analytics.logRewardedAdFailed('hint_level_5', 'not_ready'), returnsNormally);
      expect(() => analytics.logHintGranted(5), returnsNormally);
      expect(() => analytics.logHintUsed(5), returnsNormally);
      expect(() => analytics.logInterstitialRequested(12), returnsNormally);
      expect(() => analytics.logInterstitialShown(12), returnsNormally);
      expect(() => analytics.logInterstitialFailed(12, 'network_timeout'), returnsNormally);
      expect(() => analytics.logBootstrapLinkClicked('https://example.com/promo'), returnsNormally);
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

    test('Phase 2 event schema executes cleanly on DebugAnalyticsService', () {
      const analytics = DebugAnalyticsService(enableLogging: true);

      expect(() => analytics.setAnonymousContext(installationId: 'test-uuid', acquisitionSource: 'tiktok'), returnsNormally);
      expect(() => analytics.logAppOpen(source: 'tiktok'), returnsNormally);
      expect(() => analytics.logFirstLaunch(source: 'tiktok'), returnsNormally);
      expect(() => analytics.logSessionStart(sessionNumber: 1, source: 'tiktok'), returnsNormally);
      expect(() => analytics.logSessionEnd(sessionNumber: 1, durationSeconds: 120), returnsNormally);
      expect(() => analytics.logLevelStart(levelId: 1, chapterId: 1, attemptNumber: 1), returnsNormally);
      expect(() => analytics.logLevelComplete(levelId: 1, chapterId: 1, movesUsed: 3, parMoves: 2, stars: 2), returnsNormally);
      expect(() => analytics.logLevelFailed(levelId: 1, chapterId: 1, movesUsed: 5), returnsNormally);
      expect(() => analytics.logLevelRestart(levelId: 1, chapterId: 1), returnsNormally);
      expect(() => analytics.logChapterComplete(1), returnsNormally);
      expect(() => analytics.logAdLoadFailed(adType: 'rewarded', placement: 'hint', reason: 'no_fill'), returnsNormally);
      expect(() => analytics.logShareClicked(placement: 'win_dialog', levelId: 1), returnsNormally);
    });

    test('NoOpAnalyticsService executes all methods safely without operation', () {
      const analytics = NoOpAnalyticsService();

      expect(() => analytics.setAnonymousContext(installationId: 'test', acquisitionSource: 'direct'), returnsNormally);
      expect(() => analytics.logAppOpen(), returnsNormally);
      expect(() => analytics.logFirstLaunch(), returnsNormally);
      expect(() => analytics.logSessionStart(sessionNumber: 1), returnsNormally);
      expect(() => analytics.logSessionEnd(sessionNumber: 1, durationSeconds: 60), returnsNormally);
      expect(() => analytics.logLevelStart(levelId: 1), returnsNormally);
      expect(() => analytics.logLevelStarted(1), returnsNormally);
      expect(() => analytics.logLevelComplete(levelId: 1, movesUsed: 2), returnsNormally);
      expect(() => analytics.logLevelFailed(levelId: 1, movesUsed: 4), returnsNormally);
      expect(() => analytics.logLevelRestart(levelId: 1), returnsNormally);
      expect(() => analytics.logLevelRestarted(1), returnsNormally);
      expect(() => analytics.logChapterComplete(1), returnsNormally);
      expect(() => analytics.logChapterUnlocked(1), returnsNormally);
      expect(() => analytics.logShareClicked(placement: 'win_dialog'), returnsNormally);
      expect(() => analytics.logBootstrapLinkClicked('https://example.com'), returnsNormally);
      expect(() => analytics.logAdLoadFailed(adType: 'interstitial', placement: 'level_complete', reason: 'timeout'), returnsNormally);
    });
  });

  group('LightweightHttpAnalyticsService Transport & Privacy', () {
    test('disabled when endpoint is empty or blank', () {
      final service = LightweightHttpAnalyticsService(endpoint: '');
      expect(service.isEnabled, isFalse);

      service.logLevelStart(levelId: 1);
      expect(service.queuedEventCount, equals(0));
      service.dispose();
    });

    test('enforces zero-PII schema and queues events', () {
      final service = LightweightHttpAnalyticsService(
        endpoint: 'https://telemetry.example.com/events',
        initialInstallationId: 'anon-123',
        initialAcquisitionSource: 'direct',
      );
      expect(service.isEnabled, isTrue);

      service.logLevelComplete(
        levelId: 5,
        chapterId: 1,
        movesUsed: 4,
        parMoves: 4,
        stars: 3,
      );

      expect(service.queuedEventCount, equals(1));
      service.dispose();
    });

    test('dispatches batch via sender and clears successfully sent events', () async {
      final dispatchedPayloads = <String>[];

      final service = LightweightHttpAnalyticsService(
        endpoint: 'https://telemetry.example.com/events',
        initialInstallationId: 'anon-456',
        maxBatchSize: 10,
        customSender: (uri, headers, body) async {
          dispatchedPayloads.add(body);
          return true; // Success
        },
      );

      service.logLevelStart(levelId: 1);
      service.logLevelComplete(levelId: 1, movesUsed: 2);

      // Reached maxBatchSize of 2, trigger flush
      final flushed = await service.flush();
      expect(flushed, isTrue);
      expect(dispatchedPayloads.length, equals(1));
      expect(dispatchedPayloads.first, contains('level_start'));
      expect(dispatchedPayloads.first, contains('level_complete'));
      expect(service.queuedEventCount, equals(0));

      service.dispose();
    });

    test('offline-tolerant: sender failure keeps events in queue without crashing', () async {
      final service = LightweightHttpAnalyticsService(
        endpoint: 'https://telemetry.example.com/events',
        initialInstallationId: 'anon-789',
        customSender: (uri, headers, body) async {
          throw Exception('Simulated network offline failure');
        },
      );

      service.logLevelStart(levelId: 2);
      expect(service.queuedEventCount, equals(1));

      // Flush failure is caught silently and returns false
      final flushed = await service.flush();
      expect(flushed, isFalse);
      // Items remain safe in queue for subsequent retry
      expect(service.queuedEventCount, equals(1));

      service.dispose();
    });

    test('queue size is bounded: evicts oldest events during prolonged offline play', () {
      final service = LightweightHttpAnalyticsService(
        endpoint: 'https://telemetry.example.com/events',
        maxBatchSize: 100, // Do not auto-flush
        maxQueueSize: 5,
      );

      for (int i = 1; i <= 10; i++) {
        service.logLevelStart(levelId: i);
      }

      // Must never exceed maxQueueSize of 5
      expect(service.queuedEventCount, equals(5));
      service.dispose();
    });

    test('AnalyticsService.create factory respects build modes and endpoint configuration', () {
      // In debug mode: always DebugAnalyticsService
      final debugService = AnalyticsService.create(isDebug: true);
      expect(debugService, isA<DebugAnalyticsService>());

      // In release mode without endpoint: NoOpAnalyticsService
      final releaseNoOpService = AnalyticsService.create(
        endpoint: '',
        isDebug: false,
      );
      expect(releaseNoOpService, isA<NoOpAnalyticsService>());

      // In release mode with configured endpoint: LightweightHttpAnalyticsService
      final releaseHttpService = AnalyticsService.create(
        endpoint: 'https://analytics.example.com',
        isDebug: false,
      );
      expect(releaseHttpService, isA<LightweightHttpAnalyticsService>());
    });
  });
}
