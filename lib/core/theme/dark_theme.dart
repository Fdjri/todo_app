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
    final primaryHsl = HSLColor.fromColor(primary);

    // Derive darker blush
    final blush = primaryHsl
        .withLightness((primaryHsl.lightness - 0.15).clamp(0.15, 0.5))
        .withSaturation((primaryHsl.saturation * 0.5).clamp(0.0, 1.0))
        .toColor();

    // Derive cream/secondaryContainer
    final cream = primaryHsl
        .withLightness(0.12)
        .withSaturation((primaryHsl.saturation * 0.55).clamp(0.1, 0.4))
        .toColor();

    // Derive scaffold background (very dark tinted background)
    final background = primaryHsl
        .withLightness(0.08)
        .withSaturation((primaryHsl.saturation * 0.4).clamp(0.1, 0.25))
        .toColor();

    // Derive surface (slightly lighter than background)
    final surface = primaryHsl
        .withLightness(0.11)
        .withSaturation((primaryHsl.saturation * 0.35).clamp(0.08, 0.22))
        .toColor();

    // Derive dynamic textPrimary
    final textPrimary = primaryHsl
        .withLightness(0.97)
        .withSaturation((primaryHsl.saturation * 0.25).clamp(0.05, 0.2))
        .toColor();

    // Derive dynamic textBody
    final textBody = primaryHsl
        .withLightness(0.76)
        .withSaturation((primaryHsl.saturation * 0.5).clamp(0.15, 0.45))
        .toColor();

    // Derive dynamic textHint
    final textHint = primaryHsl
        .withLightness(0.48)
        .withSaturation((primaryHsl.saturation * 0.25).clamp(0.08, 0.25))
        .toColor();

    // Derive dynamic secondary (gold accent replacement) by shifting hue
    final secondary = HSLColor.fromAHSL(
      1.0,
      (primaryHsl.hue + 65) % 360,
      0.55,
      0.66,
    ).toColor();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: fontFamily,
      hintColor: textHint,
      colorScheme: ColorScheme.dark(
        primary: primary,
        primaryContainer: blush,
        secondary: secondary,
        secondaryContainer: cream,
        surface: surface,
        error: AppColors.errorDark,
        onPrimary: textPrimary,
        onSecondary: textPrimary,
        onSurface: textPrimary,
        onError: textPrimary,
        outline: blush,
      ),
      scaffoldBackgroundColor: background,
      textTheme: AppTypography.textTheme(
        primaryColor: textPrimary,
        bodyColor: textBody,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.h2(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: surface,
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
        foregroundColor: textPrimary,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
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
        hintStyle: AppTypography.body(color: textHint),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: primary,
        labelStyle: AppTypography.small(color: textBody),
        secondaryLabelStyle:
            AppTypography.small(color: textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
          side: BorderSide(
              color: blush.withValues(alpha: 0.5)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textHint,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return textHint;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return blush;
          return cream;
        }),
      ),
      dividerTheme: DividerThemeData(
        color: blush.withValues(alpha: 0.5),
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surface,
        contentTextStyle:
            AppTypography.body(color: textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
