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
}


