import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

/// Coquette-styled card with lace border effect and pink shadows, wrapping shadcn Card
class CoquetteCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final bool isCompleted;

  const CoquetteCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: isCompleted ? 0.7 : 1.0,
      child: GestureDetector(
        onTap: onTap,
        child: shadcn.Card(
          padding: padding ?? const EdgeInsets.all(16),
          filled: true,
          fillColor: isCompleted
              ? (isDark ? const Color(0xFF1C2D24) : const Color(0xFFF0F9F4))
              : (theme.cardTheme.color ?? (isDark ? const Color(0xFF24151E) : const Color(0xFFFFF8FA))),
          borderRadius: BorderRadius.circular(12),
          borderWidth: 1,
          borderColor: isCompleted
              ? (isDark ? const Color(0xFF6DAF85) : const Color(0xFFA8D8B9))
              : (isDark
                  ? const Color(0xFF3D2232).withValues(alpha: 0.5)
                  : const Color(0xFFF5D5E0)),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.2)
                  : const Color(0xFFE8A0BF).withValues(alpha: 0.12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          child: child,
        ),
      ),
    );
  }
}
