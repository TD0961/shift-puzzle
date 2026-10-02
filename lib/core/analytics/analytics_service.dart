import 'package:flutter/foundation.dart';
import 'http_analytics_service.dart';

export 'http_analytics_service.dart';

/// Lightweight, privacy-first event telemetry contract.
///
/// Designed to capture game design insights without collecting personal identity,
/// device identifiers, or tracking data.
abstract class AnalyticsService {
  /// Injects anonymous session/attribution identifiers without personal data.
  void setAnonymousContext({String? installationId, String? acquisitionSource});

  // --- App Lifecycle Telemetry (Phase 2) ---
  void logAppOpen({String? source});
  void logFirstLaunch({String? source});
  void logSessionStart({required int sessionNumber, String? source});
  void logSessionEnd({required int sessionNumber, required int durationSeconds});

  // --- Gameplay Telemetry ---
  void logLevelStart({required int levelId, int? chapterId, int attemptNumber = 1});
  void logLevelStarted(int levelId);
  void logLevelComplete({
    required int levelId,
    int? chapterId,
    required int movesUsed,
    int? parMoves,
    int? stars,
  });
  void logLevelCompleted({
    required int levelId,
    required int moves,
    required int optimalMoves,
    required int stars,
    required bool isNewBest,
  });
  void logLevelFailed({
    required int levelId,
    int? chapterId,
    required int movesUsed,
  });
  void logLevelRestart({required int levelId, int? chapterId});
  void logLevelRestarted(int levelId);
  void logChapterComplete(int chapterId);
  void logChapterUnlocked(int chapterId);
  void logGameStarted({required int highestUnlockedLevel});
  void logUndoUsed(int levelId, int currentMoveCount);
  void logEchoRecorded(int levelId, int shiftCount);
  void logEchoReplayed(int levelId, int shiftCount);
  void logSoundToggled(bool enabled);

  // --- Monetization Telemetry ---
  void logInterstitialRequested(int levelId, {String? placement, String? mode});
  void logInterstitialShown(int levelId, {String? placement, String? mode});
  void logInterstitialFailed(int levelId, String reason, {String? placement, String? mode});
  void logRewardedAdRequested(String placement, {int? levelId, String? mode});
  void logRewardedAdLoaded(String placement, {int? levelId, String? mode});
  void logRewardedAdShown(String placement, {int? levelId, String? mode});
  void logRewardedAdCompleted(String placement, {int? levelId, String? mode});
  void logRewardedAdFailed(String placement, String reason, {int? levelId, String? mode});
  void logAdLoadFailed({
    required String adType,
    required String placement,
    required String reason,
  });

  // --- Acquisition & Sharing Telemetry ---
  void logShareClicked({required String placement, int? levelId});
  void logBootstrapLinkClicked(String url, {String? placement, int? levelId});

  // --- Tutorial & Hint Telemetry ---
  void logTutorialStarted(int levelId);
  void logTutorialCompleted(int levelId);
  void logHintOffered(int levelId);
  void logHintButtonViewed(int levelId, {required bool isStruggling});
  void logHintRequested(int levelId);
  void logHintCompleted(int levelId);
  void logHintCancelled(int levelId);
  void logHintFailed(int levelId, String reason);
  void logLevelCompletedWithHint({
    required int levelId,
    required int moves,
    required int optimalMoves,
    required int stars,
  });
  void logHintGranted(int levelId);
  void logHintUsed(int levelId);

  // --- Offline & Rewarded Hint Telemetry ---
  void logHintNetworkUnavailable(int levelId, {String source = 'manual_hint'});
  void logHintAdUnavailable(int levelId, {String source = 'manual_hint'});
  void logHintAdRetry(int levelId, {required String outcome, String source = 'manual_hint'});
  void logHintAdStarted(int levelId, {required String placement, String source = 'manual_hint'});
  void logHintAdRewarded(int levelId, {required String placement, String source = 'manual_hint'});
  void logHintAdFailed(int levelId, {required String placement, required String reason, String source = 'manual_hint'});

