import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';

/// Dark coquette theme — Midnight Coquette with deep wine/burgundy tones
class DarkCoquetteTheme {
  DarkCoquetteTheme._();

  static ThemeData darkTheme({
    Color? primaryOverride,
    String? fontFamily,
  }) {
    if (fontFamily != null) {
      AppTypography.setHeadingFamily(fontFamily);
    }

    final primary = primaryOverride ?? AppColors.primaryDark;
    // Derive darker blush
    final blush = HSLColor.fromColor(primary)
        .withLightness(
            (HSLColor.fromColor(primary).lightness - 0.15).clamp(0.15, 0.5))
        .withSaturation(
            (HSLColor.fromColor(primary).saturation * 0.5).clamp(0.0, 1.0))
        .toColor();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: primary,
        primaryContainer: blush,
        secondary: AppColors.goldAccentDark,
        secondaryContainer: AppColors.creamDark,
        surface: AppColors.surfaceDark,
        error: AppColors.errorDark,
        onPrimary: AppColors.textPrimaryDark,
        onSecondary: AppColors.textPrimaryDark,
        onSurface: AppColors.textPrimaryDark,
        onError: AppColors.textPrimaryDark,
        outline: blush,
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,
      textTheme: AppTypography.textTheme(
        primaryColor: AppColors.textPrimaryDark,
        bodyColor: AppColors.textBodyDark,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundDark,
        foregroundColor: AppColors.textPrimaryDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.h2(color: AppColors.textPrimaryDark),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
              color: blush.withValues(alpha: 0.5), width: 1),
        ),
        shadowColor: primary.withValues(alpha: 0.2),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: AppColors.textPrimaryDark,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
              color: blush.withValues(alpha: 0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
              color: blush.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        hintStyle: AppTypography.body(color: AppColors.textHintDark),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceDark,
        selectedColor: primary,
        labelStyle: AppTypography.small(color: AppColors.textBodyDark),
        secondaryLabelStyle:
            AppTypography.small(color: AppColors.textPrimaryDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
          side: BorderSide(
              color: blush.withValues(alpha: 0.5)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        selectedItemColor: primary,
        unselectedItemColor: AppColors.textHintDark,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return AppColors.textHintDark;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return blush;
          return AppColors.creamDark;
        }),
      ),
      dividerTheme: DividerThemeData(
        color: blush.withValues(alpha: 0.5),
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        contentTextStyle:
            AppTypography.body(color: AppColors.textPrimaryDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
