import 'board_position.dart';
import 'piece_type.dart';

class PuzzleTarget {
  final PieceType pieceType;
  final BoardPosition position;

  const PuzzleTarget({
    required this.pieceType,
    required this.position,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PuzzleTarget &&
          runtimeType == other.runtimeType &&
          pieceType == other.pieceType &&
          position == other.position;

  @override
  int get hashCode => Object.hash(pieceType, position);

  @override
  String toString() => 'PuzzleTarget($pieceType at $position)';
}