  // --- Optimal Drift Nudge Telemetry ---
  void logOptimalDriftDetected({
    required int levelId,
    required int chapterId,
    required bool hasMemoryEcho,
    required int moveCount,
    required int optimalMoves,
  });
  void logOptimalDriftNudgeShown({
    required int levelId,
    required int chapterId,
    required bool hasMemoryEcho,
    required int moveCount,
    required int optimalMoves,
  });
  void logOptimalDriftKeepSolving({
    required int levelId,
    required int moveCount,
  });
  void logOptimalDriftHintRequested({
    required int levelId,
    required int moveCount,
  });
  void logOptimalDriftAdStarted({
    required int levelId,
    required String placement,
  });
  void logOptimalDriftAdRewarded({
    required int levelId,
    required String placement,
  });
  void logOptimalDriftAdFailed({
    required int levelId,
    required String placement,
    required String reason,
  });
  void logOptimalDriftHintRevealed({
    required int levelId,
    required int moveCount,
  });
  void logLevelCompletedAfterOptimalDrift({
    required int levelId,
    required int moves,
    required int optimalMoves,
    required int stars,
  });

  // --- Move Budget & Extra Moves Telemetry ---
  void logMoveLimitReached({
    required int levelId,
    required int chapterId,
    required int optimalMoves,
    required int normalMoveLimit,
    required int movesUsed,
    required bool isEchoLevel,
    required bool isExtendedLimit,
  });
  void logMoveLimitReplaySelected({
    required int levelId,
    required int movesUsed,
  });
  void logMoveLimitExtraMovesRequested({
    required int levelId,
    required int movesUsed,
  });
  void logMoveLimitAdStarted({
    required int levelId,
    required String placement,
  });
  void logMoveLimitAdRewarded({
    required int levelId,
    required String placement,
  });
  void logMoveLimitAdFailed({
    required int levelId,
    required String placement,
    required String reason,
  });
  void logMoveLimitExtraMovesGranted({
    required int levelId,
    required int extraMovesGranted,
    required int newMoveLimit,
  });
  void logMoveLimitFinalAttemptExhausted({
    required int levelId,
    required int movesUsed,
  });
  void logLevelCompletedAfterExtraMoves({
    required int levelId,
    required int moves,
    required int optimalMoves,
    required int stars,
  });

  /// Factory helper to create the appropriate analytics service based on environment.
  ///
  /// - Debug builds: [DebugAnalyticsService]
  /// - Release builds without endpoint: [NoOpAnalyticsService] (100% safe, zero overhead)
  /// - Release builds with endpoint: [LightweightHttpAnalyticsService]
  static AnalyticsService create({
    String? endpoint,
    String? installationId,
    String? acquisitionSource,
    bool isDebug = kDebugMode,
  }) {
    final resolvedEndpoint = endpoint ??
        const String.fromEnvironment('ANALYTICS_ENDPOINT', defaultValue: '');
    if (isDebug) {
      return const DebugAnalyticsService(enableLogging: true);
    }
    if (resolvedEndpoint.isNotEmpty) {
      return LightweightHttpAnalyticsService(
        endpoint: resolvedEndpoint,
        initialInstallationId: installationId,
        initialAcquisitionSource: acquisitionSource ?? 'direct',
      );
    }
    return const NoOpAnalyticsService();
  }
}

/// No-op analytics implementation for release builds when no analytics endpoint is configured.
class NoOpAnalyticsService implements AnalyticsService {
  const NoOpAnalyticsService();

  @override
  void setAnonymousContext({String? installationId, String? acquisitionSource}) {}

  @override
  void logAppOpen({String? source}) {}

  @override
  void logFirstLaunch({String? source}) {}

  @override
  void logSessionStart({required int sessionNumber, String? source}) {}

  @override
  void logSessionEnd({required int sessionNumber, required int durationSeconds}) {}

