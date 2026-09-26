import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Celebration particle representing a firework/rocket spark or star.
class _CelebrationSpark {
  final double angle;
  final double speed;
  final double maxRadius;
  final Color color;
  final double size;
  final bool isStar;

  const _CelebrationSpark({
    required this.angle,
    required this.speed,
    required this.maxRadius,
    required this.color,
    required this.size,
    this.isStar = false,
  });
}

/// A rocket trajectory with ascending flight followed by a bursting explosion.
class _CelebrationRocket {
  final double startX; // Normalized [0, 1]
  final double targetX;
  final double targetY;
  final double launchTime; // Normalized [0, 1]
  final double burstTime;
  final Color rocketColor;
  final List<_CelebrationSpark> sparks;

  _CelebrationRocket({
    required this.startX,
    required this.targetX,
    required this.targetY,
    required this.launchTime,
    required this.burstTime,
    required this.rocketColor,
    required this.sparks,
  });

  static _CelebrationRocket create({
    required double startX,
    required double targetX,
    required double targetY,
    required double launchTime,
    required double burstTime,
    required Color primaryColor,
    required List<Color> burstPalette,
    required int sparkCount,
    required int seed,
  }) {
    final rand = math.Random(seed);
    final sparks = List.generate(sparkCount, (i) {
      final angle = (i / sparkCount) * 2 * math.pi + (rand.nextDouble() * 0.2 - 0.1);
      final speed = 0.5 + rand.nextDouble() * 0.5;
      final maxRadius = 45.0 + rand.nextDouble() * 45.0;
      final color = burstPalette[rand.nextInt(burstPalette.length)];
      final size = 3.0 + rand.nextDouble() * 3.5;
      final isStar = rand.nextDouble() > 0.45;
      return _CelebrationSpark(
        angle: angle,
        speed: speed,
        maxRadius: maxRadius,
        color: color,
        size: size,
        isStar: isStar,
      );
    });

    return _CelebrationRocket(
      startX: startX,
      targetX: targetX,
      targetY: targetY,
      launchTime: launchTime,
      burstTime: burstTime,
      rocketColor: primaryColor,
      sparks: sparks,
    );
  }
}

/// Playful celebratory rocket & firework particle overlay.
class RocketCelebrationOverlay extends StatefulWidget {
  final Widget child;

  const RocketCelebrationOverlay({
    super.key,
    required this.child,
  });

  @override
  State<RocketCelebrationOverlay> createState() =>
      _RocketCelebrationOverlayState();
}

class _RocketCelebrationOverlayState extends State<RocketCelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_CelebrationRocket> _rockets;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..forward();

    _rockets = [
      // Rocket 1: Launches from bottom left toward upper-left quadrant
      _CelebrationRocket.create(
        startX: 0.12,
        targetX: 0.22,
        targetY: 0.18,
        launchTime: 0.05,
        burstTime: 0.38,
        primaryColor: const Color(0xFF38BDF8), // Cyan
        burstPalette: const [
          Color(0xFF38BDF8),
          Color(0xFF818CF8),
          Color(0xFFFBBF24),
          Colors.white,
        ],
        sparkCount: 22,
        seed: 42,
      ),
      // Rocket 2: Launches from bottom right toward upper-right quadrant
      _CelebrationRocket.create(
        startX: 0.88,
        targetX: 0.78,
        targetY: 0.15,
        launchTime: 0.18,
        burstTime: 0.52,
        primaryColor: const Color(0xFFF43F5E), // Rose
        burstPalette: const [
          Color(0xFFF43F5E),
          Color(0xFFFB923C),
          Color(0xFFFBBF24),
          Colors.white,
        ],
        sparkCount: 24,
        seed: 108,
      ),
      // Rocket 3: Center grand rocket soaring high
      _CelebrationRocket.create(
        startX: 0.50,
        targetX: 0.50,
        targetY: 0.08,
        launchTime: 0.30,
        burstTime: 0.65,
        primaryColor: const Color(0xFFFBBF24), // Gold
        burstPalette: const [
          Color(0xFFFBBF24),
          Color(0xFF34D399),
          Color(0xFF38BDF8),
          Colors.white,
        ],
        sparkCount: 28,
        seed: 777,
      ),
    ];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Rocket particle canvas underneath/around dialog
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return CustomPaint(
                  painter: _RocketCelebrationPainter(
                    progress: _controller.value,
                    rockets: _rockets,
                  ),
                );
              },
            ),
          ),
        ),
        // Child dialog content
        widget.child,
      ],
    );
  }
}

