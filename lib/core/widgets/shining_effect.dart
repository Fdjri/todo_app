import 'dart:math';
import 'package:flutter/material.dart';

/// A premium, reusable widget that adds a rotating, glowing border "shining" effect
/// to any child widget (e.g. buttons, cards, list items).
class ShiningBorder extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Color? shineColor;
  final double borderRadius;
  final double strokeWidth;
  final Color? baseBorderColor;

  const ShiningBorder({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 3000),
    this.shineColor,
    this.borderRadius = 8.0,
    this.strokeWidth = 2.0,
    this.baseBorderColor,
  });

  @override
  State<ShiningBorder> createState() => _ShiningBorderState();
}

class _ShiningBorderState extends State<ShiningBorder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolvedShineColor = widget.shineColor ?? theme.colorScheme.primary;
    final resolvedBaseBorderColor = widget.baseBorderColor ??
        resolvedShineColor.withValues(alpha: 0.15);

    return Stack(
      fit: StackFit.passthrough,
      children: [
        // The underlying child (button)
        widget.child,
        // The overlay glowing border
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: _ShiningBorderPainter(
                    animationValue: _controller.value,
                    shineColor: resolvedShineColor,
                    borderRadius: widget.borderRadius,
                    strokeWidth: widget.strokeWidth,
                    baseBorderColor: resolvedBaseBorderColor,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _ShiningBorderPainter extends CustomPainter {
  final double animationValue;
  final Color shineColor;
  final double borderRadius;
  final double strokeWidth;
  final Color baseBorderColor;

  _ShiningBorderPainter({
    required this.animationValue,
    required this.shineColor,
    required this.borderRadius,
    required this.strokeWidth,
    required this.baseBorderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Inset the rect by half the strokeWidth to avoid clipping at boundaries.
    final rect = Offset(strokeWidth / 2, strokeWidth / 2) &
        Size(size.width - strokeWidth, size.height - strokeWidth);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    // 1. Paint the base quiet border
    if (baseBorderColor != Colors.transparent) {
      final basePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..color = baseBorderColor;
      canvas.drawRRect(rrect, basePaint);
    }

    // 2. Paint the rotating shining glow
    final double angle = animationValue * 2 * pi;

    final shader = SweepGradient(
      center: Alignment.center,
      transform: GradientRotation(angle),
      colors: [
        Colors.transparent,
        Colors.transparent,
        shineColor.withValues(alpha: 0.05),
        shineColor, // Bright shining peak
        shineColor.withValues(alpha: 0.05),
        Colors.transparent,
        Colors.transparent,
      ],
      stops: const [0.0, 0.4, 0.45, 0.5, 0.55, 0.6, 1.0],
    ).createShader(rect);

    // Draw blurred neon shadow/glow
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 2.5
      ..shader = shader
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.5);
    canvas.drawRRect(rrect, glowPaint);

    // Draw the sharp bright border outline
    final sharpPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = shader;
    canvas.drawRRect(rrect, sharpPaint);
  }

  @override
  bool shouldRepaint(covariant _ShiningBorderPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.shineColor != shineColor ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.baseBorderColor != baseBorderColor;
  }
}
