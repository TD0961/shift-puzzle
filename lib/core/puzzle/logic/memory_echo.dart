import '../models/echo_status.dart';
import '../models/shift_record.dart';

/// Pure Dart domain controller managing explicit Memory Echo recording windows and replay lifecycle.
class MemoryEcho {
  final List<ShiftRecord> _records = [];
  EchoStatus _status = EchoStatus.idle;

  EchoStatus get status => _status;
  List<ShiftRecord> get records => List.unmodifiable(_records);
  int get length => _records.length;
  bool get isEmpty => _records.isEmpty;

  bool get isIdle => _status == EchoStatus.idle;
  bool get isRecording => _status == EchoStatus.recording;
  bool get isReady => _status == EchoStatus.ready;
  bool get isReplaying => _status == EchoStatus.replaying;
  bool get isUsed => _status == EchoStatus.used;
  bool get canReplay => _status == EchoStatus.ready && _records.isNotEmpty;

  /// Starts an explicit recording window if currently idle.
  bool startRecording() {
    if (_status != EchoStatus.idle) {
      return false;
    }
    _records.clear();
    _status = EchoStatus.recording;
    return true;
  }

  /// Appends a valid player shift if and only if an explicit recording window is active.
  void recordPlayerShift(ShiftRecord record) {
    if (_status != EchoStatus.recording) {
      return;
    }
    _records.add(record);
  }

  /// Alias for recordPlayerShift.
  void record(ShiftRecord record) => recordPlayerShift(record);

  /// Stops recording. Transitions to ready if shifts were captured, or back to idle if empty.
  bool stopRecording() {
    if (_status != EchoStatus.recording) {
      return false;
    }
    if (_records.isNotEmpty) {
      _status = EchoStatus.ready;
    } else {
      _status = EchoStatus.idle;
    }
    return true;
  }

  /// Marks the sequence as actively replaying if ready.
  bool markReplaying() {
    if (_status == EchoStatus.ready && _records.isNotEmpty) {
      _status = EchoStatus.replaying;
      return true;
    }
    return false;
  }

  /// Marks the single-use sequence as completed and used.
  void markUsed() {
    _status = EchoStatus.used;
  }

  /// Removes the most recently recorded shift if actively recording and non-empty.
  ShiftRecord? removeLastShift() {
    if (_status == EchoStatus.recording && _records.isNotEmpty) {
      return _records.removeLast();
    }
    return null;
  }

  /// Clears recorded shifts and resets status to idle.
  void clear() {
    _records.clear();
    _status = EchoStatus.idle;
  }
}
