import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/entities/user_stats_entity.dart';

/// XP progress bar showing current XP and next level threshold
class XpProgressBarWidget extends StatelessWidget {
  final UserStatsEntity stats;

  const XpProgressBarWidget({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final level = stats.level;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              level.title,
              style: AppTypography.bodyBold(color: theme.colorScheme.onSurface),
            ),
            Text(
              '${stats.xp}/${level.xpForNextLevel} XP',
              style: AppTypography.small(
                color: theme.colorScheme.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: stats.xpProgress),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          builder: (context, value, _) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 8,
                backgroundColor: isDark
                    ? AppColors.blushDark
                    : AppColors.blushLight,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDark ? AppColors.goldAccentDark : AppColors.goldAccentLight,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
