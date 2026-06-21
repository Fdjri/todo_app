import 'package:flutter/material.dart';

/// Decorative bow divider using CustomPaint — coquette section separator
class BowDivider extends StatelessWidget {
  final double width;
  final Color? color;

  const BowDivider({super.key, this.width = double.infinity, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dividerColor = color ?? theme.colorScheme.primary.withValues(alpha: 0.3);
    return SizedBox(
      width: width,
      height: 24,
      child: CustomPaint(
        painter: _BowPainter(color: dividerColor),
      ),
    );
  }
}

class _BowPainter extends CustomPainter {
  final Color color;

  _BowPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);

    // Left line
    canvas.drawLine(
      Offset(0, center.dy),
      Offset(center.dx - 16, center.dy),
      paint,
    );

    // Right line
    canvas.drawLine(
      Offset(center.dx + 16, center.dy),
      Offset(size.width, center.dy),
      paint,
    );

    // Left loop of bow
    final leftPath = Path()
      ..moveTo(center.dx, center.dy)
      ..cubicTo(
        center.dx - 20, center.dy - 14,
        center.dx - 24, center.dy - 6,
        center.dx - 12, center.dy,
      );
    canvas.drawPath(leftPath, paint);
    canvas.drawPath(leftPath, fillPaint);

    // Right loop of bow
    final rightPath = Path()
      ..moveTo(center.dx, center.dy)
      ..cubicTo(
        center.dx + 20, center.dy - 14,
        center.dx + 24, center.dy - 6,
        center.dx + 12, center.dy,
      );
    canvas.drawPath(rightPath, paint);
    canvas.drawPath(rightPath, fillPaint);

    // Bottom left tail
    final leftTail = Path()
      ..moveTo(center.dx, center.dy)
      ..cubicTo(
        center.dx - 8, center.dy + 4,
        center.dx - 10, center.dy + 10,
        center.dx - 6, center.dy + 10,
      );
    canvas.drawPath(leftTail, paint);

    // Bottom right tail
    final rightTail = Path()
      ..moveTo(center.dx, center.dy)
      ..cubicTo(
        center.dx + 8, center.dy + 4,
        center.dx + 10, center.dy + 10,
        center.dx + 6, center.dy + 10,
      );
    canvas.drawPath(rightTail, paint);

    // Center knot
    canvas.drawCircle(center, 2.5, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _BowPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
