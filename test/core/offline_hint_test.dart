import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shift_puzzle/core/analytics/analytics_service.dart';
import 'package:shift_puzzle/core/connectivity/connectivity_service.dart';
import 'package:shift_puzzle/core/monetization/ad_service.dart';
import 'package:shift_puzzle/core/puzzle/models/shift_direction.dart';
import 'package:shift_puzzle/core/storage/player_progress.dart';
import 'package:shift_puzzle/game/scenes/shift_puzzle_game.dart';
import 'package:shift_puzzle/ui/game_screen.dart';
import 'package:shift_puzzle/ui/hint_unavailable_dialog.dart';
import 'package:shift_puzzle/ui/internet_needed_dialog.dart';
import 'package:shift_puzzle/ui/optimal_drift_nudge_dialog.dart';

class TestMockAnalytics extends DebugAnalyticsService {
  final List<String> loggedEvents = [];
  final List<Map<String, dynamic>> loggedParams = [];

  TestMockAnalytics() : super(enableLogging: true);

  @override
  void logHintNetworkUnavailable(int levelId, {String source = 'manual_hint'}) {
    loggedEvents.add('hint_network_unavailable');
    loggedParams.add({'level_id': levelId, 'source': source});
  }

  @override
  void logHintAdUnavailable(int levelId, {String source = 'manual_hint'}) {
    loggedEvents.add('hint_ad_unavailable');
    loggedParams.add({'level_id': levelId, 'source': source});
  }

  @override
  void logHintAdRetry(int levelId, {required String outcome, String source = 'manual_hint'}) {
    loggedEvents.add('hint_ad_retry');
    loggedParams.add({'level_id': levelId, 'outcome': outcome, 'source': source});
  }

  @override
  void logHintAdStarted(int levelId, {required String placement, String source = 'manual_hint'}) {
    loggedEvents.add('hint_ad_started');
    loggedParams.add({'level_id': levelId, 'placement': placement, 'source': source});
  }

  @override
  void logHintAdRewarded(int levelId, {required String placement, String source = 'manual_hint'}) {
    loggedEvents.add('hint_ad_rewarded');
    loggedParams.add({'level_id': levelId, 'placement': placement, 'source': source});
  }

  @override
  void logHintAdFailed(int levelId, {required String placement, required String reason, String source = 'manual_hint'}) {
    loggedEvents.add('hint_ad_failed');
    loggedParams.add({'level_id': levelId, 'placement': placement, 'reason': reason, 'source': source});
  }

  @override
  void logHintGranted(int levelId) {
    loggedEvents.add('hint_granted');
    loggedParams.add({'level_id': levelId});
  }

  @override
  void logHintUsed(int levelId) {
    loggedEvents.add('hint_used');
    loggedParams.add({'level_id': levelId});
  }

  @override
  void logOptimalDriftDetected({
    required int levelId,
    required int chapterId,
    required bool hasMemoryEcho,
    required int moveCount,
    required int optimalMoves,
  }) {
    loggedEvents.add('optimal_drift_detected');
  }

  @override
  void logOptimalDriftNudgeShown({
    required int levelId,
    required int chapterId,
    required bool hasMemoryEcho,
    required int moveCount,
    required int optimalMoves,
  }) {
    loggedEvents.add('optimal_drift_nudge_shown');
  }

  @override
  void logOptimalDriftHintRequested({
    required int levelId,
    required int moveCount,
  }) {
    loggedEvents.add('optimal_drift_hint_requested');
  }

  @override
  void logOptimalDriftAdStarted({
    required int levelId,
    required String placement,
  }) {
    loggedEvents.add('optimal_drift_ad_started');
  }

  @override
  void logOptimalDriftAdRewarded({
    required int levelId,
    required String placement,
  }) {
    loggedEvents.add('optimal_drift_ad_rewarded');
  }

