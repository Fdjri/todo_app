import 'package:flutter/material.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/entities/user_stats_entity.dart';

/// Streak counter badge with fire emoji scaling animation
class StreakCounterWidget extends StatelessWidget {
  final UserStatsEntity stats;

  const StreakCounterWidget({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final streak = stats.currentStreak;

    String fire = '';
    if (streak >= 30) {
      fire = '🔥🔥🔥';
    } else if (streak >= 7) {
      fire = '🔥🔥';
    } else if (streak >= 1) {
      fire = '🔥';
    }

    if (streak == 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          'Start your streak! ✨',
          style: AppTypography.small(color: theme.colorScheme.secondary),
        ),
      );
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.secondary.withValues(alpha: 0.2),
                  theme.colorScheme.secondary.withValues(alpha: 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: theme.colorScheme.secondary.withValues(alpha: 0.3),
              ),
              boxShadow: streak >= 30
                  ? [
                      BoxShadow(
                        color: theme.colorScheme.secondary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(fire, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 4),
                Text(
                  '$streak days',
                  style: AppTypography.bodyBold(
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
