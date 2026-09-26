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

  // Visual styling
  final Paint _boardBgPaint = Paint()
    ..color = const Color(0xFF0F172A)
    ..style = PaintingStyle.fill;

  final Paint _boardBorderPaint = Paint()
    ..color = const Color(0xFF334155)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0;

  final Paint _cellBgPaint = Paint()
    ..color = const Color(0xFF1E293B)
    ..style = PaintingStyle.fill;

  final Paint _activeLinePaint = Paint()
    ..color = const Color(0xFF38BDF8).withValues(alpha: 0.12)
    ..style = PaintingStyle.fill;

  final Paint _activeEchoLinePaint = Paint()
    ..color = const Color(0xFFA855F7).withValues(alpha: 0.22)
    ..style = PaintingStyle.fill;

  final Paint _activeEchoLineBorderPaint = Paint()
    ..color = const Color(0xFFC084FC).withValues(alpha: 0.50)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;

  final Paint _echoPreviewBgPaint = Paint()
    ..color = const Color(0xFFA855F7).withValues(alpha: 0.10)
    ..style = PaintingStyle.fill;

  final Paint _echoPreviewBorderPaint = Paint()
    ..color = const Color(0xFFC084FC).withValues(alpha: 0.35)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;

  final Paint _echoPreviewChevronPaint = Paint()
    ..color = const Color(0xFFE9D5FF).withValues(alpha: 0.65)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.8
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
  Color backgroundColor() => const Color(0xFF090D16);

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
    _cellSpacing = (_boardSize * 0.015).clamp(4.0, 8.0);
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

    // 1. Board background container
    final boardRect = Rect.fromLTWH(
      _boardOrigin.dx,
      _boardOrigin.dy,
      _boardSize,
      _boardSize,
    );
    final boardRRect = RRect.fromRectAndRadius(boardRect, const Radius.circular(16));
    canvas.drawRRect(boardRRect, _boardBgPaint);
    canvas.drawRRect(boardRRect, _boardBorderPaint);

    // 2. Active line highlight during animation
    if (_isAnimating) {
      final activePaint = _isCurrentShiftEcho ? _activeEchoLinePaint : _activeLinePaint;
      if (_isRowShift) {
        final y = _boardOrigin.dy + _cellSpacing * (_animatingIndex + 1) + _cellSize * _animatingIndex;
        final lineRect = Rect.fromLTWH(_boardOrigin.dx + _cellSpacing, y, _boardSize - _cellSpacing * 2, _cellSize);
        final rrect = RRect.fromRectAndRadius(lineRect, const Radius.circular(10));
        canvas.drawRRect(rrect, activePaint);
        if (_isCurrentShiftEcho) {
          canvas.drawRRect(rrect, _activeEchoLineBorderPaint);
        }
      } else {
        final x = _boardOrigin.dx + _cellSpacing * (_animatingIndex + 1) + _cellSize * _animatingIndex;
        final lineRect = Rect.fromLTWH(x, _boardOrigin.dy + _cellSpacing, _cellSize, _boardSize - _cellSpacing * 2);
        final rrect = RRect.fromRectAndRadius(lineRect, const Radius.circular(10));
        canvas.drawRRect(rrect, activePaint);
        if (_isCurrentShiftEcho) {
          canvas.drawRRect(rrect, _activeEchoLineBorderPaint);
        }
      }
    }

    // 3. Grid cell tiles
    for (int r = 0; r < engine.rows; r++) {
      for (int c = 0; c < engine.cols; c++) {
        final cellRect = getCellRect(r, c);
        final cellRRect = RRect.fromRectAndRadius(cellRect, const Radius.circular(10));
        canvas.drawRRect(cellRRect, _cellBgPaint);
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
