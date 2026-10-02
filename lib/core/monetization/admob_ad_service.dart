import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../analytics/analytics_service.dart';
import '../connectivity/connectivity_service.dart';
import 'ad_service.dart';

/// Production-grade Google AdMob implementation of [AdService].
///
/// Features:
/// - Official Google Mobile Ads SDK integration.
/// - Uses official Google test ad units during development/testing.
/// - Delegates all ad-frequency and cooldown decisions to [AdPolicyManager].
/// - Non-intrusive: never displays ads during active gameplay or board interaction.
/// - Fail-safe: ad load or presentation failures never block puzzle flow or crash the app.
/// - Dispatches lifecycle telemetry events to [AnalyticsService].
/// - Graceful fallback on non-mobile platforms (Web/Desktop/Testing).
class AdMobAdService implements AdService {
  // Official Google AdMob Test Ad Unit IDs
  static const String _androidTestInterstitial = 'ca-app-pub-3940256099942544/1033173712';
  static const String _iosTestInterstitial = 'ca-app-pub-3940256099942544/4411468910';
  static const String _androidTestRewarded = 'ca-app-pub-3940256099942544/5224354917';
  static const String _iosTestRewarded = 'ca-app-pub-3940256099942544/1712485313';

  final AdPolicyManager policyManager;
  final AnalyticsService? analytics;

  final String? customInterstitialUnitId;
  final String? customRewardedUnitId;

  final bool? isSupported;
  final ConnectivityService? connectivityService;
  final bool isProductionMode;

  bool _isInitialized = false;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  bool _isLoadingInterstitial = false;
  bool _isLoadingRewarded = false;

  AdMobAdService({
    AdPolicyManager? policyManager,
    int onboardingFreeLevels = AdPolicyManager.defaultOnboardingFreeLevels,
    Duration cooldownDuration = AdPolicyManager.defaultInterstitialCooldown,
    int levelFrequency = AdPolicyManager.defaultMinimumCompletedLevels,
    this.analytics,
    this.customInterstitialUnitId,
    this.customRewardedUnitId,
    this.isSupported,
    this.connectivityService,
    bool? isProductionMode,
  })  : policyManager = policyManager ??
            AdPolicyManager(
              onboardingFreeLevels: onboardingFreeLevels,
              cooldownDuration: cooldownDuration,
              levelFrequency: levelFrequency,
            ),
        isProductionMode = isProductionMode ??
            const bool.fromEnvironment('ADMOB_PRODUCTION_MODE', defaultValue: false);

  bool get _isMobilePlatform {
    if (isSupported != null) return isSupported!;
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  static const String _envInterstitial = String.fromEnvironment('ADMOB_INTERSTITIAL_ID');
  static const String _envRewarded = String.fromEnvironment('ADMOB_REWARDED_ID');

  String get interstitialAdUnitId {
    if (customInterstitialUnitId != null) return customInterstitialUnitId!;
    if (!kDebugMode && isProductionMode) {
      return _envInterstitial;
    }
    return defaultTargetPlatform == TargetPlatform.iOS
        ? _iosTestInterstitial
        : _androidTestInterstitial;
  }

  String get rewardedAdUnitId {
    if (customRewardedUnitId != null) return customRewardedUnitId!;
    if (!kDebugMode && isProductionMode) {
      return _envRewarded;
    }
    return defaultTargetPlatform == TargetPlatform.iOS
        ? _iosTestRewarded
        : _androidTestRewarded;
  }

  @override
  Future<void> initialize() async {
    if (!_isMobilePlatform) {
      debugPrint('[AdMobAdService] Non-mobile platform detected. Running in no-op mode.');
      _isInitialized = true;
      return;
    }

    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      debugPrint(
        '[AdMobAdService] Google Mobile Ads initialized successfully (productionMode: $isProductionMode).',
      );
      _loadInterstitialAd();
      _loadRewardedAd();
    } catch (e) {
      debugPrint('[AdMobAdService] Error initializing MobileAds: $e');
      _isInitialized = false;
    }
  }

  @override
  bool get isReady => _isInitialized && _interstitialAd != null;

  @override
  bool get isRewardedAdReady {
    if (!_isInitialized || !_isMobilePlatform) return true;
    return _rewardedAd != null;
  }

  @override
  Future<void> preloadRewardedAd() async {
    _loadRewardedAd();
  }

