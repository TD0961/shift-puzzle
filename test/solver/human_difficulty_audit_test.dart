// ignore_for_file: avoid_print
import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:shift_puzzle/core/puzzle/levels/level_definitions.dart';
import 'package:shift_puzzle/core/puzzle/levels/puzzle_level.dart';
import 'package:shift_puzzle/core/puzzle/logic/puzzle_solver.dart';
import 'package:shift_puzzle/core/puzzle/models/piece_type.dart';
import 'package:shift_puzzle/core/puzzle/models/shift_direction.dart';

int _toroidalDist(int a, int b, int dim) {
  final d = (a - b).abs();
  return min(d, dim - d);
}

int _calcTotalDist(List<List<PieceType?>> grid, PuzzleLevel level) {
  int total = 0;
  for (final target in level.targets) {
    // Find matching piece
    int minDist = 999;
    for (int r = 0; r < level.rows; r++) {
      for (int c = 0; c < level.cols; c++) {
        if (grid[r][c] == target.pieceType) {
          final dist = _toroidalDist(r, target.position.row, level.rows) +
              _toroidalDist(c, target.position.col, level.cols);
          if (dist < minDist) minDist = dist;
        }
      }
    }
    total += minDist;
  }
  return total;
}

List<List<PieceType?>> _apply(
  List<List<PieceType?>> grid,
  int rows,
  int cols,
  bool isRow,
  int index,
  ShiftDirection direction,
) {
  final newGrid = List.generate(rows, (r) => List<PieceType?>.from(grid[r]));
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

void main() {
  test('Audit Human Difficulty Levels 1-50', () {
    print('AUDIT_START');
    for (int i = 1; i <= 50; i++) {
      final level = LevelDefinitions.getLevel(i);
      final solver = PuzzleSolver.solve(level, maxDepth: 12);
      final minMoves = solver?.minMoves ?? -1;
      final path = solver?.path ?? [];
      final states = solver?.statesExplored ?? 0;

      // 1. Check Independent Axes:
      // Count how many pieces share a row or column with another piece or another piece's target
      final pieceCoords = <Point<int>>[];
      for (int r = 0; r < 5; r++) {
        for (int c = 0; c < 5; c++) {
          if (level.initialGrid[r][c] != null) {
            pieceCoords.add(Point(r, c));
          }
        }
      }
      // Check if any piece shares row or col with another piece or target
      int crossInterferenceCount = 0;
      for (int p1 = 0; p1 < pieceCoords.length; p1++) {
        for (int p2 = p1 + 1; p2 < pieceCoords.length; p2++) {
          if (pieceCoords[p1].x == pieceCoords[p2].x || pieceCoords[p1].y == pieceCoords[p2].y) {
            crossInterferenceCount++;
          }
        }
      }

      // Check if optimal path moves an already-placed piece off its target (temporary sacrifice)
      var curGrid = level.initialGrid;
      int tempSacrificeCount = 0;
      for (final move in path) {
        // Check if any piece currently on target is displaced
        final previouslyOnTarget = <PieceType>{};
        for (final target in level.targets) {
          if (curGrid[target.position.row][target.position.col] == target.pieceType) {
            previouslyOnTarget.add(target.pieceType);
          }
        }
        curGrid = _apply(curGrid, 5, 5, move.isRow, move.index, move.direction);
        for (final piece in previouslyOnTarget) {
          // Check if still on target
          bool stillOnTarget = false;
          for (final target in level.targets) {
            if (target.pieceType == piece && curGrid[target.position.row][target.position.col] == piece) {
              stillOnTarget = true;
              break;
            }
          }
          if (!stillOnTarget) {
            tempSacrificeCount++;
          }
        }
      }

      // 2. Greedy Solvability test:
      // Can a pure greedy agent solve this in <= minMoves?
      var greedyGrid = level.initialGrid;
      int greedyMoves = 0;
      bool greedySolved = false;
      while (greedyMoves < minMoves + 4) {
        if (_calcTotalDist(greedyGrid, level) == 0) {
          greedySolved = true;
          break;
        }
        // Find best move that strictly decreases total distance
        int currentDist = _calcTotalDist(greedyGrid, level);
        int bestNextDist = 999;
        PuzzleMove? bestMove;
        for (int r = 0; r < 5; r++) {
          for (final dir in [ShiftDirection.left, ShiftDirection.right]) {
            final nextG = _apply(greedyGrid, 5, 5, true, r, dir);
            final d = _calcTotalDist(nextG, level);
            if (d < bestNextDist) {
              bestNextDist = d;
              bestMove = PuzzleMove(isRow: true, index: r, direction: dir);
            }
          }
        }
        for (int c = 0; c < 5; c++) {
          for (final dir in [ShiftDirection.up, ShiftDirection.down]) {
            final nextG = _apply(greedyGrid, 5, 5, false, c, dir);
            final d = _calcTotalDist(nextG, level);
            if (d < bestNextDist) {
              bestNextDist = d;
              bestMove = PuzzleMove(isRow: false, index: c, direction: dir);
            }
          }
        }
        if (bestMove != null && bestNextDist < currentDist) {
          greedyGrid = _apply(greedyGrid, 5, 5, bestMove.isRow, bestMove.index, bestMove.direction);
          greedyMoves++;
        } else {
          // Greedy got stuck in local minimum / trap!
          break;
        }
      }

      // 3. Count plausible first moves (moves that decrease distance or keep it same)
      int plausibleFirstMoves = 0;
      int initialDist = _calcTotalDist(level.initialGrid, level);
      for (int r = 0; r < 5; r++) {
        for (final dir in [ShiftDirection.left, ShiftDirection.right]) {
          final nextG = _apply(level.initialGrid, 5, 5, true, r, dir);
          if (_calcTotalDist(nextG, level) <= initialDist) plausibleFirstMoves++;
        }
      }
      for (int c = 0; c < 5; c++) {
        for (final dir in [ShiftDirection.up, ShiftDirection.down]) {
          final nextG = _apply(level.initialGrid, 5, 5, false, c, dir);
          if (_calcTotalDist(nextG, level) <= initialDist) plausibleFirstMoves++;
        }
      }

      print('L$i: "${level.title}" | Par:$minMoves | Pcs:${level.targets.length} | Echo:${level.hasMemoryEcho} | '
          'GreedySolved:${greedySolved && greedyMoves == minMoves} | GreedyTrap:${!greedySolved} | '
          'Sacrifice:$tempSacrificeCount | Interfere:$crossInterferenceCount | Plausible:$plausibleFirstMoves | States:$states');
      print('  Path: ${path.map((m) => m.toString()).join(" -> ")}');
    }
    print('AUDIT_END');
  });
}
