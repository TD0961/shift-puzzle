import 'package:flutter_test/flutter_test.dart';
import 'package:shift_puzzle/core/puzzle/levels/level_definitions.dart';
import 'package:shift_puzzle/core/puzzle/levels/puzzle_level.dart';
import 'package:shift_puzzle/core/puzzle/logic/memory_echo.dart';
import 'package:shift_puzzle/core/puzzle/logic/puzzle_engine.dart';
import 'package:shift_puzzle/core/puzzle/models/board_position.dart';
import 'package:shift_puzzle/core/puzzle/models/echo_status.dart';
import 'package:shift_puzzle/core/puzzle/models/piece_type.dart';
import 'package:shift_puzzle/core/puzzle/models/puzzle_target.dart';
import 'package:shift_puzzle/core/puzzle/models/shift_direction.dart';
import 'package:shift_puzzle/core/puzzle/models/shift_record.dart';

void main() {
  group('MemoryEcho - Pure Domain Logic (Explicit Recording Window)', () {
    late MemoryEcho echo;

    setUp(() {
      echo = MemoryEcho();
    });

    test('initial state is idle and empty', () {
      expect(echo.status, equals(EchoStatus.idle));
      expect(echo.isEmpty, isTrue);
      expect(echo.length, equals(0));
      expect(echo.isIdle, isTrue);
      expect(echo.isRecording, isFalse);
      expect(echo.isReady, isFalse);
      expect(echo.isReplaying, isFalse);
      expect(echo.isUsed, isFalse);
      expect(echo.canReplay, isFalse);
      expect(echo.records, isEmpty);
    });

    test('startRecording transitions from idle to recording', () {
      final started = echo.startRecording();
      expect(started, isTrue);
      expect(echo.status, equals(EchoStatus.recording));
      expect(echo.isRecording, isTrue);
      expect(echo.isIdle, isFalse);

      // Cannot start recording again while already recording
      final duplicateStart = echo.startRecording();
      expect(duplicateStart, isFalse);
      expect(echo.status, equals(EchoStatus.recording));
    });

    test('recordPlayerShift only records when recording is active', () {
      final record1 = ShiftRecord(isRow: true, index: 2, direction: ShiftDirection.right);

      // In idle state, shift is ignored
      echo.recordPlayerShift(record1);
      expect(echo.isEmpty, isTrue);

      // Start recording
      echo.startRecording();
      echo.recordPlayerShift(record1);
      expect(echo.length, equals(1));
      expect(echo.records.first.isRow, isTrue);
      expect(echo.records.first.index, equals(2));
      expect(echo.records.first.direction, equals(ShiftDirection.right));

      final record2 = ShiftRecord(isRow: false, index: 4, direction: ShiftDirection.down);
      echo.recordPlayerShift(record2);
      expect(echo.length, equals(2));
      expect(echo.records[1].isRow, isFalse);
      expect(echo.records[1].index, equals(4));
      expect(echo.records[1].direction, equals(ShiftDirection.down));
    });

    test('order of recorded shifts is strictly preserved', () {
      echo.startRecording();
      echo.recordPlayerShift(ShiftRecord(isRow: true, index: 0, direction: ShiftDirection.left));
      echo.recordPlayerShift(ShiftRecord(isRow: false, index: 1, direction: ShiftDirection.up));
      echo.recordPlayerShift(ShiftRecord(isRow: true, index: 2, direction: ShiftDirection.right));

      expect(echo.length, equals(3));
      expect(echo.records[0].index, equals(0));
      expect(echo.records[0].direction, equals(ShiftDirection.left));
      expect(echo.records[1].index, equals(1));
      expect(echo.records[1].direction, equals(ShiftDirection.up));
      expect(echo.records[2].index, equals(2));
      expect(echo.records[2].direction, equals(ShiftDirection.right));
    });

    test('empty recording: stopRecording with 0 shifts returns to idle', () {
      echo.startRecording();
      expect(echo.isRecording, isTrue);

      final stopped = echo.stopRecording();
      expect(stopped, isTrue);
      expect(echo.status, equals(EchoStatus.idle));
      expect(echo.isIdle, isTrue);
      expect(echo.canReplay, isFalse);
      expect(echo.isEmpty, isTrue);
    });

    test('stopRecording with captured shifts transitions to ready and freezes sequence', () {
      echo.startRecording();
      echo.recordPlayerShift(ShiftRecord(isRow: true, index: 1, direction: ShiftDirection.right));
      echo.recordPlayerShift(ShiftRecord(isRow: false, index: 2, direction: ShiftDirection.down));

      final stopped = echo.stopRecording();
      expect(stopped, isTrue);
      expect(echo.status, equals(EchoStatus.ready));
      expect(echo.isReady, isTrue);
      expect(echo.canReplay, isTrue);
      expect(echo.length, equals(2));

      // Shifts made after stopping recording are strictly ignored
      echo.recordPlayerShift(ShiftRecord(isRow: true, index: 4, direction: ShiftDirection.left));
      expect(echo.length, equals(2));
    });

    test('lifecycle: idle -> recording -> ready -> replaying -> used', () {
      echo.startRecording();
      echo.recordPlayerShift(ShiftRecord(isRow: true, index: 1, direction: ShiftDirection.right));
      echo.stopRecording();
      expect(echo.status, equals(EchoStatus.ready));

      final replayStarted = echo.markReplaying();
      expect(replayStarted, isTrue);
      expect(echo.status, equals(EchoStatus.replaying));
      expect(echo.isReplaying, isTrue);
      expect(echo.canReplay, isFalse);

      echo.markUsed();
      expect(echo.status, equals(EchoStatus.used));
      expect(echo.isUsed, isTrue);
      expect(echo.isReady, isFalse);
      expect(echo.canReplay, isFalse);

      // Once used, startRecording and recordPlayerShift are rejected
      expect(echo.startRecording(), isFalse);
      echo.recordPlayerShift(ShiftRecord(isRow: false, index: 0, direction: ShiftDirection.down));
      expect(echo.length, equals(1));
    });

    test('clear resets history and status to idle', () {
      echo.startRecording();
      echo.recordPlayerShift(ShiftRecord(isRow: true, index: 1, direction: ShiftDirection.right));
      echo.stopRecording();
      expect(echo.isReady, isTrue);

      echo.clear();
      expect(echo.status, equals(EchoStatus.idle));
      expect(echo.isIdle, isTrue);
      expect(echo.isEmpty, isTrue);
      expect(echo.length, equals(0));
    });
  });

  group('PuzzleEngine - Memory Echo Integration & Repositioning', () {
    late PuzzleLevel testLevel;

    setUp(() {
      final grid = List.generate(5, (_) => List<PieceType?>.filled(5, null));
      grid[0][2] = PieceType.cyanCircle;
      grid[0][4] = PieceType.amberDiamond;

      testLevel = PuzzleLevel(
        id: 99,
        title: 'Echo Integration Level',
        initialGrid: grid,
        targets: const [
          PuzzleTarget(
            pieceType: PieceType.cyanCircle,
            position: BoardPosition(4, 2),
          ),
          PuzzleTarget(
            pieceType: PieceType.amberDiamond,
            position: BoardPosition(2, 3),
          ),
        ],
        optimalMoves: 5,
        hasMemoryEcho: true,
      );
    });

    test('player shifts are only recorded when recording is active', () {
      final engine = PuzzleEngine(testLevel);
      expect(engine.echo.isIdle, isTrue);

      // Shift before recording
      engine.shiftColumn(2, ShiftDirection.down);
      expect(engine.moveCount, equals(1));
      expect(engine.echo.isEmpty, isTrue); // NOT recorded

      // Start recording
      engine.echo.startRecording();
      engine.shiftColumn(2, ShiftDirection.down);
      expect(engine.moveCount, equals(2));
      expect(engine.echo.length, equals(1)); // Recorded

      // Invalid shifts are not recorded even during recording
      final invalidSuccess = engine.shiftRow(-1, ShiftDirection.right);
      expect(invalidSuccess, isFalse);
      expect(engine.echo.length, equals(1));

      // Stop recording
      engine.echo.stopRecording();
      expect(engine.echo.isReady, isTrue);

      // Repositioning shifts made after stopping recording
      engine.shiftRow(0, ShiftDirection.left);
      expect(engine.moveCount, equals(3));
      expect(engine.echo.length, equals(1)); // NOT appended to frozen echo!
    });

    test('restart clears echo history and resets moves', () {
      final engine = PuzzleEngine(testLevel);
      engine.echo.startRecording();
      engine.shiftColumn(2, ShiftDirection.down);
      engine.echo.stopRecording();

      expect(engine.moveCount, equals(1));
      expect(engine.echo.length, equals(1));
      expect(engine.echo.isReady, isTrue);

      engine.reset();
      expect(engine.moveCount, equals(0));
      expect(engine.echo.isEmpty, isTrue);
      expect(engine.echo.status, equals(EchoStatus.idle));
    });

    test('switching levels produces a clean engine with idle echo', () {
      final engine1 = PuzzleEngine(LevelDefinitions.getLevel(9));
      engine1.echo.startRecording();
      engine1.shiftColumn(2, ShiftDirection.down);
      engine1.echo.stopRecording();
      expect(engine1.echo.length, equals(1));

      final engine2 = PuzzleEngine(LevelDefinitions.getLevel(1));
      expect(engine2.echo.isEmpty, isTrue);
      expect(engine2.echo.status, equals(EchoStatus.idle));
    });

    test('replaying frozen echo does not count as player moves and does not self-record', () {
      final engine = PuzzleEngine(testLevel);

      // Record 2 shifts
      engine.echo.startRecording();
      engine.shiftColumn(2, ShiftDirection.down);
      engine.shiftColumn(2, ShiftDirection.down);
      engine.echo.stopRecording();
      expect(engine.moveCount, equals(2));
      expect(engine.echo.length, equals(2));
      expect(engine.pieceAt(2, 2), equals(PieceType.cyanCircle));

      // Replay
      final records = List<ShiftRecord>.from(engine.echo.records);
      engine.echo.markReplaying();
      for (final rec in records) {
        if (rec.isRow) {
          engine.shiftRow(rec.index, rec.direction, isEcho: true);
        } else {
          engine.shiftColumn(rec.index, rec.direction, isEcho: true);
        }
      }
      engine.echo.markUsed();

      // Board has advanced (Circle shifted from (2, 2) to (4, 2))
      expect(engine.pieceAt(4, 2), equals(PieceType.cyanCircle));

      // Player move count remains strictly 2!
      expect(engine.moveCount, equals(2));

      // Echo was not self-recorded into
      expect(engine.echo.length, equals(2));
      expect(engine.echo.isUsed, isTrue);
    });

    test('Level 9 is solved via Record -> Stop -> Reposition -> Echo -> Finish in 5 player moves', () {
      final engine = PuzzleEngine(LevelDefinitions.getLevel(9));
      expect(engine.level.hasMemoryEcho, isTrue);
      expect(engine.isSolved, isFalse);
      expect(engine.moveCount, equals(0));
      expect(engine.echo.isIdle, isTrue);

      // 1. [REC] Player starts recording
      expect(engine.echo.startRecording(), isTrue);
      expect(engine.echo.isRecording, isTrue);

      // 2. Col 2 down twice (Circle moves from (0, 2) -> (1, 2) -> (2, 2))
      engine.shiftColumn(2, ShiftDirection.down);
      engine.shiftColumn(2, ShiftDirection.down);
      expect(engine.moveCount, equals(2));
      expect(engine.echo.length, equals(2));
      expect(engine.pieceAt(2, 2), equals(PieceType.cyanCircle));

      // 3. [STOP] Player stops recording -> sequence frozen at 2 shifts
      expect(engine.echo.stopRecording(), isTrue);
      expect(engine.echo.isReady, isTrue);
      expect(engine.echo.canReplay, isTrue);
      expect(engine.echo.length, equals(2));

      // 4. REPOSITIONING: Player shifts Diamond across row 0 (NOT in Echo!)
      engine.shiftRow(0, ShiftDirection.left);
      engine.shiftRow(0, ShiftDirection.left);
      // Diamond is now at (0, 2) (top of column 2)
      expect(engine.pieceAt(0, 2), equals(PieceType.amberDiamond));
      // Moves has incremented to 4
      expect(engine.moveCount, equals(4));
      // Echo remains strictly frozen with 2 shifts!
      expect(engine.echo.length, equals(2));

      // 5. [ECHO] Trigger replay of the 2 recorded shifts
      engine.echo.markReplaying();
      for (final rec in engine.echo.records) {
        if (rec.isRow) {
          engine.shiftRow(rec.index, rec.direction, isEcho: true);
        } else {
          engine.shiftColumn(rec.index, rec.direction, isEcho: true);
        }
      }
      engine.echo.markUsed();

      // Echo replays Col 2 down twice:
      // - Circle at (2, 2) shifts down 2 to (4, 2) [Target 1 seated!]
      // - Diamond at (0, 2) shifts down 2 to (2, 2)
      expect(engine.pieceAt(4, 2), equals(PieceType.cyanCircle));
      expect(engine.pieceAt(2, 2), equals(PieceType.amberDiamond));
      // Move count must NOT have increased!
      expect(engine.moveCount, equals(4));
      expect(engine.echo.isUsed, isTrue);

      // 6. FINISH: Final player move (Row 2 right)
      engine.shiftRow(2, ShiftDirection.right);
      expect(engine.pieceAt(2, 3), equals(PieceType.amberDiamond));
      expect(engine.pieceAt(4, 2), equals(PieceType.cyanCircle));

      // Puzzle is fully solved!
      expect(engine.isSolved, isTrue);
      expect(engine.moveCount, equals(5));
      expect(engine.echo.length, equals(2));
    });

    test('Level 10 (The Conveyor) solves in 5 moves via programmed column conveyor replay', () {
      final engine = PuzzleEngine(LevelDefinitions.getLevel(10));
      expect(engine.level.id, equals(10));
      expect(engine.level.hasMemoryEcho, isTrue);
      expect(engine.isSolved, isFalse);

      // 1. [REC] Start recording conveyor shifts
      engine.echo.startRecording();
      // Col 3 down twice
      engine.shiftColumn(3, ShiftDirection.down);
      engine.shiftColumn(3, ShiftDirection.down);
      expect(engine.moveCount, equals(2));
      expect(engine.echo.length, equals(2));

      // 2. [STOP] Freeze conveyor program
      engine.echo.stopRecording();
      expect(engine.echo.isReady, isTrue);

      // 3. REPOSITIONING: Load all 3 pieces into conveyor Column 3
      engine.shiftRow(0, ShiftDirection.right); // Circle from (0, 2) -> (0, 3)
      engine.shiftRow(2, ShiftDirection.right); // Square from (2, 2) -> (2, 3)
      engine.shiftRow(4, ShiftDirection.right); // Diamond from (4, 2) -> (4, 3)
      expect(engine.moveCount, equals(5));

      expect(engine.pieceAt(0, 3), equals(PieceType.cyanCircle));
      expect(engine.pieceAt(2, 3), equals(PieceType.roseSquare));
      expect(engine.pieceAt(4, 3), equals(PieceType.amberDiamond));

      // 4. [ECHO] Trigger conveyor replay (Col 3 down twice)
      engine.echo.markReplaying();
      for (final rec in engine.echo.records) {
        if (rec.isRow) {
          engine.shiftRow(rec.index, rec.direction, isEcho: true);
        } else {
          engine.shiftColumn(rec.index, rec.direction, isEcho: true);
        }
      }
      engine.echo.markUsed();

      // All 3 pieces delivered directly to their targets simultaneously!
      expect(engine.pieceAt(2, 3), equals(PieceType.cyanCircle));
      expect(engine.pieceAt(4, 3), equals(PieceType.roseSquare));
      expect(engine.pieceAt(1, 3), equals(PieceType.amberDiamond));

      // Solved with 5 player moves!
      expect(engine.isSolved, isTrue);
      expect(engine.moveCount, equals(5));
    });

    test('Level 11 (Temporal Cross) is deterministic and solvable', () {
      final engine = PuzzleEngine(LevelDefinitions.getLevel(11));
      expect(engine.level.id, equals(11));
      expect(engine.level.hasMemoryEcho, isTrue);
      expect(engine.isSolved, isFalse);

      // Solve with standard optimal path found by solver:
      // [Row 2 left, Row 3 right, Row 3 right, Col 1 up, Row 2 left, Row 1 right]
      engine.shiftRow(2, ShiftDirection.left);
      engine.shiftRow(3, ShiftDirection.right);
      engine.shiftRow(3, ShiftDirection.right);
      engine.shiftColumn(1, ShiftDirection.up);
      engine.shiftRow(2, ShiftDirection.left);
      engine.shiftRow(1, ShiftDirection.right);

      expect(engine.isSolved, isTrue);
      expect(engine.moveCount, equals(6));
    });
  });
}
