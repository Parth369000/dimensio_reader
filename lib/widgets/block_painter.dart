import 'package:flutter/material.dart';
import '../models/block_model.dart';

class MultiBlockPainter extends CustomPainter {
  final List<BlockModel> blocks;

  MultiBlockPainter({required this.blocks});

  @override
  void paint(Canvas canvas, Size size) {
    if (blocks.isEmpty) return;

    final double padding = 20.0;
    final int count = blocks.length;
    final double blockAreaWidth = (size.width - padding * 2) / count;
    final double blockAreaHeight = size.height - padding * 2;

    for (int i = 0; i < count; i++) {
      final block = blocks[i];
      final double l = block.parsedL;
      final double b = block.parsedB;
      final double h = block.parsedH;

      if (l <= 0 || b <= 0 || h <= 0) continue;

      final double depthRatioX = 0.5;
      final double depthRatioY = 0.5;

      // We are going to draw a 3x3 block array, so the bounding size is larger
      final double totalRawW = (l * 3) + (b * depthRatioX);
      final double totalRawH = (h * 3) + (b * depthRatioY);

      double scale = 1.0;
      if (totalRawW > 0 && totalRawH > 0) {
        final double scaleW = (blockAreaWidth * 0.8) / totalRawW;
        final double scaleH = (blockAreaHeight * 0.8) / totalRawH;
        scale = scaleW < scaleH ? scaleW : scaleH;
      }

      final double w = l * scale;
      final double hi = h * scale;
      final double d = b * scale;

      final double dx = d * depthRatioX;
      final double dy = -d * depthRatioY;

      final double areaStartX = padding + (i * blockAreaWidth);
      final double areaCenterX = areaStartX + (blockAreaWidth / 2);
      final double areaCenterY = size.height / 2;

      // Start coordinate calculation for the 3x3 array (so it's centered)
      final double gridTotalWidth = (w * 3) + dx;
      final double gridTotalHeight = (hi * 3) - dy;

      final double startX = areaCenterX - (gridTotalWidth / 2);
      final double startY = areaCenterY + (gridTotalHeight / 2);

      // Draw a 3x3 stack
      for (int row = 0; row < 3; row++) {
        for (int col = 0; col < 3; col++) {
          // Add a subtle gap for visual distinction (like mortar)
          final double gapX = col * (w + 2.0);
          final double gapY = row * (hi + 2.0);

          final double currentX = startX + gapX;
          final double currentY = startY - gapY;

          // Paint the base block geometry
          _paintBlockGeometry(canvas, currentX, currentY, w, hi, dx, dy);

          // Only draw label on the center-most block to avoid clutter
          if (row == 1 && col == 1) {
            _drawLabel(
              canvas,
              "[${block.name}] L:${block.lengthController.text}${block.lengthUnit}",
              Offset(currentX + w / 2, currentY + 15),
            );
            _drawLabel(
              canvas,
              "H:${block.heightController.text}${block.heightUnit}",
              Offset(currentX - 15, currentY - hi / 2),
              alignRight: true,
            );
            _drawLabel(
              canvas,
              "B:${block.breadthController.text}${block.breadthUnit}",
              Offset(currentX + w + dx / 2 + 10, currentY - hi + dy / 2 - 15),
            );
          }
        }
      }

      // Draw a title above the cluster suggesting usage
      _drawLabel(
        canvas,
        "Suggested Tiling (3x3)",
        Offset(areaCenterX, startY - (hi * 3) + dy - 30),
      );
    }
  }

  void _paintBlockGeometry(
    Canvas canvas,
    double startX,
    double startY,
    double w,
    double hi,
    double dx,
    double dy,
  ) {
    final Offset p1 = Offset(startX, startY);
    final Offset p2 = Offset(startX + w, startY);
    final Offset p3 = Offset(startX + w, startY - hi);
    final Offset p4 = Offset(startX, startY - hi);

    final Offset p6 = Offset(startX + w + dx, startY + dy);
    final Offset p7 = Offset(startX + w + dx, startY - hi + dy);
    final Offset p8 = Offset(startX + dx, startY - hi + dy);

    final Paint paintFront = Paint()
      ..color = Colors.blue.shade400.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;
    final Paint paintTop = Paint()
      ..color = Colors.blue.shade300.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;
    final Paint paintSide = Paint()
      ..color = Colors.blue.shade700.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;

    final Paint linePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.0
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final Path frontPath = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(p3.dx, p3.dy)
      ..lineTo(p4.dx, p4.dy)
      ..close();
    canvas.drawPath(frontPath, paintFront);
    canvas.drawPath(frontPath, linePaint);

    final Path topPath = Path()
      ..moveTo(p4.dx, p4.dy)
      ..lineTo(p3.dx, p3.dy)
      ..lineTo(p7.dx, p7.dy)
      ..lineTo(p8.dx, p8.dy)
      ..close();
    canvas.drawPath(topPath, paintTop);
    canvas.drawPath(topPath, linePaint);

    final Path sidePath = Path()
      ..moveTo(p2.dx, p2.dy)
      ..lineTo(p6.dx, p6.dy)
      ..lineTo(p7.dx, p7.dy)
      ..lineTo(p3.dx, p3.dy)
      ..close();
    canvas.drawPath(sidePath, paintSide);
    canvas.drawPath(sidePath, linePaint);
  }

  void _drawLabel(
    Canvas canvas,
    String text,
    Offset position, {
    bool alignRight = false,
  }) {
    final textSpan = TextSpan(
      text: text,
      style: const TextStyle(
        color: Color(0xFF8D4F23),
        fontSize: 10,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.2,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final dx = alignRight
        ? position.dx - textPainter.width
        : position.dx - textPainter.width / 2;
    final dy = position.dy - textPainter.height / 2;

    textPainter.paint(canvas, Offset(dx, dy));
  }

  @override
  bool shouldRepaint(MultiBlockPainter oldDelegate) => true;
}
