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

// ─── States ───
class ThemeState extends Equatable {
  final ThemeData themeData;
  final bool isDarkMode;

  const ThemeState({required this.themeData, required this.isDarkMode});

  @override
  List<Object?> get props => [isDarkMode];
}

// ─── BLoC ───
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  static const String _themeKey = 'is_dark_mode';

  ThemeBloc()
      : super(ThemeState(
          themeData: CoquetteTheme.lightTheme,
          isDarkMode: false,
        )) {
    on<LoadTheme>(_onLoadTheme);
    on<ToggleTheme>(_onToggleTheme);
  }

  Future<void> _onLoadTheme(LoadTheme event, Emitter<ThemeState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_themeKey) ?? false;
    emit(ThemeState(
      themeData: isDark ? DarkCoquetteTheme.darkTheme : CoquetteTheme.lightTheme,
      isDarkMode: isDark,
    ));
  }

  Future<void> _onToggleTheme(ToggleTheme event, Emitter<ThemeState> emit) async {
    final newIsDark = !state.isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, newIsDark);
    emit(ThemeState(
      themeData: newIsDark ? DarkCoquetteTheme.darkTheme : CoquetteTheme.lightTheme,
      isDarkMode: newIsDark,
    ));
  }
}
