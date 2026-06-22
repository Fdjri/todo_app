import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

/// Floating action button with coquette bow-style accent and tooltip
class QuickAddFabWidget extends StatelessWidget {
  final VoidCallback onPressed;

  const QuickAddFabWidget({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.4),
                  blurRadius: 16,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: shadcn.Button(
              style: const shadcn.ButtonStyle.primary(
                shape: shadcn.ButtonShape.circle,
              ),
              onPressed: onPressed,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add_rounded, size: 28),
                  Text(
                    '✨',
                    style: const TextStyle(fontSize: 8),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
