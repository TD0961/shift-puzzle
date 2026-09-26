import 'package:flutter/material.dart';

class GameHeader extends StatelessWidget {
  final int levelId;
  final String levelTitle;
  final String? hint;
  final int moveCount;
  final int? bestMoves;
  final int stars;
  final bool isSoundEnabled;
  final VoidCallback? onOpenLevelSelect;
  final VoidCallback? onToggleSound;

  const GameHeader({
    super.key,
    required this.levelId,
    required this.levelTitle,
    this.hint,
    required this.moveCount,
    this.bestMoves,
    this.stars = 0,
    this.isSoundEnabled = true,
    this.onOpenLevelSelect,
    this.onToggleSound,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Level Info & Select Trigger
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: onOpenLevelSelect,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'LEVEL $levelId',
                              style: const TextStyle(
                                color: Color(0xFF38BDF8),
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2.0,
                              ),
                            ),
                            if (onOpenLevelSelect != null) ...[
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.grid_view_rounded,
                                size: 14,
                                color: Color(0xFF38BDF8),
                              ),
                            ],
                            if (stars > 0) ...[
                              const SizedBox(width: 8),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: List.generate(stars, (_) => const Icon(
                                  Icons.star_rounded,
                                  size: 14,
                                  color: Color(0xFFFBBF24),
                                )),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                levelTitle,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (bestMoves != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Best: $bestMoves moves',
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Controls: Sound Toggle & Moves Counter
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onToggleSound != null)
                    IconButton(
                      key: const ValueKey('sound_toggle_button'),
                      onPressed: onToggleSound,
                      icon: Icon(
                        isSoundEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                        size: 20,
                      ),
                      color: isSoundEnabled ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      tooltip: isSoundEnabled ? 'Mute Audio' : 'Unmute Audio',
                      constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
                      padding: EdgeInsets.zero,
                    ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: Row(
                      children: [
                        const Text(
                          'Moves: ',
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '$moveCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (hint != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B).withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                hint!,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
