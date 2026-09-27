import '../levels/puzzle_level.dart';
import '../models/board_position.dart';
import '../models/piece_type.dart';
import '../models/puzzle_state.dart';
import '../models/puzzle_target.dart';
import '../models/shift_direction.dart';
import '../models/shift_record.dart';
import 'memory_echo.dart';

class PuzzleEngine {
  final PuzzleLevel level;
  late List<List<PieceType?>> _grid;
  late int _moveCount;
  late bool _isSolved;
  final MemoryEcho echo = MemoryEcho();
  final List<ShiftRecord> _history = [];
  bool _undoLocked = false;

  PuzzleEngine(this.level) {
    reset();
  }

  int get rows => level.rows;
  int get cols => level.cols;
  int get moveCount => _moveCount;
  bool get isSolved => _isSolved;
  List<PuzzleTarget> get targets => level.targets;
  bool get canUndo =>
      !_undoLocked &&
      _history.isNotEmpty &&
      !_isSolved &&
      (level.optimalMoves <= 0 || _moveCount < level.optimalMoves);
  int get undoCount => _history.length;
  bool get isUndoLocked => _undoLocked;

  void clearHistory() {
    _history.clear();
  }

  PieceType? pieceAt(int row, int col) {
    if (row < 0 || row >= rows || col < 0 || col >= cols) return null;
    return _grid[row][col];
  }

  List<List<PieceType?>> get currentGrid =>
      List.generate(rows, (r) => List<PieceType?>.from(_grid[r]));

  PuzzleState get state => PuzzleState(
        rows: rows,
        cols: cols,
        grid: List.generate(rows, (r) => List<PieceType?>.from(_grid[r])),
        targets: targets,
        moveCount: _moveCount,
        isSolved: _isSolved,
      );

  bool shiftRow(int rowIndex, ShiftDirection direction, {bool isEcho = false}) {
    if (rowIndex < 0 || rowIndex >= rows) {
      return false;
    }
    if (!direction.isHorizontal) {
      return false;
    }

    final oldRow = List<PieceType?>.from(_grid[rowIndex]);
    if (direction == ShiftDirection.right) {
      for (int c = 0; c < cols; c++) {
        _grid[rowIndex][c] = oldRow[(c - 1 + cols) % cols];
      }
    } else if (direction == ShiftDirection.left) {
      for (int c = 0; c < cols; c++) {
        _grid[rowIndex][c] = oldRow[(c + 1) % cols];
      }
    } else {
      return false;
    }

    if (!isEcho) {
      _moveCount++;
      final record = ShiftRecord(isRow: true, index: rowIndex, direction: direction);
      _history.add(record);
      echo.record(record);
      if (level.optimalMoves > 0 && _moveCount >= level.optimalMoves) {
        _undoLocked = true;
      }
    }
    _isSolved = checkSolved();
    return true;
  }

  bool shiftColumn(int columnIndex, ShiftDirection direction, {bool isEcho = false}) {
    if (columnIndex < 0 || columnIndex >= cols) {
      return false;
    }
    if (!direction.isVertical) {
      return false;
    }

    final oldCol = List<PieceType?>.generate(rows, (r) => _grid[r][columnIndex]);
    if (direction == ShiftDirection.down) {
      for (int r = 0; r < rows; r++) {
        _grid[r][columnIndex] = oldCol[(r - 1 + rows) % rows];
      }
    } else if (direction == ShiftDirection.up) {
      for (int r = 0; r < rows; r++) {
        _grid[r][columnIndex] = oldCol[(r + 1) % rows];
      }
    } else {
      return false;
    }

    if (!isEcho) {
      _moveCount++;
      final record = ShiftRecord(isRow: false, index: columnIndex, direction: direction);
      _history.add(record);
      echo.record(record);
      if (level.optimalMoves > 0 && _moveCount >= level.optimalMoves) {
        _undoLocked = true;
      }
    }
    _isSolved = checkSolved();
    return true;
  }

  /// Undoes the last normal player move.
  ShiftRecord? undo() {
    if (!canUndo) return null;
    final last = _history.removeLast();

    if (last.isRow) {
      final oppositeDir = last.direction == ShiftDirection.right ? ShiftDirection.left : ShiftDirection.right;
      final oldRow = List<PieceType?>.from(_grid[last.index]);
      if (oppositeDir == ShiftDirection.right) {
        for (int c = 0; c < cols; c++) {
          _grid[last.index][c] = oldRow[(c - 1 + cols) % cols];
        }
      } else {
        for (int c = 0; c < cols; c++) {
          _grid[last.index][c] = oldRow[(c + 1) % cols];
        }
      }
    } else {
      final oppositeDir = last.direction == ShiftDirection.down ? ShiftDirection.up : ShiftDirection.down;
      final oldCol = List<PieceType?>.generate(rows, (r) => _grid[r][last.index]);
      if (oppositeDir == ShiftDirection.down) {
        for (int r = 0; r < rows; r++) {
          _grid[r][last.index] = oldCol[(r - 1 + rows) % rows];
        }
      } else {
        for (int r = 0; r < rows; r++) {
          _grid[r][last.index] = oldCol[(r + 1) % rows];
        }
      }
    }

    if (_moveCount > 0) {
      _moveCount--;
    }

    if (echo.isRecording) {
      echo.removeLastShift();
    }

    _isSolved = checkSolved();
    return last;
  }

  bool checkSolved() {
    for (final target in targets) {
      final actual = pieceAt(target.position.row, target.position.col);
      if (actual != target.pieceType) {
        return false;
      }
    }
    return true;
  }

  void reset() {
    _grid = List.generate(
      level.rows,
      (r) => List<PieceType?>.from(level.initialGrid[r]),
    );
    _moveCount = 0;
    _undoLocked = false;
    _history.clear();
    echo.clear();
    _isSolved = checkSolved();
  }

  bool isTargetPosition(BoardPosition pos) {
    return targets.any((t) => t.position == pos);
  }

  PuzzleTarget? getTargetAt(int row, int col) {
    for (final t in targets) {
      if (t.position.row == row && t.position.col == col) {
        return t;
      }
    }
    return null;
  }
}
