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
    final primaryHsl = HSLColor.fromColor(primary);

    // Derive a lighter blush shade
    final blush = primaryHsl
        .withLightness((primaryHsl.lightness + 0.15).clamp(0.0, 1.0))
        .withSaturation((primaryHsl.saturation * 0.6).clamp(0.0, 1.0))
        .toColor();

    // Derive cream/secondaryContainer
    final cream = primaryHsl
        .withLightness(0.94)
        .withSaturation((primaryHsl.saturation * 0.9).clamp(0.0, 1.0))
        .toColor();

    // Derive scaffold background (very light tinted background)
    final background = primaryHsl
        .withLightness(0.98)
        .withSaturation((primaryHsl.saturation * 0.2).clamp(0.05, 0.1))
        .toColor();

    final surface = Colors.white;

    // Derive dynamic textPrimary
    final textPrimary = primaryHsl
        .withLightness(0.18)
        .withSaturation((primaryHsl.saturation * 0.55).clamp(0.15, 0.4))
        .toColor();

    // Derive dynamic textBody
    final textBody = primaryHsl
        .withLightness(0.30)
        .withSaturation((primaryHsl.saturation * 0.35).clamp(0.1, 0.3))
        .toColor();

    // Derive dynamic textHint
    final textHint = primaryHsl
        .withLightness(0.58)
        .withSaturation((primaryHsl.saturation * 0.25).clamp(0.08, 0.25))
        .toColor();

    // Derive dynamic secondary (gold accent replacement) by shifting hue
    final secondary = HSLColor.fromAHSL(
      1.0,
      (primaryHsl.hue + 65) % 360,
      0.48,
      0.61,
    ).toColor();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: fontFamily,
      hintColor: textHint,
      colorScheme: ColorScheme.light(
        primary: primary,
        primaryContainer: blush,
        secondary: secondary,
        secondaryContainer: cream,
        surface: surface,
        error: AppColors.errorLight,
        onPrimary: Colors.white,
        onSecondary: textPrimary,
        onSurface: textPrimary,
        onError: Colors.white,
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
        fillColor: surface,
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
        hintStyle: AppTypography.body(color: textHint),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: primary,
        labelStyle: AppTypography.small(color: textBody),
        secondaryLabelStyle: AppTypography.small(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
          side: BorderSide(color: blush),
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
        color: blush,
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: textPrimary,
        contentTextStyle: AppTypography.body(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
