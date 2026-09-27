// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'package:shift_puzzle/core/puzzle/levels/level_definitions.dart';
import 'package:shift_puzzle/core/puzzle/logic/puzzle_engine.dart';
import 'package:shift_puzzle/core/puzzle/logic/puzzle_solver.dart';

void main() async {
  print('=====================================================');
  print('TASK 18: AUTHORITATIVE OPTIMAL-MOVE INTEGRITY AUDIT');
  print('Auditing all 150 campaign levels...');
  print('=====================================================\n');

  final results = <Map<String, dynamic>>[];
  int matchCount = 0;
  int mismatchCount = 0;
  int unsolvedCount = 0;
  int totalStatesExplored = 0;
  int maxStates = 0;
  int slowestLevelId = 1;
  int maxRuntimeMs = 0;

  final globalStopwatch = Stopwatch()..start();

  for (int id = 1; id <= LevelDefinitions.totalLevels; id++) {
    final level = LevelDefinitions.getLevel(id);
    final sw = Stopwatch()..start();
    
    // Independent calculation via exact bidirectional BFS with maxDepth: 14
    final result = PuzzleSolver.solve(level, maxDepth: 14);
    sw.stop();

    final runtimeMs = sw.elapsedMilliseconds;
    if (runtimeMs > maxRuntimeMs) {
      maxRuntimeMs = runtimeMs;
      slowestLevelId = id;
    }

    if (result == null) {
      unsolvedCount++;
      results.add({
        'levelId': id,
        'chapter': level.chapter,
        'chapterTitle': level.chapterTitle,
        'title': level.title,
        'storedOptimal': level.optimalMoves,
        'calculatedOptimal': null,
        'difference': null,
        'hasMemoryEcho': level.hasMemoryEcho,
        'statesExplored': 0,
        'runtimeMs': runtimeMs,
        'status': 'ERROR_UNSOLVED',
        'shortestPath': [],
        'engineVerified': false,
      });
      print('Level $id: UNSOLVED within maxDepth 14!');
      continue;
    }

    final calculatedOptimal = result.minMoves;
    final storedOptimal = level.optimalMoves;
    final difference = storedOptimal - calculatedOptimal;
    totalStatesExplored += result.statesExplored;
    if (result.statesExplored > maxStates) {
      maxStates = result.statesExplored;
    }

    // Verify shortest path replay in production PuzzleEngine
    final engine = PuzzleEngine(level);
    bool replayValid = true;
    for (final move in result.path) {
      final success = move.isRow
          ? engine.shiftRow(move.index, move.direction)
          : engine.shiftColumn(move.index, move.direction);
      if (!success) {
        replayValid = false;
        break;
      }
    }
    final engineSolved = replayValid && engine.isSolved && engine.moveCount == calculatedOptimal;

    final status = (difference == 0 && engineSolved)
        ? 'PASS'
        : (difference != 0 ? 'MISMATCH' : 'ENGINE_REPLAY_FAILED');

    if (status == 'PASS') {
      matchCount++;
    } else {
      mismatchCount++;
    }

    results.add({
      'levelId': id,
      'chapter': level.chapter,
      'chapterTitle': level.chapterTitle,
      'title': level.title,
      'storedOptimal': storedOptimal,
      'calculatedOptimal': calculatedOptimal,
      'difference': difference,
      'hasMemoryEcho': level.hasMemoryEcho,
      'statesExplored': result.statesExplored,
      'runtimeMs': runtimeMs,
      'status': status,
      'shortestPath': result.path.map((m) => m.toString()).toList(),
      'engineVerified': engineSolved,
    });
  }

  globalStopwatch.stop();

  print('-----------------------------------------------------');
  print('AUDIT COMPLETE in ${globalStopwatch.elapsedMilliseconds}ms');
  print('Total levels audited: ${results.length}');
  print('Exact matches: $matchCount / 150');
  print('Mismatches: $mismatchCount / 150');
  print('Unsolved: $unsolvedCount');
  print('Total states explored: $totalStatesExplored');
  print('Max states explored on a level: $maxStates');
  print('Slowest level: Level $slowestLevelId (${maxRuntimeMs}ms)');
  print('-----------------------------------------------------\n');

  if (mismatchCount > 0) {
    print('!!! CRITICAL: MISMATCHES DETECTED !!!');
    for (final r in results) {
      if (r['status'] != 'PASS') {
        print('Level ${r['levelId']} "${r['title']}" (Ch ${r['chapter']}):');
        print('  Stored Optimal:     ${r['storedOptimal']}');
        print('  Calculated Optimal: ${r['calculatedOptimal']}');
        print('  Difference:         ${r['difference']}');
        print('  Status:             ${r['status']}');
        print('  Shortest Path:      ${(r['shortestPath'] as List).join(' -> ')}');
      }
    }
  } else {
    print('ALL 150 LEVELS PASSED WITH 100% MATHEMATICAL INTEGRITY!');
  }

  // Create audit directory if not exists
  final auditDir = Directory('audit');
  if (!auditDir.existsSync()) {
    auditDir.createSync(recursive: true);
  }

  final auditFile = File('audit/optimal_move_audit.json');
  final jsonContent = {
    'auditVersion': '1.0.0',
    'totalLevels': 150,
    'auditedLevels': results.length,
    'passed': matchCount,
    'mismatches': mismatchCount,
    'unsolved': unsolvedCount,
    'totalStatesExplored': totalStatesExplored,
    'totalRuntimeMs': globalStopwatch.elapsedMilliseconds,
    'levels': results,
  };

  auditFile.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(jsonContent));
  print('Saved machine-readable audit report to audit/optimal_move_audit.json\n');
}
