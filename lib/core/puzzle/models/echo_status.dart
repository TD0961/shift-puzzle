/// Represents the lifecycle status of an explicit Memory Echo recording window.
enum EchoStatus {
  /// No shifts are currently being recorded, and no frozen sequence is ready.
  idle,

  /// An explicit recording window is active; player shifts are being recorded.
  recording,

  /// Recording has stopped; a frozen sequence of shifts is ready to replay.
  ready,

  /// The ghost replay sequence is currently actively executing on the board.
  replaying,

  /// The single-use replay sequence has finished and was applied.
  used,
}