  @override
  void logLevelStart({required int levelId, int? chapterId, int attemptNumber = 1}) {}

  @override
  void logLevelStarted(int levelId) {}

  @override
  void logLevelComplete({
    required int levelId,
    int? chapterId,
    required int movesUsed,
    int? parMoves,
    int? stars,
  }) {}

  @override
  void logLevelCompleted({
    required int levelId,
    required int moves,
    required int optimalMoves,
    required int stars,
    required bool isNewBest,
  }) {}

  @override
  void logLevelFailed({
    required int levelId,
    int? chapterId,
    required int movesUsed,
  }) {}

  @override
  void logLevelRestart({required int levelId, int? chapterId}) {}

  @override
  void logLevelRestarted(int levelId) {}

  @override
  void logChapterComplete(int chapterId) {}

  @override
  void logChapterUnlocked(int chapterId) {}

  @override
  void logGameStarted({required int highestUnlockedLevel}) {}

  @override
  void logUndoUsed(int levelId, int currentMoveCount) {}

  @override
  void logEchoRecorded(int levelId, int shiftCount) {}

  @override
  void logEchoReplayed(int levelId, int shiftCount) {}

  @override
  void logSoundToggled(bool enabled) {}

  @override
  void logInterstitialRequested(int levelId, {String? placement, String? mode}) {}

  @override
  void logInterstitialShown(int levelId, {String? placement, String? mode}) {}

  @override
  void logInterstitialFailed(int levelId, String reason, {String? placement, String? mode}) {}

  @override
  void logRewardedAdRequested(String placement, {int? levelId, String? mode}) {}

  @override
  void logRewardedAdLoaded(String placement, {int? levelId, String? mode}) {}

  @override
  void logRewardedAdShown(String placement, {int? levelId, String? mode}) {}

  @override
  void logRewardedAdCompleted(String placement, {int? levelId, String? mode}) {}

  @override
  void logRewardedAdFailed(String placement, String reason, {int? levelId, String? mode}) {}

  @override
  void logAdLoadFailed({required String adType, required String placement, required String reason}) {}

  @override
  void logShareClicked({required String placement, int? levelId}) {}

  @override
  void logBootstrapLinkClicked(String url, {String? placement, int? levelId}) {}

  @override
  void logTutorialStarted(int levelId) {}

  @override
  void logTutorialCompleted(int levelId) {}

  @override
  void logHintOffered(int levelId) {}

  @override
  void logHintButtonViewed(int levelId, {required bool isStruggling}) {}

  @override
  void logHintRequested(int levelId) {}

  @override
  void logHintCompleted(int levelId) {}

  @override
  void logHintCancelled(int levelId) {}

  @override
  void logHintFailed(int levelId, String reason) {}

  @override
  void logLevelCompletedWithHint({
    required int levelId,
    required int moves,
    required int optimalMoves,
    required int stars,
  }) {}

  @override
  void logHintGranted(int levelId) {}

  @override
  void logHintUsed(int levelId) {}

  @override
  void logHintNetworkUnavailable(int levelId, {String source = 'manual_hint'}) {}

  @override
  void logHintAdUnavailable(int levelId, {String source = 'manual_hint'}) {}

  @override
  void logHintAdRetry(int levelId, {required String outcome, String source = 'manual_hint'}) {}

  @override
  void logHintAdStarted(int levelId, {required String placement, String source = 'manual_hint'}) {}

  @override
  void logHintAdRewarded(int levelId, {required String placement, String source = 'manual_hint'}) {}

  @override
  void logHintAdFailed(int levelId, {required String placement, required String reason, String source = 'manual_hint'}) {}

  @override
  void logOptimalDriftDetected({
    required int levelId,
    required int chapterId,
    required bool hasMemoryEcho,
    required int moveCount,
    required int optimalMoves,
  }) {}