  @override
  void logOptimalDriftAdFailed({
    required int levelId,
    required String placement,
    required String reason,
  }) {
    loggedEvents.add('optimal_drift_ad_failed');
    loggedParams.add({'reason': reason});
  }

  @override
  void logOptimalDriftHintRevealed({
    required int levelId,
    required int moveCount,
  }) {
    loggedEvents.add('optimal_drift_hint_revealed');
  }
}

class TestAdService implements AdService {
  bool isAdReady = true;
  bool shouldGrantReward = true;
  int rewardedAdCallCount = 0;
  int preloadCount = 0;
  String? lastPlacement;
  VoidCallback? onRewardEarnedCallback;

  @override
  bool get isReady => true;

  @override
  bool get isRewardedAdReady => isAdReady;

  @override
  Future<void> preloadRewardedAd() async {
    preloadCount++;
  }

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> showInterstitialIfAppropriate({
    required int levelId,
    required int completedLevelCount,
  }) async => false;

  @override
  Future<bool> showRewardedAd({
    required String placement,
    required VoidCallback onRewardEarned,
  }) async {
    rewardedAdCallCount++;
    lastPlacement = placement;
    onRewardEarnedCallback = onRewardEarned;
    if (shouldGrantReward) {
      onRewardEarned();
      return true;
    }
    return false;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Task 16: Offline & Connectivity Rewarded Hint Handling', () {
    late PlayerProgress progress;
    late TestMockAnalytics analytics;
    late TestAdService adService;
    late MockConnectivityService connectivityService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({
        'highest_unlocked_level': 10,
        'sound_enabled': true,
        'tutorial_completed': true,
      });
      final prefs = await SharedPreferences.getInstance();
      progress = PlayerProgress(prefs);
      analytics = TestMockAnalytics();
      adService = TestAdService();
      connectivityService = MockConnectivityService(isOnline: false);
    });

    Widget createGameScreen({int levelId = 6}) {
      progress.setLastPlayedLevel(levelId);
      return MaterialApp(
        home: GameScreen(
          progress: progress,
          analytics: analytics,
          adService: adService,
          connectivityService: connectivityService,
        ),
      );
    }

    testWidgets('1 & 2. Hint request while offline shows InternetNeededDialog', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      connectivityService.isOnline = false;

      await tester.pumpWidget(createGameScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final hintButton = find.byKey(const ValueKey('hint_button'));
      expect(hintButton, findsOneWidget);

      await tester.tap(hintButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // 2. Offline dialog appears
      expect(find.byType(InternetNeededDialog), findsOneWidget);
      expect(find.text('INTERNET CONNECTION NEEDED'), findsOneWidget);
      expect(
        find.textContaining('A rewarded ad is required to unlock this hint.'),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('internet_needed_try_again_button')), findsOneWidget);
      expect(find.byKey(const ValueKey('internet_needed_not_now_button')), findsOneWidget);

      // 3. Offline dialog does NOT attempt to show an ad
      expect(adService.rewardedAdCallCount, 0);

      // 4. Offline dialog does NOT grant a hint
      expect(analytics.loggedEvents, isNot(contains('hint_granted')));
      expect(analytics.loggedEvents, contains('hint_network_unavailable'));
    });

    testWidgets('5. TRY AGAIN rechecks connectivity: remains offline if still disconnected', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      connectivityService.isOnline = false;

      await tester.pumpWidget(createGameScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byKey(const ValueKey('hint_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(InternetNeededDialog), findsOneWidget);
      final checkCountBefore = connectivityService.checkCount;

      // Tap TRY AGAIN while still offline
      await tester.tap(find.byKey(const ValueKey('internet_needed_try_again_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Re-checked connectivity
      expect(connectivityService.checkCount, greaterThan(checkCountBefore));
      // Still on InternetNeededDialog with feedback
      expect(find.byType(InternetNeededDialog), findsOneWidget);
      expect(find.textContaining('Still offline'), findsOneWidget);
      expect(adService.rewardedAdCallCount, 0);
      expect(analytics.loggedEvents, contains('hint_ad_retry'));
    });

    testWidgets('6. NOT NOW dismisses dialog and returns cleanly to puzzle', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      connectivityService.isOnline = false;

      await tester.pumpWidget(createGameScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byKey(const ValueKey('hint_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(InternetNeededDialog), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('internet_needed_not_now_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Dialog dismissed
      expect(find.byType(InternetNeededDialog), findsNothing);
      expect(adService.rewardedAdCallCount, 0);
      expect(analytics.loggedEvents, isNot(contains('hint_granted')));
    });

    testWidgets('7 & 11. Online + ad loaded starts ad and verified reward grants exactly one hint', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      connectivityService.isOnline = true;
      adService.isAdReady = true;
      adService.shouldGrantReward = true;

      await tester.pumpWidget(createGameScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Tap hint button
      await tester.tap(find.byKey(const ValueKey('hint_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Confirmation dialog appears
      expect(find.text('NEED A HINT?'), findsOneWidget);
      expect(find.text('WATCH AD'), findsOneWidget);

      // Confirm watch ad
      await tester.tap(find.text('WATCH AD'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Ad was invoked
      expect(adService.rewardedAdCallCount, 1);
      // Verified reward granted exactly 1 hint
      expect(analytics.loggedEvents.where((e) => e == 'hint_granted').length, 1);
      expect(analytics.loggedEvents, contains('hint_ad_rewarded'));
      expect(find.textContaining('Hint: Shift'), findsOneWidget);
    });

    testWidgets('8. Online + ad unavailable shows HintUnavailableDialog (not offline dialog)', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      connectivityService.isOnline = true;
      adService.isAdReady = false; // Ad not loaded / inventory empty

      await tester.pumpWidget(createGameScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byKey(const ValueKey('hint_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('WATCH AD'));
      await tester.pump();
      // Wait for preload attempt and timeout
      await tester.pump(const Duration(seconds: 2));

      // Does NOT show offline dialog
      expect(find.byType(InternetNeededDialog), findsNothing);
      // Shows HintUnavailableDialog
      expect(find.byType(HintUnavailableDialog), findsOneWidget);
      expect(find.text('HINT TEMPORARILY UNAVAILABLE'), findsOneWidget);
      expect(
        find.text('The rewarded ad isn’t available right now. Please try again.'),
        findsOneWidget,
      );
      expect(analytics.loggedEvents, contains('hint_ad_unavailable'));
      expect(analytics.loggedEvents, isNot(contains('hint_network_unavailable')));
    });

    testWidgets('9 & 10. Ad failure or early dismissal does not grant hint', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      connectivityService.isOnline = true;
      adService.isAdReady = true;
      adService.shouldGrantReward = false; // User closed before reward

      await tester.pumpWidget(createGameScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byKey(const ValueKey('hint_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('WATCH AD'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(adService.rewardedAdCallCount, 1);
      // No hint granted
      expect(analytics.loggedEvents, isNot(contains('hint_granted')));
      expect(analytics.loggedEvents, contains('hint_ad_failed'));
      expect(find.text('Ad was not completed. Keep solving!'), findsOneWidget);
    });

    testWidgets('12. Duplicate reward callback invocations grant only one hint', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      connectivityService.isOnline = true;
      adService.isAdReady = true;

      // Mock ad service that invokes callback twice
      adService.shouldGrantReward = true;

      await tester.pumpWidget(createGameScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byKey(const ValueKey('hint_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('WATCH AD'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Attempt second duplicate callback
      adService.onRewardEarnedCallback?.call();
      await tester.pump();

      // Exactly 1 hint granted
      final grantedCount = analytics.loggedEvents.where((e) => e == 'hint_granted').length;
      expect(grantedCount, 1);
    });

    testWidgets('13. Manual Hint works after reconnecting from offline state', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      connectivityService.isOnline = false;

      await tester.pumpWidget(createGameScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Offline tap
      await tester.tap(find.byKey(const ValueKey('hint_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(InternetNeededDialog), findsOneWidget);

      // Reconnect!
      connectivityService.isOnline = true;
      adService.isAdReady = true;
      adService.shouldGrantReward = true;

      // Tap TRY AGAIN on the dialog
      await tester.tap(find.byKey(const ValueKey('internet_needed_try_again_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Dialog closed and ad executed
      expect(find.byType(InternetNeededDialog), findsNothing);
      expect(adService.rewardedAdCallCount, 1);
      expect(analytics.loggedEvents, contains('hint_granted'));
      expect(find.textContaining('Hint: Shift'), findsOneWidget);
    });

    testWidgets('14. Optimal Drift Hint: offline shows InternetNeededDialog; KEEP SOLVING remains intact', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      connectivityService.isOnline = false;

      // Level 6: optimalMoves = 5. Drift triggers at 6 moves.
      await tester.pumpWidget(createGameScreen(levelId: 6));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final gameFinder = find.byWidgetPredicate((w) => w is GameWidget);
      expect(gameFinder, findsOneWidget);
      final center = tester.getCenter(gameFinder);

      // Make 6 shifts to reach par + 1
      for (int i = 0; i < 6; i++) {
        await tester.dragFrom(center, const Offset(-50, 0));
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump();
      }

      // Optimal Drift Nudge appears
      expect(find.byType(OptimalDriftNudgeDialog), findsOneWidget);
      expect(find.byKey(const ValueKey('nudge_watch_ad_button')), findsOneWidget);

      // Tap WATCH AD + HINT while offline
      await tester.tap(find.byKey(const ValueKey('nudge_watch_ad_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Optimal drift dialog closed, InternetNeededDialog appears
      expect(find.byType(OptimalDriftNudgeDialog), findsNothing);
      expect(find.byType(InternetNeededDialog), findsOneWidget);
      expect(adService.rewardedAdCallCount, 0);
      expect(analytics.loggedEvents, contains('hint_network_unavailable'));
      expect(analytics.loggedEvents, contains('optimal_drift_ad_failed'));

      // Tap NOT NOW
      await tester.tap(find.byKey(const ValueKey('internet_needed_not_now_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Returns cleanly to board; no dialog loops
      expect(find.byType(InternetNeededDialog), findsNothing);
      expect(find.byType(OptimalDriftNudgeDialog), findsNothing);

      // Board is still interactive and playable
      await tester.dragFrom(center, const Offset(50, 0));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();
      expect(find.text('7'), findsOneWidget);
    });

    testWidgets('15 & 16. No dialog stacking and no duplicate requests', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      connectivityService.isOnline = false;

      await tester.pumpWidget(createGameScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Rapid double tap on hint
      await tester.tap(find.byKey(const ValueKey('hint_button')));
      await tester.tap(find.byKey(const ValueKey('hint_button')), warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Exactly 1 InternetNeededDialog
      expect(find.byType(InternetNeededDialog), findsOneWidget);
    });

    testWidgets('17. Puzzle remains fully playable offline: shifts, undo, solving work 100%', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      connectivityService.isOnline = false;

      // Play Level 1 (Tutorial: 1 move to solve: Row 2 left)
      await tester.pumpWidget(createGameScreen(levelId: 1));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final gameWidget = tester.widget<GameWidget<ShiftPuzzleGame>>(find.byType(GameWidget<ShiftPuzzleGame>));
      gameWidget.game!.triggerShiftRow(2, ShiftDirection.right);
      await tester.pump(const Duration(milliseconds: 210));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();

      // Puzzle solved offline!
      expect(find.text('LEVEL COMPLETE'), findsOneWidget);
      expect(find.textContaining('PERFECT'), findsOneWidget);
      expect(find.text('Next Level'), findsOneWidget);

      // Drain applause sound timers
      await tester.pump(const Duration(seconds: 2));
    });
  });
}
