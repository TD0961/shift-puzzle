import '../models/board_position.dart';
import '../models/piece_type.dart';
import '../models/puzzle_target.dart';
import 'puzzle_level.dart';

class LevelDefinitions {
  static List<List<PieceType?>> _createEmptyGrid({int rows = 5, int cols = 5}) {
    return List.generate(rows, (_) => List<PieceType?>.filled(cols, null));
  }

  static List<PuzzleLevel> get levels => [
        // CHAPTER 1: The Foundations (Levels 1–10)
        _buildLevel1(),
        _buildLevel2(),
        _buildLevel3(),
        _buildLevel4(),
        _buildLevel5(),
        _buildLevel6(),
        _buildLevel7(),
        _buildLevel8(),
        _buildLevel9(),
        _buildLevel10(),

        // CHAPTER 2: Temporal Awakening (Levels 11–20)
        _buildLevel11(),
        _buildLevel12(),
        _buildLevel13(),
        _buildLevel14(),
        _buildLevel15(),
        _buildLevel16(),
        _buildLevel17(),
        _buildLevel18(),
        _buildLevel19(),
        _buildLevel20(),

        // CHAPTER 3: Spatial Matrices (Levels 21–30)
        _buildLevel21(),
        _buildLevel22(),
        _buildLevel23(),
        _buildLevel24(),
        _buildLevel25(),
        _buildLevel26(),
        _buildLevel27(),
        _buildLevel28(),
        _buildLevel29(),
        _buildLevel30(),

        // CHAPTER 4: Complex Machines (Levels 31–40)
        _buildLevel31(),
        _buildLevel32(),
        _buildLevel33(),
        _buildLevel34(),
        _buildLevel35(),
        _buildLevel36(),
        _buildLevel37(),
        _buildLevel38(),
        _buildLevel39(),
        _buildLevel40(),

        // CHAPTER 5: Grandmaster (Levels 41–50)
        _buildLevel41(),
        _buildLevel42(),
        _buildLevel43(),
        _buildLevel44(),
        _buildLevel45(),
        _buildLevel46(),
        _buildLevel47(),
        _buildLevel48(),
        _buildLevel49(),
        _buildLevel50(),

        // CHAPTER 6: Advanced Echo (Levels 51–60)
        _buildLevel51(),
        _buildLevel52(),
        _buildLevel53(),
        _buildLevel54(),
        _buildLevel55(),
        _buildLevel56(),
        _buildLevel57(),
        _buildLevel58(),
        _buildLevel59(),
        _buildLevel60(),

        // CHAPTER 7: Spatial Paradoxes (Levels 61–70)
        _buildLevel61(),
        _buildLevel62(),
        _buildLevel63(),
        _buildLevel64(),
        _buildLevel65(),
        _buildLevel66(),
        _buildLevel67(),
        _buildLevel68(),
        _buildLevel69(),
        _buildLevel70(),

        // CHAPTER 8: Temporal Machines (Levels 71–80)
        _buildLevel71(),
        _buildLevel72(),
        _buildLevel73(),
        _buildLevel74(),
        _buildLevel75(),
        _buildLevel76(),
        _buildLevel77(),
        _buildLevel78(),
        _buildLevel79(),
        _buildLevel80(),

        // CHAPTER 9: Mastery (Levels 81–90)
        _buildLevel81(),
        _buildLevel82(),
        _buildLevel83(),
        _buildLevel84(),
        _buildLevel85(),
        _buildLevel86(),
        _buildLevel87(),
        _buildLevel88(),
        _buildLevel89(),
        _buildLevel90(),

        // CHAPTER 10: The Final Shift (Levels 91–100)
        _buildLevel91(),
        _buildLevel92(),
        _buildLevel93(),
        _buildLevel94(),
        _buildLevel95(),
        _buildLevel96(),
        _buildLevel97(),
        _buildLevel98(),
        _buildLevel99(),
        _buildLevel100(),
        // CHAPTER 11: Harmonic Resonance (Levels 101–110)
        _buildLevel101(),
        _buildLevel102(),
        _buildLevel103(),
        _buildLevel104(),
        _buildLevel105(),
        _buildLevel106(),
        _buildLevel107(),
        _buildLevel108(),
        _buildLevel109(),
        _buildLevel110(),

        // CHAPTER 12: Quantum Entanglement (Levels 111–120)
        _buildLevel111(),
        _buildLevel112(),
        _buildLevel113(),
        _buildLevel114(),
        _buildLevel115(),
        _buildLevel116(),
        _buildLevel117(),
        _buildLevel118(),
        _buildLevel119(),
        _buildLevel120(),

        // CHAPTER 13: The Echo Nexus (Levels 121–130)
        _buildLevel121(),
        _buildLevel122(),
        _buildLevel123(),
        _buildLevel124(),
        _buildLevel125(),
        _buildLevel126(),
        _buildLevel127(),
        _buildLevel128(),
        _buildLevel129(),
        _buildLevel130(),

        // CHAPTER 14: Chrono Dynamics (Levels 131–140)
        _buildLevel131(),
        _buildLevel132(),
        _buildLevel133(),
        _buildLevel134(),
        _buildLevel135(),
        _buildLevel136(),
        _buildLevel137(),
        _buildLevel138(),
        _buildLevel139(),
        _buildLevel140(),

        // CHAPTER 15: The Singularity (Levels 141–150)
        _buildLevel141(),
        _buildLevel142(),
        _buildLevel143(),
        _buildLevel144(),
        _buildLevel145(),
        _buildLevel146(),
        _buildLevel147(),
        _buildLevel148(),
        _buildLevel149(),
        _buildLevel150(),
      ];

  static int get totalLevels => levels.length;

  static PuzzleLevel getLevel(int id) {
    if (id < 1 || id > levels.length) {
      return levels.first;
    }
    return levels[id - 1];
  }

  // ==========================================
  // CHAPTER 1: THE FOUNDATIONS (Levels 1–10)
  // ==========================================

