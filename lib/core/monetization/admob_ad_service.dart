import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../connectivity/connectivity_service.dart';
import 'ad_service.dart';

/// Production-ready AdMob implementation of [AdService].
///
/// Features:
/// - Official Google Mobile Ads SDK integration.
/// - Official Google test ad units during development/testing.
/// - Strict player policy enforcement (Chapter 1 ad-free, 4-level frequency cap, 3-minute cooldown).
/// - Non-intrusive: never displays ads during active gameplay or board interaction.
/// - Fail-safe: ad load or presentation failures never block puzzle flow or crash the app.
/// - Graceful fallback on non-mobile platforms (Web/Desktop/Testing).
class AdMobAdService implements AdService {
  // Official Google AdMob Test Ad Unit IDs
  static const String _androidTestInterstitial = 'ca-app-pub-3940256099942544/1033173712';
  static const String _iosTestInterstitial = 'ca-app-pub-3940256099942544/4411468910';
  static const String _androidTestRewarded = 'ca-app-pub-3940256099942544/5224354917';
  static const String _iosTestRewarded = 'ca-app-pub-3940256099942544/1712485313';

  final Duration cooldownDuration;
  final int levelFrequency;

  final String? customInterstitialUnitId;
  final String? customRewardedUnitId;

  DateTime? _lastInterstitialTime;
  int _lastCompletedCountAtAd = 0;

  bool _isInitialized = false;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  bool _isLoadingInterstitial = false;
  bool _isLoadingRewarded = false;

  final bool? isSupported;
  final ConnectivityService? connectivityService;

  AdMobAdService({
    this.cooldownDuration = const Duration(seconds: 180),
    this.levelFrequency = 4,
    this.customInterstitialUnitId,
    this.customRewardedUnitId,
    this.isSupported,
    this.connectivityService,
  });

  bool get _isMobilePlatform {
    if (isSupported != null) return isSupported!;
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  /// Production AdMob Ad Unit IDs injected via `--dart-define` or `--dart-define-from-file`.
  /// Production ads are strictly locked behind [ADMOB_PRODUCTION_MODE=true] and [!kDebugMode].
  static const String _envInterstitial = String.fromEnvironment('ADMOB_INTERSTITIAL_ID');
  static const String _envRewarded = String.fromEnvironment('ADMOB_REWARDED_ID');
  static const bool _isProductionMode = bool.fromEnvironment('ADMOB_PRODUCTION_MODE', defaultValue: false);

  String get interstitialAdUnitId {
    if (customInterstitialUnitId != null) return customInterstitialUnitId!;
    if (!kDebugMode && _isProductionMode && _envInterstitial.isNotEmpty) {
      return _envInterstitial;
    }
    return defaultTargetPlatform == TargetPlatform.iOS
        ? _iosTestInterstitial
        : _androidTestInterstitial;
  }

  String get rewardedAdUnitId {
    if (customRewardedUnitId != null) return customRewardedUnitId!;
    if (!kDebugMode && _isProductionMode && _envRewarded.isNotEmpty) {
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
      debugPrint('[AdMobAdService] Google Mobile Ads initialized successfully.');
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

  void _loadRewardedAd() async {
    if (!_isMobilePlatform || !_isInitialized || _isLoadingRewarded || _rewardedAd != null) return;
    if (connectivityService != null) {
      final isOnline = await connectivityService!.hasInternetConnection();
      if (!isOnline) {
        debugPrint('[AdMobAdService] Device is offline. Skipping rewarded ad load.');
        return;
      }
    }
    if (_isLoadingRewarded || _rewardedAd != null) return;
    _isLoadingRewarded = true;

    try {
      RewardedAd.load(
        adUnitId: rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedAd = ad;
            _isLoadingRewarded = false;
            debugPrint('[AdMobAdService] Rewarded ad pre-loaded successfully.');
          },
          onAdFailedToLoad: (error) {
            _rewardedAd = null;
            _isLoadingRewarded = false;
            debugPrint('[AdMobAdService] Failed to load rewarded ad: ${error.message} (code: ${error.code})');
          },
        ),
      );
    } catch (e) {
      _rewardedAd = null;
      _isLoadingRewarded = false;
      debugPrint('[AdMobAdService] Exception during RewardedAd.load: $e');
    }
  }

  @override
  Future<bool> showInterstitialIfAppropriate({
    required int levelId,
    required int completedLevelCount,
  }) async {
    // 1. Chapter 1 (Levels 1–10) is strictly 100% ad-free
    if (levelId <= 10) {
      debugPrint('[AdMobAdService] Interstitial skipped: Level $levelId is in Chapter 1.');
      return false;
    }

    // 2. Frequency check (e.g. at least 4 levels completed since last ad)
    final levelsSinceLastAd = completedLevelCount - _lastCompletedCountAtAd;
    if (levelsSinceLastAd < levelFrequency) {
      debugPrint(
        '[AdMobAdService] Interstitial skipped: $levelsSinceLastAd/$levelFrequency levels completed since last ad.',
      );
      return false;
    }

    // 3. Time cooldown check (e.g. at least 3 minutes between ads)
    final now = DateTime.now();
    if (_lastInterstitialTime != null &&
        now.difference(_lastInterstitialTime!) < cooldownDuration) {
      debugPrint('[AdMobAdService] Interstitial skipped: Cooldown active.');
      return false;
    }

    // 4. Non-mobile platform check
    if (!_isMobilePlatform || _interstitialAd == null) {
      debugPrint('[AdMobAdService] Interstitial policy criteria met, but ad is not ready or platform is non-mobile.');
      _loadInterstitialAd();
      return false;
    }

    // 5. Present the interstitial ad
    final completer = Completer<bool>();
    final ad = _interstitialAd!;
    _interstitialAd = null;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint('[AdMobAdService] Interstitial presented full screen.');
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('[AdMobAdService] Interstitial dismissed by user.');
        ad.dispose();
        _lastInterstitialTime = DateTime.now();
        _lastCompletedCountAtAd = completedLevelCount;
        _loadInterstitialAd();
        if (!completer.isCompleted) completer.complete(true);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
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
    if (!_isInitialized || !_isMobilePlatform) {
      debugPrint('[AdMobAdService] Non-mobile or uninitialized environment. Running mock rewarded ad.');
      onRewardEarned();
      return true;
    }

    if (_rewardedAd == null) {
      debugPrint('[AdMobAdService] Rewarded ad not ready for "$placement".');
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
      }
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
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
      debugPrint('[AdMobAdService] Exception showing rewarded ad: $e');
      _loadRewardedAd();
      return false;
    }
  }
}
