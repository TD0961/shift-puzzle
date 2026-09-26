import 'package:flutter/material.dart';
import '../core/puzzle/models/echo_status.dart';

class GameControls extends StatelessWidget {
  final VoidCallback onRestart;
  final VoidCallback? onPreviousLevel;
  final VoidCallback? onNextLevel;
  final bool hasPrevious;
  final bool hasNext;
  final bool showEchoButton;
  final EchoStatus echoStatus;
  final int echoCount;
  final bool isBoardBusy;
  final bool canUndo;
  final VoidCallback? onUndo;
  final VoidCallback? onEchoAction;
  final VoidCallback? onDiscardEcho;
  final VoidCallback? onHint;
  final bool isHintActive;
  final bool isStruggling;

  const GameControls({
    super.key,
    required this.onRestart,
    this.onPreviousLevel,
    this.onNextLevel,
    this.hasPrevious = false,
    this.hasNext = false,
    this.showEchoButton = false,
    this.echoStatus = EchoStatus.idle,
    this.echoCount = 0,
    this.isBoardBusy = false,
    this.canUndo = false,
    this.onUndo,
    this.onEchoAction,
    this.onDiscardEcho,
    this.onHint,
    this.isHintActive = false,
    this.isStruggling = false,
  });

  @override
  Widget build(BuildContext context) {
    final isReplaying = echoStatus == EchoStatus.replaying;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Previous level button
            IconButton(
              onPressed: (!isReplaying && hasPrevious) ? onPreviousLevel : null,
              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
              color: const Color(0xFF94A3B8),
              disabledColor: const Color(0xFF334155),
              tooltip: 'Previous Level',
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            ),
            const SizedBox(width: 6),

            // Undo button
            IconButton(
              key: const ValueKey('undo_button'),
              onPressed: (!isReplaying && !isBoardBusy && canUndo) ? onUndo : null,
              icon: const Icon(Icons.undo_rounded, size: 20),
              color: const Color(0xFF38BDF8),
              disabledColor: const Color(0xFF334155),
              tooltip: 'Undo Shift',
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            ),
            const SizedBox(width: 6),

            // Hint button (contextual presentation: subtle 'Need a hint?' chip when struggling)
            if (isStruggling && !isHintActive) ...[
              OutlinedButton.icon(
                key: const ValueKey('hint_button'),
                onPressed: (!isReplaying && !isBoardBusy && onHint != null) ? onHint : null,
                icon: const Icon(
                  Icons.lightbulb_rounded,
                  size: 16,
                  color: Color(0xFFFBBF24),
                ),
                label: const Text(
                  'Need a hint?',
                  style: TextStyle(
                    color: Color(0xFFFBBF24),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: const Color(0xFF78350F).withValues(alpha: 0.3),
                  side: BorderSide(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.7),
                    width: 1.2,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ] else ...[
              IconButton(
                key: const ValueKey('hint_button'),
                onPressed: (!isReplaying && !isBoardBusy && onHint != null) ? onHint : null,
                icon: Icon(
                  isHintActive ? Icons.lightbulb_rounded : Icons.lightbulb_outline_rounded,
                  size: 20,
                ),
                color: isHintActive ? const Color(0xFFFBBF24) : const Color(0xFFF59E0B),
                disabledColor: const Color(0xFF334155),
                tooltip: 'Hint',
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              ),
            ],
            const SizedBox(width: 6),

            // Restart button
            ElevatedButton.icon(
              onPressed: isReplaying ? null : onRestart,
              icon: const Icon(Icons.refresh, size: 18, color: Colors.white),
              label: const Text(
                'Restart',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E293B),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFF131722),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFF334155)),
                ),
              ),
            ),

            if (showEchoButton) ...[
              const SizedBox(width: 10),
              _buildEchoButton(),
              if ((echoStatus == EchoStatus.ready ||
                      echoStatus == EchoStatus.recording) &&
                  onDiscardEcho != null) ...[
                const SizedBox(width: 4),
                IconButton(
                  key: const ValueKey('discard_echo_button'),
                  onPressed: isBoardBusy ? null : onDiscardEcho,
                  icon: const Icon(Icons.close_rounded, size: 18),
                  color: const Color(0xFFF43F5E),
                  disabledColor: const Color(0xFF334155),
                  tooltip: 'Discard Recording',
                  constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
                  padding: EdgeInsets.zero,
                ),
              ],
            ],

            const SizedBox(width: 8),

            // Next level button
            IconButton(
              onPressed: (!isReplaying && hasNext) ? onNextLevel : null,
              icon: const Icon(Icons.arrow_forward_ios, size: 18),
              color: const Color(0xFF94A3B8),
              disabledColor: const Color(0xFF334155),
              tooltip: 'Next Level',
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEchoButton() {
    String label;
    IconData icon;
    Color bgColor;
    Color borderColor;
    Color fgColor;
    bool isEnabled;

    switch (echoStatus) {
      case EchoStatus.idle:
        label = 'REC';
        icon = Icons.fiber_manual_record;
        bgColor = const Color(0xFF1E293B);
        borderColor = const Color(0xFFE11D48).withValues(alpha: 0.7);
        fgColor = const Color(0xFFFDA4AF);
        isEnabled = !isBoardBusy;
        break;

      case EchoStatus.recording:
        label = echoCount == 0 ? '● REC' : '● REC · $echoCount';
        icon = Icons.stop_rounded;
        bgColor = const Color(0xFF4C0519);
        borderColor = const Color(0xFFF43F5E);
        fgColor = const Color(0xFFFFF1F2);
        isEnabled = !isBoardBusy;
        break;

      case EchoStatus.ready:
        label = 'Echo ($echoCount)';
        icon = Icons.auto_awesome;
        bgColor = const Color(0xFF2E1065);
        borderColor = const Color(0xFFA855F7);
        fgColor = const Color(0xFFF3E8FF);
        isEnabled = !isBoardBusy;
        break;

      case EchoStatus.replaying:
        label = 'Replaying...';
        icon = Icons.graphic_eq;
        bgColor = const Color(0xFF3B0764);
        borderColor = const Color(0xFFC084FC);
        fgColor = const Color(0xFFF3E8FF);
        isEnabled = false;
        break;

      case EchoStatus.used:
        label = 'Echo (Used)';
        icon = Icons.check_circle_outline;
        bgColor = const Color(0xFF0F172A);
        borderColor = const Color(0xFF1E293B);
        fgColor = const Color(0xFF64748B);
        isEnabled = false;
        break;
    }

    return ElevatedButton.icon(
      key: const ValueKey('echo_button'),
      onPressed: isEnabled ? onEchoAction : null,
      icon: Icon(icon, size: 16, color: fgColor),
      label: Text(
        label,
        style: TextStyle(
          color: fgColor,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: fgColor,
        disabledBackgroundColor: bgColor,
        elevation: (isEnabled && (echoStatus == EchoStatus.ready || echoStatus == EchoStatus.recording)) ? 4 : 0,
        shadowColor: echoStatus == EchoStatus.recording
            ? const Color(0xFFF43F5E).withValues(alpha: 0.5)
            : const Color(0xFFA855F7).withValues(alpha: 0.5),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: borderColor,
            width: (echoStatus == EchoStatus.ready || echoStatus == EchoStatus.recording) ? 1.5 : 1.0,
          ),
        ),
      ),
    );
  }
}
