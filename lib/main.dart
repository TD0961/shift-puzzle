import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/analytics/analytics_service.dart';
import 'core/monetization/ad_service.dart';
import 'core/storage/player_progress.dart';
import 'ui/game_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final progress = await PlayerProgress.initialize();
  final adService = kIsWeb ? NoOpAdService() : AdMobAdService();
  await adService.initialize();
  const analytics = DebugAnalyticsService();

  runApp(ShiftPuzzleApp(
    progress: progress,
    adService: adService,
    analytics: analytics,
  ));
}

class ShiftPuzzleApp extends StatelessWidget {
  final PlayerProgress? progress;
  final AdService? adService;
  final AnalyticsService? analytics;

  const ShiftPuzzleApp({
    super.key,
    this.progress,
    this.adService,
    this.analytics,
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
      ),
    );
  }
}