  // LEVEL 1: 1 shift right on row 2
  static PuzzleLevel _buildLevel1() {
    final grid = _createEmptyGrid();
    grid[2][1] = PieceType.cyanCircle;

    return PuzzleLevel(
      id: 1,
      title: 'First Shift',
      hint: 'Swipe row 3 right to place the piece on the target.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(
          pieceType: PieceType.cyanCircle,
          position: BoardPosition(2, 2),
        ),
      ],
      optimalMoves: 1,
    );
  }

  // LEVEL 2: 1 shift right on row 2 (wraps from col 4 to col 0)
  static PuzzleLevel _buildLevel2() {
    final grid = _createEmptyGrid();
    grid[2][4] = PieceType.cyanCircle;

    return PuzzleLevel(
      id: 2,
      title: 'The Edge Wrap',
      hint: 'Rows wrap around! Swipe row 3 right across the edge.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(
          pieceType: PieceType.cyanCircle,
          position: BoardPosition(2, 0),
        ),
      ],
      optimalMoves: 1,
    );
  }

  // LEVEL 3: 1 shift down on column 2 (wraps from row 4 to row 0)
  static PuzzleLevel _buildLevel3() {
    final grid = _createEmptyGrid();
    grid[4][2] = PieceType.amberDiamond;

    return PuzzleLevel(
      id: 3,
      title: 'Vertical Shift',
      hint: 'Columns also wrap. Swipe column 3 down.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(
          pieceType: PieceType.amberDiamond,
          position: BoardPosition(0, 2),
        ),
      ],
      optimalMoves: 1,
    );
  }

  // LEVEL 4: 2 pieces, requires choosing row and column movement
  static PuzzleLevel _buildLevel4() {
    final grid = _createEmptyGrid();
    grid[2][2] = PieceType.cyanCircle;
    grid[2][4] = PieceType.amberDiamond;

    return PuzzleLevel(
      id: 4,
      title: 'Crossroads',
      hint: 'Coordinate row and column shifts to reach both targets.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(
          pieceType: PieceType.cyanCircle,
          position: BoardPosition(1, 2),
        ),
        PuzzleTarget(
          pieceType: PieceType.amberDiamond,
          position: BoardPosition(3, 2),
        ),
      ],
      optimalMoves: 4,
    );
  }

  // LEVEL 5: Dual Alignment
  static PuzzleLevel _buildLevel5() {
    final grid = _createEmptyGrid();
    grid[0][1] = PieceType.cyanCircle;
    grid[4][3] = PieceType.amberDiamond;

    return PuzzleLevel(
      id: 5,
      title: 'Dual Alignment',
      hint: 'Shift independent columns into the target row.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(
          pieceType: PieceType.cyanCircle,
          position: BoardPosition(2, 1),
        ),
        PuzzleTarget(
          pieceType: PieceType.amberDiamond,
          position: BoardPosition(2, 3),
        ),
      ],
      optimalMoves: 4,
    );
  }

  // LEVEL 6: Trio Harmony
  static PuzzleLevel _buildLevel6() {
    final grid = _createEmptyGrid();
    grid[0][1] = PieceType.cyanCircle;
    grid[4][2] = PieceType.amberDiamond;
    grid[1][3] = PieceType.roseSquare;

    return PuzzleLevel(
      id: 6,
      title: 'Trio Harmony',
      hint: 'Bring three pieces from different columns into harmony.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(
          pieceType: PieceType.cyanCircle,
          position: BoardPosition(2, 1),
        ),
        PuzzleTarget(
          pieceType: PieceType.amberDiamond,
          position: BoardPosition(2, 2),
        ),
        PuzzleTarget(
          pieceType: PieceType.roseSquare,
          position: BoardPosition(2, 3),
        ),
      ],
      optimalMoves: 5,
    );
  }

  // LEVEL 7: Triad Orbit
  static PuzzleLevel _buildLevel7() {
    final grid = _createEmptyGrid();
    grid[0][1] = PieceType.cyanCircle;
    grid[4][3] = PieceType.amberDiamond;
    grid[1][2] = PieceType.roseSquare;

    return PuzzleLevel(
      id: 7,
      title: 'Triad Orbit',
      hint: 'Bring three drifting stars into horizontal harmony.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(
          pieceType: PieceType.cyanCircle,
          position: BoardPosition(2, 1),
        ),
        PuzzleTarget(
          pieceType: PieceType.roseSquare,
          position: BoardPosition(2, 2),
        ),
        PuzzleTarget(
          pieceType: PieceType.amberDiamond,
          position: BoardPosition(2, 3),
        ),
      ],
      optimalMoves: 5,
    );
  }

  // LEVEL 8: Cross Alignment
  static PuzzleLevel _buildLevel8() {
    final grid = _createEmptyGrid();
    grid[0][2] = PieceType.cyanCircle;
    grid[4][2] = PieceType.amberDiamond;
    grid[2][0] = PieceType.roseSquare;

    return PuzzleLevel(
      id: 8,
      title: 'Cross Alignment',
      hint: 'A central cross formation. Align vertical jewels before the lateral rose square.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(
          pieceType: PieceType.cyanCircle,
          position: BoardPosition(1, 2),
        ),
        PuzzleTarget(
          pieceType: PieceType.amberDiamond,
          position: BoardPosition(3, 2),
        ),
        PuzzleTarget(
          pieceType: PieceType.roseSquare,
          position: BoardPosition(2, 3),
        ),
      ],
      optimalMoves: 6,
    );
  }


  // LEVEL 9: Echo (Memory Echo v2: Explicit Recording Window)
  static PuzzleLevel _buildLevel9() {
    final grid = _createEmptyGrid();
    grid[0][2] = PieceType.cyanCircle;
    grid[0][4] = PieceType.amberDiamond;

    return PuzzleLevel(
      id: 9,
      title: 'Echo',
      hint: 'Record shifts, stop, reposition the board, then Echo.',
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
      optimalMoves: 4,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 10: The Conveyor
  static PuzzleLevel _buildLevel10() {
    final grid = _createEmptyGrid();
    grid[0][2] = PieceType.cyanCircle;
    grid[2][2] = PieceType.roseSquare;
    grid[4][2] = PieceType.amberDiamond;

    return PuzzleLevel(
      id: 10,
      title: 'The Conveyor',
      hint: 'Program the conveyor column with REC, load pieces, then Echo.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(
          pieceType: PieceType.cyanCircle,
          position: BoardPosition(2, 3),
        ),
        PuzzleTarget(
          pieceType: PieceType.roseSquare,
          position: BoardPosition(4, 3),
        ),
        PuzzleTarget(
          pieceType: PieceType.amberDiamond,
          position: BoardPosition(1, 3),
        ),
      ],
      optimalMoves: 5,
      hasMemoryEcho: true,
    );
  }

  // ==========================================
  // CHAPTER 2: TEMPORAL AWAKENING (Levels 11–20)
  // ==========================================

  // LEVEL 11: Temporal Cross
  static PuzzleLevel _buildLevel11() {
    final grid = _createEmptyGrid();
    grid[1][1] = PieceType.cyanCircle;
    grid[3][3] = PieceType.amberDiamond;
    grid[2][2] = PieceType.emeraldHexagon;

    return PuzzleLevel(
      id: 11,
      title: 'Temporal Cross',
      hint: 'Coordinate intersecting axes with Memory Echo.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(
          pieceType: PieceType.cyanCircle,
          position: BoardPosition(3, 1),
        ),
        PuzzleTarget(
          pieceType: PieceType.amberDiamond,
          position: BoardPosition(1, 3),
        ),
        PuzzleTarget(
          pieceType: PieceType.emeraldHexagon,
          position: BoardPosition(4, 2),
        ),
      ],
      optimalMoves: 6,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 12: Dual Frequency
  static PuzzleLevel _buildLevel12() {
    final grid = _createEmptyGrid();
    grid[3][1] = PieceType.roseSquare;
    grid[4][3] = PieceType.violetTriangle;

    return PuzzleLevel(
      id: 12,
      title: 'Dual Frequency',
      hint: 'Program parallel column pulses with Memory Echo.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(
          pieceType: PieceType.roseSquare,
          position: BoardPosition(1, 1),
        ),
        PuzzleTarget(
          pieceType: PieceType.violetTriangle,
          position: BoardPosition(1, 3),
        ),
      ],
      optimalMoves: 4,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 13: The Relay
  static PuzzleLevel _buildLevel13() {
    final grid = _createEmptyGrid();
    grid[0][0] = PieceType.amberDiamond;
    grid[4][0] = PieceType.emeraldHexagon;

    return PuzzleLevel(
      id: 13,
      title: 'The Relay',
      hint: 'Relay pieces across the toroidal boundary into row 2.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(
          pieceType: PieceType.amberDiamond,
          position: BoardPosition(2, 2),
        ),
        PuzzleTarget(
          pieceType: PieceType.emeraldHexagon,
          position: BoardPosition(2, 4),
        ),
      ],
      optimalMoves: 6,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 14: Parallel Streams
  static PuzzleLevel _buildLevel14() {
    final grid = _createEmptyGrid();
    grid[0][0] = PieceType.cyanCircle;
    grid[2][4] = PieceType.roseSquare;
    grid[4][1] = PieceType.violetTriangle;

    return PuzzleLevel(
      id: 14,
      title: 'Parallel Streams',
      hint: 'Gather three streams into the central column.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(
          pieceType: PieceType.cyanCircle,
          position: BoardPosition(0, 2),
        ),
        PuzzleTarget(
          pieceType: PieceType.roseSquare,
          position: BoardPosition(2, 2),
        ),
        PuzzleTarget(
          pieceType: PieceType.violetTriangle,
          position: BoardPosition(4, 2),
        ),
      ],
      optimalMoves: 5,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 15: Orbit & Ghost
  static PuzzleLevel _buildLevel15() {
    final grid = _createEmptyGrid();
    grid[3][2] = PieceType.cyanCircle;
    grid[2][4] = PieceType.amberDiamond;
    grid[1][2] = PieceType.emeraldHexagon;

    return PuzzleLevel(
      id: 15,
      title: 'Orbit & Ghost',
      hint: 'Orbit around the center pad, then Echo to seat.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(
          pieceType: PieceType.cyanCircle,
          position: BoardPosition(1, 2),
        ),
        PuzzleTarget(
          pieceType: PieceType.amberDiamond,
          position: BoardPosition(2, 1),
        ),
        PuzzleTarget(
          pieceType: PieceType.emeraldHexagon,
          position: BoardPosition(3, 2),
        ),
      ],
      optimalMoves: 7,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 16: Cascade Lock
  static PuzzleLevel _buildLevel16() {
    final grid = _createEmptyGrid();
    grid[1][3] = PieceType.amberDiamond;
    grid[4][2] = PieceType.roseSquare;
    grid[3][1] = PieceType.emeraldHexagon;

    return PuzzleLevel(
      id: 16,
      title: 'Cascade Lock',
      hint: 'Form the diagonal staircase from row and column shifts.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(
          pieceType: PieceType.amberDiamond,
          position: BoardPosition(1, 1),
        ),
        PuzzleTarget(
          pieceType: PieceType.roseSquare,
          position: BoardPosition(2, 2),
        ),
        PuzzleTarget(
          pieceType: PieceType.emeraldHexagon,
          position: BoardPosition(3, 3),
        ),
      ],
      optimalMoves: 6,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 17: Shift Synchrony
  static PuzzleLevel _buildLevel17() {
    final grid = _createEmptyGrid();
    grid[3][1] = PieceType.cyanCircle;
    grid[2][2] = PieceType.violetTriangle;
    grid[4][3] = PieceType.amberDiamond;

    return PuzzleLevel(
      id: 17,
      title: 'Shift Synchrony',
      hint: 'Align all three pieces along the top header row.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(
          pieceType: PieceType.cyanCircle,
          position: BoardPosition(0, 1),
        ),
        PuzzleTarget(
          pieceType: PieceType.violetTriangle,
          position: BoardPosition(0, 2),
        ),
        PuzzleTarget(
          pieceType: PieceType.amberDiamond,
          position: BoardPosition(0, 3),
        ),
      ],
      optimalMoves: 5,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 18: Phantom Axis
  static PuzzleLevel _buildLevel18() {
    final grid = _createEmptyGrid();
    grid[0][0] = PieceType.roseSquare;
    grid[4][2] = PieceType.emeraldHexagon;
    grid[1][4] = PieceType.violetTriangle;

    return PuzzleLevel(
      id: 18,
      title: 'Phantom Axis',
      hint: 'Drop three vertical channels into the central equator.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(
          pieceType: PieceType.roseSquare,
          position: BoardPosition(2, 0),
        ),
        PuzzleTarget(
          pieceType: PieceType.emeraldHexagon,
          position: BoardPosition(2, 2),
        ),
        PuzzleTarget(
          pieceType: PieceType.violetTriangle,
          position: BoardPosition(2, 4),
        ),
      ],
      optimalMoves: 6,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 19: Mirror Track
  static PuzzleLevel _buildLevel19() {
    final grid = _createEmptyGrid();
    grid[4][1] = PieceType.cyanCircle;
    grid[2][0] = PieceType.amberDiamond;
    grid[3][3] = PieceType.roseSquare;

    return PuzzleLevel(
      id: 19,
      title: 'Mirror Track',
      hint: 'Balance symmetric reflections across the core.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(
          pieceType: PieceType.cyanCircle,
          position: BoardPosition(1, 1),
        ),
        PuzzleTarget(
          pieceType: PieceType.amberDiamond,
          position: BoardPosition(2, 2),
        ),
        PuzzleTarget(
          pieceType: PieceType.roseSquare,
          position: BoardPosition(1, 3),
        ),
      ],
      optimalMoves: 6,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 20: Temporal Threshold (Chapter 2 Capstone)
  static PuzzleLevel _buildLevel20() {
    final grid = _createEmptyGrid();
    grid[4][2] = PieceType.cyanCircle;
    grid[2][4] = PieceType.amberDiamond;
    grid[2][0] = PieceType.roseSquare;
    grid[0][2] = PieceType.emeraldHexagon;

    return PuzzleLevel(
      id: 20,
      title: 'Temporal Threshold',
      hint: 'The Chapter 2 climax: weave the 4-piece diamond shield.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(
          pieceType: PieceType.cyanCircle,
          position: BoardPosition(1, 2),
        ),
        PuzzleTarget(
          pieceType: PieceType.amberDiamond,
          position: BoardPosition(2, 1),
        ),
        PuzzleTarget(
          pieceType: PieceType.roseSquare,
          position: BoardPosition(2, 3),
        ),
        PuzzleTarget(
          pieceType: PieceType.emeraldHexagon,
          position: BoardPosition(3, 2),
        ),
      ],
      optimalMoves: 8,
      hasMemoryEcho: true,
    );
  }

  // ==========================================
  // CHAPTER 3: SPATIAL MATRICES (Levels 21–30)
  // ==========================================

  // LEVEL 21: The Lattice
  static PuzzleLevel _buildLevel21() {
    final grid = _createEmptyGrid();
    grid[1][0] = PieceType.roseSquare;
    grid[0][1] = PieceType.emeraldHexagon;

    return PuzzleLevel(
      id: 21,
      title: 'The Lattice',
      hint: 'Diagonal coordinates wrap around perpendicular tracks.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(
          pieceType: PieceType.roseSquare,
          position: BoardPosition(1, 3),
        ),
        PuzzleTarget(
          pieceType: PieceType.emeraldHexagon,
          position: BoardPosition(3, 1),
        ),
      ],
      optimalMoves: 4,
    );
  }

  // LEVEL 22: Ring of Saturn
  static PuzzleLevel _buildLevel22() {
    final grid = _createEmptyGrid();
    grid[4][2] = PieceType.cyanCircle;
    grid[2][2] = PieceType.amberDiamond;
    grid[2][1] = PieceType.violetTriangle;

    return PuzzleLevel(
      id: 22,
      title: 'Ring of Saturn',
      hint: 'Send outer orbital satellites along perimeter boundaries.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(
          pieceType: PieceType.cyanCircle,
          position: BoardPosition(0, 2),
        ),
        PuzzleTarget(
          pieceType: PieceType.amberDiamond,
          position: BoardPosition(2, 0),
        ),
        PuzzleTarget(
          pieceType: PieceType.violetTriangle,
          position: BoardPosition(2, 4),
        ),
      ],
      optimalMoves: 3,
    );
  }

  // LEVEL 23: Symmetry Break
  static PuzzleLevel _buildLevel23() {
    final grid = _createEmptyGrid();
    grid[4][1] = PieceType.roseSquare;
    grid[1][0] = PieceType.emeraldHexagon;
    grid[0][2] = PieceType.cyanCircle;

    return PuzzleLevel(
      id: 23,
      title: 'Symmetry Break',
      hint: 'Break the mirrored layout with an asymmetrical column shift.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(
          pieceType: PieceType.roseSquare,
          position: BoardPosition(1, 1),
        ),
        PuzzleTarget(
          pieceType: PieceType.emeraldHexagon,
          position: BoardPosition(1, 3),
        ),
        PuzzleTarget(
          pieceType: PieceType.cyanCircle,
          position: BoardPosition(3, 2),
        ),
      ],
      optimalMoves: 6,
    );
  }

  // LEVEL 24: Toroidal Bypass
  static PuzzleLevel _buildLevel24() {
    final grid = _createEmptyGrid();
    grid[2][3] = PieceType.amberDiamond;
    grid[1][2] = PieceType.violetTriangle;

    return PuzzleLevel(
      id: 24,
      title: 'Toroidal Bypass',
      hint: 'Take the wrapping shortcut from bottom to top and right to left.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(
          pieceType: PieceType.amberDiamond,
          position: BoardPosition(0, 0),
        ),
        PuzzleTarget(
          pieceType: PieceType.violetTriangle,
          position: BoardPosition(4, 4),
        ),
      ],
      optimalMoves: 6,
    );
  }

  // LEVEL 25: Quadrant Shift
  static PuzzleLevel _buildLevel25() {
    final grid = _createEmptyGrid();
    grid[1][4] = PieceType.cyanCircle;
    grid[4][3] = PieceType.amberDiamond;
    grid[0][1] = PieceType.roseSquare;
    grid[3][0] = PieceType.emeraldHexagon;

    return PuzzleLevel(
      id: 25,
      title: 'Quadrant Shift',
      hint: 'Route four pieces into the 2×2 sub-quadrant matrix.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(
          pieceType: PieceType.cyanCircle,
          position: BoardPosition(1, 1),
        ),
        PuzzleTarget(
          pieceType: PieceType.amberDiamond,
          position: BoardPosition(1, 3),
        ),
        PuzzleTarget(
          pieceType: PieceType.roseSquare,
          position: BoardPosition(3, 1),
        ),
        PuzzleTarget(
          pieceType: PieceType.emeraldHexagon,
          position: BoardPosition(3, 3),
        ),
      ],
      optimalMoves: 7,
    );
  }

  // LEVEL 26: Echo Grid
  static PuzzleLevel _buildLevel26() {
    final grid = _createEmptyGrid();
    grid[0][1] = PieceType.cyanCircle;
    grid[4][2] = PieceType.amberDiamond;
    grid[1][3] = PieceType.violetTriangle;

    return PuzzleLevel(
      id: 26,
      title: 'Echo Grid',
      hint: 'Weave three pieces into the center row with Memory Echo.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(
          pieceType: PieceType.cyanCircle,
          position: BoardPosition(2, 1),
        ),
        PuzzleTarget(
          pieceType: PieceType.amberDiamond,
          position: BoardPosition(2, 2),
        ),
        PuzzleTarget(
          pieceType: PieceType.violetTriangle,
          position: BoardPosition(2, 3),
        ),
      ],
      optimalMoves: 5,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 27: Diagonal Drift
  static PuzzleLevel _buildLevel27() {
    final grid = _createEmptyGrid();
    grid[0][3] = PieceType.roseSquare;
    grid[4][2] = PieceType.emeraldHexagon;
    grid[1][4] = PieceType.amberDiamond;

    return PuzzleLevel(
      id: 27,
      title: 'Diagonal Drift',
      hint: 'Drive diagonal anchors into the main geometric axis.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(
          pieceType: PieceType.roseSquare,
          position: BoardPosition(0, 0),
        ),
        PuzzleTarget(
          pieceType: PieceType.emeraldHexagon,
          position: BoardPosition(2, 2),
        ),
        PuzzleTarget(
          pieceType: PieceType.amberDiamond,
          position: BoardPosition(4, 4),
        ),
      ],
      optimalMoves: 6,
    );
  }

  // LEVEL 28: Phase Shift
  static PuzzleLevel _buildLevel28() {
    final grid = _createEmptyGrid();
    grid[0][4] = PieceType.cyanCircle;
    grid[1][2] = PieceType.roseSquare;
    grid[4][0] = PieceType.violetTriangle;

    return PuzzleLevel(
      id: 28,
      title: 'Phase Shift',
      hint: 'Phase the central spine using recorded column shifts.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(
          pieceType: PieceType.cyanCircle,
          position: BoardPosition(0, 2),
        ),
        PuzzleTarget(
          pieceType: PieceType.roseSquare,
          position: BoardPosition(2, 2),
        ),
        PuzzleTarget(
          pieceType: PieceType.violetTriangle,
          position: BoardPosition(4, 2),
        ),
      ],
      optimalMoves: 5,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 29: Harmonic Axis
  static PuzzleLevel _buildLevel29() {
    final grid = _createEmptyGrid();
    grid[0][0] = PieceType.cyanCircle;
    grid[4][1] = PieceType.amberDiamond;
    grid[1][3] = PieceType.roseSquare;
    grid[3][4] = PieceType.emeraldHexagon;

    return PuzzleLevel(
      id: 29,
      title: 'Harmonic Axis',
      hint: 'Dock four pieces into row 2 leaving the center core open.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(
          pieceType: PieceType.cyanCircle,
          position: BoardPosition(2, 0),
        ),
        PuzzleTarget(
          pieceType: PieceType.amberDiamond,
          position: BoardPosition(2, 1),
        ),
        PuzzleTarget(
          pieceType: PieceType.roseSquare,
          position: BoardPosition(2, 3),
        ),
        PuzzleTarget(
          pieceType: PieceType.emeraldHexagon,
          position: BoardPosition(2, 4),
        ),
      ],
      optimalMoves: 6,
    );
  }

  // LEVEL 30: The Matrix (Chapter 3 Capstone)
  static PuzzleLevel _buildLevel30() {
    final grid = _createEmptyGrid();
    grid[3][2] = PieceType.cyanCircle;
    grid[2][3] = PieceType.amberDiamond;
    grid[1][2] = PieceType.roseSquare;
    grid[2][1] = PieceType.emeraldHexagon;

    return PuzzleLevel(
      id: 30,
      title: 'The Matrix',
      hint: 'The Chapter 3 capstone: expand the inner compass outward.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(
          pieceType: PieceType.cyanCircle,
          position: BoardPosition(0, 2),
        ),
        PuzzleTarget(
          pieceType: PieceType.amberDiamond,
          position: BoardPosition(2, 0),
        ),
        PuzzleTarget(
          pieceType: PieceType.roseSquare,
          position: BoardPosition(4, 2),
        ),
        PuzzleTarget(
          pieceType: PieceType.emeraldHexagon,
          position: BoardPosition(2, 4),
        ),
      ],
      optimalMoves: 8,
    );
  }

  // ==========================================
  // CHAPTER 4: COMPLEX MACHINES (Levels 31–40)
  // ==========================================

  // LEVEL 31: Gearbox
  static PuzzleLevel _buildLevel31() {
    final grid = _createEmptyGrid();
    grid[1][1] = PieceType.cyanCircle;
    grid[1][3] = PieceType.amberDiamond;
    grid[3][1] = PieceType.roseSquare;
    grid[3][3] = PieceType.emeraldHexagon;

    return PuzzleLevel(
      id: 31,
      title: 'Gearbox',
      hint: 'Interlocking four-gear system. Row and column shifts drive adjacent cogs.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(
          pieceType: PieceType.cyanCircle,
          position: BoardPosition(1, 3),
        ),
        PuzzleTarget(
          pieceType: PieceType.amberDiamond,
          position: BoardPosition(3, 3),
        ),
        PuzzleTarget(
          pieceType: PieceType.roseSquare,
          position: BoardPosition(1, 1),
        ),
        PuzzleTarget(
          pieceType: PieceType.emeraldHexagon,
          position: BoardPosition(3, 1),
        ),
      ],
      optimalMoves: 8,
    );
  }

  // LEVEL 32: Dual Piston
  static PuzzleLevel _buildLevel32() {
    final grid = _createEmptyGrid();
    grid[4][1] = PieceType.emeraldHexagon;
    grid[0][1] = PieceType.violetTriangle;
    grid[2][0] = PieceType.cyanCircle;

    return PuzzleLevel(
      id: 32,
      title: 'Dual Piston',
      hint: 'Fire opposing pistons along the left column with Echo.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(
          pieceType: PieceType.emeraldHexagon,
          position: BoardPosition(1, 1),
        ),
        PuzzleTarget(
          pieceType: PieceType.violetTriangle,
          position: BoardPosition(3, 1),
        ),
        PuzzleTarget(
          pieceType: PieceType.cyanCircle,
          position: BoardPosition(2, 3),
        ),
      ],
      optimalMoves: 6,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 33: Switchboard
  static PuzzleLevel _buildLevel33() {
    final grid = _createEmptyGrid();
    grid[0][2] = PieceType.cyanCircle;
    grid[2][4] = PieceType.amberDiamond;
    grid[4][2] = PieceType.roseSquare;
    grid[2][0] = PieceType.emeraldHexagon;

    return PuzzleLevel(
      id: 33,
      title: 'Switchboard',
      hint: 'Route orthogonal inputs out to the four corners.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(
          pieceType: PieceType.cyanCircle,
          position: BoardPosition(0, 0),
        ),
        PuzzleTarget(
          pieceType: PieceType.amberDiamond,
          position: BoardPosition(0, 4),
        ),
        PuzzleTarget(
          pieceType: PieceType.roseSquare,
          position: BoardPosition(4, 0),
        ),
        PuzzleTarget(
          pieceType: PieceType.emeraldHexagon,
          position: BoardPosition(4, 4),
        ),
      ],
      optimalMoves: 8,
    );
  }

  // LEVEL 34: The Carousel
  static PuzzleLevel _buildLevel34() {
    final grid = _createEmptyGrid();
    grid[1][0] = PieceType.roseSquare;
    grid[4][3] = PieceType.amberDiamond;
    grid[3][4] = PieceType.violetTriangle;

    return PuzzleLevel(
      id: 34,
      title: 'The Carousel',
      hint: 'Rotate pieces around the perimeter before Echo lock.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(
          pieceType: PieceType.roseSquare,
          position: BoardPosition(1, 2),
        ),
        PuzzleTarget(
          pieceType: PieceType.amberDiamond,
          position: BoardPosition(2, 3),
        ),
        PuzzleTarget(
          pieceType: PieceType.violetTriangle,
          position: BoardPosition(3, 2),
        ),
      ],
      optimalMoves: 6,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 35: Interlock
  static PuzzleLevel _buildLevel35() {
    final grid = _createEmptyGrid();
    grid[4][1] = PieceType.cyanCircle;
    grid[0][2] = PieceType.emeraldHexagon;
    grid[1][4] = PieceType.violetTriangle;

    return PuzzleLevel(
      id: 35,
      title: 'Interlock',
      hint: 'Mesh intersecting horizontal and vertical drives.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(
          pieceType: PieceType.cyanCircle,
          position: BoardPosition(2, 1),
        ),
        PuzzleTarget(
          pieceType: PieceType.emeraldHexagon,
          position: BoardPosition(2, 2),
        ),
        PuzzleTarget(
          pieceType: PieceType.violetTriangle,
          position: BoardPosition(1, 2),
        ),
      ],
      optimalMoves: 6,
    );
  }

  // LEVEL 36: Resonator
  static PuzzleLevel _buildLevel36() {
    final grid = _createEmptyGrid();
    grid[0][0] = PieceType.cyanCircle;
    grid[1][4] = PieceType.amberDiamond;
    grid[4][4] = PieceType.roseSquare;

    return PuzzleLevel(
      id: 36,
      title: 'Resonator',
      hint: 'Resonate pulse patterns across the outer borders.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(
          pieceType: PieceType.cyanCircle,
          position: BoardPosition(0, 2),
        ),
        PuzzleTarget(
          pieceType: PieceType.amberDiamond,
          position: BoardPosition(2, 4),
        ),
        PuzzleTarget(
          pieceType: PieceType.roseSquare,
          position: BoardPosition(4, 2),
        ),
      ],
      optimalMoves: 5,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 37: Orbital Station
  static PuzzleLevel _buildLevel37() {
    final grid = _createEmptyGrid();
    grid[3][2] = PieceType.cyanCircle;
    grid[2][4] = PieceType.amberDiamond;
    grid[1][2] = PieceType.roseSquare;
    grid[2][0] = PieceType.violetTriangle;

    return PuzzleLevel(
      id: 37,
      title: 'Orbital Station',
      hint: 'Dock satellites in circular orbit around the command hub.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(
          pieceType: PieceType.cyanCircle,
          position: BoardPosition(1, 2),
        ),
        PuzzleTarget(
          pieceType: PieceType.amberDiamond,
          position: BoardPosition(2, 1),
        ),
        PuzzleTarget(
          pieceType: PieceType.roseSquare,
          position: BoardPosition(3, 2),
        ),
        PuzzleTarget(
          pieceType: PieceType.violetTriangle,
          position: BoardPosition(2, 3),
        ),
      ],
      optimalMoves: 8,
    );
  }

  // LEVEL 38: Clockwork
  static PuzzleLevel _buildLevel38() {
    final grid = _createEmptyGrid();
    grid[2][1] = PieceType.emeraldHexagon;
    grid[0][0] = PieceType.amberDiamond;
    grid[2][3] = PieceType.roseSquare;
    grid[4][4] = PieceType.violetTriangle;

    return PuzzleLevel(
      id: 38,
      title: 'Clockwork',
      hint: 'Synchronize four corner pinions with precision timing.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(
          pieceType: PieceType.emeraldHexagon,
          position: BoardPosition(0, 1),
        ),
        PuzzleTarget(
          pieceType: PieceType.amberDiamond,
          position: BoardPosition(0, 3),
        ),
        PuzzleTarget(
          pieceType: PieceType.roseSquare,
          position: BoardPosition(4, 1),
        ),
        PuzzleTarget(
          pieceType: PieceType.violetTriangle,
          position: BoardPosition(4, 3),
        ),
      ],
      optimalMoves: 8,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 39: Flux Capacitor
  static PuzzleLevel _buildLevel39() {
    final grid = _createEmptyGrid();
    grid[4][2] = PieceType.cyanCircle;
    grid[3][4] = PieceType.amberDiamond;
    grid[0][3] = PieceType.violetTriangle;

    return PuzzleLevel(
      id: 39,
      title: 'Flux Capacitor',
      hint: 'Charge the 3-point temporal nexus with Memory Echo.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(
          pieceType: PieceType.cyanCircle,
          position: BoardPosition(1, 2),
        ),
        PuzzleTarget(
          pieceType: PieceType.amberDiamond,
          position: BoardPosition(3, 1),
        ),
        PuzzleTarget(
          pieceType: PieceType.violetTriangle,
          position: BoardPosition(3, 3),
        ),
      ],
      optimalMoves: 6,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 40: The Engine (Chapter 4 Capstone)
  static PuzzleLevel _buildLevel40() {
    final grid = _createEmptyGrid();
    grid[0][1] = PieceType.cyanCircle;
    grid[1][4] = PieceType.amberDiamond;
    grid[3][0] = PieceType.roseSquare;
    grid[4][3] = PieceType.emeraldHexagon;

    return PuzzleLevel(
      id: 40,
      title: 'The Engine',
      hint: 'The Chapter 4 climax: ignite the core combustion cycle.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(
          pieceType: PieceType.cyanCircle,
          position: BoardPosition(2, 1),
        ),
        PuzzleTarget(
          pieceType: PieceType.amberDiamond,
          position: BoardPosition(1, 2),
        ),
        PuzzleTarget(
          pieceType: PieceType.roseSquare,
          position: BoardPosition(3, 2),
        ),
        PuzzleTarget(
          pieceType: PieceType.emeraldHexagon,
          position: BoardPosition(2, 3),
        ),
      ],
      optimalMoves: 8,
      hasMemoryEcho: true,
    );
  }

  // ==========================================
  // CHAPTER 5: GRANDMASTER (Levels 41–50)
  // ==========================================

  // LEVEL 41: Prism of Light
  static PuzzleLevel _buildLevel41() {
    final grid = _createEmptyGrid();
    grid[3][1] = PieceType.cyanCircle;
    grid[1][1] = PieceType.amberDiamond;
    grid[3][4] = PieceType.roseSquare;
    grid[0][3] = PieceType.violetTriangle;

    return PuzzleLevel(
      id: 41,
      title: 'Prism of Light',
      hint: 'Refract four spectral beams into the diagonal diamond.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(
          pieceType: PieceType.cyanCircle,
          position: BoardPosition(1, 1),
        ),
        PuzzleTarget(
          pieceType: PieceType.amberDiamond,
          position: BoardPosition(1, 3),
        ),
        PuzzleTarget(
          pieceType: PieceType.roseSquare,
          position: BoardPosition(3, 1),
        ),
        PuzzleTarget(
          pieceType: PieceType.violetTriangle,
          position: BoardPosition(3, 3),
        ),
      ],
      optimalMoves: 7,
    );
  }

  // LEVEL 42: Quantum Entanglement
  static PuzzleLevel _buildLevel42() {
    final grid = _createEmptyGrid();
    grid[3][2] = PieceType.amberDiamond;
    grid[2][0] = PieceType.emeraldHexagon;
    grid[1][2] = PieceType.violetTriangle;

    return PuzzleLevel(
      id: 42,
      title: 'Quantum Entanglement',
      hint: 'Couple entangled states across the central channel with Echo.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(
          pieceType: PieceType.amberDiamond,
          position: BoardPosition(0, 2),
        ),
        PuzzleTarget(
          pieceType: PieceType.emeraldHexagon,
          position: BoardPosition(2, 2),
        ),
        PuzzleTarget(
          pieceType: PieceType.violetTriangle,
          position: BoardPosition(4, 2),
        ),
      ],
      optimalMoves: 6,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 43: The Monolith
  static PuzzleLevel _buildLevel43() {
    final grid = _createEmptyGrid();
    grid[1][0] = PieceType.cyanCircle;
    grid[2][4] = PieceType.roseSquare;
    grid[3][1] = PieceType.emeraldHexagon;
    grid[4][3] = PieceType.violetTriangle;

    return PuzzleLevel(
      id: 43,
      title: 'The Monolith',
      hint: 'Stack four geometric tiers into the vertical monolith pillar.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(
          pieceType: PieceType.cyanCircle,
          position: BoardPosition(1, 2),
        ),
        PuzzleTarget(
          pieceType: PieceType.roseSquare,
          position: BoardPosition(2, 2),
        ),
        PuzzleTarget(
          pieceType: PieceType.emeraldHexagon,
          position: BoardPosition(3, 2),
        ),
        PuzzleTarget(
          pieceType: PieceType.violetTriangle,
          position: BoardPosition(4, 2),
        ),
      ],
      optimalMoves: 6,
    );
  }

  // LEVEL 44: Supernova
  static PuzzleLevel _buildLevel44() {
    final grid = _createEmptyGrid();
    grid[4][2] = PieceType.cyanCircle;
    grid[2][4] = PieceType.amberDiamond;
    grid[0][2] = PieceType.roseSquare;
    grid[2][0] = PieceType.emeraldHexagon;

    return PuzzleLevel(
      id: 44,
      title: 'Supernova',
      hint: 'Invert opposing magnetic poles through the temporal core.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(
          pieceType: PieceType.cyanCircle,
          position: BoardPosition(0, 2),
        ),
        PuzzleTarget(
          pieceType: PieceType.amberDiamond,
          position: BoardPosition(2, 0),
        ),
        PuzzleTarget(
          pieceType: PieceType.roseSquare,
          position: BoardPosition(4, 2),
        ),
        PuzzleTarget(
          pieceType: PieceType.emeraldHexagon,
          position: BoardPosition(2, 4),
        ),
      ],
      optimalMoves: 8,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 45: Labyrinth of Time
  static PuzzleLevel _buildLevel45() {
    final grid = _createEmptyGrid();
    grid[4][1] = PieceType.amberDiamond;
    grid[2][0] = PieceType.roseSquare;
    grid[0][1] = PieceType.violetTriangle;

    return PuzzleLevel(
      id: 45,
      title: 'Labyrinth of Time',
      hint: 'Thread the winding corridor between past and future.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(
          pieceType: PieceType.amberDiamond,
          position: BoardPosition(1, 1),
        ),
        PuzzleTarget(
          pieceType: PieceType.roseSquare,
          position: BoardPosition(2, 3),
        ),
        PuzzleTarget(
          pieceType: PieceType.violetTriangle,
          position: BoardPosition(3, 1),
        ),
      ],
      optimalMoves: 6,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 46: Celestial Compass
  static PuzzleLevel _buildLevel46() {
    final grid = _createEmptyGrid();
    grid[1][2] = PieceType.cyanCircle;
    grid[2][3] = PieceType.amberDiamond;
    grid[3][2] = PieceType.roseSquare;
    grid[2][1] = PieceType.emeraldHexagon;

    return PuzzleLevel(
      id: 46,
      title: 'Celestial Compass',
      hint: 'Expand inner magnetic needles to the four celestial gates.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(
          pieceType: PieceType.cyanCircle,
          position: BoardPosition(0, 2),
        ),
        PuzzleTarget(
          pieceType: PieceType.amberDiamond,
          position: BoardPosition(2, 4),
        ),
        PuzzleTarget(
          pieceType: PieceType.roseSquare,
          position: BoardPosition(4, 2),
        ),
        PuzzleTarget(
          pieceType: PieceType.emeraldHexagon,
          position: BoardPosition(2, 0),
        ),
      ],
      optimalMoves: 8,
    );
  }

  // LEVEL 47: Event Horizon
  static PuzzleLevel _buildLevel47() {
    final grid = _createEmptyGrid();
    grid[0][2] = PieceType.cyanCircle;
    grid[2][4] = PieceType.emeraldHexagon;
    grid[2][0] = PieceType.violetTriangle;
    grid[4][2] = PieceType.roseSquare;

    return PuzzleLevel(
      id: 47,
      title: 'Event Horizon',
      hint: 'Collapse outer satellites inward without crossing singularity.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(
          pieceType: PieceType.cyanCircle,
          position: BoardPosition(1, 2),
        ),
        PuzzleTarget(
          pieceType: PieceType.emeraldHexagon,
          position: BoardPosition(2, 1),
        ),
        PuzzleTarget(
          pieceType: PieceType.violetTriangle,
          position: BoardPosition(2, 3),
        ),
        PuzzleTarget(
          pieceType: PieceType.roseSquare,
          position: BoardPosition(3, 2),
        ),
      ],
      optimalMoves: 7,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 48: Singularity
  static PuzzleLevel _buildLevel48() {
    final grid = _createEmptyGrid();
    grid[0][1] = PieceType.cyanCircle;
    grid[4][2] = PieceType.amberDiamond;
    grid[0][3] = PieceType.roseSquare;
    grid[1][0] = PieceType.emeraldHexagon;

    return PuzzleLevel(
      id: 48,
      title: 'Singularity',
      hint: 'Condense four orbiting bodies into the central T-matrix.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(
          pieceType: PieceType.cyanCircle,
          position: BoardPosition(2, 1),
        ),
        PuzzleTarget(
          pieceType: PieceType.amberDiamond,
          position: BoardPosition(2, 2),
        ),
        PuzzleTarget(
          pieceType: PieceType.roseSquare,
          position: BoardPosition(2, 3),
        ),
        PuzzleTarget(
          pieceType: PieceType.emeraldHexagon,
          position: BoardPosition(1, 2),
        ),
      ],
      optimalMoves: 8,
    );
  }

  // LEVEL 49: Chronos
  static PuzzleLevel _buildLevel49() {
    final grid = _createEmptyGrid();
    grid[0][3] = PieceType.cyanCircle;
    grid[3][4] = PieceType.amberDiamond;
    grid[4][1] = PieceType.emeraldHexagon;
    grid[1][0] = PieceType.violetTriangle;

    return PuzzleLevel(
      id: 49,
      title: 'Chronos',
      hint: 'Disperse the temporal dial out to the four corners.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(
          pieceType: PieceType.cyanCircle,
          position: BoardPosition(0, 0),
        ),
        PuzzleTarget(
          pieceType: PieceType.amberDiamond,
          position: BoardPosition(0, 4),
        ),
        PuzzleTarget(
          pieceType: PieceType.emeraldHexagon,
          position: BoardPosition(4, 4),
        ),
        PuzzleTarget(
          pieceType: PieceType.violetTriangle,
          position: BoardPosition(4, 0),
        ),
      ],
      optimalMoves: 8,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 50: Shift Master (The Ultimate Climax Puzzle)
  static PuzzleLevel _buildLevel50() {
    final grid = _createEmptyGrid();
    grid[2][4] = PieceType.violetTriangle;
    grid[3][2] = PieceType.cyanCircle;
    grid[1][2] = PieceType.emeraldHexagon;
    grid[2][3] = PieceType.amberDiamond;
    grid[2][1] = PieceType.roseSquare;

    return PuzzleLevel(
      id: 50,
      title: 'Shift Master',
      hint: 'The Climax: Crown the Violet Triangle at the center of the cosmos.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(
          pieceType: PieceType.violetTriangle,
          position: BoardPosition(2, 2),
        ),
        PuzzleTarget(
          pieceType: PieceType.cyanCircle,
          position: BoardPosition(0, 2),
        ),
        PuzzleTarget(
          pieceType: PieceType.emeraldHexagon,
          position: BoardPosition(4, 2),
        ),
        PuzzleTarget(
          pieceType: PieceType.amberDiamond,
          position: BoardPosition(2, 0),
        ),
        PuzzleTarget(
          pieceType: PieceType.roseSquare,
          position: BoardPosition(2, 4),
        ),
      ],
      optimalMoves: 8,
      hasMemoryEcho: true,
    );
  }

  // ==========================================
  // CHAPTER 6: ADVANCED ECHO (Levels 51–60)
  // ==========================================

  // LEVEL 51: Temporal Conveyor
  static PuzzleLevel _buildLevel51() {
    final grid = _createEmptyGrid();
    grid[1][1] = PieceType.cyanCircle;
    grid[3][3] = PieceType.amberDiamond;
    grid[2][0] = PieceType.roseSquare;

    return PuzzleLevel(
      id: 51,
      title: 'Temporal Conveyor',
      hint: 'Macro the diagonal advance: record a double shift, then align the rose beacon.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(3, 1)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(1, 3)),
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(2, 4)),
      ],
      optimalMoves: 5,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 52: Twin Frequency
  static PuzzleLevel _buildLevel52() {
    final grid = _createEmptyGrid();
    grid[0][2] = PieceType.cyanCircle;
    grid[4][2] = PieceType.amberDiamond;
    grid[2][1] = PieceType.emeraldHexagon;

    return PuzzleLevel(
      id: 52,
      title: 'Twin Frequency',
      hint: 'Inverted carriers: synchronize the vertical twins while the hexagon marks the center.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(2, 4)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(2, 0)),
        PuzzleTarget(pieceType: PieceType.emeraldHexagon, position: BoardPosition(2, 2)),
      ],
      optimalMoves: 7,
      hasMemoryEcho: true,
    );
  }


  // LEVEL 53: Echo Reversal
  static PuzzleLevel _buildLevel53() {
    final grid = _createEmptyGrid();
    grid[2][0] = PieceType.emeraldHexagon;
    grid[4][2] = PieceType.cyanCircle;

    return PuzzleLevel(
      id: 53,
      title: 'Echo Reversal',
      hint: 'Reposition into the reverse corridor so the replay pulls inward.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.emeraldHexagon, position: BoardPosition(1, 2)),
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(2, 3)),
      ],
      optimalMoves: 5,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 54: Split Alignment
  static PuzzleLevel _buildLevel54() {
    final grid = _createEmptyGrid();
    grid[1][1] = PieceType.amberDiamond;
    grid[3][1] = PieceType.roseSquare;
    grid[2][4] = PieceType.cyanCircle;

    return PuzzleLevel(
      id: 54,
      title: 'Split Alignment',
      hint: 'Decouple the L-formation with a recorded vertical sweep.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(1, 3)),
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(3, 3)),
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(2, 1)),
      ],
      optimalMoves: 6,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 55: The Pendulum
  static PuzzleLevel _buildLevel55() {
    final grid = _createEmptyGrid();
    grid[1][3] = PieceType.violetTriangle;
    grid[4][0] = PieceType.emeraldHexagon;

    return PuzzleLevel(
      id: 55,
      title: 'The Pendulum',
      hint: 'Oscillate across the equator to cross-align north and west.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.violetTriangle, position: BoardPosition(4, 1)),
        PuzzleTarget(pieceType: PieceType.emeraldHexagon, position: BoardPosition(2, 3)),
      ],
      optimalMoves: 6,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 56: Orbit & Recall
  static PuzzleLevel _buildLevel56() {
    final grid = _createEmptyGrid();
    grid[0][4] = PieceType.cyanCircle;
    grid[2][2] = PieceType.amberDiamond;
    grid[4][0] = PieceType.violetTriangle;

    return PuzzleLevel(
      id: 56,
      title: 'Orbit & Recall',
      hint: 'Send outer pieces into orbit, then recall them to the center row.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(2, 0)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(2, 2)),
        PuzzleTarget(pieceType: PieceType.violetTriangle, position: BoardPosition(2, 4)),
      ],
      optimalMoves: 6,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 57: Temporal Setup
  static PuzzleLevel _buildLevel57() {
    final grid = _createEmptyGrid();
    grid[4][3] = PieceType.roseSquare;
    grid[1][0] = PieceType.emeraldHexagon;
    grid[0][2] = PieceType.amberDiamond;

    return PuzzleLevel(
      id: 57,
      title: 'Temporal Setup',
      hint: 'Pre-position the emerald anchor before firing the recorded burst.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(1, 1)),
        PuzzleTarget(pieceType: PieceType.emeraldHexagon, position: BoardPosition(2, 2)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(3, 3)),
      ],
      optimalMoves: 8,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 58: Dual Carrier
  static PuzzleLevel _buildLevel58() {
    final grid = _createEmptyGrid();
    grid[1][4] = PieceType.cyanCircle;
    grid[3][0] = PieceType.roseSquare;
    grid[2][3] = PieceType.violetTriangle;

    return PuzzleLevel(
      id: 58,
      title: 'Dual Carrier',
      hint: 'Carry parallel rows in tandem using a synchronized column shift.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(1, 1)),
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(3, 3)),
        PuzzleTarget(pieceType: PieceType.violetTriangle, position: BoardPosition(2, 2)),
      ],
      optimalMoves: 5,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 59: Harmonic Resonance
  static PuzzleLevel _buildLevel59() {
    final grid = _createEmptyGrid();
    grid[0][1] = PieceType.cyanCircle;
    grid[4][3] = PieceType.emeraldHexagon;
    grid[2][0] = PieceType.roseSquare;
    grid[2][4] = PieceType.amberDiamond;

    return PuzzleLevel(
      id: 59,
      title: 'Harmonic Resonance',
      hint: 'Resonate across four symmetrical axes with cross-axis Echo.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(1, 2)),
        PuzzleTarget(pieceType: PieceType.emeraldHexagon, position: BoardPosition(3, 2)),
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(2, 1)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(2, 3)),
      ],
      optimalMoves: 7,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 60: Chrono Nexus (Milestone VI Climax)
  static PuzzleLevel _buildLevel60() {
    final grid = _createEmptyGrid();
    grid[0][0] = PieceType.cyanCircle;
    grid[0][4] = PieceType.amberDiamond;
    grid[4][0] = PieceType.roseSquare;
    grid[4][4] = PieceType.emeraldHexagon;

    return PuzzleLevel(
      id: 60,
      title: 'Chrono Nexus',
      hint: 'Milestone VI: Collapse the four corners into a tight central diamond.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(1, 2)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(2, 3)),
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(2, 1)),
        PuzzleTarget(pieceType: PieceType.emeraldHexagon, position: BoardPosition(3, 2)),
      ],
      optimalMoves: 10,
      hasMemoryEcho: true,
    );
  }

  // ==========================================
  // CHAPTER 7: SPATIAL PARADOXES (Levels 61–70)
  // ==========================================

  // LEVEL 61: The Moebius Ring
  static PuzzleLevel _buildLevel61() {
    final grid = _createEmptyGrid();
    grid[0][4] = PieceType.violetTriangle;
    grid[4][0] = PieceType.amberDiamond;

    return PuzzleLevel(
      id: 61,
      title: 'The Moebius Ring',
      hint: 'The shortest distance between opposite corners is a single toroidal wrap.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.violetTriangle, position: BoardPosition(3, 1)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(1, 3)),
      ],
      optimalMoves: 7,
    );
  }

  // LEVEL 62: Cross-Axis Lock
  static PuzzleLevel _buildLevel62() {
    final grid = _createEmptyGrid();
    grid[0][3] = PieceType.cyanCircle;
    grid[4][1] = PieceType.roseSquare;
    grid[2][0] = PieceType.violetTriangle;

    return PuzzleLevel(
      id: 62,
      title: 'Cross-Axis Lock',
      hint: 'Unlock the interlocking row before shifting the column path.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(3, 1)),
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(1, 3)),
        PuzzleTarget(pieceType: PieceType.violetTriangle, position: BoardPosition(2, 4)),
      ],
      optimalMoves: 8,
    );
  }

  // LEVEL 63: Delayed Alignment
  static PuzzleLevel _buildLevel63() {
    final grid = _createEmptyGrid();
    grid[0][1] = PieceType.emeraldHexagon;
    grid[2][4] = PieceType.violetTriangle;
    grid[4][2] = PieceType.amberDiamond;

    return PuzzleLevel(
      id: 63,
      title: 'Delayed Alignment',
      hint: 'Step away from the target to allow the crossing piece passage.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.emeraldHexagon, position: BoardPosition(2, 1)),
        PuzzleTarget(pieceType: PieceType.violetTriangle, position: BoardPosition(2, 3)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(0, 3)),
      ],
      optimalMoves: 5,
    );
  }

  // LEVEL 64: Parity Inversion
  static PuzzleLevel _buildLevel64() {
    final grid = _createEmptyGrid();
    grid[4][1] = PieceType.cyanCircle;
    grid[2][0] = PieceType.roseSquare;
    grid[1][4] = PieceType.emeraldHexagon;

    return PuzzleLevel(
      id: 64,
      title: 'Parity Inversion',
      hint: 'Alternate orthogonal shifts to break coordinate parity.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(1, 1)),
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(2, 2)),
        PuzzleTarget(pieceType: PieceType.emeraldHexagon, position: BoardPosition(3, 3)),
      ],
      optimalMoves: 7,
    );
  }

  // LEVEL 65: Toroidal Vortex
  static PuzzleLevel _buildLevel65() {
    final grid = _createEmptyGrid();
    grid[0][3] = PieceType.amberDiamond;
    grid[3][4] = PieceType.violetTriangle;
    grid[4][1] = PieceType.cyanCircle;

    return PuzzleLevel(
      id: 65,
      title: 'Toroidal Vortex',
      hint: 'Wrap against intuition to bypass the long exterior perimeter.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(0, 1)),
        PuzzleTarget(pieceType: PieceType.violetTriangle, position: BoardPosition(1, 4)),
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(4, 3)),
      ],
      optimalMoves: 6,
    );
  }

  // LEVEL 66: Ghost Corridor
  static PuzzleLevel _buildLevel66() {
    final grid = _createEmptyGrid();
    grid[0][2] = PieceType.roseSquare;
    grid[4][2] = PieceType.emeraldHexagon;
    grid[2][0] = PieceType.violetTriangle;
    grid[2][4] = PieceType.cyanCircle;

    return PuzzleLevel(
      id: 66,
      title: 'Ghost Corridor',
      hint: 'Open the central intersection, record the passage, and pass through.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(4, 2)),
        PuzzleTarget(pieceType: PieceType.emeraldHexagon, position: BoardPosition(0, 2)),
        PuzzleTarget(pieceType: PieceType.violetTriangle, position: BoardPosition(2, 4)),
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(2, 0)),
      ],
      optimalMoves: 8,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 67: Interference Pattern
  static PuzzleLevel _buildLevel67() {
    final grid = _createEmptyGrid();
    grid[1][2] = PieceType.amberDiamond;
    grid[2][1] = PieceType.roseSquare;
    grid[3][3] = PieceType.emeraldHexagon;

    return PuzzleLevel(
      id: 67,
      title: 'Interference Pattern',
      hint: 'Untangle overlapping wave fronts across the diagonal spine.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(3, 1)),
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(1, 3)),
        PuzzleTarget(pieceType: PieceType.emeraldHexagon, position: BoardPosition(2, 2)),
      ],
      optimalMoves: 6,
    );
  }

  // LEVEL 68: Mirror Dimension
  static PuzzleLevel _buildLevel68() {
    final grid = _createEmptyGrid();
    grid[1][0] = PieceType.cyanCircle;
    grid[1][4] = PieceType.violetTriangle;
    grid[3][1] = PieceType.amberDiamond;
    grid[3][3] = PieceType.roseSquare;

    return PuzzleLevel(
      id: 68,
      title: 'Mirror Dimension',
      hint: 'Invert bilateral symmetry with a mirrored temporal echo.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(1, 4)),
        PuzzleTarget(pieceType: PieceType.violetTriangle, position: BoardPosition(1, 0)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(3, 3)),
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(3, 1)),
      ],
      optimalMoves: 7,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 69: Quantum Tesseract
  static PuzzleLevel _buildLevel69() {
    final grid = _createEmptyGrid();
    grid[0][2] = PieceType.cyanCircle;
    grid[2][4] = PieceType.amberDiamond;
    grid[4][2] = PieceType.emeraldHexagon;
    grid[2][0] = PieceType.roseSquare;

    return PuzzleLevel(
      id: 69,
      title: 'Quantum Tesseract',
      hint: 'Fold 4-dimensional perimeter nodes into an inner rotated square.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(1, 1)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(1, 3)),
        PuzzleTarget(pieceType: PieceType.emeraldHexagon, position: BoardPosition(3, 3)),
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(3, 1)),
      ],
      optimalMoves: 7,
    );
  }

  // LEVEL 70: Paradox Engine (Milestone VII Climax)
  static PuzzleLevel _buildLevel70() {
    final grid = _createEmptyGrid();
    grid[0][2] = PieceType.violetTriangle;
    grid[2][0] = PieceType.cyanCircle;
    grid[2][4] = PieceType.amberDiamond;
    grid[4][1] = PieceType.roseSquare;
    grid[4][3] = PieceType.emeraldHexagon;

    return PuzzleLevel(
      id: 70,
      title: 'Paradox Engine',
      hint: 'Milestone VII: Untie the 5-piece spatial knot with precision wrapping.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.violetTriangle, position: BoardPosition(2, 2)),
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(1, 2)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(3, 2)),
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(2, 1)),
        PuzzleTarget(pieceType: PieceType.emeraldHexagon, position: BoardPosition(2, 3)),
      ],
      optimalMoves: 9,
      hasMemoryEcho: true,
    );
  }

  // ==========================================
  // CHAPTER 8: TEMPORAL MACHINES (Levels 71–80)
  // ==========================================

  // LEVEL 71: The Stepper
  static PuzzleLevel _buildLevel71() {
    final grid = _createEmptyGrid();
    grid[4][0] = PieceType.cyanCircle;
    grid[0][4] = PieceType.violetTriangle;

    return PuzzleLevel(
      id: 71,
      title: 'The Stepper',
      hint: 'Build a 2-step stepping motor that advances both coordinates.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(1, 2)),
        PuzzleTarget(pieceType: PieceType.violetTriangle, position: BoardPosition(2, 1)),
      ],
      optimalMoves: 6,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 72: Binary Weaver
  static PuzzleLevel _buildLevel72() {
    final grid = _createEmptyGrid();
    grid[1][0] = PieceType.amberDiamond;
    grid[3][4] = PieceType.roseSquare;
    grid[0][2] = PieceType.emeraldHexagon;

    return PuzzleLevel(
      id: 72,
      title: 'Binary Weaver',
      hint: 'Weave alternating binary pulses between horizontal and vertical lines.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(1, 3)),
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(3, 1)),
        PuzzleTarget(pieceType: PieceType.emeraldHexagon, position: BoardPosition(4, 2)),
      ],
      optimalMoves: 5,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 73: Phase Shifter
  static PuzzleLevel _buildLevel73() {
    final grid = _createEmptyGrid();
    grid[0][1] = PieceType.cyanCircle;
    grid[3][0] = PieceType.roseSquare;
    grid[4][4] = PieceType.violetTriangle;

    return PuzzleLevel(
      id: 73,
      title: 'Phase Shifter',
      hint: 'Shift phase during the pause so the replay delivers the second pulse.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(2, 1)),
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(2, 3)),
        PuzzleTarget(pieceType: PieceType.violetTriangle, position: BoardPosition(0, 3)),
      ],
      optimalMoves: 7,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 74: Clockwork Lattice
  static PuzzleLevel _buildLevel74() {
    final grid = _createEmptyGrid();
    grid[1][1] = PieceType.cyanCircle;
    grid[1][3] = PieceType.amberDiamond;
    grid[3][3] = PieceType.roseSquare;
    grid[3][1] = PieceType.emeraldHexagon;

    return PuzzleLevel(
      id: 74,
      title: 'Clockwork Lattice',
      hint: 'Rotate the four gear teeth 90 degrees clockwise using Echo.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(1, 3)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(3, 3)),
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(3, 1)),
        PuzzleTarget(pieceType: PieceType.emeraldHexagon, position: BoardPosition(1, 1)),
      ],
      optimalMoves: 8,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 75: Strobe Gate
  static PuzzleLevel _buildLevel75() {
    final grid = _createEmptyGrid();
    grid[0][4] = PieceType.violetTriangle;
    grid[4][1] = PieceType.emeraldHexagon;
    grid[2][0] = PieceType.amberDiamond;

    return PuzzleLevel(
      id: 75,
      title: 'Strobe Gate',
      hint: 'Flash the gate open, record the transit, and strobe back to base.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.violetTriangle, position: BoardPosition(3, 1)),
        PuzzleTarget(pieceType: PieceType.emeraldHexagon, position: BoardPosition(1, 3)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(2, 4)),
      ],
      optimalMoves: 8,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 76: Cascade Relay
  static PuzzleLevel _buildLevel76() {
    final grid = _createEmptyGrid();
    grid[0][0] = PieceType.cyanCircle;
    grid[1][4] = PieceType.roseSquare;
    grid[3][0] = PieceType.violetTriangle;
    grid[4][4] = PieceType.emeraldHexagon;

    return PuzzleLevel(
      id: 76,
      title: 'Cascade Relay',
      hint: 'Trigger a sequential cascade across alternating perimeter lanes.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(2, 0)),
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(2, 4)),
        PuzzleTarget(pieceType: PieceType.violetTriangle, position: BoardPosition(0, 2)),
        PuzzleTarget(pieceType: PieceType.emeraldHexagon, position: BoardPosition(4, 2)),
      ],
      optimalMoves: 7,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 77: Recursive Loop
  static PuzzleLevel _buildLevel77() {
    final grid = _createEmptyGrid();
    grid[4][2] = PieceType.amberDiamond;
    grid[0][1] = PieceType.cyanCircle;
    grid[3][4] = PieceType.roseSquare;
    grid[1][0] = PieceType.violetTriangle;

    return PuzzleLevel(
      id: 77,
      title: 'Recursive Loop',
      hint: 'Solve the southern sector on record; solve the north on replay.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(1, 2)),
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(3, 2)),
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(2, 1)),
        PuzzleTarget(pieceType: PieceType.violetTriangle, position: BoardPosition(2, 3)),
      ],
      optimalMoves: 8,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 78: Flux Capacitor
  static PuzzleLevel _buildLevel78() {
    final grid = _createEmptyGrid();
    grid[0][4] = PieceType.emeraldHexagon;
    grid[4][4] = PieceType.roseSquare;
    grid[2][0] = PieceType.amberDiamond;

    return PuzzleLevel(
      id: 78,
      title: 'Flux Capacitor',
      hint: 'Channel three high-voltage streams into the western triangle.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.emeraldHexagon, position: BoardPosition(1, 2)),
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(3, 2)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(2, 1)),
      ],
      optimalMoves: 7,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 79: Singularity Drive
  static PuzzleLevel _buildLevel79() {
    final grid = _createEmptyGrid();
    grid[1][0] = PieceType.cyanCircle;
    grid[0][3] = PieceType.amberDiamond;
    grid[3][4] = PieceType.emeraldHexagon;
    grid[4][1] = PieceType.violetTriangle;

    return PuzzleLevel(
      id: 79,
      title: 'Singularity Drive',
      hint: 'Drive four distant stars into the gravitational center column.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(1, 2)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(2, 2)),
        PuzzleTarget(pieceType: PieceType.emeraldHexagon, position: BoardPosition(3, 2)),
        PuzzleTarget(pieceType: PieceType.violetTriangle, position: BoardPosition(4, 2)),
      ],
      optimalMoves: 8,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 80: The Automaton (Milestone VIII Climax)
  static PuzzleLevel _buildLevel80() {
    final grid = _createEmptyGrid();
    grid[0][2] = PieceType.violetTriangle;
    grid[2][1] = PieceType.cyanCircle;
    grid[2][3] = PieceType.amberDiamond;
    grid[4][0] = PieceType.roseSquare;
    grid[4][4] = PieceType.emeraldHexagon;

    return PuzzleLevel(
      id: 80,
      title: 'The Automaton',
      hint: 'Milestone VIII: Synchronize five distinct mechanisms into perfect harmony.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.violetTriangle, position: BoardPosition(2, 2)),
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(0, 2)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(4, 2)),
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(2, 0)),
        PuzzleTarget(pieceType: PieceType.emeraldHexagon, position: BoardPosition(2, 4)),
      ],
      optimalMoves: 9,
      hasMemoryEcho: true,
    );
  }

  // ==========================================
  // CHAPTER 9: MASTERY (Levels 81–90)
  // ==========================================

  // LEVEL 81: Minimalist Diamond
  static PuzzleLevel _buildLevel81() {
    final grid = _createEmptyGrid();
    grid[1][2] = PieceType.cyanCircle;
    grid[3][2] = PieceType.amberDiamond;
    grid[2][1] = PieceType.roseSquare;
    grid[2][3] = PieceType.emeraldHexagon;

    return PuzzleLevel(
      id: 81,
      title: 'Minimalist Diamond',
      hint: 'Deconstruct the diamond: four tightly packed nodes must unfurl into outer corners.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(0, 0)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(4, 4)),
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(4, 0)),
        PuzzleTarget(pieceType: PieceType.emeraldHexagon, position: BoardPosition(0, 4)),
      ],
      optimalMoves: 10,
    );
  }

  // LEVEL 82: Diamond Matrix
  static PuzzleLevel _buildLevel82() {
    final grid = _createEmptyGrid();
    grid[0][2] = PieceType.cyanCircle;
    grid[2][4] = PieceType.amberDiamond;
    grid[4][2] = PieceType.roseSquare;
    grid[2][0] = PieceType.emeraldHexagon;

    return PuzzleLevel(
      id: 82,
      title: 'Diamond Matrix',
      hint: 'Invert the celestial diamond while preserving rotational symmetry.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(4, 2)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(2, 0)),
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(0, 2)),
        PuzzleTarget(pieceType: PieceType.emeraldHexagon, position: BoardPosition(2, 4)),
      ],
      optimalMoves: 8,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 83: Precision Vector
  static PuzzleLevel _buildLevel83() {
    final grid = _createEmptyGrid();
    grid[4][0] = PieceType.roseSquare;
    grid[1][4] = PieceType.violetTriangle;
    grid[3][2] = PieceType.amberDiamond;

    return PuzzleLevel(
      id: 83,
      title: 'Precision Vector',
      hint: 'Align three directional vectors along the descending diagonal.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(1, 1)),
        PuzzleTarget(pieceType: PieceType.violetTriangle, position: BoardPosition(2, 2)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(3, 3)),
      ],
      optimalMoves: 7,
    );
  }

  // LEVEL 84: False Horizon
  static PuzzleLevel _buildLevel84() {
    final grid = _createEmptyGrid();
    grid[0][4] = PieceType.cyanCircle;
    grid[2][1] = PieceType.emeraldHexagon;
    grid[4][3] = PieceType.violetTriangle;

    return PuzzleLevel(
      id: 84,
      title: 'False Horizon',
      hint: 'Ignore the visible road; wrap across the polar horizon to save moves.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(2, 3)),
        PuzzleTarget(pieceType: PieceType.emeraldHexagon, position: BoardPosition(4, 1)),
        PuzzleTarget(pieceType: PieceType.violetTriangle, position: BoardPosition(0, 1)),
      ],
      optimalMoves: 7,
    );
  }

  // LEVEL 85: The Crucible
  static PuzzleLevel _buildLevel85() {
    final grid = _createEmptyGrid();
    grid[1][1] = PieceType.amberDiamond;
    grid[1][4] = PieceType.roseSquare;
    grid[4][1] = PieceType.emeraldHexagon;
    grid[4][4] = PieceType.cyanCircle;

    return PuzzleLevel(
      id: 85,
      title: 'The Crucible',
      hint: 'Forge four scattered vertices into the horizontal equator line.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(2, 1)),
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(2, 2)),
        PuzzleTarget(pieceType: PieceType.emeraldHexagon, position: BoardPosition(2, 3)),
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(2, 4)),
      ],
      optimalMoves: 10,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 86: Zenith & Nadir
  static PuzzleLevel _buildLevel86() {
    final grid = _createEmptyGrid();
    grid[0][2] = PieceType.violetTriangle;
    grid[4][2] = PieceType.roseSquare;
    grid[2][2] = PieceType.cyanCircle;

    return PuzzleLevel(
      id: 86,
      title: 'Zenith & Nadir',
      hint: 'Invert apex and nadir while keeping the equatorial pivot stable.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.violetTriangle, position: BoardPosition(4, 2)),
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(0, 2)),
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(2, 2)),
      ],
      optimalMoves: 5,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 87: Spectral Harmony
  static PuzzleLevel _buildLevel87() {
    final grid = _createEmptyGrid();
    grid[0][1] = PieceType.cyanCircle;
    grid[1][4] = PieceType.amberDiamond;
    grid[3][0] = PieceType.roseSquare;
    grid[4][3] = PieceType.violetTriangle;

    return PuzzleLevel(
      id: 87,
      title: 'Spectral Harmony',
      hint: 'Orchestrate four orbital planes into a staggered diamond wave.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(1, 2)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(2, 3)),
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(2, 1)),
        PuzzleTarget(pieceType: PieceType.violetTriangle, position: BoardPosition(3, 2)),
      ],
      optimalMoves: 8,
    );
  }

  // LEVEL 88: Temporal Gambit
  static PuzzleLevel _buildLevel88() {
    final grid = _createEmptyGrid();
    grid[3][0] = PieceType.emeraldHexagon;
    grid[0][4] = PieceType.amberDiamond;
    grid[4][2] = PieceType.violetTriangle;
    grid[1][3] = PieceType.roseSquare;

    return PuzzleLevel(
      id: 88,
      title: 'Temporal Gambit',
      hint: 'Sacrifice a direct line to record a multi-piece sweep.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.emeraldHexagon, position: BoardPosition(1, 1)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(1, 3)),
        PuzzleTarget(pieceType: PieceType.violetTriangle, position: BoardPosition(3, 3)),
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(3, 1)),
      ],
      optimalMoves: 7,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 89: Infinite Reflection
  static PuzzleLevel _buildLevel89() {
    final grid = _createEmptyGrid();
    grid[0][3] = PieceType.cyanCircle;
    grid[1][0] = PieceType.amberDiamond;
    grid[3][4] = PieceType.emeraldHexagon;
    grid[4][1] = PieceType.roseSquare;

    return PuzzleLevel(
      id: 89,
      title: 'Infinite Reflection',
      hint: 'Mirror opposing quadrants across the central toroidal seam.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(0, 1)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(3, 0)),
        PuzzleTarget(pieceType: PieceType.emeraldHexagon, position: BoardPosition(1, 4)),
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(4, 3)),
      ],
      optimalMoves: 8,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 90: Grand Architect (Milestone IX Climax)
  static PuzzleLevel _buildLevel90() {
    final grid = _createEmptyGrid();
    grid[0][1] = PieceType.cyanCircle;
    grid[0][3] = PieceType.amberDiamond;
    grid[4][1] = PieceType.roseSquare;
    grid[4][3] = PieceType.emeraldHexagon;
    grid[2][2] = PieceType.violetTriangle;

    return PuzzleLevel(
      id: 90,
      title: 'Grand Architect',
      hint: 'Milestone IX: Anchor the central violet beacon and draw the four pillars inward.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(1, 2)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(2, 3)),
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(2, 1)),
        PuzzleTarget(pieceType: PieceType.emeraldHexagon, position: BoardPosition(3, 2)),
        PuzzleTarget(pieceType: PieceType.violetTriangle, position: BoardPosition(2, 2)),
      ],
      optimalMoves: 8,
      hasMemoryEcho: true,
    );
  }

  // ==========================================
  // CHAPTER 10: THE FINAL SHIFT (Levels 91–100)
  // ==========================================

  // LEVEL 91: Genesis
  static PuzzleLevel _buildLevel91() {
    final grid = _createEmptyGrid();
    grid[0][0] = PieceType.cyanCircle;
    grid[4][4] = PieceType.violetTriangle;
    grid[2][2] = PieceType.amberDiamond;

    return PuzzleLevel(
      id: 91,
      title: 'Genesis',
      hint: 'From the primordial corners, collapse light back to the vertical core.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(1, 2)),
        PuzzleTarget(pieceType: PieceType.violetTriangle, position: BoardPosition(3, 2)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(2, 2)),
      ],
      optimalMoves: 6,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 92: Eventide
  static PuzzleLevel _buildLevel92() {
    final grid = _createEmptyGrid();
    grid[0][3] = PieceType.roseSquare;
    grid[2][0] = PieceType.emeraldHexagon;
    grid[4][1] = PieceType.violetTriangle;
    grid[2][4] = PieceType.cyanCircle;

    return PuzzleLevel(
      id: 92,
      title: 'Eventide',
      hint: 'At dusk, four planetary bodies settle into their orbital stations.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(1, 1)),
        PuzzleTarget(pieceType: PieceType.emeraldHexagon, position: BoardPosition(1, 3)),
        PuzzleTarget(pieceType: PieceType.violetTriangle, position: BoardPosition(3, 3)),
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(3, 1)),
      ],
      optimalMoves: 8,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 93: Ouroboros
  static PuzzleLevel _buildLevel93() {
    final grid = _createEmptyGrid();
    grid[1][1] = PieceType.cyanCircle;
    grid[1][3] = PieceType.amberDiamond;
    grid[3][3] = PieceType.roseSquare;
    grid[3][1] = PieceType.emeraldHexagon;

    return PuzzleLevel(
      id: 93,
      title: 'Ouroboros',
      hint: 'The serpent bites its tail: complete the cycle with a continuous Echo loop.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(3, 1)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(1, 1)),
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(1, 3)),
        PuzzleTarget(pieceType: PieceType.emeraldHexagon, position: BoardPosition(3, 3)),
      ],
      optimalMoves: 8,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 94: Continuum
  static PuzzleLevel _buildLevel94() {
    final grid = _createEmptyGrid();
    grid[0][2] = PieceType.violetTriangle;
    grid[4][0] = PieceType.cyanCircle;
    grid[2][4] = PieceType.emeraldHexagon;
    grid[3][1] = PieceType.amberDiamond;

    return PuzzleLevel(
      id: 94,
      title: 'Continuum',
      hint: 'Navigate the uninterrupted continuum of wrapped toroidal space.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.violetTriangle, position: BoardPosition(2, 2)),
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(0, 2)),
        PuzzleTarget(pieceType: PieceType.emeraldHexagon, position: BoardPosition(2, 0)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(4, 2)),
      ],
      optimalMoves: 6,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 95: Absolute Zero
  static PuzzleLevel _buildLevel95() {
    final grid = _createEmptyGrid();
    grid[4][2] = PieceType.roseSquare;
    grid[1][4] = PieceType.violetTriangle;
    grid[0][0] = PieceType.cyanCircle;
    grid[3][3] = PieceType.amberDiamond;

    return PuzzleLevel(
      id: 95,
      title: 'Absolute Zero',
      hint: 'Freeze kinetic energy into geometric perfection.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(1, 2)),
        PuzzleTarget(pieceType: PieceType.violetTriangle, position: BoardPosition(2, 3)),
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(3, 2)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(2, 1)),
      ],
      optimalMoves: 8,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 96: Hypercube
  static PuzzleLevel _buildLevel96() {
    final grid = _createEmptyGrid();
    grid[0][0] = PieceType.cyanCircle;
    grid[0][4] = PieceType.amberDiamond;
    grid[4][4] = PieceType.roseSquare;
    grid[4][0] = PieceType.emeraldHexagon;

    return PuzzleLevel(
      id: 96,
      title: 'Hypercube',
      hint: 'Rotate a 4-dimensional hypercube into our 5×5 space.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(1, 3)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(3, 3)),
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(3, 1)),
        PuzzleTarget(pieceType: PieceType.emeraldHexagon, position: BoardPosition(1, 1)),
      ],
      optimalMoves: 10,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 97: Omega Point
  static PuzzleLevel _buildLevel97() {
    final grid = _createEmptyGrid();
    grid[0][4] = PieceType.cyanCircle;
    grid[4][0] = PieceType.amberDiamond;
    grid[1][1] = PieceType.roseSquare;
    grid[3][3] = PieceType.emeraldHexagon;
    grid[2][0] = PieceType.violetTriangle;

    return PuzzleLevel(
      id: 97,
      title: 'Omega Point',
      hint: 'The evolutionary pinnacle: gather five wandering spirits to the cross.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(0, 2)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(4, 2)),
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(2, 0)),
        PuzzleTarget(pieceType: PieceType.emeraldHexagon, position: BoardPosition(2, 4)),
        PuzzleTarget(pieceType: PieceType.violetTriangle, position: BoardPosition(2, 2)),
      ],
      optimalMoves: 9,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 98: Epoch
  static PuzzleLevel _buildLevel98() {
    final grid = _createEmptyGrid();
    grid[0][2] = PieceType.cyanCircle;
    grid[2][4] = PieceType.amberDiamond;
    grid[4][3] = PieceType.roseSquare;
    grid[3][0] = PieceType.emeraldHexagon;
    grid[1][1] = PieceType.violetTriangle;

    return PuzzleLevel(
      id: 98,
      title: 'Epoch',
      hint: 'Spanning eons: past actions construct the foundation for future triumph.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(2, 2)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(0, 2)),
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(4, 2)),
        PuzzleTarget(pieceType: PieceType.emeraldHexagon, position: BoardPosition(2, 0)),
        PuzzleTarget(pieceType: PieceType.violetTriangle, position: BoardPosition(2, 4)),
      ],
      optimalMoves: 8,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 99: Transcendence (Penultimate Test)
  static PuzzleLevel _buildLevel99() {
    final grid = _createEmptyGrid();
    grid[4][4] = PieceType.cyanCircle;
    grid[0][0] = PieceType.amberDiamond;
    grid[1][4] = PieceType.roseSquare;
    grid[4][1] = PieceType.emeraldHexagon;
    grid[2][3] = PieceType.violetTriangle;

    return PuzzleLevel(
      id: 99,
      title: 'Transcendence',
      hint: 'The penultimate gate: harmonize complex multi-lane shifts into pure order.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(1, 1)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(1, 3)),
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(3, 1)),
        PuzzleTarget(pieceType: PieceType.emeraldHexagon, position: BoardPosition(3, 3)),
        PuzzleTarget(pieceType: PieceType.violetTriangle, position: BoardPosition(2, 2)),
      ],
      optimalMoves: 10,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 100: The Final Shift (The Grand Finale)
  static PuzzleLevel _buildLevel100() {
    final grid = _createEmptyGrid();
    grid[2][0] = PieceType.violetTriangle;
    grid[4][2] = PieceType.cyanCircle;
    grid[0][2] = PieceType.emeraldHexagon;
    grid[1][4] = PieceType.amberDiamond;
    grid[3][1] = PieceType.roseSquare;

    return PuzzleLevel(
      id: 100,
      title: 'The Final Shift',
      hint: 'The Grand Finale: Crown the Violet Triangle at the center of the cosmos.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.violetTriangle, position: BoardPosition(2, 2)),
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(0, 2)),
        PuzzleTarget(pieceType: PieceType.emeraldHexagon, position: BoardPosition(4, 2)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(2, 0)),
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(2, 4)),
      ],
      optimalMoves: 8,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 101
  static PuzzleLevel _buildLevel101() {
    final grid = _createEmptyGrid();
    grid[1][1] = PieceType.cyanCircle;
    grid[1][3] = PieceType.amberDiamond;
    grid[3][1] = PieceType.roseSquare;
    grid[3][3] = PieceType.emeraldHexagon;
    return PuzzleLevel(
      id: 101,
      title: 'Harmonic Prelude',
      hint: 'Harmonize the quad: cross-axis shifts weave the outer corners into central focus.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(2, 3)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(2, 1)),
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(3, 2)),
        PuzzleTarget(pieceType: PieceType.emeraldHexagon, position: BoardPosition(1, 2)),
      ],
      optimalMoves: 8,
    );
  }

  // LEVEL 102
  static PuzzleLevel _buildLevel102() {
    final grid = _createEmptyGrid();
    grid[0][2] = PieceType.cyanCircle;
    grid[4][2] = PieceType.amberDiamond;
    grid[2][1] = PieceType.roseSquare;
    grid[2][3] = PieceType.emeraldHexagon;
    return PuzzleLevel(
      id: 102,
      title: 'Twin Resonance',
      hint: 'Inverted polar axis: split vertical alignments through toroidal drift.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(2, 4)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(2, 0)),
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(1, 2)),
        PuzzleTarget(pieceType: PieceType.emeraldHexagon, position: BoardPosition(3, 2)),
      ],
      optimalMoves: 8,
    );
  }

  // LEVEL 103
  static PuzzleLevel _buildLevel103() {
    final grid = _createEmptyGrid();
    grid[1][0] = PieceType.cyanCircle;
    grid[1][4] = PieceType.amberDiamond;
    grid[3][1] = PieceType.roseSquare;
    grid[3][3] = PieceType.emeraldHexagon;
    return PuzzleLevel(
      id: 103,
      title: 'Chordal Shift',
      hint: 'Triadic balance: coordinate the outer wings before shifting the root.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(2, 2)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(0, 2)),
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(4, 2)),
        PuzzleTarget(pieceType: PieceType.emeraldHexagon, position: BoardPosition(2, 4)),
      ],
      optimalMoves: 7,
    );
  }

  // LEVEL 104
  static PuzzleLevel _buildLevel104() {
    final grid = _createEmptyGrid();
    grid[2][0] = PieceType.cyanCircle;
    grid[2][4] = PieceType.emeraldHexagon;
    grid[0][2] = PieceType.violetTriangle;
    return PuzzleLevel(
      id: 104,
      title: 'Octave Pulse',
      hint: 'Transpose the center: send the violet spire between lateral waves.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(1, 2)),
        PuzzleTarget(pieceType: PieceType.emeraldHexagon, position: BoardPosition(3, 2)),
        PuzzleTarget(pieceType: PieceType.violetTriangle, position: BoardPosition(2, 2)),
      ],
      optimalMoves: 6,
    );
  }

  // LEVEL 105
  static PuzzleLevel _buildLevel105() {
    final grid = _createEmptyGrid();
    grid[1][2] = PieceType.roseSquare;
    grid[3][2] = PieceType.amberDiamond;
    grid[2][1] = PieceType.cyanCircle;
    return PuzzleLevel(
      id: 105,
      title: 'Sympathetic Vibration',
      hint: 'A shift on row 2 resonates across both vertical sentinels.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(0, 3)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(4, 3)),
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(2, 4)),
      ],
      optimalMoves: 6,
    );
  }

  // LEVEL 106
  static PuzzleLevel _buildLevel106() {
    final grid = _createEmptyGrid();
    grid[1][1] = PieceType.cyanCircle;
    grid[1][3] = PieceType.amberDiamond;
    grid[3][1] = PieceType.roseSquare;
    grid[3][3] = PieceType.emeraldHexagon;
    return PuzzleLevel(
      id: 106,
      title: 'Quad Resonance',
      hint: 'Square symmetry: rotate the inner quadrant through perimeter channels.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(0, 2)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(2, 4)),
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(4, 2)),
        PuzzleTarget(pieceType: PieceType.emeraldHexagon, position: BoardPosition(2, 0)),
      ],
      optimalMoves: 7,
    );
  }

  // LEVEL 107
  static PuzzleLevel _buildLevel107() {
    final grid = _createEmptyGrid();
    grid[4][1] = PieceType.violetTriangle;
    grid[0][3] = PieceType.amberDiamond;
    grid[2][4] = PieceType.emeraldHexagon;
    return PuzzleLevel(
      id: 107,
      title: 'Timbre Weave',
      hint: 'Interleaving phases: stagger columns before collapsing the rows.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.violetTriangle, position: BoardPosition(1, 2)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(3, 2)),
        PuzzleTarget(pieceType: PieceType.emeraldHexagon, position: BoardPosition(2, 1)),
      ],
      optimalMoves: 8,
    );
  }

  // LEVEL 108
  static PuzzleLevel _buildLevel108() {
    final grid = _createEmptyGrid();
    grid[0][1] = PieceType.cyanCircle;
    grid[2][1] = PieceType.roseSquare;
    grid[4][3] = PieceType.amberDiamond;
    grid[2][3] = PieceType.emeraldHexagon;
    return PuzzleLevel(
      id: 108,
      title: 'Harmonic Cascade',
      hint: 'Cascade across parallel lanes: do not lock column 1 prematurely.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(1, 4)),
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(3, 4)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(1, 0)),
        PuzzleTarget(pieceType: PieceType.emeraldHexagon, position: BoardPosition(3, 0)),
      ],
      optimalMoves: 9,
    );
  }

  // LEVEL 109
  static PuzzleLevel _buildLevel109() {
    final grid = _createEmptyGrid();
    grid[2][2] = PieceType.violetTriangle;
    grid[1][0] = PieceType.cyanCircle;
    grid[3][4] = PieceType.roseSquare;
    grid[0][2] = PieceType.amberDiamond;
    return PuzzleLevel(
      id: 109,
      title: 'Standing Wave',
      hint: 'Constructive interference: displace the node to guide the harmonics.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.violetTriangle, position: BoardPosition(4, 2)),
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(2, 4)),
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(2, 0)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(0, 4)),
      ],
      optimalMoves: 8,
    );
  }

  // LEVEL 110
  static PuzzleLevel _buildLevel110() {
    final grid = _createEmptyGrid();
    grid[0][2] = PieceType.violetTriangle;
    grid[4][2] = PieceType.cyanCircle;
    grid[2][0] = PieceType.emeraldHexagon;
    grid[2][4] = PieceType.amberDiamond;
    return PuzzleLevel(
      id: 110,
      title: 'Grand Harmonic',
      hint: 'Chapter XI Climax: Record a cross-harmonic ripple and echo it into pure concord.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.violetTriangle, position: BoardPosition(2, 1)),
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(2, 3)),
        PuzzleTarget(pieceType: PieceType.emeraldHexagon, position: BoardPosition(1, 2)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(3, 2)),
      ],
      optimalMoves: 8,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 111
  static PuzzleLevel _buildLevel111() {
    final grid = _createEmptyGrid();
    grid[0][2] = PieceType.cyanCircle;
    grid[4][2] = PieceType.amberDiamond;
    grid[2][0] = PieceType.roseSquare;
    grid[2][4] = PieceType.emeraldHexagon;
    return PuzzleLevel(
      id: 111,
      title: 'Spin Coupling',
      hint: 'Entangled quad: rotating the central cross alters both polarities simultaneously.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(2, 4)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(2, 0)),
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(4, 2)),
        PuzzleTarget(pieceType: PieceType.emeraldHexagon, position: BoardPosition(0, 2)),
      ],
      optimalMoves: 9,
    );
  }

  // LEVEL 112
  static PuzzleLevel _buildLevel112() {
    final grid = _createEmptyGrid();
    grid[2][1] = PieceType.cyanCircle;
    grid[2][3] = PieceType.amberDiamond;
    grid[1][2] = PieceType.violetTriangle;
    return PuzzleLevel(
      id: 112,
      title: 'Superposition',
      hint: 'The central intersection cannot hold two states at once. Loop through row 0.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(2, 3)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(2, 1)),
        PuzzleTarget(pieceType: PieceType.violetTriangle, position: BoardPosition(3, 2)),
      ],
      optimalMoves: 7,
    );
  }

  // LEVEL 113
  static PuzzleLevel _buildLevel113() {
    final grid = _createEmptyGrid();
    grid[0][0] = PieceType.roseSquare;
    grid[4][4] = PieceType.emeraldHexagon;
    grid[2][2] = PieceType.cyanCircle;
    return PuzzleLevel(
      id: 113,
      title: 'Bell State',
      hint: 'Diagonal entanglement: polar corners must orbit the central nexus.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(2, 4)),
        PuzzleTarget(pieceType: PieceType.emeraldHexagon, position: BoardPosition(2, 0)),
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(4, 2)),
      ],
      optimalMoves: 7,
    );
  }

  // LEVEL 114
  static PuzzleLevel _buildLevel114() {
    final grid = _createEmptyGrid();
    grid[1][1] = PieceType.violetTriangle;
    grid[1][2] = PieceType.amberDiamond;
    grid[1][3] = PieceType.roseSquare;
    return PuzzleLevel(
      id: 114,
      title: 'Quantum Tunneling',
      hint: 'Tunnel through the boundary: wrap the trio around column edges.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.violetTriangle, position: BoardPosition(3, 3)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(3, 2)),
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(3, 1)),
      ],
      optimalMoves: 8,
    );
  }

  // LEVEL 115
  static PuzzleLevel _buildLevel115() {
    final grid = _createEmptyGrid();
    grid[0][2] = PieceType.cyanCircle;
    grid[2][0] = PieceType.emeraldHexagon;
    grid[4][2] = PieceType.roseSquare;
    grid[2][4] = PieceType.amberDiamond;
    return PuzzleLevel(
      id: 115,
      title: 'Phase Lock',
      hint: 'Cross-axis lock: shifting one arm disturbs the opposite coordinate.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(2, 2)),
        PuzzleTarget(pieceType: PieceType.emeraldHexagon, position: BoardPosition(0, 4)),
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(4, 0)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(2, 3)),
      ],
      optimalMoves: 7,
    );
  }

  // LEVEL 116
  static PuzzleLevel _buildLevel116() {
    final grid = _createEmptyGrid();
    grid[1][1] = PieceType.violetTriangle;
    grid[3][3] = PieceType.amberDiamond;
    grid[0][4] = PieceType.emeraldHexagon;
    grid[4][0] = PieceType.cyanCircle;
    return PuzzleLevel(
      id: 116,
      title: 'Wave Collapse',
      hint: 'Collapse probabilities: converge diagonally opposite pairs.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.violetTriangle, position: BoardPosition(2, 2)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(1, 3)),
        PuzzleTarget(pieceType: PieceType.emeraldHexagon, position: BoardPosition(3, 1)),
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(2, 0)),
      ],
      optimalMoves: 8,
    );
  }

  // LEVEL 117
  static PuzzleLevel _buildLevel117() {
    final grid = _createEmptyGrid();
    grid[0][0] = PieceType.cyanCircle;
    grid[0][4] = PieceType.amberDiamond;
    grid[4][0] = PieceType.roseSquare;
    grid[4][4] = PieceType.emeraldHexagon;
    return PuzzleLevel(
      id: 117,
      title: 'Quantum Teleport',
      hint: 'Toroidal teleportation: four corners must cycle through opposing quadrant edges.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(4, 4)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(4, 0)),
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(0, 4)),
        PuzzleTarget(pieceType: PieceType.emeraldHexagon, position: BoardPosition(0, 0)),
      ],
      optimalMoves: 8,
    );
  }

  // LEVEL 118
  static PuzzleLevel _buildLevel118() {
    final grid = _createEmptyGrid();
    grid[1][2] = PieceType.cyanCircle;
    grid[2][1] = PieceType.roseSquare;
    grid[3][2] = PieceType.amberDiamond;
    grid[2][3] = PieceType.violetTriangle;
    return PuzzleLevel(
      id: 118,
      title: 'Entangled Lattice',
      hint: 'Diamond matrix: expand the tight cluster into four cardinal borders.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(0, 2)),
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(2, 0)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(4, 2)),
        PuzzleTarget(pieceType: PieceType.violetTriangle, position: BoardPosition(2, 4)),
      ],
      optimalMoves: 8,
    );
  }

  // LEVEL 119
  static PuzzleLevel _buildLevel119() {
    final grid = _createEmptyGrid();
    grid[0][0] = PieceType.emeraldHexagon;
    grid[0][4] = PieceType.roseSquare;
    grid[4][0] = PieceType.amberDiamond;
    grid[4][4] = PieceType.cyanCircle;
    return PuzzleLevel(
      id: 119,
      title: 'Parity Paradox',
      hint: 'Corners inverted: swap diagonal partners without disturbing lateral lanes.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.emeraldHexagon, position: BoardPosition(4, 4)),
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(4, 0)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(0, 4)),
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(0, 0)),
      ],
      optimalMoves: 8,
    );
  }

  // LEVEL 120
  static PuzzleLevel _buildLevel120() {
    final grid = _createEmptyGrid();
    grid[2][2] = PieceType.violetTriangle;
    grid[1][1] = PieceType.cyanCircle;
    grid[1][3] = PieceType.roseSquare;
    grid[3][1] = PieceType.amberDiamond;
    grid[3][3] = PieceType.emeraldHexagon;
    return PuzzleLevel(
      id: 120,
      title: 'Quantum Apex',
      hint: 'Chapter XII Climax: Displace the quantum core, record the permutation, and collapse the matrix.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.violetTriangle, position: BoardPosition(0, 2)),
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(2, 4)),
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(4, 2)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(2, 0)),
        PuzzleTarget(pieceType: PieceType.emeraldHexagon, position: BoardPosition(2, 2)),
      ],
      optimalMoves: 7,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 121
  static PuzzleLevel _buildLevel121() {
    final grid = _createEmptyGrid();
    grid[0][1] = PieceType.cyanCircle;
    grid[4][3] = PieceType.amberDiamond;
    grid[2][0] = PieceType.roseSquare;
    grid[2][4] = PieceType.emeraldHexagon;
    return PuzzleLevel(
      id: 121,
      title: 'Echo Gateway',
      hint: 'Record lateral cycles, reposition the central axis, then replay through the gateway.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(2, 1)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(2, 3)),
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(4, 0)),
        PuzzleTarget(pieceType: PieceType.emeraldHexagon, position: BoardPosition(0, 4)),
      ],
      optimalMoves: 8,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 122
  static PuzzleLevel _buildLevel122() {
    final grid = _createEmptyGrid();
    grid[1][2] = PieceType.roseSquare;
    grid[3][2] = PieceType.emeraldHexagon;
    grid[2][4] = PieceType.cyanCircle;
    return PuzzleLevel(
      id: 122,
      title: 'Temporal Bypass',
      hint: 'Macro the vertical lane: reposition the cyan jewel before replaying.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(3, 4)),
        PuzzleTarget(pieceType: PieceType.emeraldHexagon, position: BoardPosition(1, 4)),
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(2, 2)),
      ],
      optimalMoves: 8,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 123
  static PuzzleLevel _buildLevel123() {
    final grid = _createEmptyGrid();
    grid[2][0] = PieceType.violetTriangle;
    grid[0][2] = PieceType.amberDiamond;
    grid[4][2] = PieceType.roseSquare;
    return PuzzleLevel(
      id: 123,
      title: 'Loop Program',
      hint: 'Record a row-column sequence, reposition the apex, then Echo to complete.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.violetTriangle, position: BoardPosition(2, 4)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(4, 0)),
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(0, 0)),
      ],
      optimalMoves: 6,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 124
  static PuzzleLevel _buildLevel124() {
    final grid = _createEmptyGrid();
    grid[1][1] = PieceType.emeraldHexagon;
    grid[1][3] = PieceType.cyanCircle;
    grid[3][2] = PieceType.amberDiamond;
    return PuzzleLevel(
      id: 124,
      title: 'Delayed Action',
      hint: 'Freeze the dual horizontal shift. Relocate the amber diamond into the phantom wake.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.emeraldHexagon, position: BoardPosition(4, 1)),
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(4, 3)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(0, 2)),
      ],
      optimalMoves: 6,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 125
  static PuzzleLevel _buildLevel125() {
    final grid = _createEmptyGrid();
    grid[0][2] = PieceType.violetTriangle;
    grid[2][4] = PieceType.roseSquare;
    grid[4][2] = PieceType.cyanCircle;
    grid[2][0] = PieceType.emeraldHexagon;
    return PuzzleLevel(
      id: 125,
      title: 'Phantom Axis',
      hint: 'Corners to cross: record the axis shift, load the corners, and replay.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.violetTriangle, position: BoardPosition(2, 1)),
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(1, 2)),
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(3, 2)),
        PuzzleTarget(pieceType: PieceType.emeraldHexagon, position: BoardPosition(2, 3)),
      ],
      optimalMoves: 6,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 126
  static PuzzleLevel _buildLevel126() {
    final grid = _createEmptyGrid();
    grid[2][0] = PieceType.cyanCircle;
    grid[2][4] = PieceType.amberDiamond;
    grid[0][2] = PieceType.roseSquare;
    grid[4][2] = PieceType.emeraldHexagon;
    return PuzzleLevel(
      id: 126,
      title: 'Echo Transposition',
      hint: 'Invert the central cross through programmed perimeter wraps.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(2, 4)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(2, 0)),
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(4, 2)),
        PuzzleTarget(pieceType: PieceType.emeraldHexagon, position: BoardPosition(0, 2)),
      ],
      optimalMoves: 8,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 127
  static PuzzleLevel _buildLevel127() {
    final grid = _createEmptyGrid();
    grid[0][2] = PieceType.violetTriangle;
    grid[2][1] = PieceType.amberDiamond;
    grid[4][3] = PieceType.emeraldHexagon;
    return PuzzleLevel(
      id: 127,
      title: 'Chrono Stride',
      hint: 'Staggered columns: let the phantom step carry the trailing emerald.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.violetTriangle, position: BoardPosition(3, 2)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(1, 4)),
        PuzzleTarget(pieceType: PieceType.emeraldHexagon, position: BoardPosition(2, 0)),
      ],
      optimalMoves: 6,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 128
  static PuzzleLevel _buildLevel128() {
    final grid = _createEmptyGrid();
    grid[1][1] = PieceType.cyanCircle;
    grid[1][3] = PieceType.roseSquare;
    grid[3][1] = PieceType.amberDiamond;
    grid[3][3] = PieceType.violetTriangle;
    return PuzzleLevel(
      id: 128,
      title: 'Macro Conveyor',
      hint: 'Interlocking conveyors: load gems onto both lanes before activating Echo.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(3, 1)),
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(3, 3)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(1, 1)),
        PuzzleTarget(pieceType: PieceType.violetTriangle, position: BoardPosition(1, 3)),
      ],
      optimalMoves: 8,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 129
  static PuzzleLevel _buildLevel129() {
    final grid = _createEmptyGrid();
    grid[0][2] = PieceType.emeraldHexagon;
    grid[4][2] = PieceType.amberDiamond;
    grid[2][0] = PieceType.roseSquare;
    grid[2][4] = PieceType.cyanCircle;
    return PuzzleLevel(
      id: 129,
      title: 'Replay Nexus',
      hint: 'A 3-step spatial loop: position the amber diamond right before replay.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.emeraldHexagon, position: BoardPosition(4, 0)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(0, 4)),
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(1, 1)),
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(3, 3)),
      ],
      optimalMoves: 8,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 130
  static PuzzleLevel _buildLevel130() {
    final grid = _createEmptyGrid();
    grid[2][2] = PieceType.violetTriangle;
    grid[0][2] = PieceType.cyanCircle;
    grid[4][2] = PieceType.roseSquare;
    grid[2][0] = PieceType.amberDiamond;
    grid[2][4] = PieceType.emeraldHexagon;
    return PuzzleLevel(
      id: 130,
      title: 'Nexus Transcendent',
      hint: 'Chapter XIII Climax: Program the central vortex, step aside, and unleash the macro.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.violetTriangle, position: BoardPosition(2, 2)),
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(4, 4)),
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(0, 0)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(4, 0)),
        PuzzleTarget(pieceType: PieceType.emeraldHexagon, position: BoardPosition(0, 4)),
      ],
      optimalMoves: 8,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 131
  static PuzzleLevel _buildLevel131() {
    final grid = _createEmptyGrid();
    grid[1][1] = PieceType.cyanCircle;
    grid[2][3] = PieceType.roseSquare;
    grid[4][2] = PieceType.amberDiamond;
    return PuzzleLevel(
      id: 131,
      title: 'Chrono Cadence',
      hint: 'Tight par: every move must advance at least two pieces toward their homes.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(3, 1)),
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(2, 0)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(1, 2)),
      ],
      optimalMoves: 6,
    );
  }

  // LEVEL 132
  static PuzzleLevel _buildLevel132() {
    final grid = _createEmptyGrid();
    grid[0][3] = PieceType.violetTriangle;
    grid[3][0] = PieceType.emeraldHexagon;
    grid[4][4] = PieceType.cyanCircle;
    return PuzzleLevel(
      id: 132,
      title: 'Cyclic Velocity',
      hint: 'Toroidal acceleration: ride the outer perimeter into a triple alignment.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.violetTriangle, position: BoardPosition(2, 2)),
        PuzzleTarget(pieceType: PieceType.emeraldHexagon, position: BoardPosition(2, 4)),
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(2, 0)),
      ],
      optimalMoves: 6,
    );
  }

  // LEVEL 133
  static PuzzleLevel _buildLevel133() {
    final grid = _createEmptyGrid();
    grid[1][2] = PieceType.roseSquare;
    grid[3][2] = PieceType.amberDiamond;
    grid[2][1] = PieceType.cyanCircle;
    grid[2][3] = PieceType.emeraldHexagon;
    return PuzzleLevel(
      id: 133,
      title: 'Dynamic Permutation',
      hint: 'Permute the ring: rotate row 2 and column 2 without breaking parity.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(2, 4)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(2, 0)),
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(0, 2)),
        PuzzleTarget(pieceType: PieceType.emeraldHexagon, position: BoardPosition(4, 2)),
      ],
      optimalMoves: 8,
    );
  }

  // LEVEL 134
  static PuzzleLevel _buildLevel134() {
    final grid = _createEmptyGrid();
    grid[0][1] = PieceType.violetTriangle;
    grid[0][3] = PieceType.cyanCircle;
    grid[4][1] = PieceType.roseSquare;
    grid[4][3] = PieceType.amberDiamond;
    return PuzzleLevel(
      id: 134,
      title: 'Chrono Inversion',
      hint: 'Cross-lane swap: reverse the top and bottom pairs using column wraps.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.violetTriangle, position: BoardPosition(4, 3)),
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(4, 1)),
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(0, 3)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(0, 1)),
      ],
      optimalMoves: 8,
    );
  }

  // LEVEL 135
  static PuzzleLevel _buildLevel135() {
    final grid = _createEmptyGrid();
    grid[1][0] = PieceType.emeraldHexagon;
    grid[3][0] = PieceType.amberDiamond;
    grid[0][3] = PieceType.roseSquare;
    grid[4][3] = PieceType.cyanCircle;
    return PuzzleLevel(
      id: 135,
      title: 'Momentum Shift',
      hint: 'Shift momentum between columns 0 and 3 through central bridging.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.emeraldHexagon, position: BoardPosition(2, 1)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(2, 3)),
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(1, 2)),
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(3, 2)),
      ],
      optimalMoves: 8,
    );
  }

  // LEVEL 136
  static PuzzleLevel _buildLevel136() {
    final grid = _createEmptyGrid();
    grid[2][2] = PieceType.violetTriangle;
    grid[0][0] = PieceType.amberDiamond;
    grid[0][4] = PieceType.emeraldHexagon;
    grid[4][2] = PieceType.roseSquare;
    return PuzzleLevel(
      id: 136,
      title: 'Temporal Brake',
      hint: 'Arrest the rotation: anchor the violet gem at the center early.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.violetTriangle, position: BoardPosition(2, 2)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(4, 4)),
        PuzzleTarget(pieceType: PieceType.emeraldHexagon, position: BoardPosition(4, 0)),
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(0, 2)),
      ],
      optimalMoves: 6,
    );
  }

  // LEVEL 137
  static PuzzleLevel _buildLevel137() {
    final grid = _createEmptyGrid();
    grid[1][1] = PieceType.cyanCircle;
    grid[1][4] = PieceType.roseSquare;
    grid[4][1] = PieceType.amberDiamond;
    grid[4][4] = PieceType.emeraldHexagon;
    return PuzzleLevel(
      id: 137,
      title: 'Dynamic Vortex',
      hint: 'Spiraling paths: swirl the quad gems toward the inner core.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(2, 3)),
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(3, 2)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(1, 2)),
        PuzzleTarget(pieceType: PieceType.emeraldHexagon, position: BoardPosition(2, 1)),
      ],
      optimalMoves: 9,
    );
  }

  // LEVEL 138
  static PuzzleLevel _buildLevel138() {
    final grid = _createEmptyGrid();
    grid[0][2] = PieceType.violetTriangle;
    grid[2][0] = PieceType.cyanCircle;
    grid[2][4] = PieceType.roseSquare;
    grid[4][1] = PieceType.amberDiamond;
    grid[4][3] = PieceType.emeraldHexagon;
    return PuzzleLevel(
      id: 138,
      title: 'Chrono Cascade',
      hint: 'Five-piece cascade: resolve the lower foundation before seating the crown.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.violetTriangle, position: BoardPosition(2, 2)),
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(1, 1)),
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(1, 3)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(3, 1)),
        PuzzleTarget(pieceType: PieceType.emeraldHexagon, position: BoardPosition(3, 3)),
      ],
      optimalMoves: 7,
    );
  }

  // LEVEL 139
  static PuzzleLevel _buildLevel139() {
    final grid = _createEmptyGrid();
    grid[0][2] = PieceType.cyanCircle;
    grid[4][2] = PieceType.amberDiamond;
    grid[2][0] = PieceType.roseSquare;
    grid[2][4] = PieceType.emeraldHexagon;
    grid[2][2] = PieceType.violetTriangle;
    return PuzzleLevel(
      id: 139,
      title: 'Kinetic Equilibrium',
      hint: 'Equilibrium requires exact conservation of horizontal and vertical shifts.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(2, 2)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(4, 4)),
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(0, 0)),
        PuzzleTarget(pieceType: PieceType.emeraldHexagon, position: BoardPosition(4, 0)),
        PuzzleTarget(pieceType: PieceType.violetTriangle, position: BoardPosition(0, 4)),
      ],
      optimalMoves: 10,
    );
  }

  // LEVEL 140
  static PuzzleLevel _buildLevel140() {
    final grid = _createEmptyGrid();
    grid[0][1] = PieceType.violetTriangle;
    grid[0][3] = PieceType.cyanCircle;
    grid[4][1] = PieceType.roseSquare;
    grid[4][3] = PieceType.amberDiamond;
    grid[2][2] = PieceType.emeraldHexagon;
    return PuzzleLevel(
      id: 140,
      title: 'Chrono Master',
      hint: 'Chapter XIV Climax: Master the clockwork. A 3-move macro opens the chrono lock.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.violetTriangle, position: BoardPosition(2, 2)),
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(0, 2)),
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(4, 2)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(2, 0)),
        PuzzleTarget(pieceType: PieceType.emeraldHexagon, position: BoardPosition(2, 4)),
      ],
      optimalMoves: 8,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 141
  static PuzzleLevel _buildLevel141() {
    final grid = _createEmptyGrid();
    grid[0][2] = PieceType.cyanCircle;
    grid[2][0] = PieceType.roseSquare;
    grid[4][2] = PieceType.amberDiamond;
    grid[2][4] = PieceType.emeraldHexagon;
    return PuzzleLevel(
      id: 141,
      title: 'Singularity: Event Horizon',
      hint: 'Cross the event horizon: pieces inside row 2 cannot return without wrapping.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(1, 1)),
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(3, 1)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(3, 3)),
        PuzzleTarget(pieceType: PieceType.emeraldHexagon, position: BoardPosition(1, 3)),
      ],
      optimalMoves: 7,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 142
  static PuzzleLevel _buildLevel142() {
    final grid = _createEmptyGrid();
    grid[0][2] = PieceType.cyanCircle;
    grid[4][2] = PieceType.amberDiamond;
    grid[2][0] = PieceType.roseSquare;
    grid[2][4] = PieceType.emeraldHexagon;
    grid[1][1] = PieceType.violetTriangle;
    return PuzzleLevel(
      id: 142,
      title: 'Singularity: Gravitational Lens',
      hint: 'The gravitational vortex curves all five coordinates toward the event horizon.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(2, 2)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(0, 2)),
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(4, 2)),
        PuzzleTarget(pieceType: PieceType.emeraldHexagon, position: BoardPosition(2, 0)),
        PuzzleTarget(pieceType: PieceType.violetTriangle, position: BoardPosition(2, 4)),
      ],
      optimalMoves: 9,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 143
  static PuzzleLevel _buildLevel143() {
    final grid = _createEmptyGrid();
    grid[2][1] = PieceType.emeraldHexagon;
    grid[2][3] = PieceType.roseSquare;
    grid[0][2] = PieceType.violetTriangle;
    grid[4][2] = PieceType.amberDiamond;
    return PuzzleLevel(
      id: 143,
      title: 'Singularity: Time Dilation',
      hint: 'Time slows at the core: maneuver outer rings before disturbing the cross.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.emeraldHexagon, position: BoardPosition(1, 3)),
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(3, 1)),
        PuzzleTarget(pieceType: PieceType.violetTriangle, position: BoardPosition(3, 3)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(1, 1)),
      ],
      optimalMoves: 9,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 144
  static PuzzleLevel _buildLevel144() {
    final grid = _createEmptyGrid();
    grid[1][2] = PieceType.violetTriangle;
    grid[3][2] = PieceType.cyanCircle;
    grid[2][1] = PieceType.roseSquare;
    grid[2][3] = PieceType.amberDiamond;
    grid[0][0] = PieceType.emeraldHexagon;
    return PuzzleLevel(
      id: 144,
      title: 'Singularity: Ergosphere',
      hint: 'Dragged into rotation: the ergosphere forces all gems into cyclic orbit.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.violetTriangle, position: BoardPosition(2, 2)),
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(0, 4)),
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(4, 4)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(4, 0)),
        PuzzleTarget(pieceType: PieceType.emeraldHexagon, position: BoardPosition(0, 0)),
      ],
      optimalMoves: 8,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 145
  static PuzzleLevel _buildLevel145() {
    final grid = _createEmptyGrid();
    grid[0][1] = PieceType.cyanCircle;
    grid[1][4] = PieceType.roseSquare;
    grid[4][3] = PieceType.amberDiamond;
    grid[3][0] = PieceType.emeraldHexagon;
    return PuzzleLevel(
      id: 145,
      title: 'Singularity: Frame Dragging',
      hint: 'Spacetime twist: drag each quadrant clockwise along the board boundary.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(2, 1)),
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(1, 2)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(2, 3)),
        PuzzleTarget(pieceType: PieceType.emeraldHexagon, position: BoardPosition(3, 2)),
      ],
      optimalMoves: 8,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 146
  static PuzzleLevel _buildLevel146() {
    final grid = _createEmptyGrid();
    grid[0][0] = PieceType.violetTriangle;
    grid[1][2] = PieceType.cyanCircle;
    grid[2][4] = PieceType.roseSquare;
    grid[3][1] = PieceType.amberDiamond;
    grid[4][3] = PieceType.emeraldHexagon;
    return PuzzleLevel(
      id: 146,
      title: 'Singularity: Quantum Foam',
      hint: 'Sub-planckian fluctuations: organize scattered particles into a neat cross.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.violetTriangle, position: BoardPosition(2, 2)),
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(1, 2)),
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(3, 2)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(2, 1)),
        PuzzleTarget(pieceType: PieceType.emeraldHexagon, position: BoardPosition(2, 3)),
      ],
      optimalMoves: 8,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 147
  static PuzzleLevel _buildLevel147() {
    final grid = _createEmptyGrid();
    grid[0][1] = PieceType.cyanCircle;
    grid[0][3] = PieceType.amberDiamond;
    grid[4][1] = PieceType.roseSquare;
    grid[4][3] = PieceType.emeraldHexagon;
    grid[2][2] = PieceType.violetTriangle;
    return PuzzleLevel(
      id: 147,
      title: 'Singularity: Hawking Radiation',
      hint: 'Radiant emission: the central beacon escapes while outer sentinels swap orbits.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(4, 3)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(4, 1)),
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(0, 3)),
        PuzzleTarget(pieceType: PieceType.emeraldHexagon, position: BoardPosition(0, 1)),
        PuzzleTarget(pieceType: PieceType.violetTriangle, position: BoardPosition(2, 4)),
      ],
      optimalMoves: 10,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 148
  static PuzzleLevel _buildLevel148() {
    final grid = _createEmptyGrid();
    grid[1][1] = PieceType.cyanCircle;
    grid[1][3] = PieceType.amberDiamond;
    grid[3][1] = PieceType.roseSquare;
    grid[3][3] = PieceType.emeraldHexagon;
    grid[4][2] = PieceType.violetTriangle;
    return PuzzleLevel(
      id: 148,
      title: 'Singularity: Wormhole Gateway',
      hint: 'Connect the throats: wrap the four sentinels through opposing poles.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(0, 2)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(2, 4)),
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(4, 2)),
        PuzzleTarget(pieceType: PieceType.emeraldHexagon, position: BoardPosition(2, 0)),
        PuzzleTarget(pieceType: PieceType.violetTriangle, position: BoardPosition(2, 2)),
      ],
      optimalMoves: 8,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 149
  static PuzzleLevel _buildLevel149() {
    final grid = _createEmptyGrid();
    grid[0][2] = PieceType.violetTriangle;
    grid[4][2] = PieceType.cyanCircle;
    grid[2][0] = PieceType.roseSquare;
    grid[2][4] = PieceType.amberDiamond;
    grid[1][1] = PieceType.emeraldHexagon;
    return PuzzleLevel(
      id: 149,
      title: 'Singularity: The Penrose Process',
      hint: 'Extract rotational energy: cycle the diamond ring to seat the crown.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.violetTriangle, position: BoardPosition(2, 2)),
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(3, 1)),
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(1, 3)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(3, 3)),
        PuzzleTarget(pieceType: PieceType.emeraldHexagon, position: BoardPosition(1, 1)),
      ],
      optimalMoves: 8,
      hasMemoryEcho: true,
    );
  }

  // LEVEL 150
  static PuzzleLevel _buildLevel150() {
    final grid = _createEmptyGrid();
    grid[0][0] = PieceType.violetTriangle;
    grid[0][4] = PieceType.cyanCircle;
    grid[4][0] = PieceType.roseSquare;
    grid[4][4] = PieceType.amberDiamond;
    grid[2][2] = PieceType.emeraldHexagon;
    return PuzzleLevel(
      id: 150,
      title: 'The Grand Singularity',
      hint: 'The Campaign Climax: Crown the Violet Triangle at the center of the universe.',
      initialGrid: grid,
      targets: const [
        PuzzleTarget(pieceType: PieceType.violetTriangle, position: BoardPosition(2, 2)),
        PuzzleTarget(pieceType: PieceType.cyanCircle, position: BoardPosition(0, 2)),
        PuzzleTarget(pieceType: PieceType.roseSquare, position: BoardPosition(4, 2)),
        PuzzleTarget(pieceType: PieceType.amberDiamond, position: BoardPosition(2, 0)),
        PuzzleTarget(pieceType: PieceType.emeraldHexagon, position: BoardPosition(2, 4)),
      ],
      optimalMoves: 9,
      hasMemoryEcho: true,
    );
  }
}

