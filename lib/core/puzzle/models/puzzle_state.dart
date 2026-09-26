import 'piece_type.dart';
import 'puzzle_target.dart';

class PuzzleState {
  final int rows;
  final int cols;
  final List<List<PieceType?>> grid;
  final List<PuzzleTarget> targets;
  final int moveCount;
  final bool isSolved;

  const PuzzleState({
    required this.rows,
    required this.cols,
    required this.grid,
    required this.targets,
    required this.moveCount,
    required this.isSolved,
  });

  PieceType? pieceAt(int row, int col) {
    if (row < 0 || row >= rows || col < 0 || col >= cols) return null;
    return grid[row][col];
  }

  bool isTargetAt(int row, int col) {
    return targets.any((t) => t.position.row == row && t.position.col == col);
  }

  PuzzleTarget? targetAt(int row, int col) {
    for (final t in targets) {
      if (t.position.row == row && t.position.col == col) return t;
    }
    return null;
  }

  PuzzleState copyWith({
    int? rows,
    int? cols,
    List<List<PieceType?>>? grid,
    List<PuzzleTarget>? targets,
    int? moveCount,
    bool? isSolved,
  }) {
    return PuzzleState(
      rows: rows ?? this.rows,
      cols: cols ?? this.cols,
      grid: grid ??
          List.generate(
            this.rows,
            (r) => List<PieceType?>.from(this.grid[r]),
          ),
      targets: targets ?? List.unmodifiable(this.targets),
      moveCount: moveCount ?? this.moveCount,
      isSolved: isSolved ?? this.isSolved,
    );
  }
}
