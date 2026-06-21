import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/task/data/datasources/task_local_datasource.dart';
import 'features/task/data/repositories/task_repository_impl.dart';
import 'features/task/domain/repositories/task_repository.dart';
import 'features/task/presentation/bloc/task_bloc.dart';

import 'features/category/data/datasources/category_local_datasource.dart';
import 'features/category/data/repositories/category_repository_impl.dart';
import 'features/category/presentation/bloc/category_bloc.dart';

import 'features/gamification/data/datasources/gamification_local_datasource.dart';
import 'features/gamification/presentation/bloc/gamification_bloc.dart';

import 'core/theme/theme_bloc.dart';
import 'core/services/sound_service.dart';
import 'core/services/alarm_service.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ─── External ───
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => prefs);

  // ─── Services ───
  sl.registerLazySingleton(() => SoundService());
  sl.registerLazySingleton(() => AlarmService());

  // ─── Theme ───
  sl.registerFactory(() => ThemeBloc());

  // ─── Task Feature ───
  sl.registerLazySingleton(() => TaskLocalDataSource(sl()));
  sl.registerLazySingleton<TaskRepository>(
      () => TaskRepositoryImpl(sl()));
  sl.registerFactory(() => TaskBloc(repository: sl()));

  // ─── Category Feature ───
  sl.registerLazySingleton(() => CategoryLocalDataSource(sl()));
  sl.registerLazySingleton(
      () => CategoryRepositoryImpl(sl<CategoryLocalDataSource>()));
  sl.registerFactory(() => CategoryBloc(repository: sl<CategoryRepositoryImpl>()));

  // ─── Gamification Feature ───
  sl.registerLazySingleton(() => GamificationLocalDataSource(sl()));
  sl.registerFactory(() => GamificationBloc(dataSource: sl()));
}
