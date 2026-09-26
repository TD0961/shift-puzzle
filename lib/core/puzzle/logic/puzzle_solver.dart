import 'dart:collection';
import '../levels/puzzle_level.dart';
import '../models/piece_type.dart';
import '../models/shift_direction.dart';

class PuzzleMove {
  final bool isRow;
  final int index;
  final ShiftDirection direction;

  const PuzzleMove({
    required this.isRow,
    required this.index,
    required this.direction,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PuzzleMove &&
          runtimeType == other.runtimeType &&
          isRow == other.isRow &&
          index == other.index &&
          direction == other.direction;

  @override
  int get hashCode => Object.hash(isRow, index, direction);

  @override
  String toString() =>
      isRow ? 'Row $index ${direction.name}' : 'Col $index ${direction.name}';
}

class SolverResult {
  final int minMoves;
  final List<PuzzleMove> path;
  final int statesExplored;

  const SolverResult({
    required this.minMoves,
    required this.path,
    required this.statesExplored,
  });
}

class PuzzleSolver {
  static String _encodeGrid(List<List<PieceType?>> grid, int rows, int cols) {
    final buffer = StringBuffer();
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final p = grid[r][c];
        buffer.write(p == null ? '.' : p.index.toString());
      }
    }
    return buffer.toString();
  }

  static List<List<PieceType?>> _cloneGrid(
      List<List<PieceType?>> grid, int rows, int cols) {
    return List.generate(rows, (r) => List<PieceType?>.from(grid[r]));
  }

  static List<List<PieceType?>> _applyShift(
    List<List<PieceType?>> grid,
    int rows,
    int cols,
    bool isRow,
    int index,
    ShiftDirection direction,
  ) {
    final newGrid = _cloneGrid(grid, rows, cols);
    if (isRow) {
      final oldRow = List<PieceType?>.from(grid[index]);
      if (direction == ShiftDirection.right) {
        for (int c = 0; c < cols; c++) {
          newGrid[index][c] = oldRow[(c - 1 + cols) % cols];
        }
      } else {
        for (int c = 0; c < cols; c++) {
          newGrid[index][c] = oldRow[(c + 1) % cols];
        }
      }
    } else {
      final oldCol = List<PieceType?>.generate(rows, (r) => grid[r][index]);
      if (direction == ShiftDirection.down) {
        for (int r = 0; r < rows; r++) {
          newGrid[r][index] = oldCol[(r - 1 + rows) % rows];
        }
      } else {
        for (int r = 0; r < rows; r++) {
          newGrid[r][index] = oldCol[(r + 1) % rows];
        }
      }
    }
    return newGrid;
  }

  static bool _isSolved(
      List<List<PieceType?>> grid, PuzzleLevel level) {
    for (final target in level.targets) {
      if (grid[target.position.row][target.position.col] != target.pieceType) {
        return false;
      }
    }
    return true;
  }

  static ShiftDirection _inverse(ShiftDirection dir) {
    switch (dir) {
      case ShiftDirection.left:
        return ShiftDirection.right;
      case ShiftDirection.right:
        return ShiftDirection.left;
      case ShiftDirection.up:
        return ShiftDirection.down;
      case ShiftDirection.down:
        return ShiftDirection.up;
    }
  }

  static bool _rowHasPieces(List<List<PieceType?>> grid, int r, int cols) {
    for (int c = 0; c < cols; c++) {
      if (grid[r][c] != null) return true;
    }
    return false;
  }

  static bool _colHasPieces(List<List<PieceType?>> grid, int c, int rows) {
    for (int r = 0; r < rows; r++) {
      if (grid[r][c] != null) return true;
    }
    return false;
  }

  /// Solves the level from its initial grid.
  static SolverResult? solve(PuzzleLevel level, {int maxDepth = 12}) {
    return solveFromGrid(level.initialGrid, level, maxDepth: maxDepth);
  }

  /// Finds the next optimal move from [currentGrid].
  ///
  /// Returns null if already solved or unsolvable within [maxDepth].
  static PuzzleMove? getNextBestMove(
    List<List<PieceType?>> currentGrid,
    PuzzleLevel level, {
    int maxDepth = 12,
  }) {
    if (_isSolved(currentGrid, level)) return null;
    final result = solveFromGrid(currentGrid, level, maxDepth: maxDepth);
    if (result != null && result.path.isNotEmpty) {
      return result.path.first;
    }
    return null;
  }

