import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../../core/constants/app_typography.dart';
import '../../core/theme/theme_bloc.dart';
import '../../core/widgets/bow_divider.dart';
import '../core/services/sound_service.dart';
import '../injection_container.dart';
import 'notification_sound_page.dart';

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

  @override
  void initState() {
    super.initState();
    _notificationSound = sl<SoundService>().getSelectedSound();
  }

  void _loadSettings() {
    setState(() {
      _notificationSound = sl<SoundService>().getSelectedSound();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final theme = Theme.of(context);
        final isDark = themeState.isDarkMode;
        final bg = theme.scaffoldBackgroundColor;
        final surface = theme.colorScheme.surface;
        final primary = theme.colorScheme.primary;
        final textPrimary = theme.colorScheme.onSurface;
        final textHint = theme.hintColor;

        return Scaffold(
          backgroundColor: bg,
          body: SafeArea(
            child: shadcn.OverlayManagerLayer(
              popoverHandler: shadcn.OverlayHandler.popover,
              menuHandler: shadcn.OverlayHandler.popover,
              tooltipHandler: shadcn.OverlayHandler.popover,
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
                          selectedColorIndex: themeState.colorIndex,
                          onColorSelected: (idx) {
                            context.read<ThemeBloc>().add(ChangeThemeColor(idx));
                          },
                        ),

                        _buildDivider(textHint),

                        // Font style
                        _buildFontDropdownRow(
                          value: themeState.fontFamily,
                          options: ThemeBloc.fontFamilies,
                          textPrimary: textPrimary,
                          textHint: textHint,
                          primary: primary,
                          surface: surface,
                          onChanged: (v) {
                            if (v != null) {
                              context.read<ThemeBloc>().add(ChangeFontStyle(v));
                            }
                          },
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
                        _buildNavigationRow(
                          icon: Icons.music_note_rounded,
                          label: 'Notification Sound',
                          value: _notificationSound,
                          textPrimary: textPrimary,
                          textHint: textHint,
                          primary: primary,
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const NotificationSoundPage(),
                              ),
                            );
                            _loadSettings();
                          },
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
          ),
        );
      },
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
          shadcn.Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildColorPickerRow({
    required Color textPrimary,
    required Color textHint,
    required Color primary,
    required int selectedColorIndex,
    required ValueChanged<int> onColorSelected,
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
            children: List.generate(ThemeBloc.themeColors.length, (i) {
              final isSelected = selectedColorIndex == i;
              return GestureDetector(
                onTap: () => onColorSelected(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(left: 8),
                  width: isSelected ? 28 : 24,
                  height: isSelected ? 28 : 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ThemeBloc.themeColors[i],
                    border: isSelected
                        ? Border.all(
                            color: Colors.white,
                            width: 2,
                          )
                        : null,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: ThemeBloc.themeColors[i].withValues(alpha: 0.50),
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


  Widget _buildNavigationRow({
    required IconData icon,
    required String label,
    required String value,
    required Color textPrimary,
    required Color textHint,
    required Color primary,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
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
              child: Text(label, style: AppTypography.body(color: textPrimary)),
            ),
            Text(value, style: AppTypography.small(color: textHint)),
            const SizedBox(width: 6),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: textHint.withValues(alpha: 0.5),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  TextStyle _getFontFamilyStyle(
    String family, {
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
  }) {
    switch (family) {
      case 'Nunito':
        return GoogleFonts.nunito(
          color: color,
          fontSize: fontSize,
          fontWeight: fontWeight,
        );
      case 'Dancing Script':
        return GoogleFonts.dancingScript(
          color: color,
          fontSize: fontSize,
          fontWeight: fontWeight,
        );
      case 'Playfair Display':
      default:
        return GoogleFonts.playfairDisplay(
          color: color,
          fontSize: fontSize,
          fontWeight: fontWeight,
        );
    }
  }

  Widget _buildFontDropdownRow({
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
            child: Icon(Icons.text_fields_rounded, color: primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text('Font Style', style: AppTypography.body(color: textPrimary)),
          ),
          // Dropdown button -> shadcn Select
          shadcn.Select<String>(
            value: value,
            onChanged: onChanged,
            popupWidthConstraint: shadcn.PopoverConstraint.flexible,
            popupConstraints: const BoxConstraints(
              minWidth: 140,
              maxWidth: 200,
            ),
            itemBuilder: (context, val) => Text(
              val,
              style: _getFontFamilyStyle(
                val,
                color: textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            popup: (context) => shadcn.SelectPopup(
              items: shadcn.SelectItemList(
                children: options.map((opt) {
                  return shadcn.SelectItemButton(
                    value: opt,
                    child: Text(
                      opt,
                      style: _getFontFamilyStyle(
                        opt,
                        color: textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
