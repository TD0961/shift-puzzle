import 'package:flutter/material.dart';

/// Lightweight, editorial dialog shown when a player reaches the move limit
/// for their attempt (optimalMoves + 3, or extended optimalMoves + 3 + 5).
///
/// Designed with a calm, premium aesthetic. It avoids alarming game-over warnings
/// and presents the player with a free Replay option and an optional rewarded ad rescue.
class MoveLimitDialog extends StatelessWidget {
  final int levelId;
  final int movesUsed;
  final int optimalMoves;
  final bool canExtend;
  final VoidCallback onReplay;
  final VoidCallback onWatchAd;

  const MoveLimitDialog({
    super.key,
    required this.levelId,
    required this.movesUsed,
    required this.optimalMoves,
    required this.canExtend,
    required this.onReplay,
    required this.onWatchAd,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFFFBBF24).withValues(alpha: 0.45),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFBBF24).withValues(alpha: 0.14),
                blurRadius: 28,
                spreadRadius: 2,
              ),
              const BoxShadow(
                color: Color(0x90000000),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon Badge
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBBF24).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.hourglass_bottom_rounded,
                  color: Color(0xFFFBBF24),
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),

              // Category Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBBF24).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  canExtend ? 'MOVE BUDGET REACHED' : 'FINAL ATTEMPT EXHAUSTED',
                  style: const TextStyle(
                    color: Color(0xFFFBBF24),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.8,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Title
              const Text(
                'MOVE LIMIT REACHED',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 10),

              // Body
              Text(
                canExtend
                    ? "You've reached the move limit for this attempt."
                    : "You've reached the extended move limit for this attempt.",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFE2E8F0),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 6),

              // Subtext
              Text(
                canExtend
                    ? 'Replay to try a cleaner solution, or watch a short video to unlock 5 extra moves.'
                    : 'Replay the level to try again with a fresh board.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 12.5,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              if (canExtend) ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        key: const ValueKey('replay_button'),
                        onPressed: onReplay,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF94A3B8),
                          side: const BorderSide(color: Color(0xFF334155)),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'REPLAY LEVEL',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        key: const ValueKey('watch_ad_moves_button'),
                        onPressed: onWatchAd,
                        icon: const Icon(Icons.play_circle_filled_rounded, size: 16),
                        label: const Text(
                          'WATCH AD + 5',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF59E0B),
                          foregroundColor: const Color(0xFF0F172A),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    key: const ValueKey('replay_button'),
                    onPressed: onReplay,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF38BDF8),
                      foregroundColor: const Color(0xFF0F172A),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'REPLAY LEVEL',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
