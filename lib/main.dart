import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/analytics/analytics_service.dart';
import 'core/connectivity/connectivity_service.dart';
import 'core/monetization/ad_service.dart';
import 'core/sharing/share_service.dart';
import 'core/storage/player_progress.dart';
import 'ui/game_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set orientations asynchronously without blocking the first frame render
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  const connectivityService = NetworkConnectivityService();
  final analytics = AnalyticsService.create();
  const shareService = ClipboardShareService();

  final monetizationConfig = MonetizationConfig.fromEnvironment();
  final adService = kIsWeb
      ? NoOpAdService(policyManager: monetizationConfig.policyManager)
      : monetizationConfig.createAdService(
          analytics: analytics,
          connectivityService: connectivityService,
          urlLauncher: (url) async {
            try {
              const channel = MethodChannel('com.shiftpuzzle.game/audio');
              final result = await channel.invokeMethod<bool>('openUrl', {'url': url});
              return result ?? true;
            } catch (e) {
              debugPrint('[Main] Failed to open URL via MethodChannel: $e');
              return false;
            }
          },
        );

  // Mount Flutter UI IMMEDIATELY on the very first frame.
  // GameScreen handles asynchronous PlayerProgress initialization gracefully.
  runApp(ShiftPuzzleApp(
    adService: adService,
    analytics: analytics,
    connectivityService: connectivityService,
    shareService: shareService,
  ));

  // Initialize ad service asynchronously after Flutter UI has mounted
  try {
    adService.initialize();
  } catch (e) {
    debugPrint('[Main] AdService initialization deferred: $e');
  }
}

class ShiftPuzzleApp extends StatelessWidget {
  final PlayerProgress? progress;
  final AdService? adService;
  final AnalyticsService? analytics;
  final ConnectivityService? connectivityService;
  final ShareService? shareService;

  const ShiftPuzzleApp({
    super.key,
    this.progress,
    this.adService,
    this.analytics,
    this.connectivityService,
    this.shareService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shift Puzzle',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF090D16),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF38BDF8),
          surface: Color(0xFF0F172A),
        ),
      ),
      home: GameScreen(
        progress: progress,
        adService: adService,
        analytics: analytics,
        connectivityService: connectivityService,
        shareService: shareService,
      ),
    );
  }
}
