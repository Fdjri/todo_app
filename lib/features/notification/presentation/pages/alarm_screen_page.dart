import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/services/sound_service.dart';
import '../../../../injection_container.dart';

/// Full-screen alarm page with pulsing Lottie animation, task info, and action buttons
/// Design spec: gradient background, pulsing alarm icon, mark done / snooze / dismiss
class AlarmScreenPage extends StatefulWidget {
  final String taskTitle;
  final String categoryEmoji;
  final String categoryName;
  final String? dueTimeText;

  const AlarmScreenPage({
    super.key,
    required this.taskTitle,
    this.categoryEmoji = '📌',
    this.categoryName = 'Task',
    this.dueTimeText,
  });

  static const String routeName = '/alarm_screen';

  @override
  State<AlarmScreenPage> createState() => _AlarmScreenPageState();
}

class _AlarmScreenPageState extends State<AlarmScreenPage>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Pulse animation for the alarm icon glow
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Fade-in for content
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );

    // Play alarm sound
    sl<SoundService>().playLevelUp();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final bg = theme.scaffoldBackgroundColor;
    final primaryDarker = HSLColor.fromColor(primary)
        .withLightness((HSLColor.fromColor(primary).lightness - 0.15).clamp(0.0, 1.0))
        .toColor();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryDarker,
              bg,
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // ─── Pulsing alarm icon with Lottie ───
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: primary
                                .withValues(alpha: _pulseAnimation.value * 0.5),
                            blurRadius: 40 * _pulseAnimation.value,
                            spreadRadius: 10 * _pulseAnimation.value,
                          ),
                        ],
                      ),
                      child: Lottie.asset(
                        'assets/lottie/alarm_pulse.json',
                        repeat: true,
                        fit: BoxFit.contain,
                      ),
                    );
                  },
                ),

                const SizedBox(height: 32),

                // ─── "It's time, bestie!" ───
                Text(
                  "It's time, bestie!",
                  style: AppTypography.quoteLarge(
                    color: Colors.white.withValues(alpha: 0.95),
                  ),
                ),

                const SizedBox(height: 24),

                // ─── Task title ───
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    '"${widget.taskTitle}"',
                    textAlign: TextAlign.center,
                    style: AppTypography.h1(
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ─── Category + time ───
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${widget.categoryEmoji} ${widget.categoryName}',
                      style: AppTypography.body(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),

                if (widget.dueTimeText != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.dueTimeText!,
                    style: AppTypography.caption(
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],

                const Spacer(flex: 2),

                // ─── Action buttons ───
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      // Mark Done button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: FilledButton.icon(
                          onPressed: () {
                            sl<SoundService>().playTaskComplete();
                            Navigator.pop(context, 'done');
                          },
                          icon: const Text('✅', style: TextStyle(fontSize: 20)),
                          label: Text(
                            'Mark Done',
                            style: AppTypography.h3(color: Colors.white),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: isDark
                                ? AppColors.successDark
                                : AppColors.successLight,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Snooze button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context, 'snooze');
                          },
                          icon: const Text('⏰', style: TextStyle(fontSize: 20)),
                          label: Text(
                            'Snooze (15m)',
                            style: AppTypography.h3(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.4),
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Dismiss link
                      TextButton(
                        onPressed: () => Navigator.pop(context, 'dismiss'),
                        child: Text(
                          'Dismiss',
                          style: AppTypography.body(
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