  @override
  void logOptimalDriftNudgeShown({
    required int levelId,
    required int chapterId,
    required bool hasMemoryEcho,
    required int moveCount,
    required int optimalMoves,
  }) {}

  @override
  void logOptimalDriftKeepSolving({required int levelId, required int moveCount}) {}

  @override
  void logOptimalDriftHintRequested({required int levelId, required int moveCount}) {}

  @override
  void logOptimalDriftAdStarted({required int levelId, required String placement}) {}

  @override
  void logOptimalDriftAdRewarded({required int levelId, required String placement}) {}

  @override
  void logOptimalDriftAdFailed({required int levelId, required String placement, required String reason}) {}

  @override
  void logOptimalDriftHintRevealed({required int levelId, required int moveCount}) {}

  @override
  void logLevelCompletedAfterOptimalDrift({
    required int levelId,
    required int moves,
    required int optimalMoves,
    required int stars,
  }) {}

  @override
  void logMoveLimitReached({
    required int levelId,
    required int chapterId,
    required int optimalMoves,
    required int normalMoveLimit,
    required int movesUsed,
    required bool isEchoLevel,
    required bool isExtendedLimit,
  }) {}

  @override
  void logMoveLimitReplaySelected({required int levelId, required int movesUsed}) {}

  @override
  void logMoveLimitExtraMovesRequested({required int levelId, required int movesUsed}) {}

  @override
  void logMoveLimitAdStarted({required int levelId, required String placement}) {}

  @override
  void logMoveLimitAdRewarded({required int levelId, required String placement}) {}

  @override
  void logMoveLimitAdFailed({required int levelId, required String placement, required String reason}) {}

  @override
  void logMoveLimitExtraMovesGranted({required int levelId, required int extraMovesGranted, required int newMoveLimit}) {}

  @override
  void logMoveLimitFinalAttemptExhausted({required int levelId, required int movesUsed}) {}

  @override
  void logLevelCompletedAfterExtraMoves({
    required int levelId,
    required int moves,
    required int optimalMoves,
    required int stars,
  }) {}
}

/// Production default debug logger analytics service.
class DebugAnalyticsService implements AnalyticsService {
  final bool enableLogging;

  const DebugAnalyticsService({this.enableLogging = kDebugMode});

  void _log(String event, Map<String, dynamic> params) {
    if (enableLogging) {
      debugPrint('[Analytics] $event: $params');
    }
  }

  @override
  void setAnonymousContext({String? installationId, String? acquisitionSource}) {
    _log('anonymous_context_set', {
      'installation_id': installationId ?? 'anonymous',
      'source': acquisitionSource ?? 'direct',
    });
  }

  // --- App Lifecycle ---

  @override
  void logAppOpen({String? source}) {
    _log('app_open', {'source': source ?? 'direct'});
  }

  @override
  void logFirstLaunch({String? source}) {
    _log('first_launch', {'source': source ?? 'direct'});
  }

  @override
  void logSessionStart({required int sessionNumber, String? source}) {
    _log('session_start', {
      'session_number': sessionNumber,
      'source': source ?? 'direct',
    });
  }

  @override
  void logSessionEnd({required int sessionNumber, required int durationSeconds}) {
    _log('session_end', {
      'session_number': sessionNumber,
      'duration_seconds': durationSeconds,
    });
  }

  // --- Gameplay ---

  @override
  void logLevelStart({required int levelId, int? chapterId, int attemptNumber = 1}) {
    _log('level_start', {
      'level_id': levelId,
      'chapter_id': chapterId ?? ((levelId - 1) ~/ 10) + 1,
      'attempt_number': attemptNumber,
    });
  }

  @override
  void logLevelStarted(int levelId) {
    logLevelStart(levelId: levelId);
  }

