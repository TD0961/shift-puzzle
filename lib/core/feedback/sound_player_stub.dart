import 'package:flutter/services.dart';

class SoundPlayerImpl {
  void playTone(double frequency, double durationMs, {double gain = 0.08, String type = 'sine'}) {
    SystemSound.play(SystemSoundType.click);
  }

  void playChord(List<double> frequencies, double durationMs, {double gain = 0.06}) {
    SystemSound.play(SystemSoundType.click);
  }

  void playApplause({int clapCount = 14, double durationMs = 1300.0}) {
    for (int i = 0; i < clapCount; i++) {
      Future.delayed(Duration(milliseconds: (i * (durationMs / clapCount)).round()), () {
        SystemSound.play(SystemSoundType.click);
        HapticFeedback.selectionClick();
      });
    }
  }
}
