import 'dart:math' as math;
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../../core/puzzle/logic/puzzle_engine.dart';
import '../../core/puzzle/logic/puzzle_solver.dart';
import '../../core/puzzle/models/shift_direction.dart';
import '../../core/puzzle/models/shift_record.dart';
import '../components/piece_renderer.dart';

class ShiftPuzzleGame extends FlameGame {
  PuzzleEngine engine;
  final VoidCallback onStateChanged;
  final VoidCallback onLevelSolved;
  final void Function(bool isEcho, bool justSeatedPiece)? onShiftComplete;

  // Animation state
  bool _isAnimating = false;
  bool get isAnimating => _isAnimating;

  bool _isRowShift = true;
  int _animatingIndex = 0;
  ShiftDirection _shiftDirection = ShiftDirection.right;
  double _animProgress = 0.0;
  static const double _animationDuration = 0.20; // 200 ms

  // Hint state
  PuzzleMove? _activeHint;
  PuzzleMove? get activeHint => _activeHint;
  double _hintPulseTimer = 0.0;

  // Memory Echo replay state
  bool _isEchoReplaying = false;
  bool get isEchoReplaying => _isEchoReplaying;
  bool _isCurrentShiftEcho = false;
  bool get isCurrentShiftEcho => _isCurrentShiftEcho;
  List<ShiftRecord> _pendingEchoShifts = [];
  double _echoPauseTimer = 0.0;
  static const double _echoStepPause = 0.12; // 120ms pause between Echo shifts
  VoidCallback? _onEchoComplete;

  // Board layout metrics
  double _boardSize = 0.0;
  double _cellSize = 0.0;
  double _cellSpacing = 6.0;
  Offset _boardOrigin = Offset.zero;

