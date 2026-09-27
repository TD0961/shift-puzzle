// ignore_for_file: avoid_print
import 'package:flutter_test/flutter_test.dart';
import 'package:shift_puzzle/core/puzzle/levels/level_definitions.dart';
import 'campaign_exact_bfs_audit_test.dart';

void main() {
  test('Campaign Difficulty Hierarchy Analysis across all 15 Chapters', () {
    final chapterNames = [
      'Foundations',
      'Temporal Echo',
      'Orthogonal Crossroads',
      'Dual Echo Harmony',
      'Grandmaster Crucible',
      'Toroidal Labyrinths',
      'Echo Cadence',
      'Symmetry & Inverse',
      'Echo Weaver',
      'Century Crucible',
      'Quantum Echoes',
      'Parity & Flux',
      'Echo Resonance',
      'Geometric Horizons',
      'The Outer Sanctum',
    ];

    print('\n======================================================================');
    print('CAMPAIGN DIFFICULTY HIERARCHY & METRICS (LEVELS 1–150)');
    print('======================================================================\n');

    for (int ch = 1; ch <= 15; ch++) {
      final startId = (ch - 1) * 10 + 1;
      final endId = ch * 10;
      final chapterTitle = chapterNames[ch - 1];

      final optimalMovesList = <int>[];
      final statesList = <int>[];
      final piecesList = <int>[];
      int echoCount = 0;

      final levelDetails = <String>[];

      for (int id = startId; id <= endId; id++) {
        final level = LevelDefinitions.getLevel(id);
        final exact = CorrectBidirectionalBfs.solve(level, maxDepth: 12)!;
        final opt = exact.minMoves;
        optimalMovesList.add(opt);
        statesList.add(exact.statesExplored);
        piecesList.add(level.targets.length);
        if (level.hasMemoryEcho) echoCount++;

        final delta = level.optimalMoves != opt ? ' [WAS ${level.optimalMoves}]' : '';
        levelDetails.add('L$id: opt=$opt$delta, pieces=${level.targets.length}, states=${exact.statesExplored}${level.hasMemoryEcho ? ', ECHO' : ''}');
      }

      optimalMovesList.sort();
      final minOpt = optimalMovesList.first;
      final maxOpt = optimalMovesList.last;
      final avgOpt = optimalMovesList.reduce((a, b) => a + b) / optimalMovesList.length;
      final medianOpt = (optimalMovesList[4] + optimalMovesList[5]) / 2.0;

      final avgStates = statesList.reduce((a, b) => a + b) / statesList.length;
      final avgPieces = piecesList.reduce((a, b) => a + b) / piecesList.length;
      final echoPct = (echoCount / 10.0) * 100;

      print('----------------------------------------------------------------------');
      print('CHAPTER $ch: $chapterTitle (Levels $startId–$endId)');
      print('----------------------------------------------------------------------');
      print('Optimal Moves: Min=$minOpt, Max=$maxOpt, Avg=${avgOpt.toStringAsFixed(1)}, Median=${medianOpt.toStringAsFixed(1)}');
      print('Avg Pieces: ${avgPieces.toStringAsFixed(1)}, Avg States Explored: ${avgStates.toStringAsFixed(0)}, Echo %: ${echoPct.toStringAsFixed(0)}%');
      print('Levels:');
      for (final l in levelDetails) {
        print('  $l');
      }
      print('');
    }
  });
}
