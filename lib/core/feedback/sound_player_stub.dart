import 'package:flutter/services.dart';

class SoundPlayerImpl {
  void playTone(double frequency, double durationMs, {double gain = 0.08, String type = 'sine'}) {
    SystemSound.play(SystemSoundType.click);
  }

  void playChord(List<double> frequencies, double durationMs, {double gain = 0.06}) {
    SystemSound.play(SystemSoundType.click);
  }
}
