import 'package:flutter/services.dart';
import '../storage/player_progress.dart';
import 'sound_player.dart';

/// Coordinates subtle tactile audio and haptic feedback across gameplay events.
class GameFeedback {
  final PlayerProgress progress;

  const GameFeedback(this.progress);

  bool get isSoundEnabled => progress.isSoundEnabled;

  /// Subtle soft tactile click when a row or column is shifted.
  void playShift() {
    HapticFeedback.selectionClick();
    if (!isSoundEnabled) return;
    SoundPlayer.playTone(220.0, 45.0, gain: 0.05, type: 'sine');
  }

  /// Crisp feedback when a piece locks into its target pad.
  void playPieceSeated() {
    HapticFeedback.lightImpact();
    if (!isSoundEnabled) return;
    SoundPlayer.playTone(523.25, 120.0, gain: 0.07, type: 'sine');
    Future.delayed(const Duration(milliseconds: 40), () {
      if (isSoundEnabled) {
        SoundPlayer.playTone(659.25, 140.0, gain: 0.08, type: 'sine');
      }
    });
  }

  /// Resonant ethereal chime during an Echo ghost shift replay.
  void playEchoShift() {
    HapticFeedback.lightImpact();
    if (!isSoundEnabled) return;
    SoundPlayer.playTone(880.0, 150.0, gain: 0.06, type: 'triangle');
  }

  /// Gentle feedback when undo is triggered.
  void playUndo() {
    HapticFeedback.selectionClick();
    if (!isSoundEnabled) return;
    SoundPlayer.playTone(180.0, 50.0, gain: 0.04, type: 'sine');
  }

  /// Subtle click when a recording is discarded.
  void playDiscard() {
    HapticFeedback.selectionClick();
    if (!isSoundEnabled) return;
    SoundPlayer.playTone(160.0, 60.0, gain: 0.04, type: 'sine');
  }

  /// Uplifting chord sequence and cheering applause upon puzzle completion.
  void playLevelComplete() {
    HapticFeedback.mediumImpact();
    if (!isSoundEnabled) return;
    SoundPlayer.playChord([523.25, 659.25, 783.99, 1046.50], 400.0, gain: 0.08);
    SoundPlayer.playApplause(clapCount: 14, durationMs: 1300.0);
  }
}
