import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class SoundPlayerImpl {
  static const MethodChannel _audioChannel = MethodChannel('com.shiftpuzzle.game/audio');

  void playTone(double frequency, double durationMs, {double gain = 0.08, String type = 'sine'}) {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      _audioChannel.invokeMethod('playTone', {
        'frequency': frequency,
        'durationMs': durationMs,
        'gain': (gain * 3.5).clamp(0.0, 1.0),
        'type': type,
      }).catchError((_) {
        SystemSound.play(SystemSoundType.click);
      });
    } else {
      SystemSound.play(SystemSoundType.click);
    }
  }

  void playChord(List<double> frequencies, double durationMs, {double gain = 0.06}) {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      _audioChannel.invokeMethod('playChord', {
        'frequencies': frequencies,
        'durationMs': durationMs,
        'gain': (gain * 3.5).clamp(0.0, 1.0),
      }).catchError((_) {
        SystemSound.play(SystemSoundType.click);
      });
    } else {
      SystemSound.play(SystemSoundType.click);
    }
  }

  void playApplause({int clapCount = 14, double durationMs = 1300.0}) {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      _audioChannel.invokeMethod('playApplause', {
        'clapCount': clapCount,
        'durationMs': durationMs,
      }).catchError((_) {
        _fallbackApplause(clapCount, durationMs);
      });
      _playHaptics(clapCount, durationMs);
    } else {
      _fallbackApplause(clapCount, durationMs);
    }
  }

  void _playHaptics(int clapCount, double durationMs) {
    for (int i = 0; i < clapCount; i++) {
      Future.delayed(Duration(milliseconds: (i * (durationMs / clapCount)).round()), () {
        HapticFeedback.selectionClick();
      });
    }
  }

  void _fallbackApplause(int clapCount, double durationMs) {
    for (int i = 0; i < clapCount; i++) {
      Future.delayed(Duration(milliseconds: (i * (durationMs / clapCount)).round()), () {
        SystemSound.play(SystemSoundType.click);
        HapticFeedback.selectionClick();
      });
    }
  }
}
