import 'package:flutter/material.dart';

/// Coquette color palette with light and dark mode tokens
class AppColors {
  AppColors._();

  // ─── Light Mode ───
  static const Color primaryLight = Color(0xFFE8A0BF);
  static const Color primaryDarkLight = Color(0xFFD4789C);
  static const Color blushLight = Color(0xFFF5D5E0);
  static const Color creamLight = Color(0xFFFCE4EC);
  static const Color backgroundLight = Color(0xFFFFF8F9);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color goldAccentLight = Color(0xFFC9A96E);
  static const Color textPrimaryLight = Color(0xFF3D2232);
  static const Color textBodyLight = Color(0xFF5A4350);
  static const Color textHintLight = Color(0xFFA68E9A);

  // ─── Dark Mode (Midnight Coquette) ───
  static const Color primaryDark = Color(0xFFD4789C);
  static const Color primaryDarkDark = Color(0xFFC0577A);
  static const Color blushDark = Color(0xFF3D2232);
  static const Color creamDark = Color(0xFF2A1822);
  static const Color backgroundDark = Color(0xFF1A1118);
  static const Color surfaceDark = Color(0xFF241920);
  static const Color goldAccentDark = Color(0xFFD4B87A);
  static const Color textPrimaryDark = Color(0xFFFFF0F5);
  static const Color textBodyDark = Color(0xFFD4AEBE);
  static const Color textHintDark = Color(0xFF8A6B7A);

  // ─── Semantic Colors ───
  static const Color successLight = Color(0xFFA8D8B9);
  static const Color successDark = Color(0xFF6DAF85);
  static const Color warningLight = Color(0xFFFFD4A8);
  static const Color warningDark = Color(0xFFE5A66B);
  static const Color errorLight = Color(0xFFE57373);
  static const Color errorDark = Color(0xFFCF6679);
  static const Color infoLight = Color(0xFFB8CCE3);
  static const Color infoDark = Color(0xFF7BA3CC);

  // ─── Category Colors ───
  static const Color categorySelfCare = Color(0xFFF5D5E0);
  static const Color categoryWork = Color(0xFFD4C5F9);
  static const Color categoryStudy = Color(0xFFB8CCE3);
  static const Color categoryErrands = Color(0xFFFFD4A8);
  static const Color categorySocial = Color(0xFFFFB3BA);
  static const Color categoryHealth = Color(0xFFA8D8B9);
  static const Color categoryCreative = Color(0xFFF9E4B7);
  static const Color categoryHome = Color(0xFFC9DCD2);

  // ─── Priority Colors ───
  static const Color priorityLow = Color(0xFFA8D8B9);
  static const Color priorityMedium = Color(0xFFF5D5E0);
  static const Color priorityHigh = Color(0xFFFFD4A8);
  static const Color priorityUrgent = Color(0xFFE57373);
}
