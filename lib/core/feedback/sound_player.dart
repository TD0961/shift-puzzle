import 'sound_player_stub.dart'
    if (dart.library.js_interop) 'sound_player_web.dart';

class SoundPlayer {
  static final SoundPlayerImpl _impl = SoundPlayerImpl();

  static void playTone(double frequency, double durationMs, {double gain = 0.08, String type = 'sine'}) {
    _impl.playTone(frequency, durationMs, gain: gain, type: type);
  }

  static void playChord(List<double> frequencies, double durationMs, {double gain = 0.06}) {
    _impl.playChord(frequencies, durationMs, gain: gain);
  }
}
