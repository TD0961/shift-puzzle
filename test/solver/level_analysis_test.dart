// ignore_for_file: avoid_print
import 'package:flutter_test/flutter_test.dart';
import 'package:shift_puzzle/core/puzzle/levels/level_definitions.dart';
import 'puzzle_solver.dart';

void main() {
  group('PuzzleSolver Analysis - 150 Handcrafted Levels Quality', () {
    test('Campaign contains exactly 150 unique levels across 15 chapters', () {
      expect(LevelDefinitions.totalLevels, equals(150));

      final seenGrids = <String>{};
      for (int i = 1; i <= 150; i++) {
        final level = LevelDefinitions.getLevel(i);
        expect(level.id, equals(i));
        expect(level.chapter, equals(((i - 1) ~/ 10) + 1));
        expect(level.title.isNotEmpty, isTrue);
        expect(level.targets.isNotEmpty, isTrue);

        // Grid signature combining pieces and targets
        final signature = '${level.targets.map((t) => "${t.pieceType.name}@${t.position.row},${t.position.col}").join(";")}|'
            '${level.initialGrid.expand((row) => row).map((p) => p?.name ?? ".").join()}';
        expect(seenGrids.contains(signature), isFalse,
            reason: 'Level $i has a duplicate layout with an earlier level');
        seenGrids.add(signature);
      }
    });

    for (int i = 1; i <= LevelDefinitions.totalLevels; i++) {
      test('Level $i has a valid minimum solution matching optimalMoves', () {
        final level = LevelDefinitions.getLevel(i);
        final result = PuzzleSolver.solve(level, maxDepth: 12);

        expect(result, isNotNull, reason: 'Level $i is unsolvable within 12 moves');
        print('=== Level $i: "${level.title}" ===');
        print('Pieces: ${level.targets.length}');
        print('Minimum Moves: ${result!.minMoves} (Par: ${level.optimalMoves})');
        print('Optimal Path: ${result.path.map((m) => m.toString()).join(" -> ")}');
        print('States Explored: ${result.statesExplored}');

        expect(result.minMoves, equals(level.optimalMoves),
            reason: 'Level $i optimalMoves does not match solver minMoves');
      });
    }
  });
}

