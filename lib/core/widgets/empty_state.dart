import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../constants/app_assets.dart';
import '../constants/app_strings.dart';
import '../constants/app_typography.dart';

/// Motivational empty state with Lottie animation and random coquette quotes
class EmptyStateWidget extends StatelessWidget {
  final VoidCallback? onAddTask;

  const EmptyStateWidget({super.key, this.onAddTask});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Lottie animation
            SizedBox(
              width: 180,
              height: 180,
              child: Lottie.asset(
                AppAssets.lottieEmptyState,
                repeat: true,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 24),
            // Random motivational quote
            Text(
              AppStrings.randomEmptyQuote,
              textAlign: TextAlign.center,
              style: AppTypography.quoteLarge(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            // Add task button
            if (onAddTask != null)
              FilledButton.icon(
                onPressed: onAddTask,
                icon: const Icon(Icons.add_rounded, size: 20),
                label: Text(
                  'Add your first task',
                  style: AppTypography.bodyBold(color: theme.colorScheme.onPrimary),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
