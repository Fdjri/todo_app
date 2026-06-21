import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'injection_container.dart';
import 'core/theme/theme_bloc.dart';
import 'features/task/presentation/bloc/task_bloc.dart';
import 'features/category/presentation/bloc/category_bloc.dart';
import 'features/gamification/presentation/bloc/gamification_bloc.dart';
import 'features/task/presentation/pages/home_page.dart';

class WorkaholicApp extends StatelessWidget {
  const WorkaholicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<ThemeBloc>()..add(LoadTheme())),
        BlocProvider(create: (_) => sl<TaskBloc>()..add(LoadTasks())),
        BlocProvider(create: (_) => sl<CategoryBloc>()..add(LoadCategories())),
        BlocProvider(create: (_) => sl<GamificationBloc>()..add(LoadStats())),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            title: 'Workaholic',
            debugShowCheckedModeBanner: false,
            theme: themeState.themeData,
            home: const HomePage(),
          );
        },
      ),
    );
  }
}