  // Visual styling: 3D Glowing Neon Cyber-Glass Theme (App Icon Match)
  final Paint _boardAuraPaint = Paint()
    ..color = const Color(0xFF0066FF).withValues(alpha: 0.35)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);

  final Paint _boardBgPaint = Paint()
    ..color = const Color(0xFF02071E)
    ..style = PaintingStyle.fill;

  final Paint _boardBorderPaint = Paint()
    ..color = const Color(0xFF1E60FF)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.5;

  final Paint _boardInnerRimPaint = Paint()
    ..color = const Color(0xFF00E5FF).withValues(alpha: 0.40)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;

  // 5x5 Individual Tile Paints (App Icon Glowing Sapphire Blue Style)
  final Paint _cellAuraPaint = Paint()
    ..color = const Color(0xFF0055FF).withValues(alpha: 0.32)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

  final Paint _cellBgPaint = Paint()
    ..color = const Color(0xFF0C2A78)
    ..style = PaintingStyle.fill;

  final Paint _cellRimPaint = Paint()
    ..color = const Color(0xFF2E75FF)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.8;

  final Paint _cellGlossPaint = Paint()
    ..color = const Color(0xFF80B3FF).withValues(alpha: 0.22)
    ..style = PaintingStyle.fill;

  // 3D Tile Extrusion and Bevel Paints
  final Paint _cellBaseShadowPaint = Paint()
    ..color = const Color(0xFF020718)
    ..style = PaintingStyle.fill;

  final Paint _cellSideWallPaint = Paint()
    ..color = const Color(0xFF06153E)
    ..style = PaintingStyle.fill;

  final Paint _cellTopBevelLightPaint = Paint()
    ..color = const Color(0xFF569CFF).withValues(alpha: 0.85)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.4;

  final Paint _cellBottomBevelDarkPaint = Paint()
    ..color = const Color(0xFF020718).withValues(alpha: 0.80)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.4;

  // Active Shifting Row/Col Tile Paints (Icon Electric Cyan Style)
  final Paint _activeCellAuraPaint = Paint()
    ..color = const Color(0xFF00E5FF).withValues(alpha: 0.45)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);

  final Paint _activeCellBgPaint = Paint()
    ..color = const Color(0xFF0091EA)
    ..style = PaintingStyle.fill;

  final Paint _activeCellRimPaint = Paint()
    ..color = const Color(0xFFE0F7FA)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0;

  final Paint _activeCellBaseShadowPaint = Paint()
    ..color = const Color(0xFF010A1E)
    ..style = PaintingStyle.fill;

  final Paint _activeCellSideWallPaint = Paint()
    ..color = const Color(0xFF005B94)
    ..style = PaintingStyle.fill;

  final Paint _activeCellTopBevelLightPaint = Paint()
    ..color = Colors.white.withValues(alpha: 0.90)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.6;

  // Shifting Laser Track Behind Row (Electric Cyan)
  final Paint _activeLineAuraPaint = Paint()
    ..color = const Color(0xFF00E5FF).withValues(alpha: 0.35)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

  final Paint _activeLinePaint = Paint()
    ..color = const Color(0xFF00E5FF).withValues(alpha: 0.25)
    ..style = PaintingStyle.fill;

  final Paint _activeLineBorderPaint = Paint()
    ..color = const Color(0xFF00E5FF).withValues(alpha: 0.95)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0;

  final Paint _activeLineStreakPaint = Paint()
    ..color = Colors.white.withValues(alpha: 0.50)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.8
    ..strokeCap = StrokeCap.round;

  final Paint _activeArrowPaint = Paint()
    ..color = const Color(0xFF00E5FF)
    ..style = PaintingStyle.fill;

  final Paint _activeArrowRimPaint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.8;

  // Active Laser Shift Lane (Echo)
  final Paint _activeEchoLineAuraPaint = Paint()
    ..color = const Color(0xFFC084FC).withValues(alpha: 0.35)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

  final Paint _activeEchoLinePaint = Paint()
    ..color = const Color(0xFFA855F7).withValues(alpha: 0.28)
    ..style = PaintingStyle.fill;

  final Paint _activeEchoLineBorderPaint = Paint()
    ..color = const Color(0xFFE9D5FF).withValues(alpha: 0.90)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.2;

  final Paint _echoPreviewBgPaint = Paint()
    ..color = const Color(0xFFA855F7).withValues(alpha: 0.12)
    ..style = PaintingStyle.fill;

  final Paint _echoPreviewBorderPaint = Paint()
    ..color = const Color(0xFFC084FC).withValues(alpha: 0.45)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.2;

  final Paint _echoPreviewChevronPaint = Paint()
    ..color = const Color(0xFFE9D5FF).withValues(alpha: 0.75)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  ShiftPuzzleGame({
    required this.engine,
    required this.onStateChanged,
    required this.onLevelSolved,
    this.onShiftComplete,
  });

  void updateEngine(PuzzleEngine newEngine) {
    engine = newEngine;
    _isAnimating = false;
    _animProgress = 0.0;
    _isEchoReplaying = false;
    _isCurrentShiftEcho = false;
    _pendingEchoShifts.clear();
    _onEchoComplete = null;
    _activeHint = null;
  }

  void setHint(PuzzleMove? move) {
    _activeHint = move;
    _hintPulseTimer = 0.0;
  }

  void clearHint() {
    _activeHint = null;
  }

  int _countSeatedPieces() {
    int count = 0;
    for (final target in engine.targets) {
      if (engine.pieceAt(target.position.row, target.position.col) == target.pieceType) {
        count++;
      }
    }
    return count;
  }

  @override
  Color backgroundColor() => const Color(0xFF040C3A);

  @override
  void update(double dt) {
    super.update(dt);
    _hintPulseTimer += dt;

    if (_isAnimating) {
      _animProgress += dt / _animationDuration;
      if (_animProgress >= 1.0) {
        _animProgress = 0.0;
        _isAnimating = false;

        final int seatedBefore = _countSeatedPieces();

        if (_isRowShift) {
          engine.shiftRow(_animatingIndex, _shiftDirection, isEcho: _isCurrentShiftEcho);
        } else {
          engine.shiftColumn(_animatingIndex, _shiftDirection, isEcho: _isCurrentShiftEcho);
        }

        final int seatedAfter = _countSeatedPieces();
        final bool justSeated = seatedAfter > seatedBefore;

        onShiftComplete?.call(_isCurrentShiftEcho, justSeated);
        onStateChanged();

        if (_isEchoReplaying) {
          _echoPauseTimer = _echoStepPause;
        } else {
          if (engine.isSolved) {
            onLevelSolved();
          }
        }
      }
    } else if (_isEchoReplaying) {
      if (_echoPauseTimer > 0) {
        _echoPauseTimer -= dt;
      } else {
        if (_pendingEchoShifts.isNotEmpty) {
          final next = _pendingEchoShifts.removeAt(0);
          _isCurrentShiftEcho = true;
          _isAnimating = true;
          _isRowShift = next.isRow;
          _animatingIndex = next.index;
          _shiftDirection = next.direction;
          _animProgress = 0.0;
        } else {
          // Completed all Echo shifts
          _isEchoReplaying = false;
          _isCurrentShiftEcho = false;
          engine.echo.markUsed();
          onStateChanged();
          _onEchoComplete?.call();
          _onEchoComplete = null;

          if (engine.isSolved) {
            onLevelSolved();
          }
        }
      }
    }
  }

  void _calculateMetrics() {
    final availableWidth = size.x;
    final availableHeight = size.y;
    final minDim = math.min(availableWidth, availableHeight);

    _boardSize = (minDim * 0.92).clamp(240.0, 480.0);
    _cellSpacing = (_boardSize * 0.022).clamp(6.0, 10.0);
    final totalSpacing = _cellSpacing * (engine.cols + 1);
    _cellSize = (_boardSize - totalSpacing) / engine.cols;

    _boardOrigin = Offset(
      (availableWidth - _boardSize) / 2,
      (availableHeight - _boardSize) / 2,
    );
  }

  Offset getCellCenter(int row, int col) {
    final x = _boardOrigin.dx +
        _cellSpacing * (col + 1) +
        _cellSize * col +
        _cellSize / 2;
    final y = _boardOrigin.dy +
        _cellSpacing * (row + 1) +
        _cellSize * row +
        _cellSize / 2;
    return Offset(x, y);
  }

  Rect getCellRect(int row, int col) {
    final x = _boardOrigin.dx + _cellSpacing * (col + 1) + _cellSize * col;
    final y = _boardOrigin.dy + _cellSpacing * (row + 1) + _cellSize * row;
    return Rect.fromLTWH(x, y, _cellSize, _cellSize);
  }

  int? getRowAt(Offset position) {
    if (position.dx < _boardOrigin.dx ||
        position.dx > _boardOrigin.dx + _boardSize ||
        position.dy < _boardOrigin.dy ||
        position.dy > _boardOrigin.dy + _boardSize) {
      return null;
    }
    final relativeY = position.dy - _boardOrigin.dy;
    final cellStep = _cellSize + _cellSpacing;
    final row = (relativeY / cellStep).floor().clamp(0, engine.rows - 1);
    return row;
  }

  int? getColAt(Offset position) {
    if (position.dx < _boardOrigin.dx ||
        position.dx > _boardOrigin.dx + _boardSize ||
        position.dy < _boardOrigin.dy ||
        position.dy > _boardOrigin.dy + _boardSize) {
      return null;
    }
    final relativeX = position.dx - _boardOrigin.dx;
    final cellStep = _cellSize + _cellSpacing;
    final col = (relativeX / cellStep).floor().clamp(0, engine.cols - 1);
    return col;
  }

  bool triggerShiftRow(int row, ShiftDirection direction) {
    if (_isAnimating || _isEchoReplaying || engine.isSolved) return false;
    if (row < 0 || row >= engine.rows) return false;
    if (!direction.isHorizontal) return false;

    _activeHint = null;
    _isCurrentShiftEcho = false;
    _isAnimating = true;
    _isRowShift = true;
    _animatingIndex = row;
    _shiftDirection = direction;
    _animProgress = 0.0;
    return true;
  }

  bool triggerShiftColumn(int col, ShiftDirection direction) {
    if (_isAnimating || _isEchoReplaying || engine.isSolved) return false;
    if (col < 0 || col >= engine.cols) return false;
    if (!direction.isVertical) return false;

    _activeHint = null;
    _isCurrentShiftEcho = false;
    _isAnimating = true;
    _isRowShift = false;
    _animatingIndex = col;
    _shiftDirection = direction;
    _animProgress = 0.0;
    return true;
  }

  /// Triggers a ghost replay of the recorded Memory Echo shift sequence.
  bool triggerEchoReplay(VoidCallback onComplete) {
    if (_isAnimating || _isEchoReplaying || engine.isSolved) return false;
    if (!engine.echo.canReplay) return false;

    _activeHint = null;
    _isEchoReplaying = true;
    engine.clearHistory();
    _pendingEchoShifts = List<ShiftRecord>.from(engine.echo.records);
    _onEchoComplete = onComplete;
    engine.echo.markReplaying();
    onStateChanged();

    // Trigger the first shift
    final firstShift = _pendingEchoShifts.removeAt(0);
    _isCurrentShiftEcho = true;
    _isAnimating = true;
    _isRowShift = firstShift.isRow;
    _animatingIndex = firstShift.index;
    _shiftDirection = firstShift.direction;
    _animProgress = 0.0;
    return true;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    _calculateMetrics();

    // 1. Board background container with radiant neon squircle aura
    final boardRect = Rect.fromLTWH(
      _boardOrigin.dx,
      _boardOrigin.dy,
      _boardSize,
      _boardSize,
    );
    final boardRRect = RRect.fromRectAndRadius(boardRect, const Radius.circular(22));
    canvas.drawRRect(boardRRect, _boardAuraPaint);
    canvas.drawRRect(boardRRect, _boardBgPaint);
    canvas.drawRRect(boardRRect, _boardBorderPaint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(boardRect.deflate(2.0), const Radius.circular(20)),
      _boardInnerRimPaint,
    );

    final double cellRadius = _cellSize * 0.24;

    // 2. Active laser shift beam & directional arrow during animation (drawn behind tiles)
    if (_isAnimating) {
      final auraPaint = _isCurrentShiftEcho ? _activeEchoLineAuraPaint : _activeLineAuraPaint;
      final activePaint = _isCurrentShiftEcho ? _activeEchoLinePaint : _activeLinePaint;
      final borderPaint = _isCurrentShiftEcho ? _activeEchoLineBorderPaint : _activeLineBorderPaint;

      if (_isRowShift) {
        final y = _boardOrigin.dy + _cellSpacing * (_animatingIndex + 1) + _cellSize * _animatingIndex;
        final lineRect = Rect.fromLTWH(
          _boardOrigin.dx + _cellSpacing / 2,
          y - 2,
          _boardSize - _cellSpacing,
          _cellSize + 4,
        );
        final rrect = RRect.fromRectAndRadius(lineRect, Radius.circular(cellRadius + 2));
        canvas.drawRRect(rrect, auraPaint);
        canvas.drawRRect(rrect, activePaint);
        canvas.drawRRect(rrect, borderPaint);

        // Kinetic laser center streak
        final midY = y + _cellSize / 2;
        canvas.drawLine(
          Offset(_boardOrigin.dx + _cellSpacing, midY),
          Offset(_boardOrigin.dx + _boardSize - _cellSpacing, midY),
          _activeLineStreakPaint,
        );

        // Directional 3D arrow on the leading edge (matching app icon)
        final isRight = _shiftDirection == ShiftDirection.right;
        final arrowTipX = isRight
            ? _boardOrigin.dx + _boardSize - _cellSpacing + 10
            : _boardOrigin.dx + _cellSpacing - 10;
        final arrowBaseX = isRight ? arrowTipX - 16 : arrowTipX + 16;
        final arrowPath = Path()
          ..moveTo(arrowTipX, midY)
          ..lineTo(arrowBaseX, midY - 12)
          ..lineTo(arrowBaseX + (isRight ? 5 : -5), midY)
          ..lineTo(arrowBaseX, midY + 12)
          ..close();
        canvas.drawPath(arrowPath, _activeArrowPaint);
        canvas.drawPath(arrowPath, _activeArrowRimPaint);
      } else {
        final x = _boardOrigin.dx + _cellSpacing * (_animatingIndex + 1) + _cellSize * _animatingIndex;
        final lineRect = Rect.fromLTWH(
          x - 2,
          _boardOrigin.dy + _cellSpacing / 2,
          _cellSize + 4,
          _boardSize - _cellSpacing,
        );
        final rrect = RRect.fromRectAndRadius(lineRect, Radius.circular(cellRadius + 2));
        canvas.drawRRect(rrect, auraPaint);
        canvas.drawRRect(rrect, activePaint);
        canvas.drawRRect(rrect, borderPaint);

        // Kinetic laser center streak
        final midX = x + _cellSize / 2;
        canvas.drawLine(
          Offset(midX, _boardOrigin.dy + _cellSpacing),
          Offset(midX, _boardOrigin.dy + _boardSize - _cellSpacing),
          _activeLineStreakPaint,
        );

        // Directional 3D arrow on the leading edge (matching app icon)
        final isDown = _shiftDirection == ShiftDirection.down;
        final arrowTipY = isDown
            ? _boardOrigin.dy + _boardSize - _cellSpacing + 10
            : _boardOrigin.dy + _cellSpacing - 10;
        final arrowBaseY = isDown ? arrowTipY - 16 : arrowTipY + 16;
        final arrowPath = Path()
          ..moveTo(midX, arrowTipY)
          ..lineTo(midX - 12, arrowBaseY)
          ..lineTo(midX, arrowBaseY + (isDown ? 5 : -5))
          ..lineTo(midX + 12, arrowBaseY)
          ..close();
        canvas.drawPath(arrowPath, _activeArrowPaint);
        canvas.drawPath(arrowPath, _activeArrowRimPaint);
      }
    }

    // 3. Grid cell tiles: Tactile 3D Luminous Sapphire Blue Pads (App Icon 3D Style)
    for (int r = 0; r < engine.rows; r++) {
      for (int c = 0; c < engine.cols; c++) {
        final cellRect = getCellRect(r, c);
        final bool isMoving = _isAnimating &&
            ((_isRowShift && r == _animatingIndex) || (!_isRowShift && c == _animatingIndex));

        final double depth = isMoving ? 5.5 : 4.0;
        final double lift = isMoving ? 1.5 : 0.8;

        if (isMoving) {
          // 3D Shifting Line Pad: Elevated electric cyan button
          // A. Soft base neon glow
          final auraRect = cellRect.inflate(3.5);
          canvas.drawRRect(
            RRect.fromRectAndRadius(auraRect, Radius.circular(cellRadius + 3)),
            _activeCellAuraPaint,
          );

          // B. Deep 3D drop shadow & extruded side skirt
          final shadowRect = Rect.fromLTWH(cellRect.left, cellRect.top + depth, cellRect.width, cellRect.height);
          canvas.drawRRect(
            RRect.fromRectAndRadius(shadowRect, Radius.circular(cellRadius)),
            _activeCellBaseShadowPaint,
          );

          final skirtRect = Rect.fromLTWH(cellRect.left, cellRect.top + depth * 0.4, cellRect.width, cellRect.height * 0.6);
          canvas.drawRRect(
            RRect.fromRectAndRadius(skirtRect, Radius.circular(cellRadius)),
            _activeCellSideWallPaint,
          );

          // C. Elevated Top Face
          final topFaceRect = Rect.fromLTWH(cellRect.left, cellRect.top - lift, cellRect.width, cellRect.height);
          final topFaceRRect = RRect.fromRectAndRadius(topFaceRect, Radius.circular(cellRadius));
          canvas.drawRRect(topFaceRRect, _activeCellBgPaint);
          canvas.drawRRect(topFaceRRect, _activeCellRimPaint);

          // D. Top specular highlight bevel
          final bevelPath = Path()
            ..moveTo(topFaceRect.left + cellRadius * 0.5, topFaceRect.top + 1.0)
            ..lineTo(topFaceRect.right - cellRadius * 0.5, topFaceRect.top + 1.0)
            ..moveTo(topFaceRect.left + 1.0, topFaceRect.top + cellRadius * 0.5)
            ..lineTo(topFaceRect.left + 1.0, topFaceRect.bottom - cellRadius * 0.5);
          canvas.drawPath(bevelPath, _activeCellTopBevelLightPaint);
        } else {
          // Standard 3D Sapphire Blue Pad
          // A. Soft floor neon aura
          final auraRect = cellRect.inflate(2.5);
          canvas.drawRRect(
            RRect.fromRectAndRadius(auraRect, Radius.circular(cellRadius + 2)),
            _cellAuraPaint,
          );

          // B. 3D Drop shadow and extruded lower base riser
          final shadowRect = Rect.fromLTWH(cellRect.left, cellRect.top + depth, cellRect.width, cellRect.height);
          canvas.drawRRect(
            RRect.fromRectAndRadius(shadowRect, Radius.circular(cellRadius)),
            _cellBaseShadowPaint,
          );

          final skirtRect = Rect.fromLTWH(cellRect.left, cellRect.top + depth * 0.4, cellRect.width, cellRect.height * 0.6);
          canvas.drawRRect(
            RRect.fromRectAndRadius(skirtRect, Radius.circular(cellRadius)),
            _cellSideWallPaint,
          );

          // C. Raised Top Face
          final topFaceRect = Rect.fromLTWH(cellRect.left, cellRect.top - lift, cellRect.width, cellRect.height);
          final topFaceRRect = RRect.fromRectAndRadius(topFaceRect, Radius.circular(cellRadius));
          canvas.drawRRect(topFaceRRect, _cellBgPaint);
          canvas.drawRRect(topFaceRRect, _cellRimPaint);

          // D. Crisp 3D Bevels (Top/Left light, Bottom/Right shadow)
          final topBevelPath = Path()
            ..moveTo(topFaceRect.left + cellRadius * 0.5, topFaceRect.top + 1.0)
            ..lineTo(topFaceRect.right - cellRadius * 0.5, topFaceRect.top + 1.0)
            ..moveTo(topFaceRect.left + 1.0, topFaceRect.top + cellRadius * 0.5)
            ..lineTo(topFaceRect.left + 1.0, topFaceRect.bottom - cellRadius * 0.5);
          canvas.drawPath(topBevelPath, _cellTopBevelLightPaint);

          final bottomBevelPath = Path()
            ..moveTo(topFaceRect.left + cellRadius * 0.5, topFaceRect.bottom - 1.0)
            ..lineTo(topFaceRect.right - cellRadius * 0.5, topFaceRect.bottom - 1.0)
            ..moveTo(topFaceRect.right - 1.0, topFaceRect.top + cellRadius * 0.5)
            ..lineTo(topFaceRect.right - 1.0, topFaceRect.bottom - cellRadius * 0.5);
          canvas.drawPath(bottomBevelPath, _cellBottomBevelDarkPaint);

          // E. Glossy Top Specular Sheen
          final glossRect = Rect.fromLTWH(
            topFaceRect.left + 2.5,
            topFaceRect.top + 2.5,
            topFaceRect.width - 5,
            topFaceRect.height * 0.36,
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(glossRect, Radius.circular(cellRadius * 0.7)),
            _cellGlossPaint,
          );
        }
      }
    }

    // 3.5 Subtle Memory Echo queued trajectory preview
    if (!_isAnimating && engine.echo.canReplay) {
      _drawEchoPreview(canvas);
    }

    // 3.6 Playful animated Hint preview
    if (!_isAnimating && _activeHint != null) {
      _drawHintHighlight(canvas);
    }

    // 4. Target indicators
    for (final target in engine.targets) {
      final center = getCellCenter(target.position.row, target.position.col);
      PieceRenderer.drawTarget(
        canvas: canvas,
        type: target.pieceType,
        center: center,
        size: _cellSize,
      );
    }

    // 5. Pieces rendering (static vs animating line)
    final cellStep = _cellSize + _cellSpacing;

    if (!_isAnimating) {
      for (int r = 0; r < engine.rows; r++) {
        for (int c = 0; c < engine.cols; c++) {
          final piece = engine.pieceAt(r, c);
          if (piece != null) {
            final center = getCellCenter(r, c);
            final target = engine.getTargetAt(r, c);
            final isSeated = target != null && target.pieceType == piece;
            PieceRenderer.drawPiece(
              canvas: canvas,
              type: piece,
              center: center,
              size: _cellSize,
              isSeatedOnTarget: isSeated,
            );
          }
        }
      }
    } else {
      // Draw unaffected cells
      for (int r = 0; r < engine.rows; r++) {
        for (int c = 0; c < engine.cols; c++) {
          if (_isRowShift && r == _animatingIndex) continue;
          if (!_isRowShift && c == _animatingIndex) continue;

          final piece = engine.pieceAt(r, c);
          if (piece != null) {
            final center = getCellCenter(r, c);
            final target = engine.getTargetAt(r, c);
            final isSeated = target != null && target.pieceType == piece;
            PieceRenderer.drawPiece(
              canvas: canvas,
              type: piece,
              center: center,
              size: _cellSize,
              isSeatedOnTarget: isSeated,
            );
          }
        }
      }

      // Draw moving line with toroidal wrap-around clipping
      canvas.save();
      if (_isRowShift) {
        final rowY = _boardOrigin.dy + _cellSpacing * (_animatingIndex + 1) + _cellSize * _animatingIndex;
        final clipRect = Rect.fromLTWH(
          _boardOrigin.dx + _cellSpacing / 2,
          rowY,
          _boardSize - _cellSpacing,
          _cellSize,
        );
        canvas.clipRRect(RRect.fromRectAndRadius(clipRect, const Radius.circular(8)));

        final shiftSign = _shiftDirection == ShiftDirection.right ? 1.0 : -1.0;
        final deltaX = shiftSign * _animProgress * cellStep;
        final totalLength = engine.cols * cellStep;

        for (int c = 0; c < engine.cols; c++) {
          final piece = engine.pieceAt(_animatingIndex, c);
          if (piece != null) {
            final baseCenter = getCellCenter(_animatingIndex, c);
            final animatedCenter = Offset(baseCenter.dx + deltaX, baseCenter.dy);

            // Draw primary position
            PieceRenderer.drawPiece(
              canvas: canvas,
              type: piece,
              center: animatedCenter,
              size: _cellSize,
              isEchoGhost: _isCurrentShiftEcho,
            );

            // Draw wrap-around clone
            Offset wrappedCenter;
            if (_shiftDirection == ShiftDirection.right) {
              wrappedCenter = Offset(animatedCenter.dx - totalLength, animatedCenter.dy);
            } else {
              wrappedCenter = Offset(animatedCenter.dx + totalLength, animatedCenter.dy);
            }
            PieceRenderer.drawPiece(
              canvas: canvas,
              type: piece,
              center: wrappedCenter,
              size: _cellSize,
              isEchoGhost: _isCurrentShiftEcho,
            );
          }
        }
      } else {
        final colX = _boardOrigin.dx + _cellSpacing * (_animatingIndex + 1) + _cellSize * _animatingIndex;
        final clipRect = Rect.fromLTWH(
          colX,
          _boardOrigin.dy + _cellSpacing / 2,
          _cellSize,
          _boardSize - _cellSpacing,
        );
        canvas.clipRRect(RRect.fromRectAndRadius(clipRect, const Radius.circular(8)));

        final shiftSign = _shiftDirection == ShiftDirection.down ? 1.0 : -1.0;
        final deltaY = shiftSign * _animProgress * cellStep;
        final totalLength = engine.rows * cellStep;

        for (int r = 0; r < engine.rows; r++) {
          final piece = engine.pieceAt(r, _animatingIndex);
          if (piece != null) {
            final baseCenter = getCellCenter(r, _animatingIndex);
            final animatedCenter = Offset(baseCenter.dx, baseCenter.dy + deltaY);

            // Draw primary position
            PieceRenderer.drawPiece(
              canvas: canvas,
              type: piece,
              center: animatedCenter,
              size: _cellSize,
              isEchoGhost: _isCurrentShiftEcho,
            );

            // Draw wrap-around clone
            Offset wrappedCenter;
            if (_shiftDirection == ShiftDirection.down) {
              wrappedCenter = Offset(animatedCenter.dx, animatedCenter.dy - totalLength);
            } else {
              wrappedCenter = Offset(animatedCenter.dx, animatedCenter.dy + totalLength);
            }
            PieceRenderer.drawPiece(
              canvas: canvas,
              type: piece,
              center: wrappedCenter,
              size: _cellSize,
              isEchoGhost: _isCurrentShiftEcho,
            );
          }
        }
      }
      canvas.restore();
    }
  }

  void _drawEchoPreview(Canvas canvas) {
    final processedRows = <int, ShiftDirection>{};
    final processedCols = <int, ShiftDirection>{};

    for (final record in engine.echo.records) {
      if (record.isRow) {
        processedRows.putIfAbsent(record.index, () => record.direction);
      } else {
        processedCols.putIfAbsent(record.index, () => record.direction);
      }
    }

    for (final entry in processedRows.entries) {
      final r = entry.key;
      final dir = entry.value;
      final y = _boardOrigin.dy + _cellSpacing * (r + 1) + _cellSize * r;
      final lineRect = Rect.fromLTWH(_boardOrigin.dx + _cellSpacing, y, _boardSize - _cellSpacing * 2, _cellSize);
      final rrect = RRect.fromRectAndRadius(lineRect, const Radius.circular(10));
      canvas.drawRRect(rrect, _echoPreviewBgPaint);
      canvas.drawRRect(rrect, _echoPreviewBorderPaint);

      final yCenter = y + _cellSize / 2;
      for (int c = 1; c < engine.cols; c++) {
        final x = _boardOrigin.dx + _cellSpacing * c + _cellSize * c - _cellSpacing / 2;
        final path = Path();
        if (dir == ShiftDirection.right) {
          path.moveTo(x - 3.5, yCenter - 6.0);
          path.lineTo(x + 3.0, yCenter);
          path.lineTo(x - 3.5, yCenter + 6.0);
        } else {
          path.moveTo(x + 3.5, yCenter - 6.0);
          path.lineTo(x - 3.0, yCenter);
          path.lineTo(x + 3.5, yCenter + 6.0);
        }
        canvas.drawPath(path, _echoPreviewChevronPaint);
      }
    }

    for (final entry in processedCols.entries) {
      final c = entry.key;
      final dir = entry.value;
      final x = _boardOrigin.dx + _cellSpacing * (c + 1) + _cellSize * c;
      final lineRect = Rect.fromLTWH(x, _boardOrigin.dy + _cellSpacing, _cellSize, _boardSize - _cellSpacing * 2);
      final rrect = RRect.fromRectAndRadius(lineRect, const Radius.circular(10));
      canvas.drawRRect(rrect, _echoPreviewBgPaint);
      canvas.drawRRect(rrect, _echoPreviewBorderPaint);

      final xCenter = x + _cellSize / 2;
      for (int r = 1; r < engine.rows; r++) {
        final y = _boardOrigin.dy + _cellSpacing * r + _cellSize * r - _cellSpacing / 2;
        final path = Path();
        if (dir == ShiftDirection.down) {
          path.moveTo(xCenter - 6.0, y - 3.5);
          path.lineTo(xCenter, y + 3.0);
          path.lineTo(xCenter + 6.0, y - 3.5);
        } else {
          path.moveTo(xCenter - 6.0, y + 3.5);
          path.lineTo(xCenter, y - 3.0);
          path.lineTo(xCenter + 6.0, y + 3.5);
        }
        canvas.drawPath(path, _echoPreviewChevronPaint);
      }
    }
  }

  void _drawHintHighlight(Canvas canvas) {
    if (_activeHint == null || _isAnimating) return;

    final pulse = 0.5 + 0.5 * math.sin(_hintPulseTimer * 4.5);
    final alphaBg = 0.14 + 0.12 * pulse;
    final alphaBorder = 0.55 + 0.40 * pulse;

    final hintBgPaint = Paint()
      ..color = const Color(0xFFFBBF24).withValues(alpha: alphaBg)
      ..style = PaintingStyle.fill;

    final hintBorderPaint = Paint()
      ..color = const Color(0xFFFBBF24).withValues(alpha: alphaBorder)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final hintChevronPaint = Paint()
      ..color = const Color(0xFFFEF3C7).withValues(alpha: alphaBorder)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (_activeHint!.isRow) {
      final r = _activeHint!.index;
      final y = _boardOrigin.dy + _cellSpacing * (r + 1) + _cellSize * r;
      final lineRect = Rect.fromLTWH(
        _boardOrigin.dx + _cellSpacing,
        y,
        _boardSize - _cellSpacing * 2,
        _cellSize,
      );
      final rrect = RRect.fromRectAndRadius(lineRect, const Radius.circular(10));
      canvas.drawRRect(rrect, hintBgPaint);
      canvas.drawRRect(rrect, hintBorderPaint);

      final yCenter = y + _cellSize / 2;
      final dir = _activeHint!.direction;
      for (int c = 1; c < engine.cols; c++) {
        final x = _boardOrigin.dx + _cellSpacing * c + _cellSize * c - _cellSpacing / 2;
        final path = Path();
        if (dir == ShiftDirection.right) {
          path.moveTo(x - 4.0, yCenter - 7.0);
          path.lineTo(x + 4.0, yCenter);
          path.lineTo(x - 4.0, yCenter + 7.0);
        } else {
          path.moveTo(x + 4.0, yCenter - 7.0);
          path.lineTo(x - 4.0, yCenter);
          path.lineTo(x + 4.0, yCenter + 7.0);
        }
        canvas.drawPath(path, hintChevronPaint);
      }
    } else {
      final c = _activeHint!.index;
      final x = _boardOrigin.dx + _cellSpacing * (c + 1) + _cellSize * c;
      final lineRect = Rect.fromLTWH(
        x,
        _boardOrigin.dy + _cellSpacing,
        _cellSize,
        _boardSize - _cellSpacing * 2,
      );
      final rrect = RRect.fromRectAndRadius(lineRect, const Radius.circular(10));
      canvas.drawRRect(rrect, hintBgPaint);
      canvas.drawRRect(rrect, hintBorderPaint);

      final xCenter = x + _cellSize / 2;
      final dir = _activeHint!.direction;
      for (int r = 1; r < engine.rows; r++) {
        final y = _boardOrigin.dy + _cellSpacing * r + _cellSize * r - _cellSpacing / 2;
        final path = Path();
        if (dir == ShiftDirection.down) {
          path.moveTo(xCenter - 7.0, y - 4.0);
          path.lineTo(xCenter, y + 4.0);
          path.lineTo(xCenter + 7.0, y - 4.0);
        } else {
          path.moveTo(xCenter - 7.0, y + 4.0);
          path.lineTo(xCenter, y - 4.0);
          path.lineTo(xCenter + 7.0, y + 4.0);
        }
        canvas.drawPath(path, hintChevronPaint);
      }
    }
  }
}
