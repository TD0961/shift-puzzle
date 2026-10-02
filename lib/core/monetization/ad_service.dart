import 'package:flutter/foundation.dart';

export 'ad_policy_manager.dart';
export 'admob_ad_service.dart';
export 'bootstrap_ad_service.dart';
export 'development_ad_service.dart';
export 'monetization_config.dart';
export 'no_op_ad_service.dart';

/// Contract for non-intrusive game monetization.
///
/// Designed with an offline-first philosophy:
/// - Never interrupts active gameplay or move planning.
/// - Never shows ads on tutorial / introductory levels (Chapter 1: 1–10).
/// - Enforces sensible cooldown intervals and completion frequency caps.
/// - Allows zero-dependency operation via [NoOpAdService] or [DevelopmentAdService].
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
