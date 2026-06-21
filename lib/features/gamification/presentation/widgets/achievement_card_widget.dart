import 'package:flutter/material.dart';
import '../../../../core/constants/app_typography.dart';

/// Achievement badge card with icon, title, and unlock status
class AchievementCardWidget extends StatelessWidget {
  final String title;
  final String description;
  final String emoji;
  final bool isUnlocked;

  const AchievementCardWidget({
    super.key,
    required this.title,
    required this.description,
    required this.emoji,
    this.isUnlocked = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isUnlocked
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.secondary.withValues(alpha: 0.15),
                  theme.colorScheme.primary.withValues(alpha: 0.08),
                ],
              )
            : null,
        color: isUnlocked ? null : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnlocked
              ? theme.colorScheme.secondary.withValues(alpha: 0.4)
              : theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
        boxShadow: isUnlocked
            ? [
                BoxShadow(
                  color: theme.colorScheme.secondary.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          // Emoji badge
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isUnlocked
                  ? theme.colorScheme.secondary.withValues(alpha: 0.2)
                  : theme.colorScheme.outline.withValues(alpha: 0.1),
            ),
            child: Center(
              child: Text(
                isUnlocked ? emoji : '🔒',
                style: TextStyle(fontSize: isUnlocked ? 24 : 20),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Title + description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyBold(
                    color: isUnlocked
                        ? theme.colorScheme.onSurface
                        : theme.textTheme.bodySmall?.color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: AppTypography.caption(
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),

          // Unlocked indicator
          if (isUnlocked)
            Icon(
              Icons.check_circle_rounded,
              color: theme.colorScheme.secondary,
              size: 22,
            ),
        ],
      ),
    );
  }
}
