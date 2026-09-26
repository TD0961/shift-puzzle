import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/puzzle/models/piece_type.dart';

class PieceRenderer {
  static const Color cyanColor = Color(0xFF00E5FF);
  static const Color amberColor = Color(0xFFFFC107);
  static const Color roseColor = Color(0xFFFF1744);
  static const Color emeraldColor = Color(0xFF00E676);
  static const Color violetColor = Color(0xFFD500F9);

  static Color getColor(PieceType type) {
    switch (type) {
      case PieceType.cyanCircle:
        return cyanColor;
      case PieceType.amberDiamond:
        return amberColor;
      case PieceType.roseSquare:
        return roseColor;
      case PieceType.emeraldHexagon:
        return emeraldColor;
      case PieceType.violetTriangle:
        return violetColor;
    }
  }

  static void drawPiece({
    required Canvas canvas,
    required PieceType type,
    required Offset center,
    required double size,
    bool isSeatedOnTarget = false,
    bool isEchoGhost = false,
  }) {
    final color = getColor(type);
    final radius = size * 0.38;

    // Optional ethereal Echo ghost aura
    if (isEchoGhost) {
      final ghostAura = Paint()
        ..color = const Color(0xFFC084FC).withValues(alpha: 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
      canvas.drawCircle(center, radius + 8, ghostAura);
    }

    // Enhanced seated halo glow & confirmation aura
    if (isSeatedOnTarget) {
      final haloPaint = Paint()
        ..color = color.withValues(alpha: 0.50)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
      canvas.drawCircle(center, radius + 8, haloPaint);

      final ringPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.65)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawCircle(center, radius + 4, ringPaint);
    }

    final fillPaint = Paint()
      ..color = isEchoGhost ? color.withValues(alpha: 0.78) : color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = isEchoGhost
          ? const Color(0xFFE9D5FF).withValues(alpha: 0.95)
          : Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isEchoGhost ? 2.5 : 2.0;

    final innerGlowPaint = Paint()
      ..color = Colors.white.withValues(alpha: isEchoGhost ? 0.45 : 0.3)
      ..style = PaintingStyle.fill;

    switch (type) {
      case PieceType.cyanCircle:
        canvas.drawCircle(center, radius, fillPaint);
        canvas.drawCircle(center, radius, borderPaint);
        canvas.drawCircle(center - Offset(radius * 0.25, radius * 0.25), radius * 0.3, innerGlowPaint);
        break;

      case PieceType.amberDiamond:
        final path = Path()
          ..moveTo(center.dx, center.dy - radius * 1.1)
          ..lineTo(center.dx + radius * 0.9, center.dy)
          ..lineTo(center.dx, center.dy + radius * 1.1)
          ..lineTo(center.dx - radius * 0.9, center.dy)
          ..close();
        canvas.drawPath(path, fillPaint);
        canvas.drawPath(path, borderPaint);
        break;

      case PieceType.roseSquare:
        final rect = Rect.fromCenter(center: center, width: radius * 1.7, height: radius * 1.7);
        final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius * 0.3));
        canvas.drawRRect(rrect, fillPaint);
        canvas.drawRRect(rrect, borderPaint);
        break;

      case PieceType.emeraldHexagon:
        final path = Path();
        for (int i = 0; i < 6; i++) {
          final angle = (i * 60 - 30) * math.pi / 180;
          final x = center.dx + radius * 1.05 * math.cos(angle);
          final y = center.dy + radius * 1.05 * math.sin(angle);
          if (i == 0) {
            path.moveTo(x, y);
          } else {
            path.lineTo(x, y);
          }
        }
        path.close();
        canvas.drawPath(path, fillPaint);
        canvas.drawPath(path, borderPaint);
        break;

      case PieceType.violetTriangle:
        final path = Path()
          ..moveTo(center.dx, center.dy - radius * 1.05)
          ..lineTo(center.dx + radius * 1.0, center.dy + radius * 0.8)
          ..lineTo(center.dx - radius * 1.0, center.dy + radius * 0.8)
          ..close();
        canvas.drawPath(path, fillPaint);
        canvas.drawPath(path, borderPaint);
        break;
    }

    if (isSeatedOnTarget) {
      final gleamPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.65)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, 3.2, gleamPaint);
    }
  }

  static void drawTarget({
    required Canvas canvas,
    required PieceType type,
    required Offset center,
    required double size,
  }) {
    final color = getColor(type);
    final radius = size * 0.38;

    final targetPaint = Paint()
      ..color = color.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final targetFillPaint = Paint()
      ..color = color.withValues(alpha: 0.10)
      ..style = PaintingStyle.fill;

    final dotPaint = Paint()
      ..color = color.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    // Center indicator dot
    canvas.drawCircle(center, 3.0, dotPaint);

    switch (type) {
      case PieceType.cyanCircle:
        canvas.drawCircle(center, radius, targetFillPaint);
        canvas.drawCircle(center, radius, targetPaint);
        break;

      case PieceType.amberDiamond:
        final path = Path()
          ..moveTo(center.dx, center.dy - radius * 1.1)
          ..lineTo(center.dx + radius * 0.9, center.dy)
          ..lineTo(center.dx, center.dy + radius * 1.1)
          ..lineTo(center.dx - radius * 0.9, center.dy)
          ..close();
        canvas.drawPath(path, targetFillPaint);
        canvas.drawPath(path, targetPaint);
        break;

      case PieceType.roseSquare:
        final rect = Rect.fromCenter(center: center, width: radius * 1.7, height: radius * 1.7);
        final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius * 0.3));
        canvas.drawRRect(rrect, targetFillPaint);
        canvas.drawRRect(rrect, targetPaint);
        break;

      case PieceType.emeraldHexagon:
        final path = Path();
        for (int i = 0; i < 6; i++) {
          final angle = (i * 60 - 30) * math.pi / 180;
          final x = center.dx + radius * 1.05 * math.cos(angle);
          final y = center.dy + radius * 1.05 * math.sin(angle);
          if (i == 0) {
            path.moveTo(x, y);
          } else {
            path.lineTo(x, y);
          }
        }
        path.close();
        canvas.drawPath(path, targetFillPaint);
        canvas.drawPath(path, targetPaint);
        break;

      case PieceType.violetTriangle:
        final path = Path()
          ..moveTo(center.dx, center.dy - radius * 1.05)
          ..lineTo(center.dx + radius * 1.0, center.dy + radius * 0.8)
          ..lineTo(center.dx - radius * 1.0, center.dy + radius * 0.8)
          ..close();
        canvas.drawPath(path, targetFillPaint);
        canvas.drawPath(path, targetPaint);
        break;
    }
  }
}
