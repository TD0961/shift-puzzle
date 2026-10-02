import 'package:flutter/foundation.dart';

/// Centralized, provider-independent policy engine for Shift Puzzle advertisements.
///
/// Enforces player-first gameplay protection rules regardless of the active ad provider:
/// 1. First-session / onboarding protection: introductory levels (default: 1–5) are completely ad-free.
/// 2. Cooldown timer: minimum duration between full-screen interstitials (default: 90 seconds).
/// 3. Completion frequency: minimum completed levels between interstitials (default: 2 completed levels).
/// 4. Active gameplay protection: NEVER interrupts active puzzle solving, move planning, or app launch.
/// 5. Failure protection: NEVER displays an interstitial on a failed level attempt.
/// 6. Rewarded protection: rewarded ads are strictly voluntary/opt-in.
class AdPolicyManager {
  /// Default number of onboarding levels that are 100% ad-free (Levels 1–5).
  static const int defaultOnboardingFreeLevels = 5;

  /// Default cooldown duration between interstitial ads (90 seconds).
  static const Duration defaultInterstitialCooldown = Duration(seconds: 90);

  /// Default minimum number of completed levels required between interstitials.
  static const int defaultMinimumCompletedLevels = 2;

  /// Legacy alias for Chapter 1 maximum level (Level 10) for backward-compatibility.
  static const int chapterOneMaxLevel = 10;

  final int onboardingFreeLevels;
  final Duration cooldownDuration;
  final int levelFrequency;
  final bool isRewardedAvailable;
  final bool isBootstrapMonetizationEnabled;

  DateTime? _lastInterstitialTime;
  int _lastCompletedCountAtAd = 0;
  int _totalInterstitialsShown = 0;

  AdPolicyManager({
    this.onboardingFreeLevels = defaultOnboardingFreeLevels,
    this.cooldownDuration = defaultInterstitialCooldown,
    this.levelFrequency = defaultMinimumCompletedLevels,
    this.isRewardedAvailable = true,
    this.isBootstrapMonetizationEnabled = true,
  });

  /// Timestamp when the last interstitial ad was presented, or null if none yet.
  DateTime? get lastInterstitialTime => _lastInterstitialTime;

  /// Completed level count at the time the last interstitial ad was shown.
  int get lastCompletedCountAtAd => _lastCompletedCountAtAd;

  /// Total number of interstitials recorded by this policy manager.
  int get totalInterstitialsShown => _totalInterstitialsShown;

  /// Evaluates whether an interstitial ad is permitted under current policy thresholds.
  ///
  /// An interstitial is permitted ONLY if:
  /// - App is not in cold launch state ([isAppLaunch] is false).
  /// - Player is not actively solving or dragging ([isSolvingActive] is false).
  /// - Level attempt did not end in failure ([isLevelFailed] is false).
  /// - The target level is beyond onboarding ([levelId] > [onboardingFreeLevels]).
  /// - At least [levelFrequency] levels have been completed since the last interstitial.
  /// - At least [cooldownDuration] has elapsed since the last interstitial.
  bool canShowInterstitial({
    required int levelId,
    required int completedLevelCount,
    bool isSolvingActive = false,
    bool isLevelFailed = false,
    bool isAppLaunch = false,
    DateTime? now,
  }) {
    // 1. Guard against app launch interruption
    if (isAppLaunch) {
      debugPrint('[AdPolicyManager] Interstitial denied: Cannot show immediately after app launch.');
      return false;
    }

    // 2. Guard against active puzzle solving interruption
    if (isSolvingActive) {
      debugPrint('[AdPolicyManager] Interstitial denied: Cannot interrupt active puzzle solving.');
      return false;
    }

    // 3. Guard against showing an ad after a failed level attempt
    if (isLevelFailed) {
      debugPrint('[AdPolicyManager] Interstitial denied: Cannot show on a failed level attempt.');
      return false;
    }

    // 4. Onboarding protection check
    if (levelId <= onboardingFreeLevels) {
      debugPrint(
        '[AdPolicyManager] Interstitial denied: Level $levelId is protected under onboarding ($onboardingFreeLevels levels).',
      );
      return false;
    }

    // 5. Completion frequency check (e.g., at least 2 levels completed since last ad)
    final levelsSinceLastAd = completedLevelCount - _lastCompletedCountAtAd;
    if (levelsSinceLastAd < levelFrequency) {
      debugPrint(
        '[AdPolicyManager] Interstitial denied: $levelsSinceLastAd/$levelFrequency levels completed since last ad.',
      );
      return false;
    }

    // 6. Time cooldown check (e.g., at least 90s elapsed since last ad)
    final currentTime = now ?? DateTime.now();
    if (_lastInterstitialTime != null &&
        currentTime.difference(_lastInterstitialTime!) < cooldownDuration) {
      final elapsed = currentTime.difference(_lastInterstitialTime!).inSeconds;
      final required = cooldownDuration.inSeconds;
      debugPrint(
        '[AdPolicyManager] Interstitial denied: Cooldown active ($elapsed/${required}s elapsed).',
      );
      return false;
    }

    return true;
  }

  /// Records an interstitial ad presentation, updating the cooldown timestamp and counter.
  void recordInterstitialShown({
    required int levelId,
    required int completedLevelCount,
    DateTime? now,
  }) {
    _lastInterstitialTime = now ?? DateTime.now();
    _lastCompletedCountAtAd = completedLevelCount;
    _totalInterstitialsShown++;
    debugPrint(
      '[AdPolicyManager] Interstitial recorded for Level $levelId (total: $_totalInterstitialsShown).',
    );
  }

  /// Resets policy tracking state (primarily for automated testing).
  void reset() {
    _lastInterstitialTime = null;
    _lastCompletedCountAtAd = 0;
    _totalInterstitialsShown = 0;
  }
}
