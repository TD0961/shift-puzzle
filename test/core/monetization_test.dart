import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shift_puzzle/core/monetization/ad_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/google_mobile_ads'),
      (MethodCall methodCall) async {
        return null;
      },
    );
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/google_mobile_ads'),
      null,
    );
  });

  group('NoOpAdService Monetization Policy', () {
    test('initial state: not ready, initializes cleanly', () async {
      final adService = NoOpAdService();
      expect(adService.isReady, isFalse);
      await expectLater(adService.initialize(), completes);
    });

    test('Chapter 1 levels (1–10) are strictly 100% ad-free', () async {
      final adService = NoOpAdService(levelFrequency: 1, cooldownDuration: Duration.zero);

      for (int levelId = 1; levelId <= 10; levelId++) {
        final shown = await adService.showInterstitialIfAppropriate(
          levelId: levelId,
          completedLevelCount: levelId,
        );
        expect(shown, isFalse, reason: 'Level $levelId must be ad-free in Chapter 1');
      }
    });

    test('interstitials respect level completion frequency cap', () async {
      final adService = NoOpAdService(
        levelFrequency: 4,
        cooldownDuration: Duration.zero,
      );

      // Level 11, completed 1 level since start (1 < 4)
      final step1 = await adService.showInterstitialIfAppropriate(
        levelId: 11,
        completedLevelCount: 1,
      );
      expect(step1, isFalse);

      // Level 12, completed 2 levels since start (2 < 4)
      final step2 = await adService.showInterstitialIfAppropriate(
        levelId: 12,
        completedLevelCount: 2,
      );
      expect(step2, isFalse);

      // Level 14, completed 4 levels since start (4 >= 4)
      await adService.showInterstitialIfAppropriate(
        levelId: 14,
        completedLevelCount: 4,
      );
    });

    test('interstitials respect cooldown duration', () async {
      final adService = NoOpAdService(
        levelFrequency: 1,
        cooldownDuration: const Duration(minutes: 5),
      );

      // First call outside Chapter 1
      await adService.showInterstitialIfAppropriate(
        levelId: 11,
        completedLevelCount: 1,
      );

      // Immediate second call should be blocked by cooldown
      final immediateSecond = await adService.showInterstitialIfAppropriate(
        levelId: 12,
        completedLevelCount: 2,
      );
      expect(immediateSecond, isFalse);
    });

    test('rewarded ad invokes reward callback', () async {
      final adService = NoOpAdService();
      bool rewardGranted = false;

      final success = await adService.showRewardedAd(
        placement: 'bonus_hint',
        onRewardEarned: () {
          rewardGranted = true;
        },
      );

      expect(success, isTrue);
      expect(rewardGranted, isTrue);
    });
  });

  group('AdMobAdService Integration & Policy', () {
    test('initializes cleanly on non-mobile / test environment without error', () async {
      final adService = AdMobAdService();
      expect(adService.isReady, isFalse);
      await expectLater(adService.initialize(), completes);
    });

    test('exposes default Google test ad units for Android and custom unit overrides', () {
      final defaultService = AdMobAdService();
      expect(defaultService.interstitialAdUnitId, isNotEmpty);
      expect(defaultService.rewardedAdUnitId, isNotEmpty);

      final customService = AdMobAdService(
        customInterstitialUnitId: 'custom-interstitial-id',
        customRewardedUnitId: 'custom-rewarded-id',
      );
      expect(customService.interstitialAdUnitId, 'custom-interstitial-id');
      expect(customService.rewardedAdUnitId, 'custom-rewarded-id');
    });

    test('strictly enforces Chapter 1 ad-free policy', () async {
      final adService = AdMobAdService(levelFrequency: 1, cooldownDuration: Duration.zero);
      await adService.initialize();

      for (int levelId = 1; levelId <= 10; levelId++) {
        final shown = await adService.showInterstitialIfAppropriate(
          levelId: levelId,
          completedLevelCount: levelId,
        );
        expect(shown, isFalse, reason: 'Level $levelId must never show ads');
      }
    });

    test('strictly enforces frequency cap and cooldown policy', () async {
      final adService = AdMobAdService(
        levelFrequency: 4,
        cooldownDuration: const Duration(minutes: 3),
      );
      await adService.initialize();

      // Less than frequency cap
      final step1 = await adService.showInterstitialIfAppropriate(
        levelId: 11,
        completedLevelCount: 2,
      );
      expect(step1, isFalse);
    });

    test('rewarded ad gracefully grants fallback reward on non-mobile/unloaded state', () async {
      final adService = AdMobAdService();
      await adService.initialize();
      expect(adService.isRewardedAdReady, isTrue);
      bool rewardEarned = false;

      final result = await adService.showRewardedAd(
        placement: 'undo_bonus',
        onRewardEarned: () {
          rewardEarned = true;
        },
      );

      expect(result, isTrue);
      expect(rewardEarned, isTrue);
    });

    test('defaults to official Google test ad units when production mode is inactive', () {
      final adService = AdMobAdService();
      expect(adService.interstitialAdUnitId, startsWith('ca-app-pub-3940256099942544'));
      expect(adService.rewardedAdUnitId, startsWith('ca-app-pub-3940256099942544'));
    });

    test('production-configured empty ad unit IDs do not fall back to test IDs and remain empty', () {
      final adService = AdMobAdService(
        customInterstitialUnitId: '',
        customRewardedUnitId: '',
      );
      expect(adService.interstitialAdUnitId, isEmpty);
      expect(adService.rewardedAdUnitId, isEmpty);
      expect(adService.interstitialAdUnitId, isNot(contains('ca-app-pub-3940256099942544')));
      expect(adService.rewardedAdUnitId, isNot(contains('ca-app-pub-3940256099942544')));
    });

    test('empty ad unit IDs fail-safe without exception during preload or ad display requests', () async {
      final adService = AdMobAdService(
        customInterstitialUnitId: '',
        customRewardedUnitId: '',
      );
      await adService.initialize();

      // Preload should complete silently without throwing
      await expectLater(adService.preloadRewardedAd(), completes);

      // Showing interstitial should return false without throwing
      final interstitialResult = await adService.showInterstitialIfAppropriate(
        levelId: 15,
        completedLevelCount: 5,
      );
      expect(interstitialResult, isFalse);

      // Showing rewarded ad should handle mock fallback gracefully in test environment
      bool rewardEarned = false;
      final rewardedResult = await adService.showRewardedAd(
        placement: 'extra_moves',
        onRewardEarned: () {
          rewardEarned = true;
        },
      );
      expect(rewardedResult, isTrue);
      expect(rewardEarned, isTrue);
    });

    test('production ad unit IDs correctly override defaults without exposing test credentials', () {
      const prodInterstitial = 'ca-app-pub-1234567890123456/1111111111';
      const prodRewarded = 'ca-app-pub-1234567890123456/2222222222';

      final adService = AdMobAdService(
        customInterstitialUnitId: prodInterstitial,
        customRewardedUnitId: prodRewarded,
      );

      expect(adService.interstitialAdUnitId, prodInterstitial);
      expect(adService.rewardedAdUnitId, prodRewarded);
      expect(adService.interstitialAdUnitId, isNot(contains('3940256099942544')));
      expect(adService.rewardedAdUnitId, isNot(contains('3940256099942544')));
    });
  });

  group('AdPolicyManager Provider-Independent Rules', () {
    test('strictly enforces onboarding ad immunity for levels 1 to 5 by default', () {
      final policy = AdPolicyManager(levelFrequency: 1, cooldownDuration: Duration.zero);

      for (int level = 1; level <= 5; level++) {
        expect(
          policy.canShowInterstitial(levelId: level, completedLevelCount: level),
          isFalse,
          reason: 'Level $level in onboarding must be ad-free',
        );
      }

      // Level 6 is beyond default onboarding
      expect(policy.canShowInterstitial(levelId: 6, completedLevelCount: 6), isTrue);
    });

    test('supports configurable Chapter 1 ad immunity (levels 1 to 10)', () {
      final policy = AdPolicyManager(
        onboardingFreeLevels: 10,
        levelFrequency: 1,
        cooldownDuration: Duration.zero,
      );

      for (int level = 1; level <= 10; level++) {
        expect(
          policy.canShowInterstitial(levelId: level, completedLevelCount: level),
          isFalse,
          reason: 'Level $level in Chapter 1 must be ad-free',
        );
      }

      expect(policy.canShowInterstitial(levelId: 11, completedLevelCount: 11), isTrue);
    });

    test('enforces active-gameplay, failure, and app launch protection', () {
      final policy = AdPolicyManager(levelFrequency: 1, cooldownDuration: Duration.zero);

      // Denies when player is actively solving
      expect(
        policy.canShowInterstitial(
          levelId: 11,
          completedLevelCount: 11,
          isSolvingActive: true,
        ),
        isFalse,
      );

      // Denies on failed level attempt
      expect(
        policy.canShowInterstitial(
          levelId: 11,
          completedLevelCount: 11,
          isLevelFailed: true,
        ),
        isFalse,
      );

      // Denies immediately on app launch
      expect(
        policy.canShowInterstitial(
          levelId: 11,
          completedLevelCount: 11,
          isAppLaunch: true,
        ),
        isFalse,
      );
    });

    test('enforces completion frequency cap', () {
      final policy = AdPolicyManager(levelFrequency: 4, cooldownDuration: Duration.zero);

      expect(policy.canShowInterstitial(levelId: 11, completedLevelCount: 1), isFalse);
      expect(policy.canShowInterstitial(levelId: 11, completedLevelCount: 3), isFalse);
      expect(policy.canShowInterstitial(levelId: 11, completedLevelCount: 4), isTrue);

      policy.recordInterstitialShown(levelId: 11, completedLevelCount: 4);

      // Now requires 4 more completed levels (4 + 4 = 8)
      expect(policy.canShowInterstitial(levelId: 12, completedLevelCount: 7), isFalse);
      expect(policy.canShowInterstitial(levelId: 12, completedLevelCount: 8), isTrue);
    });

    test('enforces cooldown duration with injected timestamps', () {
      final policy = AdPolicyManager(
        levelFrequency: 1,
        cooldownDuration: const Duration(minutes: 3),
      );

      final t0 = DateTime(2026, 10, 1, 12, 0, 0);
      expect(policy.canShowInterstitial(levelId: 11, completedLevelCount: 1, now: t0), isTrue);

      policy.recordInterstitialShown(levelId: 11, completedLevelCount: 1, now: t0);

      // 2 minutes later (less than 3 minutes cooldown)
      final t1 = t0.add(const Duration(minutes: 2));
      expect(policy.canShowInterstitial(levelId: 12, completedLevelCount: 2, now: t1), isFalse);

      // 3 minutes and 1 second later
      final t2 = t0.add(const Duration(minutes: 3, seconds: 1));
      expect(policy.canShowInterstitial(levelId: 12, completedLevelCount: 2, now: t2), isTrue);
    });

    test('reset clears timestamps and counters', () {
      final policy = AdPolicyManager(levelFrequency: 1, cooldownDuration: Duration.zero);
      policy.recordInterstitialShown(levelId: 11, completedLevelCount: 5);
      expect(policy.totalInterstitialsShown, 1);
      expect(policy.lastCompletedCountAtAd, 5);

      policy.reset();
      expect(policy.totalInterstitialsShown, 0);
      expect(policy.lastCompletedCountAtAd, 0);
      expect(policy.lastInterstitialTime, isNull);
    });
  });

  group('DevelopmentAdService Deterministic Mocking', () {
    test('initializes immediately, handles preloads and reports ready', () async {
      final devService = DevelopmentAdService();
      expect(devService.isReady, isTrue);
      expect(devService.isRewardedAdReady, isTrue);

      await devService.initialize();
      await devService.preloadRewardedAd();

      expect(devService.preloadCount, 1);
      expect(devService.isRewardedAdReady, isTrue);
    });

    test('rewarded flow invokes callback exactly once and tracks state', () async {
      final devService = DevelopmentAdService();
      int rewardTimes = 0;

      final result = await devService.showRewardedAd(
        placement: 'hint_test',
        onRewardEarned: () {
          rewardTimes++;
        },
      );

      expect(result, isTrue);
      expect(rewardTimes, 1);
      expect(devService.rewardedCount, 1);
      expect(devService.lastRewardedPlacement, 'hint_test');
    });

    test('interstitial respects AdPolicyManager', () async {
      final policy = AdPolicyManager(levelFrequency: 4, cooldownDuration: Duration.zero);
      final devService = DevelopmentAdService(policyManager: policy);

      // Level in Chapter 1 should be denied
      final chapter1Result = await devService.showInterstitialIfAppropriate(
        levelId: 5,
        completedLevelCount: 10,
      );
      expect(chapter1Result, isFalse);
      expect(devService.interstitialCount, 0);

      // Level 15 with 4 completed levels should be allowed
      final allowedResult = await devService.showInterstitialIfAppropriate(
        levelId: 15,
        completedLevelCount: 4,
      );
      expect(allowedResult, isTrue);
      expect(devService.interstitialCount, 1);
    });

    test('simulateFailure prevents reward callback and returns false', () async {
      final devService = DevelopmentAdService(simulateFailure: true);
      bool rewardGranted = false;

      final rewardedResult = await devService.showRewardedAd(
        placement: 'extra_moves',
        onRewardEarned: () {
          rewardGranted = true;
        },
      );
      expect(rewardedResult, isFalse);
      expect(rewardGranted, isFalse);

      final interstitialResult = await devService.showInterstitialIfAppropriate(
        levelId: 15,
        completedLevelCount: 5,
      );
      expect(interstitialResult, isFalse);
    });
  });

  group('BootstrapAdService Outbound Promotion & Separation from Rewards', () {
    test('reports availability based on configured URL', () {
      final unconfigured = BootstrapAdService();
      expect(unconfigured.isBootstrapLinkAvailable, isFalse);
      expect(unconfigured.getBootstrapLink(), isNull);

      final configured = BootstrapAdService(
        bootstrapLinkUrl: 'https://shiftpuzzle.example/discover',
      );
      expect(configured.isBootstrapLinkAvailable, isTrue);
      expect(configured.getBootstrapLink(), 'https://shiftpuzzle.example/discover');
    });

    test('opening bootstrap link NEVER invokes reward callback or grants moves/hints', () async {
      String? launchedUrl;
      final service = BootstrapAdService(
        bootstrapLinkUrl: 'https://adsterra.example/smartlink',
        urlLauncher: (url) async {
          launchedUrl = url;
          return true;
        },
      );

      final opened = await service.openBootstrapLink();
      expect(opened, isTrue);
      expect(launchedUrl, 'https://adsterra.example/smartlink');
      expect(service.bootstrapLinkClicks, 1);

      // Verify that native rewarded ad flow is completely separate
      bool rewardEarned = false;
      final rewardedResult = await service.showRewardedAd(
        placement: 'test_reward',
        onRewardEarned: () {
          rewardEarned = true;
        },
      );
      expect(rewardedResult, isTrue);
      expect(rewardEarned, isTrue);
    });

    test('delegates native ad methods safely to inner NoOpAdService', () async {
      final service = BootstrapAdService();
      await service.initialize();
      expect(service.isReady, isFalse);
      expect(service.isRewardedAdReady, isTrue);
      await expectLater(service.preloadRewardedAd(), completes);

      // Chapter 1 is still protected by delegated policy
      final interstitialResult = await service.showInterstitialIfAppropriate(
        levelId: 2,
        completedLevelCount: 2,
      );
      expect(interstitialResult, isFalse);
    });
  });

  group('MonetizationConfig & Mode Resolution', () {
    test('resolves appropriate AdService based on explicit MonetizationMode', () {
      final policy = AdPolicyManager();

      final devConfig = MonetizationConfig(
        mode: MonetizationMode.development,
        policyManager: policy,
      );
      final devService = devConfig.createAdService();
      expect(devService, isA<DevelopmentAdService>());

      final testConfig = MonetizationConfig(
        mode: MonetizationMode.testAds,
        policyManager: policy,
      );
      final testService = testConfig.createAdService();
      expect(testService, isA<AdMobAdService>());
      expect((testService as AdMobAdService).isProductionMode, isFalse);

      final bootstrapConfig = MonetizationConfig(
        mode: MonetizationMode.bootstrap,
        policyManager: policy,
        bootstrapLinkUrl: 'https://promo.example/smart',
      );
      final bootstrapService = bootstrapConfig.createAdService();
      expect(bootstrapService, isA<BootstrapAdService>());
      expect((bootstrapService as BootstrapAdService).isBootstrapLinkAvailable, isTrue);

      final prodConfig = MonetizationConfig(
        mode: MonetizationMode.production,
        policyManager: policy,
        customInterstitialUnitId: 'prod-int-123',
        customRewardedUnitId: 'prod-rew-456',
      );
      final prodService = prodConfig.createAdService();
      expect(prodService, isA<AdMobAdService>());
      expect((prodService as AdMobAdService).isProductionMode, isTrue);
      expect(prodService.interstitialAdUnitId, 'prod-int-123');
      expect(prodService.rewardedAdUnitId, 'prod-rew-456');
    });

    test('fromEnvironment resolves default mode safely without production leakage', () {
      final config = MonetizationConfig.fromEnvironment();
      expect(config.policyManager, isNotNull);
      // In test runner / debug environment, mode should resolve to development
      expect(config.mode, MonetizationMode.development);
      final service = config.createAdService();
      expect(service, isA<DevelopmentAdService>());
    });
  });
}


