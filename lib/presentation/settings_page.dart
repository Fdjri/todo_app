import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/theme/theme_bloc.dart';
import '../../core/widgets/bow_divider.dart';

/// Settings page — Midnight Coquette dark toggle, theme color selection,
/// font style, notification toggles, and notification sound picker.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _dailyReminders = true;
  bool _urgentAlarms = true;
  String _notificationSound = 'Soft Chime';
  String _fontStyle = 'Playfair Display';

  static const _soundOptions = ['Soft Chime', 'Gentle Bell', 'Sparkle', 'None'];
  static const _fontOptions = ['Playfair Display', 'Nunito', 'Dancing Script'];

  // Theme color choices (accent colors beyond primary)
  static const _themeColors = [
    Color(0xFFE8A0BF), // Rose Pink
    Color(0xFFB8CCE3), // Baby Blue
    Color(0xFFD4C5F9), // Lavender
    Color(0xFFC9A96E), // Antique Gold
  ];

  int _selectedColorIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final primary = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textHint = isDark ? AppColors.textHintDark : AppColors.textHintLight;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ─── Title ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 24, 0, 4),
                child: Center(
                  child: Text(
                    'Settings',
                    style: AppTypography.h1(color: textPrimary),
                  ),
                ),
              ),
            ),

            // ─── Appearance Section ───
            SliverToBoxAdapter(
              child: _buildSection(
                surface: surface,
                primary: primary,
                children: [
                  // Dark mode toggle
                  _buildToggleRow(
                    icon: Icons.nightlight_round,
                    label: 'Midnight Coquette',
                    value: isDark,
                    textPrimary: textPrimary,
                    primary: primary,
                    onChanged: (_) {
                      context.read<ThemeBloc>().add(ToggleTheme());
                    },
                  ),

                  _buildDivider(textHint),

                  // Theme color picker
                  _buildColorPickerRow(
                    textPrimary: textPrimary,
                    textHint: textHint,
                    primary: primary,
                  ),

                  _buildDivider(textHint),

                  // Font style
                  _buildDropdownRow(
                    icon: Icons.text_fields_rounded,
                    label: 'Font Style',
                    value: _fontStyle,
                    options: _fontOptions,
                    textPrimary: textPrimary,
                    textHint: textHint,
                    primary: primary,
                    surface: surface,
                    onChanged: (v) => setState(() => _fontStyle = v!),
                  ),
                ],
              ),
            ),

            // ─── Bow Divider ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 4),
                child: BowDivider(),
              ),
            ),

            // ─── Notifications Section ───
            SliverToBoxAdapter(
              child: _buildSection(
                surface: surface,
                primary: primary,
                children: [
                  // Daily reminders
                  _buildToggleRow(
                    icon: Icons.notifications_rounded,
                    label: 'Daily Reminders',
                    value: _dailyReminders,
                    textPrimary: textPrimary,
                    primary: primary,
                    onChanged: (v) => setState(() => _dailyReminders = v),
                  ),

                  _buildDivider(textHint),

                  // Urgent alarms
                  _buildToggleRow(
                    icon: Icons.priority_high_rounded,
                    label: 'Urgent Alarms',
                    subtitle: 'For high priority tasks, bestie!',
                    value: _urgentAlarms,
                    textPrimary: textPrimary,
                    textHint: textHint,
                    primary: primary,
                    onChanged: (v) => setState(() => _urgentAlarms = v),
                  ),

                  _buildDivider(textHint),

                  // Notification sound
                  _buildDropdownRow(
                    icon: Icons.music_note_rounded,
                    label: 'Notification Sound',
                    value: _notificationSound,
                    options: _soundOptions,
                    textPrimary: textPrimary,
                    textHint: textHint,
                    primary: primary,
                    surface: surface,
                    onChanged: (v) => setState(() => _notificationSound = v!),
                  ),
                ],
              ),
            ),

            // ─── Version info ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 100),
                child: Center(
                  child: Text(
                    '🎀 Workaholic v1.0.0',
                    style: AppTypography.caption(color: textHint),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required Color surface,
    required Color primary,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider(Color textHint) => Divider(
        height: 1,
        indent: 56,
        endIndent: 16,
        color: textHint.withValues(alpha: 0.15),
      );

  Widget _buildToggleRow({
    required IconData icon,
    required String label,
    String? subtitle,
    required bool value,
    required Color textPrimary,
    Color? textHint,
    required Color primary,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTypography.body(color: textPrimary)),
                if (subtitle != null && textHint != null)
                  Text(
                    subtitle,
                    style: AppTypography.small(color: textHint),
                  ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeTrackColor: primary,
          ),
        ],
      ),
    );
  }

  Widget _buildColorPickerRow({
    required Color textPrimary,
    required Color textHint,
    required Color primary,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.palette_rounded, color: primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text('Theme Selection',
                style: AppTypography.body(color: textPrimary)),
          ),
          // Color circles
          Row(
            children: List.generate(_themeColors.length, (i) {
              final isSelected = _selectedColorIndex == i;
              return GestureDetector(
                onTap: () => setState(() => _selectedColorIndex = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(left: 8),
                  width: isSelected ? 28 : 24,
                  height: isSelected ? 28 : 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _themeColors[i],
                    border: isSelected
                        ? Border.all(
                            color: Colors.white,
                            width: 2,
                          )
                        : null,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: _themeColors[i].withValues(alpha: 0.50),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownRow({
    required IconData icon,
    required String label,
    required String value,
    required List<String> options,
    required Color textPrimary,
    required Color textHint,
    required Color primary,
    required Color surface,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label, style: AppTypography.body(color: textPrimary)),
          ),
          // Dropdown button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: primary.withValues(alpha: 0.20),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isDense: true,
                icon: Icon(Icons.expand_more_rounded,
                    color: primary, size: 18),
                dropdownColor: surface,
                style: AppTypography.small(color: primary),
                items: options.map((opt) {
                  return DropdownMenuItem(
                    value: opt,
                    child: Text(opt,
                        style: AppTypography.small(color: textPrimary)),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
