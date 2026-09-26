import 'package:flutter_test/flutter_test.dart';
import 'package:shift_puzzle/core/puzzle/levels/level_definitions.dart';
import 'package:shift_puzzle/core/puzzle/levels/puzzle_level.dart';
import 'package:shift_puzzle/core/puzzle/logic/puzzle_engine.dart';
import 'package:shift_puzzle/core/puzzle/models/board_position.dart';
import 'package:shift_puzzle/core/puzzle/models/piece_type.dart';
import 'package:shift_puzzle/core/puzzle/models/puzzle_target.dart';
import 'package:shift_puzzle/core/puzzle/models/shift_direction.dart';

void main() {
  group('PuzzleEngine - Core Shifting & Wrapping', () {
    late PuzzleLevel simpleLevel;

    setUp(() {
      final grid = List.generate(
        5,
        (_) => List<PieceType?>.filled(5, null),
      );
      grid[2][1] = PieceType.cyanCircle;
      grid[2][3] = PieceType.amberDiamond;

      simpleLevel = PuzzleLevel(
        id: 99,
        title: 'Test Level',
        initialGrid: grid,
        targets: const [
          PuzzleTarget(
            pieceType: PieceType.cyanCircle,
            position: BoardPosition(2, 2),
          ),
        ],
      );
    });

    test('shiftRow right moves pieces to adjacent right cells', () {
      final engine = PuzzleEngine(simpleLevel);
      expect(engine.pieceAt(2, 1), equals(PieceType.cyanCircle));
      expect(engine.pieceAt(2, 3), equals(PieceType.amberDiamond));

      final success = engine.shiftRow(2, ShiftDirection.right);
      expect(success, isTrue);

      expect(engine.pieceAt(2, 1), isNull);
      expect(engine.pieceAt(2, 2), equals(PieceType.cyanCircle));
      expect(engine.pieceAt(2, 4), equals(PieceType.amberDiamond));
      expect(engine.moveCount, equals(1));
    });

    test('shiftRow left moves pieces to adjacent left cells', () {
      final engine = PuzzleEngine(simpleLevel);
      final success = engine.shiftRow(2, ShiftDirection.left);
      expect(success, isTrue);

      expect(engine.pieceAt(2, 0), equals(PieceType.cyanCircle));
      expect(engine.pieceAt(2, 2), equals(PieceType.amberDiamond));
      expect(engine.moveCount, equals(1));
    });

    test('shiftRow wraps around board boundaries horizontally', () {
      final engine = PuzzleEngine(simpleLevel);
      // cyanCircle is at (2, 1). Shift left 2 times -> col 1 -> col 0 -> col 4
      engine.shiftRow(2, ShiftDirection.left);
      expect(engine.pieceAt(2, 0), equals(PieceType.cyanCircle));

      engine.shiftRow(2, ShiftDirection.left);
      expect(engine.pieceAt(2, 4), equals(PieceType.cyanCircle));

      // Now shift right 1 time -> wraps from col 4 back to col 0
      engine.shiftRow(2, ShiftDirection.right);
      expect(engine.pieceAt(2, 0), equals(PieceType.cyanCircle));
    });

    test('shiftColumn down moves pieces down and wraps around vertically', () {
      final engine = PuzzleEngine(simpleLevel);
      // cyanCircle is at (2, 1)
      expect(engine.pieceAt(2, 1), equals(PieceType.cyanCircle));

      engine.shiftColumn(1, ShiftDirection.down);
      expect(engine.pieceAt(3, 1), equals(PieceType.cyanCircle));

      engine.shiftColumn(1, ShiftDirection.down);
      expect(engine.pieceAt(4, 1), equals(PieceType.cyanCircle));

      // Wrap around bottom to top (row 4 -> row 0)
      engine.shiftColumn(1, ShiftDirection.down);
      expect(engine.pieceAt(0, 1), equals(PieceType.cyanCircle));
      expect(engine.moveCount, equals(3));
    });

    test('shiftColumn up moves pieces up and wraps around vertically', () {
      final engine = PuzzleEngine(simpleLevel);
      // cyanCircle is at (2, 1)
      engine.shiftColumn(1, ShiftDirection.up);
      expect(engine.pieceAt(1, 1), equals(PieceType.cyanCircle));

      engine.shiftColumn(1, ShiftDirection.up);
      expect(engine.pieceAt(0, 1), equals(PieceType.cyanCircle));

      // Wrap around top to bottom (row 0 -> row 4)
      engine.shiftColumn(1, ShiftDirection.up);
      expect(engine.pieceAt(4, 1), equals(PieceType.cyanCircle));
      expect(engine.moveCount, equals(3));
    });

    test('5 shifts in the same direction on 5-cell line return to original configuration', () {
      final engine = PuzzleEngine(simpleLevel);
      final initialGrid = engine.currentGrid;

      for (int i = 0; i < 5; i++) {
        engine.shiftRow(2, ShiftDirection.right);
      }

      expect(engine.currentGrid, equals(initialGrid));
      expect(engine.moveCount, equals(5));

      for (int i = 0; i < 5; i++) {
        engine.shiftColumn(1, ShiftDirection.up);
      }
      expect(engine.currentGrid, equals(initialGrid));
      expect(engine.moveCount, equals(10));
    });

    test('4 shifts right is equivalent to 1 shift left on a 5-cell line', () {
      final engine1 = PuzzleEngine(simpleLevel);
      final engine2 = PuzzleEngine(simpleLevel);

      for (int i = 0; i < 4; i++) {
        engine1.shiftRow(2, ShiftDirection.right);
      }

      engine2.shiftRow(2, ShiftDirection.left);

      expect(engine1.currentGrid, equals(engine2.currentGrid));
    });
  });

  group('PuzzleEngine - Input Validation & Move Counting', () {
    late PuzzleLevel level;

    setUp(() {
      level = LevelDefinitions.getLevel(1);
    });

    test('valid shifts strictly increment move count', () {
      final engine = PuzzleEngine(level);
      expect(engine.moveCount, equals(0));

      engine.shiftRow(0, ShiftDirection.left);
      expect(engine.moveCount, equals(1));

      engine.shiftColumn(0, ShiftDirection.down);
      expect(engine.moveCount, equals(2));
    });

    test('invalid row index does not modify state or increment moves', () {
      final engine = PuzzleEngine(level);
      final initialGrid = engine.currentGrid;

      final successNegative = engine.shiftRow(-1, ShiftDirection.left);
      expect(successNegative, isFalse);
      expect(engine.moveCount, equals(0));
      expect(engine.currentGrid, equals(initialGrid));

      final successOverflow = engine.shiftRow(5, ShiftDirection.right);
      expect(successOverflow, isFalse);
      expect(engine.moveCount, equals(0));
      expect(engine.currentGrid, equals(initialGrid));
    });

    test('invalid column index does not modify state or increment moves', () {
      final engine = PuzzleEngine(level);
      final initialGrid = engine.currentGrid;

      final successNegative = engine.shiftColumn(-1, ShiftDirection.up);
      expect(successNegative, isFalse);
      expect(engine.moveCount, equals(0));
      expect(engine.currentGrid, equals(initialGrid));

      final successOverflow = engine.shiftColumn(5, ShiftDirection.down);
      expect(successOverflow, isFalse);
      expect(engine.moveCount, equals(0));
      expect(engine.currentGrid, equals(initialGrid));
    });

    test('vertical direction for shiftRow is rejected', () {
      final engine = PuzzleEngine(level);
      final initialGrid = engine.currentGrid;

      final success = engine.shiftRow(2, ShiftDirection.up);
      expect(success, isFalse);
      expect(engine.moveCount, equals(0));
      expect(engine.currentGrid, equals(initialGrid));
    });

    test('horizontal direction for shiftColumn is rejected', () {
      final engine = PuzzleEngine(level);
      final initialGrid = engine.currentGrid;

      final success = engine.shiftColumn(2, ShiftDirection.left);
      expect(success, isFalse);
      expect(engine.moveCount, equals(0));
      expect(engine.currentGrid, equals(initialGrid));
    });
  });

  group('PuzzleEngine - Reset & Win Detection', () {
    test('reset restores initial grid and resets move count', () {
      final level = LevelDefinitions.getLevel(1);
      final engine = PuzzleEngine(level);

      engine.shiftRow(2, ShiftDirection.right);
      expect(engine.moveCount, equals(1));
      expect(engine.isSolved, isTrue);

      engine.reset();
      expect(engine.moveCount, equals(0));
      expect(engine.isSolved, isFalse);
      expect(engine.pieceAt(2, 1), equals(PieceType.cyanCircle));
      expect(engine.pieceAt(2, 2), isNull);
    });

    test('win detection triggers only when all targets have matching pieces', () {
      final level = LevelDefinitions.getLevel(4);
      final engine = PuzzleEngine(level);

      expect(engine.isSolved, isFalse);

      // Solve level 4:
      // Col 2 up -> Circle moves from (2, 2) to (1, 2) [target 1 reached, but diamond not yet]
      engine.shiftColumn(2, ShiftDirection.up);
      expect(engine.isSolved, isFalse);

      // Col 4 down -> amber at (3, 4)
      engine.shiftColumn(4, ShiftDirection.down);
      expect(engine.isSolved, isFalse);

      // Row 3 left once -> amber at (3, 3)
      engine.shiftRow(3, ShiftDirection.left);
      expect(engine.isSolved, isFalse);

      // Row 3 left again -> amber at (3, 2) [both targets reached!]
      engine.shiftRow(3, ShiftDirection.left);
      expect(engine.isSolved, isTrue);
    });
  });

  group('Level Definitions & Deterministic Solvability', () {
    test('Level 1 is solvable in 1 shift', () {
      final engine = PuzzleEngine(LevelDefinitions.getLevel(1));
      expect(engine.isSolved, isFalse);
      engine.shiftRow(2, ShiftDirection.right);
      expect(engine.isSolved, isTrue);
      expect(engine.moveCount, equals(1));
    });

    test('Level 2 demonstrates horizontal wrapping in 1 shift', () {
      final engine = PuzzleEngine(LevelDefinitions.getLevel(2));
      expect(engine.isSolved, isFalse);
      engine.shiftRow(2, ShiftDirection.right);
      expect(engine.isSolved, isTrue);
      expect(engine.moveCount, equals(1));
    });

    test('Level 3 demonstrates vertical wrapping in 1 shift', () {
      final engine = PuzzleEngine(LevelDefinitions.getLevel(3));
      expect(engine.isSolved, isFalse);
      engine.shiftColumn(2, ShiftDirection.down);
      expect(engine.isSolved, isTrue);
      expect(engine.moveCount, equals(1));
    });

    test('Level 4 is solvable in 4 shifts', () {
      final engine = PuzzleEngine(LevelDefinitions.getLevel(4));
      expect(engine.isSolved, isFalse);

      engine.shiftColumn(2, ShiftDirection.up);
      engine.shiftColumn(4, ShiftDirection.down);
      engine.shiftRow(3, ShiftDirection.left);
      engine.shiftRow(3, ShiftDirection.left);

      expect(engine.isSolved, isTrue);
      expect(engine.moveCount, equals(4));
    });

    test('Level 5 is solvable in 4 shifts', () {
      final engine = PuzzleEngine(LevelDefinitions.getLevel(5));
      expect(engine.isSolved, isFalse);

      // Col 1 down 2 -> circle to (2, 1)
      engine.shiftColumn(1, ShiftDirection.down);
      engine.shiftColumn(1, ShiftDirection.down);

      // Col 3 up 2 -> diamond to (2, 3)
      engine.shiftColumn(3, ShiftDirection.up);
      engine.shiftColumn(3, ShiftDirection.up);

      expect(engine.isSolved, isTrue);
      expect(engine.moveCount, equals(4));
    });

    test('Level 6 is solvable in 5 shifts', () {
      final engine = PuzzleEngine(LevelDefinitions.getLevel(6));
      expect(engine.isSolved, isFalse);

      // Col 1 down 2 -> circle to (2, 1)
      engine.shiftColumn(1, ShiftDirection.down);
      engine.shiftColumn(1, ShiftDirection.down);

      // Col 2 up 2 -> diamond to (2, 2)
      engine.shiftColumn(2, ShiftDirection.up);
      engine.shiftColumn(2, ShiftDirection.up);

      // Col 3 down 1 -> rose to (2, 3)
      engine.shiftColumn(3, ShiftDirection.down);

      expect(engine.isSolved, isTrue);
      expect(engine.moveCount, equals(5));
    });

    test('Level 7 is solvable in 5 shifts', () {
      final engine = PuzzleEngine(LevelDefinitions.getLevel(7));
      expect(engine.isSolved, isFalse);

      // Optimal 5-shift sequence: Col 3 up -> Col 3 up -> Col 2 down -> Col 1 down -> Col 1 down
      engine.shiftColumn(3, ShiftDirection.up);
      engine.shiftColumn(3, ShiftDirection.up);
      engine.shiftColumn(2, ShiftDirection.down);
      engine.shiftColumn(1, ShiftDirection.down);
      engine.shiftColumn(1, ShiftDirection.down);

      expect(engine.isSolved, isTrue);
      expect(engine.moveCount, equals(5));
    });

    test('Level 8 is solvable in 6 shifts', () {
      final engine = PuzzleEngine(LevelDefinitions.getLevel(8));
      expect(engine.isSolved, isFalse);

      // Optimal 6-shift sequence: Row 0 left -> Row 2 left -> Col 2 up -> Col 1 down -> Row 2 left -> Row 1 right
      engine.shiftRow(0, ShiftDirection.left);
      engine.shiftRow(2, ShiftDirection.left);
      engine.shiftColumn(2, ShiftDirection.up);
      engine.shiftColumn(1, ShiftDirection.down);
      engine.shiftRow(2, ShiftDirection.left);
      engine.shiftRow(1, ShiftDirection.right);

      expect(engine.isSolved, isTrue);
      expect(engine.moveCount, equals(6));
    });

    test('all levels have 5x5 boards and matching target piece counts', () {
      for (final lvl in LevelDefinitions.levels) {
        expect(lvl.rows, equals(5));
        expect(lvl.cols, equals(5));
        expect(lvl.targets, isNotEmpty);

        // Count pieces on initial grid
        int pieceCount = 0;
        for (int r = 0; r < 5; r++) {
          for (int c = 0; c < 5; c++) {
            if (lvl.initialGrid[r][c] != null) {
              pieceCount++;
            }
          }
        }
        expect(pieceCount, equals(lvl.targets.length),
            reason: 'Level ${lvl.id} has mismatched pieces and targets');
      }
    });
  });
}
