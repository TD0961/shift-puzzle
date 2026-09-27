// ignore_for_file: avoid_print, curly_braces_in_flow_control_structures
import 'dart:collection';
import 'package:flutter_test/flutter_test.dart';
import 'package:shift_puzzle/core/puzzle/levels/level_definitions.dart';
import 'package:shift_puzzle/core/puzzle/levels/puzzle_level.dart';
import 'package:shift_puzzle/core/puzzle/logic/puzzle_solver.dart';
import 'package:shift_puzzle/core/puzzle/models/piece_type.dart';
import 'package:shift_puzzle/core/puzzle/models/shift_direction.dart';

class CorrectBidirectionalBfs {
  static SolverResult? solve(PuzzleLevel level, {int maxDepth = 12}) {
    final rows = level.rows;
    final cols = level.cols;

    bool isSolved(List<List<PieceType?>> grid) {
      for (final target in level.targets) {
        if (grid[target.position.row][target.position.col] != target.pieceType) {
          return false;
        }
      }
      return true;
    }

    if (isSolved(level.initialGrid)) {
      return const SolverResult(minMoves: 0, path: [], statesExplored: 1);
    }

    String encode(List<List<PieceType?>> grid) {
      final buf = StringBuffer();
      for (int r = 0; r < rows; r++) {
        for (int c = 0; c < cols; c++) {
          final p = grid[r][c];
          buf.write(p == null ? '.' : p.index.toString());
        }
      }
      return buf.toString();
    }

    List<List<PieceType?>> clone(List<List<PieceType?>> g) =>
        List.generate(rows, (r) => List<PieceType?>.from(g[r]));

    List<List<PieceType?>> applyShift(
      List<List<PieceType?>> grid,
      bool isRow,
      int index,
      ShiftDirection direction,
    ) {
      final newGrid = clone(grid);
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

    final goalGrid = List.generate(rows, (_) => List<PieceType?>.filled(cols, null));
    for (final target in level.targets) {
      goalGrid[target.position.row][target.position.col] = target.pieceType;
    }

    final startCode = encode(level.initialGrid);
    final goalCode = encode(goalGrid);

    final fwdVisited = <String, int>{startCode: 0};
    final bwdVisited = <String, int>{goalCode: 0};

    final fwdParentMove = <String, PuzzleMove>{};
    final fwdParentState = <String, String>{};

    final bwdParentMove = <String, PuzzleMove>{};
    final bwdParentState = <String, String>{};

    final fwdQueue = Queue<List<List<PieceType?>>>();
    final bwdQueue = Queue<List<List<PieceType?>>>();

    fwdQueue.add(clone(level.initialGrid));
    bwdQueue.add(clone(goalGrid));

    int statesExplored = 0;
    int bestDist = maxDepth + 1;
    String? bestMeetingCode;

    while (fwdQueue.isNotEmpty && bwdQueue.isNotEmpty) {
      final fwdFrontierDist = fwdVisited[encode(fwdQueue.first)]!;
      final bwdFrontierDist = bwdVisited[encode(bwdQueue.first)]!;

      // Termination condition: If sum of frontier distances >= bestDist, no shorter path is possible!
      if (fwdFrontierDist + bwdFrontierDist >= bestDist) {
        break;
      }

      // Expand the queue with smaller frontier distance, or smaller length
      final bool expandForward;
      if (fwdFrontierDist < bwdFrontierDist) {
        expandForward = true;
      } else if (fwdFrontierDist > bwdFrontierDist) {
        expandForward = false;
      } else {
        expandForward = fwdQueue.length <= bwdQueue.length;
      }

      final currentQueue = expandForward ? fwdQueue : bwdQueue;
      final currentVisited = expandForward ? fwdVisited : bwdVisited;
      final otherVisited = expandForward ? bwdVisited : fwdVisited;
      final currentParentMove = expandForward ? fwdParentMove : bwdParentMove;
      final currentParentState = expandForward ? fwdParentState : bwdParentState;

      final current = currentQueue.removeFirst();
      final currentCode = encode(current);
      final currentDist = currentVisited[currentCode]!;
      statesExplored++;

      if (currentDist >= bestDist) continue;

      // Expand rows
      for (int r = 0; r < rows; r++) {
        bool hasP = false;
        for (int c = 0; c < cols; c++) if (current[r][c] != null) hasP = true;
        if (!hasP) continue;

        for (final dir in [ShiftDirection.left, ShiftDirection.right]) {
          final nextGrid = applyShift(current, true, r, dir);
          final nextCode = encode(nextGrid);

          if (!currentVisited.containsKey(nextCode)) {
            final nextDist = currentDist + 1;
            currentVisited[nextCode] = nextDist;
            currentParentMove[nextCode] = PuzzleMove(isRow: true, index: r, direction: dir);
            currentParentState[nextCode] = currentCode;

            if (otherVisited.containsKey(nextCode)) {
              final totalDist = nextDist + otherVisited[nextCode]!;
              if (totalDist < bestDist) {
                bestDist = totalDist;
                bestMeetingCode = nextCode;
              }
            }

            if (nextDist < bestDist) {
              currentQueue.add(nextGrid);
            }
          }
        }
      }

      // Expand cols
      for (int c = 0; c < cols; c++) {
        bool hasP = false;
        for (int r = 0; r < rows; r++) if (current[r][c] != null) hasP = true;
        if (!hasP) continue;

        for (final dir in [ShiftDirection.up, ShiftDirection.down]) {
          final nextGrid = applyShift(current, false, c, dir);
          final nextCode = encode(nextGrid);

          if (!currentVisited.containsKey(nextCode)) {
            final nextDist = currentDist + 1;
            currentVisited[nextCode] = nextDist;
            currentParentMove[nextCode] = PuzzleMove(isRow: false, index: c, direction: dir);
            currentParentState[nextCode] = currentCode;

            if (otherVisited.containsKey(nextCode)) {
              final totalDist = nextDist + otherVisited[nextCode]!;
              if (totalDist < bestDist) {
                bestDist = totalDist;
                bestMeetingCode = nextCode;
              }
            }

            if (nextDist < bestDist) {
              currentQueue.add(nextGrid);
            }
          }
        }
      }
    }

    if (bestMeetingCode == null || bestDist > maxDepth) return null;

    ShiftDirection inverse(ShiftDirection d) {
      switch (d) {
        case ShiftDirection.left: return ShiftDirection.right;
        case ShiftDirection.right: return ShiftDirection.left;
        case ShiftDirection.up: return ShiftDirection.down;
        case ShiftDirection.down: return ShiftDirection.up;
      }
    }

    // Reconstruct path
    final fwdPath = <PuzzleMove>[];
    String curr = bestMeetingCode;
    while (fwdParentMove.containsKey(curr)) {
      fwdPath.add(fwdParentMove[curr]!);
      curr = fwdParentState[curr]!;
    }
    final path = fwdPath.reversed.toList();

    curr = bestMeetingCode;
    while (bwdParentMove.containsKey(curr)) {
      final bwdMove = bwdParentMove[curr]!;
      path.add(PuzzleMove(
        isRow: bwdMove.isRow,
        index: bwdMove.index,
        direction: inverse(bwdMove.direction),
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

void main() {
  test('Audit all 150 levels with correct bidirectional BFS vs Configured Par and PuzzleSolver', () {
    final discrepancies = <Map<String, dynamic>>[];
    final matches = <int>[];
    final unsolved = <int>[];

    final stopwatch = Stopwatch()..start();

    for (int id = 1; id <= 150; id++) {
      final level = LevelDefinitions.getLevel(id);
      final exact = CorrectBidirectionalBfs.solve(level, maxDepth: 12);
      final oldSolver = PuzzleSolver.solve(level, maxDepth: 12);

      if (exact == null) {
        unsolved.add(id);
        print('UNSOLVED: Level $id "${level.title}"');
        continue;
      }

      final configuredPar = level.optimalMoves;
      final exactMoves = exact.minMoves;
      final oldSolverMoves = oldSolver?.minMoves;

      if (exactMoves != configuredPar || exactMoves != oldSolverMoves) {
        discrepancies.add({
          'id': id,
          'title': level.title,
          'chapter': level.chapter,
          'configuredPar': configuredPar,
          'exactMoves': exactMoves,
          'oldSolverMoves': oldSolverMoves,
          'exactPath': exact.path.map((m) => m.toString()).join(' -> '),
          'oldSolverPath': oldSolver?.path.map((m) => m.toString()).join(' -> '),
          'statesExplored': exact.statesExplored,
        });
      } else {
        matches.add(id);
      }
    }

    stopwatch.stop();
    print('\n========================================');
    print('AUDIT COMPLETE in ${stopwatch.elapsedMilliseconds}ms');
    print('Total matches: ${matches.length} / 150');
    print('Total discrepancies: ${discrepancies.length} / 150');
    print('Total unsolved: ${unsolved.length}');
    print('========================================\n');

    if (discrepancies.isNotEmpty) {
      print('=== DISCREPANCIES FOUND ===');
      for (final d in discrepancies) {
        print('Level ${d['id']} "${d['title']}" (Ch ${d['chapter']}): '
            'Configured Par = ${d['configuredPar']}, '
            'Exact BFS = ${d['exactMoves']}, '
            'Old Solver = ${d['oldSolverMoves']}');
        print('  Exact Path (${d['exactMoves']} moves): ${d['exactPath']}');
        if (d['oldSolverPath'] != null) {
          print('  Old Solver Path (${d['oldSolverMoves']} moves): ${d['oldSolverPath']}');
        }
      }
    }
  });
}