  @override
  void logLevelComplete({
    required int levelId,
    int? chapterId,
    required int movesUsed,
    int? parMoves,
    int? stars,
  }) {
    _log('level_complete', {
      'level_id': levelId,
      'chapter_id': chapterId ?? ((levelId - 1) ~/ 10) + 1,
      'moves_used': movesUsed,
      'par_moves': parMoves ?? 0,
      'stars': stars ?? 0,
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
    _log('level_completed', {
      'level_id': levelId,
      'moves': moves,
      'optimal_moves': optimalMoves,
      'delta_from_optimal': moves - optimalMoves,
      'stars': stars,
      'is_new_best': isNewBest,
    });
  }

  @override
  void logLevelFailed({
    required int levelId,
    int? chapterId,
    required int movesUsed,
  }) {
    _log('level_failed', {
      'level_id': levelId,
      'chapter_id': chapterId ?? ((levelId - 1) ~/ 10) + 1,
      'moves_used': movesUsed,
    });
  }

  @override
  void logLevelRestart({required int levelId, int? chapterId}) {
    _log('level_restart', {
      'level_id': levelId,
      'chapter_id': chapterId ?? ((levelId - 1) ~/ 10) + 1,
    });
  }

  @override
  void logLevelRestarted(int levelId) {
    logLevelRestart(levelId: levelId);
  }

  @override
  void logChapterComplete(int chapterId) {
    _log('chapter_complete', {'chapter_id': chapterId});
  }

  @override
  void logChapterUnlocked(int chapterId) {
    _log('chapter_unlocked', {'chapter_id': chapterId});
  }

  @override
  void logGameStarted({required int highestUnlockedLevel}) {
    _log('game_started', {'highest_unlocked': highestUnlockedLevel});
  }

  @override
  void logUndoUsed(int levelId, int currentMoveCount) {
    _log('undo_used', {'level_id': levelId, 'move_count': currentMoveCount});
  }

  @override
  void logEchoRecorded(int levelId, int shiftCount) {
    _log('echo_recorded', {'level_id': levelId, 'shift_count': shiftCount});
  }

  @override
  void logEchoReplayed(int levelId, int shiftCount) {
    _log('echo_replayed', {'level_id': levelId, 'shift_count': shiftCount});
  }

  @override
  void logSoundToggled(bool enabled) {
    _log('sound_toggled', {'enabled': enabled});
  }

  @override
  void logTutorialStarted(int levelId) {
    _log('tutorial_started', {'level_id': levelId});
  }

  @override
  void logTutorialCompleted(int levelId) {
    _log('tutorial_completed', {'level_id': levelId});
  }

  // --- Monetization ---

  @override
  void logInterstitialRequested(int levelId, {String? placement, String? mode}) {
    _log('interstitial_requested', {
      'level_id': levelId,
      'placement': placement ?? 'level_complete',
      'mode': mode ?? 'default',
    });
  }

  @override
  void logInterstitialShown(int levelId, {String? placement, String? mode}) {
    _log('interstitial_shown', {
      'level_id': levelId,
      'placement': placement ?? 'level_complete',
      'mode': mode ?? 'default',
    });
  }

  @override
  void logInterstitialFailed(int levelId, String reason, {String? placement, String? mode}) {
    _log('interstitial_failed', {
      'level_id': levelId,
      'reason': reason,
      'placement': placement ?? 'level_complete',
      'mode': mode ?? 'default',
    });
  }

  @override
  void logRewardedAdRequested(String placement, {int? levelId, String? mode}) {
    _log('rewarded_requested', {
      'placement': placement,
      'level_id': levelId ?? 0,
      'mode': mode ?? 'default',
    });
  }

  @override
  void logRewardedAdLoaded(String placement, {int? levelId, String? mode}) {
    _log('rewarded_loaded', {
      'placement': placement,
      'level_id': levelId ?? 0,
      'mode': mode ?? 'default',
    });
  }

  @override
  void logRewardedAdShown(String placement, {int? levelId, String? mode}) {
    _log('rewarded_shown', {
      'placement': placement,
      'level_id': levelId ?? 0,
      'mode': mode ?? 'default',
    });
  }

  @override
  void logRewardedAdCompleted(String placement, {int? levelId, String? mode}) {
    _log('rewarded_completed', {
      'placement': placement,
      'level_id': levelId ?? 0,
      'mode': mode ?? 'default',
    });
  }

  @override
  void logRewardedAdFailed(String placement, String reason, {int? levelId, String? mode}) {
    _log('rewarded_failed', {
      'placement': placement,
      'reason': reason,
      'level_id': levelId ?? 0,
      'mode': mode ?? 'default',
    });
  }

  @override
  void logAdLoadFailed({
    required String adType,
    required String placement,
    required String reason,
  }) {
    _log('ad_load_failed', {
      'ad_type': adType,
      'placement': placement,
      'reason': reason,
    });
  }

  // --- Acquisition & Sharing ---

  @override
  void logShareClicked({required String placement, int? levelId}) {
    _log('share_clicked', {
      'placement': placement,
      'level_id': levelId ?? 0,
    });
  }

  @override
  void logBootstrapLinkClicked(String url, {String? placement, int? levelId}) {
    _log('bootstrap_link_clicked', {
      'url': url,
      'placement': placement ?? 'bootstrap_banner',
      'level_id': levelId ?? 0,
    });
  }

  // --- Hints & Special Moves ---

  @override
  void logHintOffered(int levelId) {
    _log('hint_offered', {'level_id': levelId});
  }

  @override
  void logHintButtonViewed(int levelId, {required bool isStruggling}) {
    _log('hint_button_viewed', {'level_id': levelId, 'is_struggling': isStruggling});
  }

  @override
  void logHintRequested(int levelId) {
    _log('hint_requested', {'level_id': levelId});
  }

  @override
  void logHintCompleted(int levelId) {
    _log('hint_completed', {'level_id': levelId});
  }

  @override
  void logHintCancelled(int levelId) {
    _log('hint_cancelled', {'level_id': levelId});
  }

  @override
  void logHintFailed(int levelId, String reason) {
    _log('hint_failed', {'level_id': levelId, 'reason': reason});
  }

  @override
  void logLevelCompletedWithHint({
    required int levelId,
    required int moves,
    required int optimalMoves,
    required int stars,
  }) {
    _log('level_completed_with_hint', {
      'level_id': levelId,
      'moves': moves,
      'optimal_moves': optimalMoves,
      'stars': stars,
    });
  }

  @override
  void logHintGranted(int levelId) {
    _log('hint_granted', {'level_id': levelId});
  }

  @override
  void logHintUsed(int levelId) {
    _log('hint_used', {'level_id': levelId});
  }

  @override
  void logHintNetworkUnavailable(int levelId, {String source = 'manual_hint'}) {
    _log('hint_network_unavailable', {'level_id': levelId, 'source': source});
  }

  @override
  void logHintAdUnavailable(int levelId, {String source = 'manual_hint'}) {
    _log('hint_ad_unavailable', {'level_id': levelId, 'source': source});
  }

  @override
  void logHintAdRetry(int levelId, {required String outcome, String source = 'manual_hint'}) {
    _log('hint_ad_retry', {'level_id': levelId, 'outcome': outcome, 'source': source});
  }

  @override
  void logHintAdStarted(int levelId, {required String placement, String source = 'manual_hint'}) {
    _log('hint_ad_started', {'level_id': levelId, 'placement': placement, 'source': source});
  }

  @override
  void logHintAdRewarded(int levelId, {required String placement, String source = 'manual_hint'}) {
    _log('hint_ad_rewarded', {'level_id': levelId, 'placement': placement, 'source': source});
  }

  @override
  void logHintAdFailed(int levelId, {required String placement, required String reason, String source = 'manual_hint'}) {
    _log('hint_ad_failed', {'level_id': levelId, 'placement': placement, 'reason': reason, 'source': source});
  }

  @override
  void logOptimalDriftDetected({
    required int levelId,
    required int chapterId,
    required bool hasMemoryEcho,
    required int moveCount,
    required int optimalMoves,
  }) {
    _log('optimal_drift_detected', {
      'level_id': levelId,
      'chapter_id': chapterId,
      'has_memory_echo': hasMemoryEcho,
      'move_count': moveCount,
      'optimal_moves': optimalMoves,
      'delta': moveCount - optimalMoves,
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
    _log('optimal_drift_nudge_shown', {
      'level_id': levelId,
      'chapter_id': chapterId,
      'has_memory_echo': hasMemoryEcho,
      'move_count': moveCount,
      'optimal_moves': optimalMoves,
    });
  }

  @override
  void logOptimalDriftKeepSolving({
    required int levelId,
    required int moveCount,
  }) {
    _log('optimal_drift_keep_solving', {
      'level_id': levelId,
      'move_count': moveCount,
    });
  }

  @override
  void logOptimalDriftHintRequested({
    required int levelId,
    required int moveCount,
  }) {
    _log('optimal_drift_hint_requested', {
      'level_id': levelId,
      'move_count': moveCount,
    });
  }

  @override
  void logOptimalDriftAdStarted({
    required int levelId,
    required String placement,
  }) {
    _log('optimal_drift_ad_started', {
      'level_id': levelId,
      'placement': placement,
    });
  }

  @override
  void logOptimalDriftAdRewarded({
    required int levelId,
    required String placement,
  }) {
    _log('optimal_drift_ad_rewarded', {
      'level_id': levelId,
      'placement': placement,
    });
  }

  @override
  void logOptimalDriftAdFailed({
    required int levelId,
    required String placement,
    required String reason,
  }) {
    _log('optimal_drift_ad_failed', {
      'level_id': levelId,
      'placement': placement,
      'reason': reason,
    });
  }

  @override
  void logOptimalDriftHintRevealed({
    required int levelId,
    required int moveCount,
  }) {
    _log('optimal_drift_hint_revealed', {
      'level_id': levelId,
      'move_count': moveCount,
    });
  }

  @override
  void logLevelCompletedAfterOptimalDrift({
    required int levelId,
    required int moves,
    required int optimalMoves,
    required int stars,
  }) {
    _log('level_completed_after_optimal_drift', {
      'level_id': levelId,
      'moves': moves,
      'optimal_moves': optimalMoves,
      'delta': moves - optimalMoves,
      'stars': stars,
    });
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
    _log('move_limit_reached', {
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
    _log('move_limit_replay_selected', {
      'level_id': levelId,
      'moves_used': movesUsed,
    });
  }

  @override
  void logMoveLimitExtraMovesRequested({
    required int levelId,
    required int movesUsed,
  }) {
    _log('move_limit_extra_moves_requested', {
      'level_id': levelId,
      'moves_used': movesUsed,
    });
  }

  @override
  void logMoveLimitAdStarted({
    required int levelId,
    required String placement,
  }) {
    _log('move_limit_ad_started', {
      'level_id': levelId,
      'placement': placement,
    });
  }

  @override
  void logMoveLimitAdRewarded({
    required int levelId,
    required String placement,
  }) {
    _log('move_limit_ad_rewarded', {
      'level_id': levelId,
      'placement': placement,
    });
  }

  @override
  void logMoveLimitAdFailed({
    required int levelId,
    required String placement,
    required String reason,
  }) {
    _log('move_limit_ad_failed', {
      'level_id': levelId,
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
    _log('move_limit_extra_moves_granted', {
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
    _log('move_limit_final_attempt_exhausted', {
      'level_id': levelId,
      'moves_used': movesUsed,
    });
  }

  @override
  void logLevelCompletedAfterExtraMoves({
    required int levelId,
    required int moves,
    required int optimalMoves,
    required int stars,
  }) {
    _log('level_completed_after_extra_moves', {
      'level_id': levelId,
      'moves': moves,
      'optimal_moves': optimalMoves,
      'stars': stars,
    });
  }
}
