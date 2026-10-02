import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'analytics_service.dart';

/// Signature for testing or injecting custom HTTP transport implementations.
typedef HttpEventSender = Future<bool> Function(
  Uri uri,
  Map<String, String> headers,
  String body,
);

/// Lightweight, provider-independent HTTP analytics transport foundation.
///
/// Principles:
/// - Completely offline-tolerant and fail-safe.
/// - Non-blocking: queued and dispatched asynchronously.
/// - Batched: dispatches in batches to minimize radio wakeups.
/// - Disabled by default: safe no-op if [endpoint] is empty or invalid.
/// - ZERO PII: only anonymous telemetry with randomly generated installation UUID.
class LightweightHttpAnalyticsService implements AnalyticsService {
  final String endpoint;
  final String? initialInstallationId;
  final String initialAcquisitionSource;
  final HttpEventSender? customSender;
  final int maxBatchSize;
  final int maxQueueSize;

  String? _installationId;
  String _acquisitionSource;
  final List<Map<String, dynamic>> _queue = [];
  bool _isFlushing = false;
  Timer? _periodicFlushTimer;

  LightweightHttpAnalyticsService({
    required this.endpoint,
    this.initialInstallationId,
    this.initialAcquisitionSource = 'direct',
    this.customSender,
    this.maxBatchSize = 10,
    this.maxQueueSize = 100,
  })  : _installationId = initialInstallationId,
        _acquisitionSource = initialAcquisitionSource {
    if (isEnabled) {
      _periodicFlushTimer = Timer.periodic(
        const Duration(seconds: 30),
        (_) => flush(),
      );
    }
  }

  /// Whether HTTP event transmission is active.
  ///
  /// Safe: Evaluates to false if the endpoint is empty, null, or invalid.
  bool get isEnabled => endpoint.trim().isNotEmpty;

  /// Current number of events waiting in the offline queue.
  int get queuedEventCount => _queue.length;

  @override
  void setAnonymousContext({String? installationId, String? acquisitionSource}) {
    if (installationId != null && installationId.isNotEmpty) {
      _installationId = installationId;
    }
    if (acquisitionSource != null && acquisitionSource.isNotEmpty) {
      _acquisitionSource = acquisitionSource;
    }
  }

  /// Internal enqueue helper that guarantees fail-safe, non-blocking queuing.
  void _enqueue(String eventName, Map<String, dynamic> params) {
    if (!isEnabled) return;

    try {
      // Guard against unbounded memory growth during prolonged offline play
      if (_queue.length >= maxQueueSize) {
        _queue.removeAt(0); // Evict oldest event
      }

      final payload = {
        'event': eventName,
        'timestamp': DateTime.now().toUtc().toIso8601String(),
        'installation_id': _installationId ?? 'anonymous',
        'source': _acquisitionSource,
        'properties': params,
      };

      _queue.add(payload);

      if (_queue.length >= maxBatchSize) {
        // Trigger asynchronous flush without blocking caller
        unawaited(flush());
      }
    } catch (e) {
      // Fail-safe: telemetry errors must never escape to caller
      debugPrint('[HttpAnalytics] Enqueue ignored: $e');
    }
  }

  /// Flushes all queued events to the configured HTTP endpoint.
  Future<bool> flush() async {
    if (!isEnabled || _queue.isEmpty || _isFlushing) return false;

    _isFlushing = true;
    final batch = List<Map<String, dynamic>>.from(_queue);

    try {
      final uri = Uri.parse(endpoint);
      final body = jsonEncode({
        'events': batch,
        'sent_at': DateTime.now().toUtc().toIso8601String(),
      });

      final headers = {
        'Content-Type': 'application/json; charset=utf-8',
        'User-Agent': 'ShiftPuzzle-Telemetry/1.0',
      };

      bool success = false;
      if (customSender != null) {
        success = await customSender!(uri, headers, body);
      } else {
        final client = HttpClient()..connectionTimeout = const Duration(seconds: 4);
        try {
          final request = await client.postUrl(uri);
          headers.forEach((key, value) => request.headers.set(key, value));
          request.write(body);
          final response = await request.close().timeout(const Duration(seconds: 5));
          success = response.statusCode >= 200 && response.statusCode < 300;
          await response.drain<void>();
        } finally {
          client.close();
        }
      }

      if (success) {
        // Remove only the items that were successfully dispatched
        _queue.removeRange(0, batch.length);
        return true;
      }
      return false;
    } catch (e) {
      // Offline / transient network failure: keep items in queue for future flush
      debugPrint('[HttpAnalytics] Flush failed safely (offline-tolerant): $e');
      return false;
    } finally {
      _isFlushing = false;
    }
  }

