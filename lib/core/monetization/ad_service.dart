import 'package:flutter/foundation.dart';
export 'admob_ad_service.dart';

/// Contract for non-intrusive game monetization.
///
/// Designed with an offline-first philosophy:
/// - Never interrupts active gameplay or move planning.
/// - Never shows ads on tutorial / introductory levels (Chapter 1: 1–10).
/// - Enforces sensible cooldown intervals and completion frequency caps.
/// - Allows zero-dependency operation via [NoOpAdService].
abstract class AdService {
  /// Initializes the ad subsystem asynchronously.
  Future<void> initialize();

  /// Whether the ad service is ready to display ads.
  bool get isReady;

  /// Whether a rewarded ad is currently loaded and ready to present.
  bool get isRewardedAdReady;

  /// Attempts to display an interstitial ad if player policy thresholds are met.
  ///
  /// Returns `true` if an ad was displayed, `false` otherwise.
  Future<bool> showInterstitialIfAppropriate({
    required int levelId,
    required int completedLevelCount,
  });

  /// Preloads a rewarded ad if supported and conditions are appropriate.
  Future<void> preloadRewardedAd();

  /// Displays an optional rewarded ad.
  ///
  /// Calls [onRewardEarned] upon successful completion of the ad.
  Future<bool> showRewardedAd({
    required String placement,
    required VoidCallback onRewardEarned,
  });
}

/// Production default no-op / offline ad service.
///
/// Guarantees that the game runs 100% offline without external SDK dependencies,
/// network calls, or third-party tracking.
class NoOpAdService implements AdService {
  DateTime? _lastInterstitialTime;
  int _lastCompletedCountAtAd = 0;

  /// Cooldown between interstitials (default: 3 minutes).
  final Duration cooldownDuration;

  /// Levels completed between interstitials (default: every 4 levels).
  final int levelFrequency;

  NoOpAdService({
    this.cooldownDuration = const Duration(seconds: 180),
    this.levelFrequency = 4,
  });

  @override
  Future<void> initialize() async {
    debugPrint('[AdService] Initialized in offline/no-op mode.');
  }

  @override
  bool get isReady => false;

  @override
  bool get isRewardedAdReady => true;

  @override
  Future<void> preloadRewardedAd() async {}

  @override
  Future<bool> showInterstitialIfAppropriate({
    required int levelId,
    required int completedLevelCount,
  }) async {
    // 1. Chapter 1 (Levels 1–10) is always 100% ad-free
    if (levelId <= 10) {
      debugPrint('[AdService] Interstitial skipped: Level $levelId is in Chapter 1.');
      return false;
    }

    // 2. Frequency check (e.g., every 4 levels)
    final levelsSinceLastAd = completedLevelCount - _lastCompletedCountAtAd;
    if (levelsSinceLastAd < levelFrequency) {
      debugPrint(
        '[AdService] Interstitial skipped: $levelsSinceLastAd/$levelFrequency levels completed since last ad.',
      );
      return false;
    }

    // 3. Time cooldown check
    final now = DateTime.now();
    if (_lastInterstitialTime != null &&
        now.difference(_lastInterstitialTime!) < cooldownDuration) {
      debugPrint('[AdService] Interstitial skipped: Cooldown active.');
      return false;
    }

    // Record ad slot trigger
    _lastInterstitialTime = now;
    _lastCompletedCountAtAd = completedLevelCount;
    debugPrint('[AdService] Interstitial policy criteria met for Level $levelId.');
    return false;
  }

  @override
  Future<bool> showRewardedAd({
    required String placement,
    required VoidCallback onRewardEarned,
  }) async {
    debugPrint('[AdService] Rewarded ad requested for "$placement" (granting mock reward).');
    onRewardEarned();
    return true;
  }
}
