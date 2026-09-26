import 'package:flutter/material.dart';

/// Lightweight, playful animated gesture tutorial overlay for Levels 1 and 2.
/// Designed to visually teach core spatial mechanics without disruptive text modals.
class TutorialOverlay extends StatefulWidget {
  final int levelId;
  final VoidCallback onDismiss;

  const TutorialOverlay({
    super.key,
    required this.levelId,
    required this.onDismiss,
  });

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1900),
    )..repeat();

    _progressAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.18, 0.78, curve: Curves.easeInOutCubic),
    );

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 15),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 58),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 27),
    ]).animate(_controller);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLevel1 = widget.levelId == 1;
    final title = isLevel1 ? 'SWIPE TO SHIFT ➔' : 'THE BOARD WRAPS ↺';
    final subtitle = isLevel1
        ? 'Slide row 3 right to seat the piece in its target'
        : 'Swipe row 3 right — edges loop around!';

    return Positioned.fill(
      child: IgnorePointer(
        ignoring: true, // Non-blocking: touches pass directly to the game board
        child: LayoutBuilder(
          builder: (context, constraints) {
            final boardSize = constraints.maxWidth;
            final cellSize = boardSize / 5.0;
            const handSize = 54.0;

            // Row 2 is the middle row:
            final centerY = 2.5 * cellSize;

            // For Level 1: Piece is at (row 2, col 1), target is at (row 2, col 2)
            // For Level 2: Piece is at (row 2, col 4), target is at (row 2, col 0) via wrap
            final double startX;
            final double endX;
            if (isLevel1) {
              startX = 1.5 * cellSize;
              endX = 2.5 * cellSize;
            } else {
              // Level 2: Piece is placed at col 4 (right edge)
              startX = 4.5 * cellSize;
              // Swipes across right border
              endX = 5.35 * cellSize;
            }

            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final t = _progressAnimation.value;
                final currentX = startX + (endX - startX) * t;
                final opacity = _opacityAnimation.value.clamp(0.0, 1.0);

                return Stack(
                  children: [
                    // 1. Playful prompt badge near the top of the board
                    Positioned(
                      top: 14,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Opacity(
                          opacity: opacity,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A).withValues(alpha: 0.94),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF38BDF8).withValues(alpha: 0.85),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF38BDF8).withValues(alpha: 0.25),
                                  blurRadius: 16,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Transform.scale(
                                      scale: _pulseAnimation.value,
                                      child: const Icon(
                                        Icons.touch_app_rounded,
                                        color: Color(0xFF38BDF8),
                                        size: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      title,
                                      style: const TextStyle(
                                        color: Color(0xFF38BDF8),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  subtitle,
                                  style: const TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // On Level 2, show a subtle pulse glow on col 0 (the wrap destination)
                    if (!isLevel1)
                      Positioned(
                        left: 0.5 * cellSize - (handSize / 2),
                        top: centerY - (handSize / 2),
                        child: Opacity(
                          opacity: (t > 0.45 ? (t - 0.45) * 1.8 * opacity : 0.0).clamp(0.0, 0.8),
                          child: Container(
                            width: handSize,
                            height: handSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF38BDF8).withValues(alpha: 0.6),
                                width: 2.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF38BDF8).withValues(alpha: 0.35),
                                  blurRadius: 16,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.arrow_back_rounded,
                                color: Color(0xFF38BDF8),
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                      ),

                    // 2. Animated finger/hand gesture placed on the exact piece position
                    Positioned(
                      left: currentX - (handSize / 2),
                      top: centerY - (handSize / 2),
                      child: Opacity(
                        opacity: (opacity * 0.95).clamp(0.0, 1.0),
                        child: Container(
                          width: handSize,
                          height: handSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF38BDF8).withValues(alpha: 0.25),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.9),
                              width: 2.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF38BDF8).withValues(alpha: 0.5),
                                blurRadius: 22,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.pan_tool_alt_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
