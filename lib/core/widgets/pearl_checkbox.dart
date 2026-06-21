import 'package:flutter/material.dart';

/// Pearl-style circular checkbox with bounce animation
class PearlCheckbox extends StatefulWidget {
  final bool isChecked;
  final ValueChanged<bool>? onChanged;
  final double size;

  const PearlCheckbox({
    super.key,
    required this.isChecked,
    this.onChanged,
    this.size = 24,
  });

  @override
  State<PearlCheckbox> createState() => _PearlCheckboxState();
}

class _PearlCheckboxState extends State<PearlCheckbox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.8), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 0.8, end: 1.15), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0), weight: 30),
    ]).animate(_controller); // Linear driver — bounce is encoded in tween values
  }

  @override
  void didUpdateWidget(PearlCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isChecked != oldWidget.isChecked) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => widget.onChanged?.call(!widget.isChecked),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.isChecked
                    ? theme.colorScheme.primary
                    : Colors.transparent,
                border: Border.all(
                  color: widget.isChecked
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline,
                  width: 2,
                ),
                boxShadow: widget.isChecked
                    ? [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.6),
                          blurRadius: 4,
                          offset: const Offset(-1, -1),
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(1, 1),
                        ),
                      ],
              ),
              child: widget.isChecked
                  ? Icon(
                      Icons.check_rounded,
                      size: widget.size * 0.6,
                      color: theme.colorScheme.onPrimary,
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}