class _RocketCelebrationPainter extends CustomPainter {
  final double progress;
  final List<_CelebrationRocket> rockets;

  _RocketCelebrationPainter({
    required this.progress,
    required this.rockets,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final rocket in rockets) {
      if (progress < rocket.launchTime) continue;

      final startPos = Offset(rocket.startX * size.width, size.height + 20);
      final burstPos = Offset(rocket.targetX * size.width, rocket.targetY * size.height);

      if (progress <= rocket.burstTime) {
        // Flight phase: Rocket ascending with fiery trail
        final flightT = (progress - rocket.launchTime) /
            (rocket.burstTime - rocket.launchTime);
        final currentPos = Offset.lerp(startPos, burstPos, flightT)!;

        // Draw ascending rocket head
        final headPaint = Paint()
          ..color = rocket.rocketColor
          ..style = PaintingStyle.fill;
        canvas.drawCircle(currentPos, 4.0, headPaint);

        // Rocket glow
        final glowPaint = Paint()
          ..color = rocket.rocketColor.withValues(alpha: 0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        canvas.drawCircle(currentPos, 8.0, glowPaint);

        // Sparkle smoke trail behind rocket
        final trailPaint = Paint()
          ..color = rocket.rocketColor.withValues(alpha: 0.7)
          ..strokeWidth = 2.2
          ..strokeCap = StrokeCap.round;
        final trailEnd = Offset.lerp(startPos, burstPos, (flightT - 0.12).clamp(0.0, 1.0))!;
        canvas.drawLine(trailEnd, currentPos, trailPaint);
      } else {
        // Burst phase: Firework explosion & falling confetti
        final burstDuration = 1.0 - rocket.burstTime;
        final explosionT = ((progress - rocket.burstTime) / burstDuration).clamp(0.0, 1.0);
        final fadeOut = (1.0 - explosionT).clamp(0.0, 1.0);

        // Radiant central flash at burst moment
        if (explosionT < 0.25) {
          final flashT = explosionT / 0.25;
          final flashPaint = Paint()
            ..color = Colors.white.withValues(alpha: (1.0 - flashT) * 0.85)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
          canvas.drawCircle(burstPos, 20.0 * (1.0 + flashT), flashPaint);
        }

        // Exploding sparks
        for (final spark in rocket.sparks) {
          final currentDist = spark.maxRadius * math.pow(explosionT, 0.6) * spark.speed;
          final gravityOffset = 38.0 * explosionT * explosionT;
          final sparkX = burstPos.dx + math.cos(spark.angle) * currentDist;
          final sparkY = burstPos.dy + math.sin(spark.angle) * currentDist + gravityOffset;

          final sparkPaint = Paint()
            ..color = spark.color.withValues(alpha: (fadeOut * 0.9).clamp(0.0, 1.0))
            ..style = PaintingStyle.fill;

          if (spark.isStar) {
            // Draw playful 4-point diamond star
            final path = Path();
            final r = spark.size * fadeOut;
            path.moveTo(sparkX, sparkY - r);
            path.lineTo(sparkX + r * 0.5, sparkY);
            path.lineTo(sparkX, sparkY + r);
            path.lineTo(sparkX - r * 0.5, sparkY);
            path.close();
            canvas.drawPath(path, sparkPaint);
          } else {
            canvas.drawCircle(Offset(sparkX, sparkY), spark.size * 0.65 * fadeOut, sparkPaint);
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RocketCelebrationPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
