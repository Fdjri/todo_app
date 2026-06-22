import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Coquette typography with swappable heading font family.
/// The body font is always Nunito; the heading/accent font can be changed.
class AppTypography {
  AppTypography._();

  /// Current heading font family — changed via Settings
  static String _headingFamily = 'Playfair Display';

  /// Update the heading font family globally.
  static void setHeadingFamily(String family) {
    _headingFamily = family;
  }

  // ─── Font Families ───
  static TextStyle get _heading {
    switch (_headingFamily) {
      case 'Nunito':
        return GoogleFonts.nunito();
      case 'Dancing Script':
        return GoogleFonts.dancingScript();
      case 'Playfair Display':
      default:
        return GoogleFonts.playfairDisplay();
    }
  }

  static TextStyle get _nunito => GoogleFonts.nunito();
  static TextStyle get _dancingScript => GoogleFonts.dancingScript();

  // ─── Display ───
  static TextStyle display({Color? color}) => _heading.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: color,
      );

  // ─── Headings ───
  static TextStyle h1({Color? color}) => _heading.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: color,
      );

  static TextStyle h2({Color? color}) => _heading.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: color,
      );

  static TextStyle h3({Color? color}) => _nunito.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        height: 1.4,
        color: color,
      );

  // ─── Body ───
  static TextStyle body({Color? color}) => _nunito.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: color,
      );

  static TextStyle bodyBold({Color? color}) => _nunito.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        height: 1.5,
        color: color,
      );

  // ─── Caption ───
  static TextStyle caption({Color? color}) => _nunito.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: color,
      );

  // ─── Small ───
  static TextStyle small({Color? color}) => _nunito.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: color,
      );

  // ─── Accent / Quotes ───
  static TextStyle quote({Color? color}) => _dancingScript.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: color,
      );

  static TextStyle quoteLarge({Color? color}) => _dancingScript.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: color,
      );

  // ─── TextTheme for ThemeData ───
  static TextTheme textTheme(
      {required Color primaryColor, required Color bodyColor}) {
    return TextTheme(
      displayLarge: display(color: primaryColor),
      headlineLarge: h1(color: primaryColor),
      headlineMedium: h2(color: primaryColor),
      headlineSmall: h3(color: primaryColor),
      bodyLarge: bodyBold(color: bodyColor),
      bodyMedium: body(color: bodyColor),
      bodySmall: caption(color: bodyColor),
      labelLarge: small(color: bodyColor),
      labelMedium: small(color: bodyColor),
      labelSmall: small(color: bodyColor),
    );
  }
}
