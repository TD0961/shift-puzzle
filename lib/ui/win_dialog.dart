import 'package:flutter/material.dart';
import 'widgets/bouncy_button.dart';
import 'widgets/rocket_celebration.dart';

class WinDialog extends StatefulWidget {
  final int levelId;
  final int moveCount;
  final int optimalMoves;
  final bool hasNextLevel;
  final bool isNewBest;
  final VoidCallback onNextLevel;
  final VoidCallback onReplay;

  const WinDialog({
    super.key,
    required this.levelId,
    required this.moveCount,
    this.optimalMoves = 0,
    required this.hasNextLevel,
    this.isNewBest = false,
    required this.onNextLevel,
    required this.onReplay,
  });

  @override
  State<WinDialog> createState() => _WinDialogState();
}

class _WinDialogState extends State<WinDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late List<Animation<double>> _starAnimations;

  int get _starCount {
    if (widget.optimalMoves <= 0) return 3;
    if (widget.moveCount <= widget.optimalMoves) return 3;
    if (widget.moveCount <= widget.optimalMoves + 1) return 2;
    return 1;
  }

  String get _ratingLabel {
    final stars = _starCount;
    if (stars == 3) return 'PERFECT!';
    if (stars == 2) return 'GREAT SOLVE!';
    return 'PUZZLE SOLVED';
  }

  Color get _ratingColor {
    final stars = _starCount;
    if (stars == 3) return const Color(0xFFFBBF24);
    if (stars == 2) return const Color(0xFF38BDF8);
    return const Color(0xFF94A3B8);
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _scaleAnimation = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _starAnimations = List.generate(3, (i) {
      final start = 0.25 + i * 0.18;
      final end = (start + 0.35).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.elasticOut),
        ),
      );
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stars = _starCount;

    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: RocketCelebrationOverlay(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 26),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: stars == 3
                    ? const Color(0xFFFBBF24).withValues(alpha: 0.6)
                    : const Color(0xFF38BDF8).withValues(alpha: 0.4),
                width: 1.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: stars == 3
                      ? const Color(0xFFFBBF24).withValues(alpha: 0.22)
                      : const Color(0xFF38BDF8).withValues(alpha: 0.16),
                  blurRadius: 32,
                  spreadRadius: 3,
                ),
                const BoxShadow(
                  color: Color(0x90000000),
                  blurRadius: 24,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Playful celebration badge
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: stars == 3
                        ? const Color(0xFFFBBF24).withValues(alpha: 0.15)
                        : const Color(0xFF38BDF8).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    stars == 3 ? Icons.auto_awesome : Icons.check_circle_outline,
                    color: stars == 3
                        ? const Color(0xFFFBBF24)
                        : const Color(0xFF38BDF8),
                    size: 44,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'LEVEL COMPLETE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 12),

                // Animated bouncy stars row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    final isFilled = index < stars;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: AnimatedBuilder(
                        animation: _starAnimations[index],
                        builder: (context, child) => Transform.scale(
                          scale: isFilled
                              ? _starAnimations[index].value.clamp(0.0, 1.3)
                              : 1.0,
                          child: child,
                        ),
                        child: Icon(
                          isFilled
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 38,
                          color: isFilled
                              ? const Color(0xFFFBBF24)
                              : const Color(0xFF334155),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 6),
                Text(
                  _ratingLabel,
                  style: TextStyle(
                    color: _ratingColor,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Moves: ${widget.moveCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (widget.optimalMoves > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Optimal: ${widget.optimalMoves} moves',
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                if (widget.isNewBest) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBBF24).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFFBBF24).withValues(alpha: 0.5),
                        width: 1.0,
                      ),
                    ),
                    child: const Text(
                      '★ NEW PERSONAL BEST!',
                      style: TextStyle(
                        color: Color(0xFFFBBF24),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),

                // Playful bouncy action buttons
                Row(
                  children: [
                    Expanded(
                      child: BouncyButton(
                        onPressed: widget.onReplay,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF334155)),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Replay',
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (widget.hasNextLevel) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: BouncyButton(
                          onPressed: widget.onNextLevel,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF38BDF8),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF38BDF8)
                                      .withValues(alpha: 0.35),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'Next Level',
                              style: TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
    ),
    );
  }
}
