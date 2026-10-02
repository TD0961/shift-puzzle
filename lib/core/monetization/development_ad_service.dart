import 'package:flutter/foundation.dart';
import '../analytics/analytics_service.dart';
import 'ad_service.dart';

/// Fast, deterministic mock ad service for local development, emulator runs, and automated testing.
///
/// Features:
/// - Never contacts Google AdMob, Adsterra, or any external network.
/// - Simulates rewarded ads and invokes reward callbacks immediately (or after a configurable delay).
/// - Enforces the shared [AdPolicyManager] to ensure development mirrors real interstitial rules.
/// - Fires lifecycle events to an optional [AnalyticsService] for verification without SDK overhead.
class DevelopmentAdService implements AdService {
  final AdPolicyManager policyManager;
  final AnalyticsService? analytics;

  /// Whether to simulate a brief asynchronous delay before completing ads.
  final bool simulateDelay;

  /// Whether to simulate ad presentation failure (useful for testing fallback flows).
  final bool simulateFailure;

  bool _isReady = true;
  bool _isRewardedAdReady = true;

  int _interstitialCount = 0;
  int _rewardedCount = 0;
  int _preloadCount = 0;
  String? _lastRewardedPlacement;

  DevelopmentAdService({
    AdPolicyManager? policyManager,
    this.analytics,
    this.simulateDelay = false,
    this.simulateFailure = false,
  }) : policyManager = policyManager ?? AdPolicyManager();

  @override
  Future<void> initialize() async {
    debugPrint('[DevelopmentAdService] Initialized in mock development mode.');
  }

  @override
  bool get isReady => _isReady;

  set isReady(bool value) => _isReady = value;

  @override
  bool get isRewardedAdReady => _isRewardedAdReady;

  set isRewardedAdReady(bool value) => _isRewardedAdReady = value;

  int get interstitialCount => _interstitialCount;
  int get rewardedCount => _rewardedCount;
  int get preloadCount => _preloadCount;
  String? get lastRewardedPlacement => _lastRewardedPlacement;

  @override
  Future<void> preloadRewardedAd() async {
    _preloadCount++;
    _isRewardedAdReady = true;
    analytics?.logRewardedAdLoaded('preload');
    debugPrint('[DevelopmentAdService] Rewarded ad preloaded (preloadCount: $_preloadCount).');
  }

  @override
  Future<bool> showInterstitialIfAppropriate({
    required int levelId,
    required int completedLevelCount,
    bool isSolvingActive = false,
    bool isLevelFailed = false,
    bool isAppLaunch = false,
  }) async {
    analytics?.logInterstitialRequested(levelId);

    if (!policyManager.canShowInterstitial(
      levelId: levelId,
      completedLevelCount: completedLevelCount,
      isSolvingActive: isSolvingActive,
      isLevelFailed: isLevelFailed,
      isAppLaunch: isAppLaunch,
    )) {
      debugPrint('[DevelopmentAdService] Interstitial denied by AdPolicyManager for Level $levelId.');
      return false;
    }

    if (simulateDelay) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }

    if (simulateFailure) {
      analytics?.logInterstitialFailed(levelId, 'simulated_dev_failure');
      debugPrint('[DevelopmentAdService] Interstitial failed (simulated failure).');
      return false;
    }

    policyManager.recordInterstitialShown(
      levelId: levelId,
      completedLevelCount: completedLevelCount,
    );
    _interstitialCount++;
    analytics?.logInterstitialShown(levelId);
    debugPrint('[DevelopmentAdService] Interstitial shown successfully (total: $_interstitialCount).');
    return true;
  }

  @override
  Future<bool> showRewardedAd({
    required String placement,
    required VoidCallback onRewardEarned,
  }) async {
    _lastRewardedPlacement = placement;
    analytics?.logRewardedAdRequested(placement);

    if (simulateDelay) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }

    if (simulateFailure) {
      analytics?.logRewardedAdFailed(placement, 'simulated_dev_failure');
      debugPrint('[DevelopmentAdService] Rewarded ad failed (simulated failure).');
      return false;
    }

    analytics?.logRewardedAdShown(placement);
    onRewardEarned();
    _rewardedCount++;
    analytics?.logRewardedAdCompleted(placement);
    debugPrint('[DevelopmentAdService] Rewarded ad completed for "$placement" (total: $_rewardedCount).');
    return true;
  }
}
