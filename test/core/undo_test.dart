import 'package:flutter_test/flutter_test.dart';
import 'package:shift_puzzle/core/puzzle/levels/level_definitions.dart';
import 'package:shift_puzzle/core/puzzle/logic/puzzle_engine.dart';
import 'package:shift_puzzle/core/puzzle/models/piece_type.dart';
import 'package:shift_puzzle/core/puzzle/models/shift_direction.dart';

void main() {
  group('PuzzleEngine - Undo Functionality', () {
    test('initial state has canUndo == false', () {
      final engine = PuzzleEngine(LevelDefinitions.getLevel(1));
      expect(engine.canUndo, isFalse);
      expect(engine.undoCount, equals(0));
      expect(engine.undo(), isNull);
    });

    test('normal player shift can be undone, restoring board and moveCount', () {
      final engine = PuzzleEngine(LevelDefinitions.getLevel(1));
      expect(engine.pieceAt(2, 1), equals(PieceType.cyanCircle));
      expect(engine.pieceAt(2, 2), isNull);

      // Perform a shift
      engine.shiftRow(2, ShiftDirection.right);
      expect(engine.moveCount, equals(1));
      expect(engine.pieceAt(2, 2), equals(PieceType.cyanCircle));
      expect(engine.canUndo, isFalse); // Because level 1 is solved in 1 move!

      // Test on Level 4 (not solved in 1 move)
      final engine4 = PuzzleEngine(LevelDefinitions.getLevel(4));
      expect(engine4.moveCount, equals(0));
      expect(engine4.canUndo, isFalse);

      engine4.shiftColumn(4, ShiftDirection.down);
      expect(engine4.moveCount, equals(1));
      expect(engine4.canUndo, isTrue);

      final undone = engine4.undo();
      expect(undone, isNotNull);
      expect(undone!.isRow, isFalse);
      expect(undone.index, equals(4));
      expect(undone.direction, equals(ShiftDirection.down));
      expect(engine4.moveCount, equals(0));
      expect(engine4.canUndo, isFalse);
      // Board is back to initial state
      expect(engine4.pieceAt(2, 4), equals(PieceType.amberDiamond));
    });

    test('multi-step undo sequentially reverses moves in LIFO order', () {
      final engine = PuzzleEngine(LevelDefinitions.getLevel(4));
      engine.shiftColumn(4, ShiftDirection.down);
      engine.shiftRow(3, ShiftDirection.left);
      engine.shiftColumn(2, ShiftDirection.up);

      expect(engine.moveCount, equals(3));
      expect(engine.undoCount, equals(3));

      // Undo 1
      expect(engine.undo()!.direction, equals(ShiftDirection.up));
      expect(engine.moveCount, equals(2));

      // Undo 2
      expect(engine.undo()!.direction, equals(ShiftDirection.left));
      expect(engine.moveCount, equals(1));

      // Undo 3
      expect(engine.undo()!.direction, equals(ShiftDirection.down));
      expect(engine.moveCount, equals(0));
      expect(engine.canUndo, isFalse);
    });

    test('undo during Echo recording removes move from both grid and Echo records', () {
      final engine = PuzzleEngine(LevelDefinitions.getLevel(9));
      engine.echo.startRecording();
      expect(engine.echo.isRecording, isTrue);

      // Record 2 shifts
      engine.shiftColumn(2, ShiftDirection.down);
      engine.shiftColumn(2, ShiftDirection.down);
      expect(engine.echo.length, equals(2));
      expect(engine.moveCount, equals(2));

      // Undo 1 shift
      final undone = engine.undo();
      expect(undone, isNotNull);
      expect(engine.moveCount, equals(1));
      expect(engine.echo.length, equals(1)); // Echo record was removed!
      expect(engine.pieceAt(1, 2), equals(PieceType.cyanCircle));

      // Undo 2nd shift
      engine.undo();
      expect(engine.moveCount, equals(0));
      expect(engine.echo.isEmpty, isTrue);
      expect(engine.pieceAt(0, 2), equals(PieceType.cyanCircle));
    });

    test('undo after stopping Echo recording reverts repositioning while leaving Echo intact', () {
      final engine = PuzzleEngine(LevelDefinitions.getLevel(9));
      engine.echo.startRecording();
      engine.shiftColumn(2, ShiftDirection.down);
      engine.shiftColumn(2, ShiftDirection.down);
      engine.echo.stopRecording();

      expect(engine.echo.isReady, isTrue);
      expect(engine.echo.length, equals(2));
      expect(engine.moveCount, equals(2));

      // Repositioning move
      engine.shiftRow(0, ShiftDirection.left);
      expect(engine.moveCount, equals(3));
      expect(engine.echo.length, equals(2));

      // Undo the repositioning move
      engine.undo();
      expect(engine.moveCount, equals(2));
      // Echo sequence remains strictly intact
      expect(engine.echo.isReady, isTrue);
      expect(engine.echo.length, equals(2));
      expect(engine.echo.records[0].direction, equals(ShiftDirection.down));
      expect(engine.echo.records[1].direction, equals(ShiftDirection.down));
    });

    test('reset clears undo history', () {
      final engine = PuzzleEngine(LevelDefinitions.getLevel(4));
      engine.shiftColumn(4, ShiftDirection.down);
      expect(engine.canUndo, isTrue);

      engine.reset();
      expect(engine.canUndo, isFalse);
      expect(engine.undoCount, equals(0));
      expect(engine.undo(), isNull);
    });
  });
}
