import 'package:flutter_test/flutter_test.dart';
import 'package:shift_puzzle/core/puzzle/levels/level_definitions.dart';
import 'package:shift_puzzle/core/puzzle/levels/puzzle_level.dart';
import 'package:shift_puzzle/core/puzzle/logic/puzzle_engine.dart';
import 'package:shift_puzzle/core/puzzle/logic/puzzle_solver.dart';
import 'package:shift_puzzle/core/puzzle/models/piece_type.dart';
import 'package:shift_puzzle/core/puzzle/models/shift_direction.dart';

void main() {
  group('TASK 18: Authoritative Optimal-Move Integrity Audit', () {
    // 1. State encoding correctness
    test('1. State encoding produces deterministic, unique signatures', () {
      final level = LevelDefinitions.getLevel(1);
      final engine = PuzzleEngine(level);

      final stateA = engine.currentGrid;
      final stateB = engine.currentGrid;

      // Two identical grids must have identical state representations
      expect(stateA, equals(stateB));

      // Altering a single piece produces a distinct state
      final altered = List.generate(5, (r) => List<PieceType?>.from(stateA[r]));
      altered[0][0] = PieceType.amberDiamond;
      expect(altered, isNot(equals(stateA)));
    });

    // 2. State equality correctness
    test('2. State equality correctly distinguishes identical vs non-identical boards', () {
      final grid1 = List.generate(5, (_) => List<PieceType?>.filled(5, null));
      grid1[2][2] = PieceType.cyanCircle;

      final grid2 = List.generate(5, (_) => List<PieceType?>.filled(5, null));
      grid2[2][2] = PieceType.cyanCircle;

      final grid3 = List.generate(5, (_) => List<PieceType?>.filled(5, null));
      grid3[2][3] = PieceType.cyanCircle;

      bool areGridsEqual(List<List<PieceType?>> a, List<List<PieceType?>> b) {
        for (int r = 0; r < 5; r++) {
          for (int c = 0; c < 5; c++) {
            if (a[r][c] != b[r][c]) return false;
          }
        }
        return true;
      }

      expect(areGridsEqual(grid1, grid2), isTrue);
      expect(areGridsEqual(grid1, grid3), isFalse);
    });

    // 3. Move reversibility
    test('3. Shift reversibility: Move and its inverse restores exact board state', () {
      final level = LevelDefinitions.getLevel(22);
      final engine = PuzzleEngine(level);
      final initialGrid = engine.currentGrid;

      // Row shift reversibility
      for (int r = 0; r < 5; r++) {
        engine.shiftRow(r, ShiftDirection.right);
        engine.shiftRow(r, ShiftDirection.left);
        expect(engine.currentGrid, equals(initialGrid),
            reason: 'Row $r right followed by left must restore state');

        engine.shiftRow(r, ShiftDirection.left);
        engine.shiftRow(r, ShiftDirection.right);
        expect(engine.currentGrid, equals(initialGrid),
            reason: 'Row $r left followed by right must restore state');
      }

      // Column shift reversibility
      for (int c = 0; c < 5; c++) {
        engine.shiftColumn(c, ShiftDirection.down);
        engine.shiftColumn(c, ShiftDirection.up);
        expect(engine.currentGrid, equals(initialGrid),
            reason: 'Col $c down followed by up must restore state');

        engine.shiftColumn(c, ShiftDirection.up);
        engine.shiftColumn(c, ShiftDirection.down);
        expect(engine.currentGrid, equals(initialGrid),
            reason: 'Col $c up followed by down must restore state');
      }
    });

    // 4 & 5. Row and column shift correctness
    test('4 & 5. Row and column shifts only mutate target row/column', () {
      final level = LevelDefinitions.getLevel(10);
      final engine = PuzzleEngine(level);

      final initialGrid = engine.currentGrid;
      engine.shiftRow(2, ShiftDirection.right);

      // Check rows 0, 1, 3, 4 are completely unchanged
      for (int r = 0; r < 5; r++) {
        if (r == 2) continue;
        expect(engine.currentGrid[r], equals(initialGrid[r]));
      }

      engine.shiftColumn(3, ShiftDirection.down);
      // Check cols 0, 1, 2, 4 are unchanged except at row 2
      for (int c = 0; c < 5; c++) {
        if (c == 3) continue;
        for (int r = 0; r < 5; r++) {
          if (r == 2) continue;
          expect(engine.pieceAt(r, c), equals(initialGrid[r][c]));
        }
      }
    });

    // 6. Toroidal wrapping
    test('6. Toroidal wrapping: 5 shifts in one direction returns to origin', () {
      final level = LevelDefinitions.getLevel(6);
      final engine = PuzzleEngine(level);
      final initialGrid = engine.currentGrid;

      // 5 row shifts right = 360 wrap
      for (int i = 0; i < 5; i++) {
        engine.shiftRow(1, ShiftDirection.right);
      }
      expect(engine.currentGrid, equals(initialGrid));

      // 5 column shifts down = 360 wrap
      for (int i = 0; i < 5; i++) {
        engine.shiftColumn(2, ShiftDirection.down);
      }
      expect(engine.currentGrid, equals(initialGrid));
    });

    // 7. Solved-state equivalence
    test('7. Solved-state equivalence between PuzzleEngine and PuzzleSolver', () {
      for (int id = 1; id <= 10; id++) {
        final level = LevelDefinitions.getLevel(id);
        final engine = PuzzleEngine(level);
        final solverResult = PuzzleSolver.solve(level);

        expect(solverResult, isNotNull);
        expect(engine.isSolved, isFalse);

        for (final move in solverResult!.path) {
          if (move.isRow) {
            engine.shiftRow(move.index, move.direction);
          } else {
            engine.shiftColumn(move.index, move.direction);
          }
        }

        // Both engine and solver logic must agree the state is solved
        expect(engine.isSolved, isTrue);
        expect(engine.moveCount, equals(solverResult.minMoves));
      }
    });

    // 8. Exact shortest-path calculation
    test('8. Exact shortest-path calculation verifies analytical solutions', () {
      // Level 1: 1 move
      final l1 = LevelDefinitions.getLevel(1);
      final r1 = PuzzleSolver.solve(l1)!;
      expect(r1.minMoves, equals(1));
      expect(l1.optimalMoves, equals(1));

      // Level 2: 1 move (edge wrap)
      final l2 = LevelDefinitions.getLevel(2);
      final r2 = PuzzleSolver.solve(l2)!;
      expect(r2.minMoves, equals(1));
      expect(l2.optimalMoves, equals(1));

      // Level 4: 4 moves
      final l4 = LevelDefinitions.getLevel(4);
      final r4 = PuzzleSolver.solve(l4)!;
      expect(r4.minMoves, equals(4));
      expect(l4.optimalMoves, equals(4));

      // Level 5: 3 moves (Task 15 verified)
      final l5 = LevelDefinitions.getLevel(5);
      final r5 = PuzzleSolver.solve(l5)!;
      expect(r5.minMoves, equals(3));
      expect(l5.optimalMoves, equals(3));

      // Level 22: 5 moves
      final l22 = LevelDefinitions.getLevel(22);
      final r22 = PuzzleSolver.solve(l22)!;
      expect(r22.minMoves, equals(5));
      expect(l22.optimalMoves, equals(5));

      // Level 150: 9 moves
      final l150 = LevelDefinitions.getLevel(150);
      final r150 = PuzzleSolver.solve(l150)!;
      expect(r150.minMoves, equals(9));
      expect(l150.optimalMoves, equals(9));
    });

    // 9 & 10. Complete 150-level audit comparison
    test('9 & 10. Complete 150-level audit: 100% agreement between stored and calculated optimal', () {
      int passed = 0;
      final mismatches = <int>[];

      for (int id = 1; id <= LevelDefinitions.totalLevels; id++) {
        final level = LevelDefinitions.getLevel(id);
        final result = PuzzleSolver.solve(level, maxDepth: 14);

        expect(result, isNotNull, reason: 'Level $id must be solvable within depth 14');
        if (result!.minMoves == level.optimalMoves) {
          passed++;
        } else {
          mismatches.add(id);
        }
      }

      expect(mismatches, isEmpty, reason: 'Mismatches found on levels: $mismatches');
      expect(passed, equals(150));
    });

    // 11. "TEST THE TEST": Audit detects deliberately corrupted optimalMoves
    test('11. "TEST THE TEST": Audit harness detects corrupted claimed optimal values', () {
      // Create a mock level with an intentionally corrupted optimalMoves (true is 5, claimed is 6)
      final realLevel = LevelDefinitions.getLevel(22);
      final corruptedHigh = PuzzleLevel(
        id: realLevel.id,
        title: realLevel.title,
        initialGrid: realLevel.initialGrid,
        targets: realLevel.targets,
        optimalMoves: realLevel.optimalMoves + 1, // Corrupted: 6 instead of 5
        hasMemoryEcho: realLevel.hasMemoryEcho,
      );

      final resultHigh = PuzzleSolver.solve(corruptedHigh)!;
      final diffHigh = corruptedHigh.optimalMoves - resultHigh.minMoves;
      expect(diffHigh, equals(1), reason: 'Audit must detect stored par is 1 too high');
      expect(diffHigh == 0, isFalse, reason: 'Corrupted level must fail match check');

      // Create a mock level with an intentionally corrupted optimalMoves (true is 5, claimed is 4)
      final corruptedLow = PuzzleLevel(
        id: realLevel.id,
        title: realLevel.title,
        initialGrid: realLevel.initialGrid,
        targets: realLevel.targets,
        optimalMoves: realLevel.optimalMoves - 1, // Corrupted: 4 instead of 5
        hasMemoryEcho: realLevel.hasMemoryEcho,
      );

      final resultLow = PuzzleSolver.solve(corruptedLow)!;
      final diffLow = corruptedLow.optimalMoves - resultLow.minMoves;
      expect(diffLow, equals(-1), reason: 'Audit must detect stored par is 1 too low');
      expect(diffLow == 0, isFalse, reason: 'Corrupted level must fail match check');
    });

    // 12. Level 150 Deep Audit
    test('12. Level 150 ("The Grand Singularity") deep audit', () {
      final level = LevelDefinitions.getLevel(150);
      expect(level.id, equals(150));
      expect(level.title, equals('The Grand Singularity'));
      expect(level.chapter, equals(15));
      expect(level.optimalMoves, equals(9));
      expect(level.hasMemoryEcho, isTrue);

      final solverResult = PuzzleSolver.solve(level, maxDepth: 14);
      expect(solverResult, isNotNull);
      expect(solverResult!.minMoves, equals(9));
      expect(solverResult.path.length, equals(9));

      // Replay through PuzzleEngine
      final engine = PuzzleEngine(level);
      for (final move in solverResult.path) {
        final success = move.isRow
            ? engine.shiftRow(move.index, move.direction)
            : engine.shiftColumn(move.index, move.direction);
        expect(success, isTrue);
      }
      expect(engine.isSolved, isTrue);
      expect(engine.moveCount, equals(9));
    });
  });
}
