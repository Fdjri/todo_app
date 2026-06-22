import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';

/// Light coquette theme — warm pinks, soft shadows, romantic feel
class CoquetteTheme {
  CoquetteTheme._();

  static ThemeData lightTheme({
    Color? primaryOverride,
    String? fontFamily,
  }) {
    // Apply font family if provided
    if (fontFamily != null) {
      AppTypography.setHeadingFamily(fontFamily);
    }

    final primary = primaryOverride ?? AppColors.primaryLight;
    // Derive a lighter blush shade
    final blush = HSLColor.fromColor(primary)
        .withLightness(
            (HSLColor.fromColor(primary).lightness + 0.15).clamp(0.0, 1.0))
        .withSaturation(
            (HSLColor.fromColor(primary).saturation * 0.6).clamp(0.0, 1.0))
        .toColor();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: primary,
        primaryContainer: blush,
        secondary: AppColors.goldAccentLight,
        secondaryContainer: AppColors.creamLight,
        surface: AppColors.surfaceLight,
        error: AppColors.errorLight,
        onPrimary: Colors.white,
        onSecondary: AppColors.textPrimaryLight,
        onSurface: AppColors.textPrimaryLight,
        onError: Colors.white,
        outline: blush,
      ),
      scaffoldBackgroundColor: AppColors.backgroundLight,
      textTheme: AppTypography.textTheme(
        primaryColor: AppColors.textPrimaryLight,
        bodyColor: AppColors.textBodyLight,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundLight,
        foregroundColor: AppColors.textPrimaryLight,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.h2(color: AppColors.textPrimaryLight),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: blush, width: 1),
        ),
        shadowColor: primary.withValues(alpha: 0.15),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: blush),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: blush),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        hintStyle: AppTypography.body(color: AppColors.textHintLight),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceLight,
        selectedColor: primary,
        labelStyle: AppTypography.small(color: AppColors.textBodyLight),
        secondaryLabelStyle: AppTypography.small(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
          side: BorderSide(color: blush),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceLight,
        selectedItemColor: primary,
        unselectedItemColor: AppColors.textHintLight,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return AppColors.textHintLight;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return blush;
          return AppColors.creamLight;
        }),
      ),
      dividerTheme: DividerThemeData(
        color: blush,
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimaryLight,
        contentTextStyle: AppTypography.body(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