  /// Disposes background timers and resources.
  void dispose() {
    _periodicFlushTimer?.cancel();
    _periodicFlushTimer = null;
  }

  // --- App Lifecycle Telemetry ---

  @override
  void logAppOpen({String? source}) {
    _enqueue('app_open', {'source': source ?? _acquisitionSource});
  }

  @override
  void logFirstLaunch({String? source}) {
    _enqueue('first_launch', {'source': source ?? _acquisitionSource});
  }

  @override
  void logSessionStart({required int sessionNumber, String? source}) {
    _enqueue('session_start', {
      'session_number': sessionNumber,
      'source': source ?? _acquisitionSource,
    });
  }

  @override
  void logSessionEnd({required int sessionNumber, required int durationSeconds}) {
    _enqueue('session_end', {
      'session_number': sessionNumber,
      'duration_seconds': durationSeconds,
    });
  }

  // --- Gameplay Telemetry ---

  @override
  void logLevelStart({required int levelId, int? chapterId, int attemptNumber = 1}) {
    _enqueue('level_start', {
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
    _enqueue('level_complete', {
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
    logLevelComplete(
      levelId: levelId,
      movesUsed: moves,
      parMoves: optimalMoves,
      stars: stars,
    );
  }

  @override
  void logLevelFailed({
    required int levelId,
    int? chapterId,
    required int movesUsed,
  }) {
    _enqueue('level_failed', {
      'level_id': levelId,
      'chapter_id': chapterId ?? ((levelId - 1) ~/ 10) + 1,
      'moves_used': movesUsed,
    });
  }

  @override
  void logLevelRestart({required int levelId, int? chapterId}) {
    _enqueue('level_restart', {
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
    _enqueue('chapter_complete', {'chapter_id': chapterId});
  }

  @override
  void logChapterUnlocked(int chapterId) {
    logChapterComplete(chapterId);
  }

  @override
  void logGameStarted({required int highestUnlockedLevel}) {
    _enqueue('game_started', {'highest_unlocked': highestUnlockedLevel});
  }

  @override
  void logUndoUsed(int levelId, int currentMoveCount) {
    _enqueue('undo_used', {'level_id': levelId, 'move_count': currentMoveCount});
  }

  @override
  void logEchoRecorded(int levelId, int shiftCount) {
    _enqueue('echo_recorded', {'level_id': levelId, 'shift_count': shiftCount});
  }

  @override
  void logEchoReplayed(int levelId, int shiftCount) {
    _enqueue('echo_replayed', {'level_id': levelId, 'shift_count': shiftCount});
  }

  @override
  void logSoundToggled(bool enabled) {
    _enqueue('sound_toggled', {'enabled': enabled});
  }

  @override
  void logTutorialStarted(int levelId) {
    _enqueue('tutorial_started', {'level_id': levelId});
  }

  @override
  void logTutorialCompleted(int levelId) {
    _enqueue('tutorial_completed', {'level_id': levelId});
  }

  // --- Monetization Telemetry ---

  @override
  void logInterstitialRequested(int levelId, {String? placement, String? mode}) {
    _enqueue('interstitial_requested', {
      'level_id': levelId,
      'placement': placement ?? 'level_complete',
      'mode': mode ?? 'default',
    });
  }

  @override
  void logInterstitialShown(int levelId, {String? placement, String? mode}) {
    _enqueue('interstitial_shown', {
      'level_id': levelId,
      'placement': placement ?? 'level_complete',
      'mode': mode ?? 'default',
    });
  }

  @override
  void logInterstitialFailed(int levelId, String reason, {String? placement, String? mode}) {
    _enqueue('interstitial_failed', {
      'level_id': levelId,
      'reason': reason,
      'placement': placement ?? 'level_complete',
      'mode': mode ?? 'default',
    });
  }

  @override
  void logRewardedAdRequested(String placement, {int? levelId, String? mode}) {
    _enqueue('rewarded_requested', {
      'placement': placement,
      'level_id': levelId ?? 0,
      'mode': mode ?? 'default',
    });
  }

  @override
  void logRewardedAdLoaded(String placement, {int? levelId, String? mode}) {
    _enqueue('rewarded_loaded', {
      'placement': placement,
      'level_id': levelId ?? 0,
      'mode': mode ?? 'default',
    });
  }

  @override
  void logRewardedAdShown(String placement, {int? levelId, String? mode}) {
    _enqueue('rewarded_shown', {
      'placement': placement,
      'level_id': levelId ?? 0,
      'mode': mode ?? 'default',
    });
  }

  @override
  void logRewardedAdCompleted(String placement, {int? levelId, String? mode}) {
    _enqueue('rewarded_completed', {
      'placement': placement,
      'level_id': levelId ?? 0,
      'mode': mode ?? 'default',
    });
  }

  @override
  void logRewardedAdFailed(String placement, String reason, {int? levelId, String? mode}) {
    _enqueue('rewarded_failed', {
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
    _enqueue('ad_load_failed', {
      'ad_type': adType,
      'placement': placement,
      'reason': reason,
    });
  }

  // --- Acquisition & Sharing Telemetry ---

  @override
  void logShareClicked({required String placement, int? levelId}) {
    _enqueue('share_clicked', {
      'placement': placement,
      'level_id': levelId ?? 0,
    });
  }

  @override
  void logBootstrapLinkClicked(String url, {String? placement, int? levelId}) {
    _enqueue('bootstrap_link_clicked', {
      'url': url,
      'placement': placement ?? 'bootstrap_banner',
      'level_id': levelId ?? 0,
    });
  }

  // --- Hints & Special Moves Telemetry ---

  @override
  void logHintOffered(int levelId) {
    _enqueue('hint_offered', {'level_id': levelId});
  }

  @override
  void logHintButtonViewed(int levelId, {required bool isStruggling}) {
    _enqueue('hint_button_viewed', {'level_id': levelId, 'is_struggling': isStruggling});
  }

  @override
  void logHintRequested(int levelId) {
    _enqueue('hint_requested', {'level_id': levelId});
  }

  @override
  void logHintCompleted(int levelId) {
    _enqueue('hint_completed', {'level_id': levelId});
  }

  @override
  void logHintCancelled(int levelId) {
    _enqueue('hint_cancelled', {'level_id': levelId});
  }

  @override
  void logHintFailed(int levelId, String reason) {
    _enqueue('hint_failed', {'level_id': levelId, 'reason': reason});
  }

  @override
  void logLevelCompletedWithHint({
    required int levelId,
    required int moves,
    required int optimalMoves,
    required int stars,
  }) {
    _enqueue('level_completed_with_hint', {
      'level_id': levelId,
      'moves': moves,
      'optimal_moves': optimalMoves,
      'stars': stars,
    });
  }

  @override
  void logHintGranted(int levelId) {
    _enqueue('hint_granted', {'level_id': levelId});
  }

  @override
  void logHintUsed(int levelId) {
    _enqueue('hint_used', {'level_id': levelId});
  }

  @override
  void logHintNetworkUnavailable(int levelId, {String source = 'manual_hint'}) {
    _enqueue('hint_network_unavailable', {'level_id': levelId, 'source': source});
  }

  @override
  void logHintAdUnavailable(int levelId, {String source = 'manual_hint'}) {
    _enqueue('hint_ad_unavailable', {'level_id': levelId, 'source': source});
  }

  @override
  void logHintAdRetry(int levelId, {required String outcome, String source = 'manual_hint'}) {
    _enqueue('hint_ad_retry', {'level_id': levelId, 'outcome': outcome, 'source': source});
  }

  @override
  void logHintAdStarted(int levelId, {required String placement, String source = 'manual_hint'}) {
    _enqueue('hint_ad_started', {'level_id': levelId, 'placement': placement, 'source': source});
  }

  @override
  void logHintAdRewarded(int levelId, {required String placement, String source = 'manual_hint'}) {
    _enqueue('hint_ad_rewarded', {'level_id': levelId, 'placement': placement, 'source': source});
  }

  @override
  void logHintAdFailed(int levelId, {required String placement, required String reason, String source = 'manual_hint'}) {
    _enqueue('hint_ad_failed', {'level_id': levelId, 'placement': placement, 'reason': reason, 'source': source});
  }

  @override
  void logOptimalDriftDetected({
    required int levelId,
    required int chapterId,
    required bool hasMemoryEcho,
    required int moveCount,
    required int optimalMoves,
  }) {
    _enqueue('optimal_drift_detected', {
      'level_id': levelId,
      'chapter_id': chapterId,
      'has_memory_echo': hasMemoryEcho,
      'move_count': moveCount,
      'optimal_moves': optimalMoves,
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
    _enqueue('optimal_drift_nudge_shown', {
      'level_id': levelId,
      'chapter_id': chapterId,
      'has_memory_echo': hasMemoryEcho,
      'move_count': moveCount,
      'optimal_moves': optimalMoves,
    });
  }

  @override
  void logOptimalDriftKeepSolving({required int levelId, required int moveCount}) {
    _enqueue('optimal_drift_keep_solving', {'level_id': levelId, 'move_count': moveCount});
  }

  @override
  void logOptimalDriftHintRequested({required int levelId, required int moveCount}) {
    _enqueue('optimal_drift_hint_requested', {'level_id': levelId, 'move_count': moveCount});
  }

  @override
  void logOptimalDriftAdStarted({required int levelId, required String placement}) {
    _enqueue('optimal_drift_ad_started', {'level_id': levelId, 'placement': placement});
  }

  @override
  void logOptimalDriftAdRewarded({required int levelId, required String placement}) {
    _enqueue('optimal_drift_ad_rewarded', {'level_id': levelId, 'placement': placement});
  }

  @override
  void logOptimalDriftAdFailed({required int levelId, required String placement, required String reason}) {
    _enqueue('optimal_drift_ad_failed', {'level_id': levelId, 'placement': placement, 'reason': reason});
  }

  @override
  void logOptimalDriftHintRevealed({required int levelId, required int moveCount}) {
    _enqueue('optimal_drift_hint_revealed', {'level_id': levelId, 'move_count': moveCount});
  }

  @override
  void logLevelCompletedAfterOptimalDrift({
    required int levelId,
    required int moves,
    required int optimalMoves,
    required int stars,
  }) {
    _enqueue('level_completed_after_optimal_drift', {
      'level_id': levelId,
      'moves': moves,
      'optimal_moves': optimalMoves,
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
    _enqueue('move_limit_reached', {
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
  void logMoveLimitReplaySelected({required int levelId, required int movesUsed}) {
    _enqueue('move_limit_replay_selected', {'level_id': levelId, 'moves_used': movesUsed});
  }

  @override
  void logMoveLimitExtraMovesRequested({required int levelId, required int movesUsed}) {
    _enqueue('move_limit_extra_moves_requested', {'level_id': levelId, 'moves_used': movesUsed});
  }

  @override
  void logMoveLimitAdStarted({required int levelId, required String placement}) {
    _enqueue('move_limit_ad_started', {'level_id': levelId, 'placement': placement});
  }

  @override
  void logMoveLimitAdRewarded({required int levelId, required String placement}) {
    _enqueue('move_limit_ad_rewarded', {'level_id': levelId, 'placement': placement});
  }

  @override
  void logMoveLimitAdFailed({required int levelId, required String placement, required String reason}) {
    _enqueue('move_limit_ad_failed', {'level_id': levelId, 'placement': placement, 'reason': reason});
  }

  @override
  void logMoveLimitExtraMovesGranted({required int levelId, required int extraMovesGranted, required int newMoveLimit}) {
    _enqueue('move_limit_extra_moves_granted', {
      'level_id': levelId,
      'extra_moves_granted': extraMovesGranted,
      'new_move_limit': newMoveLimit,
    });
  }

  @override
  void logMoveLimitFinalAttemptExhausted({required int levelId, required int movesUsed}) {
    _enqueue('move_limit_final_attempt_exhausted', {'level_id': levelId, 'moves_used': movesUsed});
  }

  @override
  void logLevelCompletedAfterExtraMoves({
    required int levelId,
    required int moves,
    required int optimalMoves,
    required int stars,
  }) {
    _enqueue('level_completed_after_extra_moves', {
      'level_id': levelId,
      'moves': moves,
      'optimal_moves': optimalMoves,
      'stars': stars,
    });
  }
}
