import 'package:flutter/foundation.dart';
import 'ad_service.dart';

/// Offline / no-op ad service implementation.
///
/// Guarantees that the game runs 100% offline without external SDK dependencies,
/// network calls, or third-party tracking.
///
/// In this mode:
/// - Interstitials are never rendered on screen, but policy thresholds are tracked.
/// - Rewarded ad requests immediately invoke the reward callback to ensure
///   the player is never stuck or penalized in offline environments.
class NoOpAdService implements AdService {
  final AdPolicyManager policyManager;

  NoOpAdService({
    AdPolicyManager? policyManager,
    int onboardingFreeLevels = AdPolicyManager.defaultOnboardingFreeLevels,
    Duration cooldownDuration = AdPolicyManager.defaultInterstitialCooldown,
    int levelFrequency = AdPolicyManager.defaultMinimumCompletedLevels,
  }) : policyManager = policyManager ??
            AdPolicyManager(
              onboardingFreeLevels: onboardingFreeLevels,
              cooldownDuration: cooldownDuration,
              levelFrequency: levelFrequency,
            );

  @override
  Future<void> initialize() async {
    debugPrint('[NoOpAdService] Initialized in offline/no-op mode.');
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
    bool isSolvingActive = false,
    bool isLevelFailed = false,
    bool isAppLaunch = false,
  }) async {
    if (!policyManager.canShowInterstitial(
      levelId: levelId,
      completedLevelCount: completedLevelCount,
      isSolvingActive: isSolvingActive,
      isLevelFailed: isLevelFailed,
      isAppLaunch: isAppLaunch,
    )) {
      return false;
    }

    // Record the trigger against policy, but display no real ad
    policyManager.recordInterstitialShown(
      levelId: levelId,
      completedLevelCount: completedLevelCount,
    );
    debugPrint('[NoOpAdService] Interstitial policy criteria met for Level $levelId (no-op).');
    return false;
  }

  @override
  Future<bool> showRewardedAd({
    required String placement,
    required VoidCallback onRewardEarned,
  }) async {
    debugPrint('[NoOpAdService] Rewarded ad requested for "$placement" (granting mock reward).');
    onRewardEarned();
    return true;
  }
}
