import 'package:flutter/foundation.dart';
import '../analytics/analytics_service.dart';
import '../connectivity/connectivity_service.dart';
import 'ad_service.dart';

/// Available monetization operating modes for Shift Puzzle.
enum MonetizationMode {
  /// Fast mock ads with deterministic completion. No real ad networks contacted.
  development,

  /// Google Mobile Ads with official Google test ad units. Safe for device QA.
  testAds,

  /// Direct APK / Sideload distribution mode.
  /// Native rewarded/interstitial ads run offline (NoOp), and an optional external
  /// SmartLink may be exposed without fake rewarded mechanics.
  bootstrap,

  /// Full Google Mobile Ads production mode intended for Google Play release.
  /// Requires explicit production configuration and non-debug builds.
  production,
}

/// Central configuration for Shift Puzzle monetization subsystem.
class MonetizationConfig {
  final MonetizationMode mode;
  final AdPolicyManager policyManager;
  final String? customInterstitialUnitId;
  final String? customRewardedUnitId;
  final String? bootstrapLinkUrl;

  const MonetizationConfig({
    required this.mode,
    required this.policyManager,
    this.customInterstitialUnitId,
    this.customRewardedUnitId,
    this.bootstrapLinkUrl,
  });

  /// Resolves configuration from environment variables and platform build modes.
  ///
  /// Environment Variables:
  /// - `MONETIZATION_MODE`: 'development' | 'testAds' / 'test_ads' | 'bootstrap' | 'production'
  /// - `BOOTSTRAP_AD_LINK`: External URL for bootstrap direct link promotion
  /// - `ADMOB_PRODUCTION_MODE`: 'true' | 'false'
  /// - `ADMOB_INTERSTITIAL_ID`: Production interstitial unit ID
  /// - `ADMOB_REWARDED_ID`: Production rewarded unit ID
  factory MonetizationConfig.fromEnvironment({
    AdPolicyManager? policyManager,
    int onboardingFreeLevels = AdPolicyManager.defaultOnboardingFreeLevels,
    Duration cooldownDuration = AdPolicyManager.defaultInterstitialCooldown,
    int levelFrequency = AdPolicyManager.defaultMinimumCompletedLevels,
  }) {
    const rawMode = String.fromEnvironment('MONETIZATION_MODE', defaultValue: '');
    const bootstrapLink = String.fromEnvironment(
      'BOOTSTRAP_AD_LINK',
      defaultValue: String.fromEnvironment(
        'ADSTERRA_SMARTLINK_URL',
        defaultValue: 'https://ardance.org/4/c70a9976026d7450e7919b3773152e55',
      ),
    );
    const isAdMobProd = bool.fromEnvironment('ADMOB_PRODUCTION_MODE', defaultValue: false);
    const prodInterstitial = String.fromEnvironment('ADMOB_INTERSTITIAL_ID', defaultValue: '');
    const prodRewarded = String.fromEnvironment('ADMOB_REWARDED_ID', defaultValue: '');

    final resolvedPolicy = policyManager ??
        AdPolicyManager(
          onboardingFreeLevels: onboardingFreeLevels,
          cooldownDuration: cooldownDuration,
          levelFrequency: levelFrequency,
        );

    final MonetizationMode resolvedMode;

    if (rawMode.isNotEmpty) {
      switch (rawMode.toLowerCase()) {
        case 'development':
        case 'dev':
        case 'mock':
          resolvedMode = MonetizationMode.development;
          break;
        case 'testads':
        case 'test_ads':
        case 'test':
          resolvedMode = MonetizationMode.testAds;
          break;
        case 'bootstrap':
        case 'sideload':
        case 'apk':
          resolvedMode = MonetizationMode.bootstrap;
          break;
        case 'production':
        case 'prod':
          // Safety guard: Never allow production ad mode during debug builds
          resolvedMode = kDebugMode ? MonetizationMode.testAds : MonetizationMode.production;
          break;
        default:
          resolvedMode = kDebugMode ? MonetizationMode.development : MonetizationMode.bootstrap;
      }
    } else {
      // Default resolution when MONETIZATION_MODE is unset:
      if (kDebugMode) {
        resolvedMode = MonetizationMode.development;
      } else if (isAdMobProd) {
        resolvedMode = MonetizationMode.production;
      } else {
        // Direct APK release default
        resolvedMode = MonetizationMode.bootstrap;
      }
    }

    return MonetizationConfig(
      mode: resolvedMode,
      policyManager: resolvedPolicy,
      customInterstitialUnitId: prodInterstitial.isNotEmpty ? prodInterstitial : null,
      customRewardedUnitId: prodRewarded.isNotEmpty ? prodRewarded : null,
      bootstrapLinkUrl: bootstrapLink.isNotEmpty ? bootstrapLink : null,
    );
  }

  /// Instantiates the appropriate [AdService] based on the active [mode].
  AdService createAdService({
    AnalyticsService? analytics,
    ConnectivityService? connectivityService,
    BootstrapUrlLauncher? urlLauncher,
  }) {
    switch (mode) {
      case MonetizationMode.development:
        debugPrint('[MonetizationConfig] Creating DevelopmentAdService (mock mode).');
        return DevelopmentAdService(
          policyManager: policyManager,
          analytics: analytics,
        );

      case MonetizationMode.testAds:
        debugPrint('[MonetizationConfig] Creating AdMobAdService in official test-ads mode.');
        return AdMobAdService(
          policyManager: policyManager,
          analytics: analytics,
          connectivityService: connectivityService,
          isProductionMode: false,
        );

      case MonetizationMode.bootstrap:
        debugPrint(
          '[MonetizationConfig] Creating BootstrapAdService (direct APK distribution mode).',
        );
        return BootstrapAdService(
          innerAdService: NoOpAdService(policyManager: policyManager),
          bootstrapLinkUrl: bootstrapLinkUrl,
          urlLauncher: urlLauncher,
          analytics: analytics,
        );

      case MonetizationMode.production:
        debugPrint(
          '[MonetizationConfig] Creating AdMobAdService in PRODUCTION mode (Google Play release).',
        );
        return AdMobAdService(
          policyManager: policyManager,
          analytics: analytics,
          connectivityService: connectivityService,
          isProductionMode: true,
          customInterstitialUnitId: customInterstitialUnitId,
          customRewardedUnitId: customRewardedUnitId,
        );
    }
  }
}
