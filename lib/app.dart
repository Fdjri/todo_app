import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'injection_container.dart';
import 'main.dart' show navigatorKey;
import 'core/theme/theme_bloc.dart';
import 'core/theme/shadcn_theme.dart';
import 'core/widgets/permission_onboarding_dialog.dart';
import 'features/task/presentation/bloc/task_bloc.dart';
import 'features/category/presentation/bloc/category_bloc.dart';
import 'features/gamification/presentation/bloc/gamification_bloc.dart';
import 'features/alarm/presentation/pages/alarm_page.dart';
import 'features/settings/presentation/cubit/settings_cubit.dart';
import 'features/calendar/presentation/cubit/calendar_cubit.dart';
import 'core/widgets/main_shell.dart';

class WorkaholicApp extends StatefulWidget {
  /// If the app was cold-started by tapping an alarm notification,
  /// these fields carry the task info to show AlarmPage immediately.
  final String? coldStartAlarmTaskId;
  final String? coldStartAlarmTitle;

  const WorkaholicApp({
    super.key,
    this.coldStartAlarmTaskId,
    this.coldStartAlarmTitle,
  });

  @override
  State<WorkaholicApp> createState() => _WorkaholicAppState();
}

class _WorkaholicAppState extends State<WorkaholicApp> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<ThemeBloc>()..add(LoadTheme())),
        BlocProvider(create: (_) => sl<TaskBloc>()..add(LoadTasks())),
        BlocProvider(create: (_) => sl<CategoryBloc>()..add(LoadCategories())),
        BlocProvider(create: (_) => sl<GamificationBloc>()..add(LoadStats())),
        BlocProvider(create: (_) => sl<SettingsCubit>()),
        BlocProvider(create: (_) => sl<CalendarCubit>()),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          final isDark = themeState.isDarkMode;
          final currentTheme = themeState.themeData;
          final primaryColor = currentTheme.colorScheme.primary;
          final primaryContainer = currentTheme.colorScheme.primaryContainer;
          final secondaryContainer = currentTheme.colorScheme.secondaryContainer;
          final scaffoldBg = currentTheme.scaffoldBackgroundColor;
          final surface = currentTheme.colorScheme.surface;
          final textPrimary = currentTheme.colorScheme.onSurface;
          final textHint = currentTheme.hintColor;

          final shadcnScheme = isDark
              ? shadcn.ColorSchemes.darkZinc.copyWith(
                  primary: () => primaryColor,
                  primaryForeground: () => Colors.white,
                  background: () => scaffoldBg,
                  foreground: () => textPrimary,
                  card: () => surface,
                  cardForeground: () => textPrimary,
                  popover: () => surface,
                  popoverForeground: () => textPrimary,
                  border: () => primaryContainer,
                  input: () => primaryContainer,
                  secondary: () => secondaryContainer,
                  secondaryForeground: () => textPrimary,
                  muted: () => secondaryContainer,
                  mutedForeground: () => textHint,
                  accent: () => primaryContainer,
                  accentForeground: () => textPrimary,
                )
              : shadcn.ColorSchemes.lightZinc.copyWith(
                  primary: () => primaryColor,
                  primaryForeground: () => Colors.white,
                  background: () => scaffoldBg,
                  foreground: () => textPrimary,
                  card: () => surface,
                  cardForeground: () => textPrimary,
                  popover: () => surface,
                  popoverForeground: () => textPrimary,
                  border: () => primaryContainer,
                  input: () => primaryContainer,
                  secondary: () => secondaryContainer,
                  secondaryForeground: () => textPrimary,
                  muted: () => secondaryContainer,
                  mutedForeground: () => textHint,
                  accent: () => primaryContainer,
                  accentForeground: () => textPrimary,
                );

          return shadcn.ShadcnApp(
            title: 'Workaholic',
            debugShowCheckedModeBanner: false,
            // shadcn theme (for shadcn components)
            theme: isDark
                ? ShadcnCoquetteTheme.dark(colorSchemeOverride: shadcnScheme)
                : ShadcnCoquetteTheme.light(colorSchemeOverride: shadcnScheme),
            // Material theme (for backward-compat with Material widgets)
            materialTheme: currentTheme,
            navigatorKey: navigatorKey,
            builder: (context, child) {
              return shadcn.ComponentTheme<shadcn.SwitchTheme>(
                data: shadcn.SwitchTheme(
                  inactiveThumbColor: currentTheme.hintColor,
                  inactiveColor: currentTheme.colorScheme.secondaryContainer,
                ),
                child: child!,
              );
            },
            home: _AppHome(
              coldStartAlarmTaskId: widget.coldStartAlarmTaskId,
              coldStartAlarmTitle: widget.coldStartAlarmTitle,
            ),
          );
        },
      ),
    );
  }
}

class _AppHome extends StatefulWidget {
  final String? coldStartAlarmTaskId;
  final String? coldStartAlarmTitle;

  const _AppHome({
    this.coldStartAlarmTaskId,
    this.coldStartAlarmTitle,
  });

  @override
  State<_AppHome> createState() => _AppHomeState();
}

class _AppHomeState extends State<_AppHome> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _postInit();
    });
  }

  Future<void> _postInit() async {
    FlutterNativeSplash.remove();
    if (!mounted) return;

    // Show permission onboarding if first launch
    await PermissionOnboardingDialog.showIfNeeded(context);

    // If cold-started from an alarm notification, open AlarmPage
    if (widget.coldStartAlarmTaskId != null &&
        widget.coldStartAlarmTitle != null) {
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          settings: const RouteSettings(name: '/alarm'),
          builder: (_) => AlarmPage(
            taskId: widget.coldStartAlarmTaskId!,
            taskTitle: widget.coldStartAlarmTitle!,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => const MainShell();
}
