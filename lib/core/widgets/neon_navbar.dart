import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';

/// Neon glow bottom navigation bar inspired by the design reference.
/// Active item gets a pill-shaped elevated container; the bar itself
/// has a frosted/blurred backdrop with a soft neon-pink top glow.
class NeonNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const NeonNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final background = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final textHint = isDark ? AppColors.textHintDark : AppColors.textHintLight;

    return Container(
      // Neon top shadow glow
      decoration: BoxDecoration(
        color: surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          // Neon glow line on top
          BoxShadow(
            color: primary.withValues(alpha: isDark ? 0.55 : 0.30),
            blurRadius: isDark ? 22 : 14,
            spreadRadius: isDark ? 2 : 1,
            offset: const Offset(0, -2),
          ),
          // Soft ambient shadow
          BoxShadow(
            color: primary.withValues(alpha: isDark ? 0.18 : 0.10),
            blurRadius: 40,
            spreadRadius: 0,
            offset: const Offset(0, -8),
          ),
          // Base shadow
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.40 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                isActive: currentIndex == 0,
                activeColor: primary,
                inactiveColor: textHint,
                onTap: () => onTap(0),
                isDark: isDark,
                surface: background,
              ),
              _NavItem(
                icon: Icons.history_rounded,
                label: 'History',
                isActive: currentIndex == 1,
                activeColor: primary,
                inactiveColor: textHint,
                onTap: () => onTap(1),
                isDark: isDark,
                surface: background,
              ),
              _NavItem(
                icon: Icons.settings_rounded,
                label: 'Settings',
                isActive: currentIndex == 2,
                activeColor: primary,
                inactiveColor: textHint,
                onTap: () => onTap(2),
                isDark: isDark,
                surface: background,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;
  final bool isDark;
  final Color surface;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
    required this.isDark,
    required this.surface,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 20 : 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? activeColor.withValues(alpha: isDark ? 0.18 : 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          // Inner neon border on active
          border: isActive
              ? Border.all(
                  color: activeColor.withValues(alpha: isDark ? 0.35 : 0.22),
                  width: 1,
                )
              : null,
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: isDark ? 0.30 : 0.15),
                    blurRadius: isDark ? 14 : 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              padding: EdgeInsets.all(isActive ? 6 : 4),
              decoration: BoxDecoration(
                color: isActive ? activeColor : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                boxShadow: isActive && isDark
                    ? [
                        BoxShadow(
                          color: activeColor.withValues(alpha: 0.50),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                icon,
                size: 22,
                color: isActive ? Colors.white : inactiveColor,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 280),
              style: AppTypography.small(
                color: isActive ? activeColor : inactiveColor,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
