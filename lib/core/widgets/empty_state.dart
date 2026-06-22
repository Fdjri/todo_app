import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import '../constants/app_assets.dart';
import '../constants/app_strings.dart';
import '../constants/app_typography.dart';
import 'shining_effect.dart';

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
            // Add task button — shadcn Button.primary
            if (onAddTask != null)
              ShiningBorder(
                child: shadcn.Button.primary(
                  onPressed: onAddTask,
                  leading: const Icon(Icons.add_rounded, size: 20),
                  child: Text(
                    'Add your first task',
                    style: AppTypography.bodyBold(color: theme.colorScheme.onPrimary),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
