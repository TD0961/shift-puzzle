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

  void playApplause({int clapCount = 14, double durationMs = 1300.0}) {
    try {
      final ctx = _getContext();
      final now = ctx.currentTime;
      final totalSec = durationMs / 1000.0;

      for (int i = 0; i < clapCount; i++) {
        // Micro-stagger claps to simulate natural applause
        final baseOffset = (i / clapCount) * totalSec;
        final jitter = ((i * 37) % 19) / 450.0;
        final clapTime = now + baseOffset + jitter;

        final osc = ctx.createOscillator();
        final gainNode = ctx.createGain();

        // Fast pitch envelope mimicking handclap acoustic transient
        osc.type = 'triangle';
        final startFreq = 780.0 + ((i * 47) % 320);
        osc.frequency.setValueAtTime(startFreq, clapTime);
        osc.frequency.exponentialRampToValueAtTime(140.0, clapTime + 0.035);

        final clapGain = 0.035 + (((i * 23) % 25) / 1000.0);
        gainNode.gain.setValueAtTime(clapGain, clapTime);
        gainNode.gain.exponentialRampToValueAtTime(0.0001, clapTime + 0.04);

        osc.connect(gainNode);
        gainNode.connect(ctx.destination);

        osc.start(clapTime);
        osc.stop(clapTime + 0.045);
      }
    } catch (_) {}
  }
}