  /// Solves the puzzle from an arbitrary [startGrid] state towards the level targets.
  static SolverResult? solveFromGrid(
    List<List<PieceType?>> startGrid,
    PuzzleLevel level, {
    int maxDepth = 12,
  }) {
    final rows = level.rows;
    final cols = level.cols;

    if (_isSolved(startGrid, level)) {
      return const SolverResult(minMoves: 0, path: [], statesExplored: 1);
    }

    // Build unique goal grid
    final goalGrid = List.generate(rows, (_) => List<PieceType?>.filled(cols, null));
    for (final target in level.targets) {
      goalGrid[target.position.row][target.position.col] = target.pieceType;
    }

    final startCode = _encodeGrid(startGrid, rows, cols);
    final goalCode = _encodeGrid(goalGrid, rows, cols);

    final fwdVisited = <String, int>{startCode: 0};
    final bwdVisited = <String, int>{goalCode: 0};

    final fwdParentMove = <String, PuzzleMove>{};
    final fwdParentState = <String, String>{};

    final bwdParentMove = <String, PuzzleMove>{};
    final bwdParentState = <String, String>{};

    final fwdQueue = Queue<List<List<PieceType?>>>();
    final bwdQueue = Queue<List<List<PieceType?>>>();

    fwdQueue.add(_cloneGrid(startGrid, rows, cols));
    bwdQueue.add(_cloneGrid(goalGrid, rows, cols));

    int statesExplored = 0;
    final halfDepth = (maxDepth + 1) ~/ 2;

    while (fwdQueue.isNotEmpty && bwdQueue.isNotEmpty) {
      // Step Forward Queue if smaller or equal
      final expandForward = fwdQueue.length <= bwdQueue.length;
      final currentQueue = expandForward ? fwdQueue : bwdQueue;
      final currentVisited = expandForward ? fwdVisited : bwdVisited;
      final otherVisited = expandForward ? bwdVisited : fwdVisited;
      final currentParentMove = expandForward ? fwdParentMove : bwdParentMove;
      final currentParentState = expandForward ? fwdParentState : bwdParentState;

      final current = currentQueue.removeFirst();
      final currentCode = _encodeGrid(current, rows, cols);
      final currentDist = currentVisited[currentCode]!;
      statesExplored++;

      if (currentDist >= halfDepth) continue;

      // Expand rows
      for (int r = 0; r < rows; r++) {
        if (!_rowHasPieces(current, r, cols)) continue;
        for (final dir in [ShiftDirection.left, ShiftDirection.right]) {
          final nextGrid = _applyShift(current, rows, cols, true, r, dir);
          final nextCode = _encodeGrid(nextGrid, rows, cols);

          if (!currentVisited.containsKey(nextCode)) {
            currentVisited[nextCode] = currentDist + 1;
            currentParentMove[nextCode] = PuzzleMove(isRow: true, index: r, direction: dir);
            currentParentState[nextCode] = currentCode;

            if (otherVisited.containsKey(nextCode)) {
              return _reconstructBidirectionalPath(
                meetingCode: nextCode,
                fwdVisited: fwdVisited,
                bwdVisited: bwdVisited,
                fwdParentMove: fwdParentMove,
                fwdParentState: fwdParentState,
                bwdParentMove: bwdParentMove,
                bwdParentState: bwdParentState,
                statesExplored: statesExplored,
              );
            }

            currentQueue.add(nextGrid);
          }
        }
      }

      // Expand cols
      for (int c = 0; c < cols; c++) {
        if (!_colHasPieces(current, c, rows)) continue;
        for (final dir in [ShiftDirection.up, ShiftDirection.down]) {
          final nextGrid = _applyShift(current, rows, cols, false, c, dir);
          final nextCode = _encodeGrid(nextGrid, rows, cols);

          if (!currentVisited.containsKey(nextCode)) {
            currentVisited[nextCode] = currentDist + 1;
            currentParentMove[nextCode] = PuzzleMove(isRow: false, index: c, direction: dir);
            currentParentState[nextCode] = currentCode;

            if (otherVisited.containsKey(nextCode)) {
              return _reconstructBidirectionalPath(
                meetingCode: nextCode,
                fwdVisited: fwdVisited,
                bwdVisited: bwdVisited,
                fwdParentMove: fwdParentMove,
                fwdParentState: fwdParentState,
                bwdParentMove: bwdParentMove,
                bwdParentState: bwdParentState,
                statesExplored: statesExplored,
              );
            }

            currentQueue.add(nextGrid);
          }
        }
      }
    }

    return null;
  }

  static SolverResult _reconstructBidirectionalPath({
    required String meetingCode,
    required Map<String, int> fwdVisited,
    required Map<String, int> bwdVisited,
    required Map<String, PuzzleMove> fwdParentMove,
    required Map<String, String> fwdParentState,
    required Map<String, PuzzleMove> bwdParentMove,
    required Map<String, String> bwdParentState,
    required int statesExplored,
  }) {
    // 1. Reconstruct forward path from start -> meetingCode
    final fwdPath = <PuzzleMove>[];
    String curr = meetingCode;
    while (fwdParentMove.containsKey(curr)) {
      fwdPath.add(fwdParentMove[curr]!);
      curr = fwdParentState[curr]!;
    }
    final path = fwdPath.reversed.toList();

    // 2. Reconstruct backward path from meetingCode -> goal
    curr = meetingCode;
    while (bwdParentMove.containsKey(curr)) {
      final bwdMove = bwdParentMove[curr]!;
      path.add(PuzzleMove(
        isRow: bwdMove.isRow,
        index: bwdMove.index,
        direction: _inverse(bwdMove.direction),
      ));
      curr = bwdParentState[curr]!;
    }

    return SolverResult(
      minMoves: path.length,
      path: path,
      statesExplored: statesExplored,
    );
  }
}
