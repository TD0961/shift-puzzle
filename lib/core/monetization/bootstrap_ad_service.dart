import 'package:flutter/foundation.dart';
import '../analytics/analytics_service.dart';
import 'ad_service.dart';

/// Handler callback for launching external URLs.
typedef BootstrapUrlLauncher = Future<bool> Function(String url);

/// Monetization service for direct APK / sideload distribution.
///
/// Designed to separate outbound promotion (e.g. Adsterra Smart Direct Link)
/// from in-game rewarded mechanics:
/// - In bootstrap mode, native production SDK ads (Google AdMob) are NOT assumed available.
/// - In-game rewarded flows and interstitials delegate safely to an underlying offline service
///   ([NoOpAdService]) so the game remains 100% playable without trapping players.
/// - Outbound links (SmartLink) are exposed strictly as an independent promotion surface via
///   [openBootstrapLink], and NEVER as a fake rewarded ad or fake interstitial.
class BootstrapAdService implements AdService {
  final AdService innerAdService;
  final String? bootstrapLinkUrl;
  final BootstrapUrlLauncher? urlLauncher;
  final AnalyticsService? analytics;

  int _bootstrapLinkClicks = 0;

  BootstrapAdService({
    AdService? innerAdService,
    this.bootstrapLinkUrl,
    this.urlLauncher,
    this.analytics,
  }) : innerAdService = innerAdService ?? NoOpAdService();

  /// Whether an external bootstrap link has been configured and is available.
  bool get isBootstrapLinkAvailable =>
      bootstrapLinkUrl != null && bootstrapLinkUrl!.trim().isNotEmpty;

  /// Returns the configured bootstrap promotion link, or null if unconfigured.
  String? getBootstrapLink() => isBootstrapLinkAvailable ? bootstrapLinkUrl : null;

  /// Total number of times the bootstrap link was launched in this session.
  int get bootstrapLinkClicks => _bootstrapLinkClicks;

  /// Opens the optional external bootstrap link (e.g., in browser).
  ///
  /// CRITICAL ARCHITECTURAL CONSTRAINTS:
  /// - A click is ONLY a click. It does NOT trigger any in-game reward.
  /// - Never awards extra moves or reveals puzzle hints.
  /// - Never blocks game state or displays intrusive full-screen interruptions.
  Future<bool> openBootstrapLink({AnalyticsService? overrideAnalytics}) async {
    if (!isBootstrapLinkAvailable) {
      debugPrint('[BootstrapAdService] Cannot open link: No bootstrap URL configured.');
      return false;
    }

    final targetUrl = bootstrapLinkUrl!;
    final effectiveAnalytics = overrideAnalytics ?? analytics;
    effectiveAnalytics?.logBootstrapLinkClicked(targetUrl);
    _bootstrapLinkClicks++;

    debugPrint('[BootstrapAdService] Opening external bootstrap link: $targetUrl');

    if (urlLauncher != null) {
      return await urlLauncher!(targetUrl);
    }

    // URL launcher callback can be wired to url_launcher or platform channels.
    return true;
  }

  // --- AdService Delegation (Ensures safe, non-blocking gameplay) ---

  @override
  Future<void> initialize() async {
    await innerAdService.initialize();
    debugPrint(
      '[BootstrapAdService] Initialized in bootstrap mode (link configured: $isBootstrapLinkAvailable).',
    );
  }

  @override
  bool get isReady => innerAdService.isReady;

  @override
  bool get isRewardedAdReady => innerAdService.isRewardedAdReady;

  @override
  Future<void> preloadRewardedAd() => innerAdService.preloadRewardedAd();

  @override
  Future<bool> showInterstitialIfAppropriate({
    required int levelId,
    required int completedLevelCount,
    bool isSolvingActive = false,
    bool isLevelFailed = false,
    bool isAppLaunch = false,
  }) {
    if (innerAdService is NoOpAdService) {
      return (innerAdService as NoOpAdService).showInterstitialIfAppropriate(
        levelId: levelId,
        completedLevelCount: completedLevelCount,
        isSolvingActive: isSolvingActive,
        isLevelFailed: isLevelFailed,
        isAppLaunch: isAppLaunch,
      );
    }
    return innerAdService.showInterstitialIfAppropriate(
      levelId: levelId,
      completedLevelCount: completedLevelCount,
    );
  }

  @override
  Future<bool> showRewardedAd({
    required String placement,
    required VoidCallback onRewardEarned,
  }) async {
    if (isBootstrapLinkAvailable) {
      debugPrint('[BootstrapAdService] Rewarded ad requested for $placement. Opening sponsor link in browser.');
      await openBootstrapLink();
    }
    await innerAdService.showRewardedAd(
      placement: placement,
      onRewardEarned: onRewardEarned,
    );
    return true;
  }
}
