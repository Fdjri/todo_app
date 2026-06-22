import 'package:flutter/material.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/entities/user_stats_entity.dart';

/// Level badge showing current level, title, and XP progress bar
class LevelBadgeWidget extends StatelessWidget {
  final UserStatsEntity stats;
  final bool compact;

  const LevelBadgeWidget({
    super.key,
    required this.stats,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final level = stats.level;

    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.secondary.withValues(alpha: 0.15),
              theme.colorScheme.primary.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: theme.colorScheme.secondary.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          level.title,
          style: AppTypography.small(color: theme.colorScheme.secondary),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.secondary.withValues(alpha: 0.1),
            theme.colorScheme.primary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.secondary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Level title
          Row(
            children: [
              Text(
                level.title,
                style: AppTypography.h3(color: theme.colorScheme.onSurface),
              ),
              const Spacer(),
              Text(
                'Lv.${level.level}',
                style: AppTypography.bodyBold(
                  color: theme.colorScheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // XP progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: stats.xpProgress,
              minHeight: 10,
              backgroundColor: theme.colorScheme.primaryContainer,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.secondary,
              ),
            ),
          ),
          const SizedBox(height: 6),

          // XP text
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${stats.xp} XP',
                style: AppTypography.small(
                  color: theme.colorScheme.secondary,
                ),
              ),
              if (level.nextLevel != null)
                Text(
                  '${level.xpForNextLevel} XP needed',
                  style: AppTypography.small(
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
