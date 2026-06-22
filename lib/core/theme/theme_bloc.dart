import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'coquette_theme.dart';
import 'dark_theme.dart';

// ─── Events ───
abstract class ThemeEvent extends Equatable {
  const ThemeEvent();
  @override
  List<Object?> get props => [];
}

class LoadTheme extends ThemeEvent {}

class ToggleTheme extends ThemeEvent {}

class ChangeThemeColor extends ThemeEvent {
  final int colorIndex;
  const ChangeThemeColor(this.colorIndex);
  @override
  List<Object?> get props => [colorIndex];
}

class ChangeFontStyle extends ThemeEvent {
  final String fontFamily;
  const ChangeFontStyle(this.fontFamily);
  @override
  List<Object?> get props => [fontFamily];
}

// ─── States ───
class ThemeState extends Equatable {
  final ThemeData themeData;
  final bool isDarkMode;
  final int colorIndex;
  final String fontFamily;

  const ThemeState({
    required this.themeData,
    required this.isDarkMode,
    this.colorIndex = 0,
    this.fontFamily = 'Playfair Display',
  });

  @override
  List<Object?> get props => [isDarkMode, colorIndex, fontFamily];
}

// ─── BLoC ───
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  static const String _themeKey = 'is_dark_mode';
  static const String _colorKey = 'theme_color_index';
  static const String _fontKey = 'theme_font_family';

  /// Available theme accent colors
  static const List<Color> themeColors = [
    Color(0xFFE8A0BF), // Rose Pink (default)
    Color(0xFFB8CCE3), // Baby Blue
    Color(0xFFD4C5F9), // Lavender
    Color(0xFFC9A96E), // Antique Gold
  ];

  /// Available font families
  static const List<String> fontFamilies = [
    'Playfair Display',
    'Nunito',
    'Dancing Script',
  ];

  ThemeBloc()
      : super(ThemeState(
          themeData: CoquetteTheme.lightTheme(),
          isDarkMode: false,
        )) {
    on<LoadTheme>(_onLoadTheme);
    on<ToggleTheme>(_onToggleTheme);
    on<ChangeThemeColor>(_onChangeThemeColor);
    on<ChangeFontStyle>(_onChangeFontStyle);
  }

  Future<void> _onLoadTheme(LoadTheme event, Emitter<ThemeState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_themeKey) ?? false;
    final colorIndex = prefs.getInt(_colorKey) ?? 0;
    final fontFamily = prefs.getString(_fontKey) ?? 'Playfair Display';

    emit(ThemeState(
      themeData: _buildTheme(isDark, colorIndex, fontFamily),
      isDarkMode: isDark,
      colorIndex: colorIndex,
      fontFamily: fontFamily,
    ));
  }

  Future<void> _onToggleTheme(
      ToggleTheme event, Emitter<ThemeState> emit) async {
    final newIsDark = !state.isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, newIsDark);
    emit(ThemeState(
      themeData: _buildTheme(newIsDark, state.colorIndex, state.fontFamily),
      isDarkMode: newIsDark,
      colorIndex: state.colorIndex,
      fontFamily: state.fontFamily,
    ));
  }

  Future<void> _onChangeThemeColor(
      ChangeThemeColor event, Emitter<ThemeState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_colorKey, event.colorIndex);
    emit(ThemeState(
      themeData:
          _buildTheme(state.isDarkMode, event.colorIndex, state.fontFamily),
      isDarkMode: state.isDarkMode,
      colorIndex: event.colorIndex,
      fontFamily: state.fontFamily,
    ));
  }

  Future<void> _onChangeFontStyle(
      ChangeFontStyle event, Emitter<ThemeState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fontKey, event.fontFamily);
    emit(ThemeState(
      themeData:
          _buildTheme(state.isDarkMode, state.colorIndex, event.fontFamily),
      isDarkMode: state.isDarkMode,
      colorIndex: state.colorIndex,
      fontFamily: event.fontFamily,
    ));
  }

  ThemeData _buildTheme(bool isDark, int colorIndex, String fontFamily) {
    final safeIndex = colorIndex.clamp(0, themeColors.length - 1);
    final primaryColor = themeColors[safeIndex];

    if (isDark) {
      return DarkCoquetteTheme.darkTheme(
        primaryOverride: primaryColor,
        fontFamily: fontFamily,
      );
    } else {
      return CoquetteTheme.lightTheme(
        primaryOverride: primaryColor,
        fontFamily: fontFamily,
      );
    }
  }
}