  void _loadInterstitialAd() {
    if (!_isMobilePlatform || !_isInitialized || _isLoadingInterstitial || _interstitialAd != null) return;
    if (interstitialAdUnitId.isEmpty) {
      debugPrint('[AdMobAdService] Interstitial ad unit ID is empty or unconfigured. Skipping load.');
      return;
    }
    _isLoadingInterstitial = true;

    try {
      InterstitialAd.load(
        adUnitId: interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialAd = ad;
            _isLoadingInterstitial = false;
            debugPrint('[AdMobAdService] Interstitial ad pre-loaded successfully.');
          },
          onAdFailedToLoad: (error) {
            _interstitialAd = null;
            _isLoadingInterstitial = false;
            debugPrint('[AdMobAdService] Failed to load interstitial ad: ${error.message} (code: ${error.code})');
          },
        ),
      );
    } catch (e) {
      _interstitialAd = null;
      _isLoadingInterstitial = false;
      debugPrint('[AdMobAdService] Exception during InterstitialAd.load: $e');
    }
  }

  Future<void> _loadRewardedAd() async {
    if (!_isMobilePlatform || !_isInitialized || _isLoadingRewarded || _rewardedAd != null) return;
    if (rewardedAdUnitId.isEmpty) {
      debugPrint('[AdMobAdService] Rewarded ad unit ID is empty or unconfigured. Skipping load.');
      return;
    }
    try {
      if (connectivityService != null) {
        final isOnline = await connectivityService!.hasInternetConnection();
        if (!isOnline) {
          debugPrint('[AdMobAdService] Device is offline. Skipping rewarded ad load.');
          return;
        }
      }
      if (_isLoadingRewarded || _rewardedAd != null) return;
      _isLoadingRewarded = true;

      RewardedAd.load(
        adUnitId: rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedAd = ad;
            _isLoadingRewarded = false;
            analytics?.logRewardedAdLoaded('rewarded_slot');
            debugPrint('[AdMobAdService] Rewarded ad pre-loaded successfully.');
          },
          onAdFailedToLoad: (error) {
            _rewardedAd = null;
            _isLoadingRewarded = false;
            analytics?.logRewardedAdFailed('rewarded_slot', error.message);
            debugPrint('[AdMobAdService] Failed to load rewarded ad: ${error.message} (code: ${error.code})');
          },
        ),
      );
    } catch (e) {
      _rewardedAd = null;
      _isLoadingRewarded = false;
      analytics?.logRewardedAdFailed('rewarded_slot', e.toString());
      debugPrint('[AdMobAdService] Exception during RewardedAd.load: $e');
    }
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

    // 1. Delegate frequency, cooldown, and Chapter 1 policy checks to AdPolicyManager
    if (!policyManager.canShowInterstitial(
      levelId: levelId,
      completedLevelCount: completedLevelCount,
      isSolvingActive: isSolvingActive,
      isLevelFailed: isLevelFailed,
      isAppLaunch: isAppLaunch,
    )) {
      return false;
    }

    // 2. Non-mobile platform or ad not cached check
    if (!_isMobilePlatform || _interstitialAd == null) {
      debugPrint('[AdMobAdService] Interstitial policy criteria met, but ad is not ready or platform is non-mobile.');
      _loadInterstitialAd();
      return false;
    }

    // 3. Present the interstitial ad
    final completer = Completer<bool>();
    final ad = _interstitialAd!;
    _interstitialAd = null;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        policyManager.recordInterstitialShown(
          levelId: levelId,
          completedLevelCount: completedLevelCount,
        );
        analytics?.logInterstitialShown(levelId);
        debugPrint('[AdMobAdService] Interstitial presented full screen.');
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('[AdMobAdService] Interstitial dismissed by user.');
        ad.dispose();
        _loadInterstitialAd();
        if (!completer.isCompleted) completer.complete(true);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        analytics?.logInterstitialFailed(levelId, error.message);
        debugPrint('[AdMobAdService] Interstitial failed to show: ${error.message}');
        ad.dispose();
        _loadInterstitialAd();
        if (!completer.isCompleted) completer.complete(false);
      },
    );

    try {
      await ad.show();
      return await completer.future;
    } catch (e) {
      analytics?.logInterstitialFailed(levelId, e.toString());
      debugPrint('[AdMobAdService] Exception showing interstitial: $e');
      _loadInterstitialAd();
      return false;
    }
  }

  @override
  Future<bool> showRewardedAd({
    required String placement,
    required VoidCallback onRewardEarned,
  }) async {
    analytics?.logRewardedAdRequested(placement);

    if (!_isInitialized || !_isMobilePlatform) {
      debugPrint('[AdMobAdService] Non-mobile or uninitialized environment. Running mock rewarded ad.');
      analytics?.logRewardedAdShown(placement);
      onRewardEarned();
      analytics?.logRewardedAdCompleted(placement);
      return true;
    }

    if (_rewardedAd == null) {
      debugPrint('[AdMobAdService] Rewarded ad not ready for "$placement".');
      analytics?.logRewardedAdFailed(placement, 'ad_not_ready');
      _loadRewardedAd();
      return false;
    }

    final completer = Completer<bool>();
    final ad = _rewardedAd!;
    _rewardedAd = null;
    bool userEarned = false;
    bool rewardDispatched = false;

    void dispatchRewardOnce() {
      if (!rewardDispatched && userEarned) {
        rewardDispatched = true;
        onRewardEarned();
        analytics?.logRewardedAdCompleted(placement);
      }
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        analytics?.logRewardedAdShown(placement);
        debugPrint('[AdMobAdService] Rewarded ad showed full screen.');
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('[AdMobAdService] Rewarded ad dismissed.');
        ad.dispose();
        _loadRewardedAd();
        dispatchRewardOnce();
        if (!completer.isCompleted) completer.complete(userEarned);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        analytics?.logRewardedAdFailed(placement, error.message);
        debugPrint('[AdMobAdService] Rewarded ad failed to show: ${error.message}');
        ad.dispose();
        _loadRewardedAd();
        if (!completer.isCompleted) completer.complete(false);
      },
    );

    try {
      await ad.show(onUserEarnedReward: (ad, reward) {
        debugPrint('[AdMobAdService] User earned reward: ${reward.amount} ${reward.type}');
        userEarned = true;
      });
      return await completer.future;
    } catch (e) {
      analytics?.logRewardedAdFailed(placement, e.toString());
      debugPrint('[AdMobAdService] Exception showing rewarded ad: $e');
      _loadRewardedAd();
      return false;
    }
  }

  void dispose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _interstitialAd = null;
    _rewardedAd = null;
  }
}
