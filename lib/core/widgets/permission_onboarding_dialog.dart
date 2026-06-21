import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../services/alarm_service.dart';

/// Onboarding dialog that requests notification + exact alarm permissions.
/// Shown once on first app launch (guarded by SharedPreferences flag).
class PermissionOnboardingDialog extends StatelessWidget {
  const PermissionOnboardingDialog({super.key});

  static const _shownKey = 'permission_onboarding_shown';

  /// Show the dialog once. Call this from app startup.
  static Future<void> showIfNeeded(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final alreadyShown = prefs.getBool(_shownKey) ?? false;
    if (alreadyShown) return;
    if (!context.mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PermissionOnboardingDialog(),
    );
    await prefs.setBool(_shownKey, true);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textBody =
        isDark ? AppColors.textBodyDark : AppColors.textBodyLight;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    return Dialog(
      backgroundColor: surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    primary.withValues(alpha: 0.3),
                    primary.withValues(alpha: 0.05),
                  ],
                ),
              ),
              child: const Center(
                child: Text('⏰', style: TextStyle(fontSize: 36)),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              'Enable Alarms 🎀',
              style: AppTypography.h2(color: textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Body
            Text(
              'Workaholic needs two permissions to deliver your task alarms on time:\n\n'
              '• 📣 Notifications — to send you alerts\n'
              '• ⏱ Exact Alarms — so alarms fire at the exact second (Android 12+)\n\n'
              'After pressing Continue, Android may open a settings page — just toggle the switch and come back!',
              style: AppTypography.body(color: textBody),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),

            // Button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () async {
                  Navigator.of(context).pop();
                  final svc = AlarmService();
                  // 1. Request POST_NOTIFICATIONS (Android 13+)
                  await svc.requestNotificationPermission();
                  // 2. Open exact alarm settings (Android 12+)
                  final canExact = await svc.canScheduleExactAlarms();
                  if (!canExact) {
                    await svc.openExactAlarmSettings();
                  }
                },
                child: Text(
                  'Continue ✨',
                  style:
                      AppTypography.bodyBold(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Skip
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Skip for now',
                style: AppTypography.caption(
                    color: textBody.withValues(alpha: 0.6)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
