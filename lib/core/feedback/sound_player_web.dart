import 'package:web/web.dart' as web;

class SoundPlayerImpl {
  web.AudioContext? _ctx;

  web.AudioContext _getContext() {
    _ctx ??= web.AudioContext();
    if (_ctx!.state == 'suspended') {
      _ctx!.resume();
    }
    return _ctx!;
  }

  void playTone(double frequency, double durationMs, {double gain = 0.08, String type = 'sine'}) {
    try {
      final ctx = _getContext();
      final osc = ctx.createOscillator();
      final gainNode = ctx.createGain();

      osc.type = type;
      osc.frequency.setValueAtTime(frequency, ctx.currentTime);

      final now = ctx.currentTime;
      final dur = durationMs / 1000.0;
      gainNode.gain.setValueAtTime(gain, now);
      gainNode.gain.exponentialRampToValueAtTime(0.0001, now + dur);

      osc.connect(gainNode);
      gainNode.connect(ctx.destination);

      osc.start(now);
      osc.stop(now + dur);
    } catch (_) {}
  }

  void playChord(List<double> frequencies, double durationMs, {double gain = 0.06}) {
    for (final f in frequencies) {
      playTone(f, durationMs, gain: gain, type: 'triangle');
    }
  }
}
