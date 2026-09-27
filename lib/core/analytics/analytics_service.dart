import 'package:flutter/foundation.dart';

/// Lightweight, privacy-first event telemetry contract.
///
/// Designed to capture game design insights without collecting personal identity,
/// device identifiers, or tracking data.
abstract class AnalyticsService {
  void logGameStarted({required int highestUnlockedLevel});
  void logLevelStarted(int levelId);
  void logLevelCompleted({
    required int levelId,
    required int moves,
    required int optimalMoves,
    required int stars,
    required bool isNewBest,
  });
  void logLevelRestarted(int levelId);
  void logUndoUsed(int levelId, int currentMoveCount);
  void logEchoRecorded(int levelId, int shiftCount);
  void logEchoReplayed(int levelId, int shiftCount);
  void logChapterUnlocked(int chapterId);
  void logSoundToggled(bool enabled);

  // Task 12 Monetization & Tutorial Telemetry
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
  void logRewardedAdRequested(String placement);
  void logRewardedAdCompleted(String placement);
  void logRewardedAdFailed(String placement, String reason);
  void logHintGranted(int levelId);
  void logHintUsed(int levelId);
  void logInterstitialRequested(int levelId);
  void logInterstitialShown(int levelId);

  // Task 14 Optimal Drift Nudge Telemetry
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
}

/// Production default debug logger / no-op analytics service.
class DebugAnalyticsService implements AnalyticsService {
  final bool enableLogging;

  const DebugAnalyticsService({this.enableLogging = kDebugMode});

  void _log(String event, Map<String, dynamic> params) {
    if (enableLogging) {
      debugPrint('[Analytics] $event: $params');
    }
  }

  @override
  void logGameStarted({required int highestUnlockedLevel}) {
    _log('game_started', {'highest_unlocked': highestUnlockedLevel});
  }

  @override
  void logLevelStarted(int levelId) {
    _log('level_started', {'level_id': levelId});
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
  void logLevelRestarted(int levelId) {
    _log('level_restarted', {'level_id': levelId});
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
  void logChapterUnlocked(int chapterId) {
    _log('chapter_unlocked', {'chapter_id': chapterId});
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
  void logRewardedAdRequested(String placement) {
    _log('rewarded_ad_requested', {'placement': placement});
  }

  @override
  void logRewardedAdCompleted(String placement) {
    _log('rewarded_ad_completed', {'placement': placement});
  }

  @override
  void logRewardedAdFailed(String placement, String reason) {
    _log('rewarded_ad_failed', {'placement': placement, 'reason': reason});
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
  void logInterstitialRequested(int levelId) {
    _log('interstitial_requested', {'level_id': levelId});
  }

  @override
  void logInterstitialShown(int levelId) {
    _log('interstitial_shown', {'level_id': levelId});
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
}
