import '../models/piece_type.dart';
import '../models/puzzle_target.dart';

class PuzzleLevel {
  final int id;
  final String title;
  final String? hint;
  final int rows;
  final int cols;
  final List<List<PieceType?>> initialGrid;
  final List<PuzzleTarget> targets;
  final int optimalMoves;
  final bool hasMemoryEcho;

  const PuzzleLevel({
    required this.id,
    required this.title,
    this.hint,
    this.rows = 5,
    this.cols = 5,
    required this.initialGrid,
    required this.targets,
    this.optimalMoves = 1,
    this.hasMemoryEcho = false,
  });

  /// Chapter number (1 to 10, 10 levels per chapter).
  int get chapter => ((id - 1) ~/ 10) + 1;

  /// Thematic title of the chapter.
  String get chapterTitle {
    switch (chapter) {
      case 1:
        return 'The Foundations';
      case 2:
        return 'Temporal Awakening';
      case 3:
        return 'Spatial Matrices';
      case 4:
        return 'Complex Machines';
      case 5:
        return 'Grandmaster';
      case 6:
        return 'Advanced Echo';
      case 7:
        return 'Spatial Paradoxes';
      case 8:
        return 'Temporal Machines';
      case 9:
        return 'Mastery';
      case 10:
        return 'The Final Shift';
      case 11:
        return 'Harmonic Resonance';
      case 12:
        return 'Quantum Entanglement';
      case 13:
        return 'The Echo Nexus';
      case 14:
        return 'Chrono Dynamics';
      case 15:
        return 'The Singularity';
      default:
        return 'Campaign';
    }
  }
}
