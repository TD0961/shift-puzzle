import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/puzzle/models/piece_type.dart';

/// Renders game pieces and target indicators with a 3D glowing neon glassmorphic aesthetic.
/// Matches the high-impact visual identity of the app icon:
/// - Luminous outer neon bloom aura
/// - Specular glass highlights and 3D bevels
/// - Resonant locked-in confirmation rings for seated pieces
/// - Crisp, high-contrast silhouette readable at any zoom level
class PieceRenderer {
  static const Color cyanColor = Color(0xFF00E5FF);
  static const Color amberColor = Color(0xFFFFD740);
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

    // 1. Ambient Neon Bloom Aura
    if (!isEchoGhost) {
      final neonAura = Paint()
        ..color = color.withValues(alpha: isSeatedOnTarget ? 0.48 : 0.28)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.45);
      canvas.drawCircle(center, radius + 4, neonAura);
    } else {
      // Memory Echo ghost aura (ethereal neon purple)
      final ghostAura = Paint()
        ..color = const Color(0xFFC084FC).withValues(alpha: 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
      canvas.drawCircle(center, radius + 8, ghostAura);
    }

    // 2. Seated confirmation resonant ring
    if (isSeatedOnTarget) {
      final ringPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawCircle(center, radius + 5, ringPaint);

      final outerWave = Paint()
        ..color = color.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      canvas.drawCircle(center, radius + 9, outerWave);
    }

    // 3. Piece Body Paint
    final fillPaint = Paint()
      ..color = isEchoGhost ? color.withValues(alpha: 0.78) : color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = isEchoGhost
          ? const Color(0xFFE9D5FF).withValues(alpha: 0.95)
          : Colors.white.withValues(alpha: 0.90)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isEchoGhost ? 2.5 : 2.2;

    // 4. Draw Specific Shape Geometry with 3D Depth
    switch (type) {
      case PieceType.cyanCircle:
        // Base Circle
        canvas.drawCircle(center, radius, fillPaint);
        canvas.drawCircle(center, radius, borderPaint);

        // Inner glowing core ring (iconic swirl hero motif)
        final innerRingPaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.40)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8;
        canvas.drawCircle(center, radius * 0.55, innerRingPaint);

        // Specular 3D highlight (top-left gleam)
        final gleamPaint = Paint()
          ..color = Colors.white.withValues(alpha: isEchoGhost ? 0.45 : 0.65)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(
          center - Offset(radius * 0.32, radius * 0.32),
          radius * 0.28,
          gleamPaint,
        );
        break;

      case PieceType.amberDiamond:
        final path = Path()
          ..moveTo(center.dx, center.dy - radius * 1.15)
          ..lineTo(center.dx + radius * 0.95, center.dy)
          ..lineTo(center.dx, center.dy + radius * 1.15)
          ..lineTo(center.dx - radius * 0.95, center.dy)
          ..close();
        canvas.drawPath(path, fillPaint);
        canvas.drawPath(path, borderPaint);

        // Facet reflection line
        final facetPaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;
        canvas.drawLine(
          Offset(center.dx - radius * 0.95, center.dy),
          Offset(center.dx + radius * 0.95, center.dy),
          facetPaint,
        );

        // Top apex gleam
        final gleamPath = Path()
          ..moveTo(center.dx, center.dy - radius * 1.15)
          ..lineTo(center.dx + radius * 0.40, center.dy - radius * 0.45)
          ..lineTo(center.dx - radius * 0.40, center.dy - radius * 0.45)
          ..close();
        final topGleam = Paint()
          ..color = Colors.white.withValues(alpha: 0.45)
          ..style = PaintingStyle.fill;
        canvas.drawPath(gleamPath, topGleam);
        break;

      case PieceType.roseSquare:
        final rect = Rect.fromCenter(
          center: center,
          width: radius * 1.7,
          height: radius * 1.7,
        );
        final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius * 0.32));
        canvas.drawRRect(rrect, fillPaint);
        canvas.drawRRect(rrect, borderPaint);

        // Top bevel specular line
        final bevelPaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.40)
          ..style = PaintingStyle.fill;
        final innerRect = Rect.fromLTWH(
          rect.left + 3,
          rect.top + 3,
          rect.width - 6,
          rect.height * 0.35,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(innerRect, Radius.circular(radius * 0.20)),
          bevelPaint,
        );
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

        // Inner geometric core
        final innerPath = Path();
        for (int i = 0; i < 6; i++) {
          final angle = (i * 60 - 30) * math.pi / 180;
          final x = center.dx + radius * 0.52 * math.cos(angle);
          final y = center.dy + radius * 0.52 * math.sin(angle);
          if (i == 0) {
            innerPath.moveTo(x, y);
          } else {
            innerPath.lineTo(x, y);
          }
        }
        innerPath.close();
        final innerHexPaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.38)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4;
        canvas.drawPath(innerPath, innerHexPaint);
        break;

      case PieceType.violetTriangle:
        final path = Path()
          ..moveTo(center.dx, center.dy - radius * 1.1)
          ..lineTo(center.dx + radius * 1.02, center.dy + radius * 0.82)
          ..lineTo(center.dx - radius * 1.02, center.dy + radius * 0.82)
          ..close();
        canvas.drawPath(path, fillPaint);
        canvas.drawPath(path, borderPaint);

        // Prism facet lines
        final prismPaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.40)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;
        canvas.drawLine(
          Offset(center.dx, center.dy - radius * 1.1),
          Offset(center.dx, center.dy + radius * 0.25),
          prismPaint,
        );
        break;
    }

    // 5. Center specular flare when locked on target
    if (isSeatedOnTarget) {
      final gleamPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, 3.8, gleamPaint);
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

    // 1. Intense outer neon beacon aura
    final beaconAura = Paint()
      ..color = color.withValues(alpha: 0.40)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.45);
    canvas.drawCircle(center, radius + 3, beaconAura);

    // 2. High-visibility solid neon glowing bed
    final targetFillPaint = Paint()
      ..color = color.withValues(alpha: 0.28)
      ..style = PaintingStyle.fill;

    // 3. Crisp vibrant perimeter border
    final targetBorderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8;

    // 4. Inner resonant geometric glyph
    final innerGlyphPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    switch (type) {
      case PieceType.cyanCircle:
        canvas.drawCircle(center, radius, targetFillPaint);
        canvas.drawCircle(center, radius, targetBorderPaint);
        canvas.drawCircle(center, radius * 0.52, innerGlyphPaint);
        break;

      case PieceType.amberDiamond:
        final path = Path()
          ..moveTo(center.dx, center.dy - radius * 1.15)
          ..lineTo(center.dx + radius * 0.95, center.dy)
          ..lineTo(center.dx, center.dy + radius * 1.15)
          ..lineTo(center.dx - radius * 0.95, center.dy)
          ..close();
        canvas.drawPath(path, targetFillPaint);
        canvas.drawPath(path, targetBorderPaint);

        final innerPath = Path()
          ..moveTo(center.dx, center.dy - radius * 0.60)
          ..lineTo(center.dx + radius * 0.50, center.dy)
          ..lineTo(center.dx, center.dy + radius * 0.60)
          ..lineTo(center.dx - radius * 0.50, center.dy)
          ..close();
        canvas.drawPath(innerPath, innerGlyphPaint);
        break;

      case PieceType.roseSquare:
        final rect = Rect.fromCenter(
          center: center,
          width: radius * 1.7,
          height: radius * 1.7,
        );
        final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius * 0.32));
        canvas.drawRRect(rrect, targetFillPaint);
        canvas.drawRRect(rrect, targetBorderPaint);

        final innerRect = Rect.fromCenter(
          center: center,
          width: radius * 0.9,
          height: radius * 0.9,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(innerRect, Radius.circular(radius * 0.18)),
          innerGlyphPaint,
        );
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
        canvas.drawPath(path, targetBorderPaint);

        final innerHex = Path();
        for (int i = 0; i < 6; i++) {
          final angle = (i * 60 - 30) * math.pi / 180;
          final x = center.dx + radius * 0.52 * math.cos(angle);
          final y = center.dy + radius * 0.52 * math.sin(angle);
          if (i == 0) {
            innerHex.moveTo(x, y);
          } else {
            innerHex.lineTo(x, y);
          }
        }
        innerHex.close();
        canvas.drawPath(innerHex, innerGlyphPaint);
        break;

      case PieceType.violetTriangle:
        final path = Path()
          ..moveTo(center.dx, center.dy - radius * 1.1)
          ..lineTo(center.dx + radius * 1.02, center.dy + radius * 0.82)
          ..lineTo(center.dx - radius * 1.02, center.dy + radius * 0.82)
          ..close();
        canvas.drawPath(path, targetFillPaint);
        canvas.drawPath(path, targetBorderPaint);

        final innerTri = Path()
          ..moveTo(center.dx, center.dy - radius * 0.55)
          ..lineTo(center.dx + radius * 0.52, center.dy + radius * 0.42)
          ..lineTo(center.dx - radius * 0.52, center.dy + radius * 0.42)
          ..close();
        canvas.drawPath(innerTri, innerGlyphPaint);
        break;
    }

    // 5. Bright glowing center beacon pip
    final dotAura = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 4.0, dotAura);

    final whiteCore = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 2.2, whiteCore);
  }
}
