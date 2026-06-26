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

import 'features/settings/data/datasources/settings_local_datasource.dart';
import 'features/settings/data/repositories/settings_repository_impl.dart';
import 'features/settings/domain/repositories/settings_repository.dart';
import 'features/settings/domain/usecases/get_settings_usecase.dart';
import 'features/settings/domain/usecases/save_settings_usecase.dart';
import 'features/settings/presentation/cubit/settings_cubit.dart';

import 'features/calendar/data/datasources/calendar_local_datasource.dart';
import 'features/calendar/data/repositories/calendar_repository_impl.dart';
import 'features/calendar/domain/repositories/calendar_repository.dart';
import 'features/calendar/domain/usecases/get_daily_note_usecase.dart';
import 'features/calendar/domain/usecases/save_daily_note_usecase.dart';
import 'features/calendar/presentation/cubit/calendar_cubit.dart';

import 'features/notes/data/datasources/notes_local_datasource.dart';
import 'features/notes/data/repositories/notes_repository_impl.dart';
import 'features/notes/domain/repositories/notes_repository.dart';
import 'features/notes/presentation/bloc/notes_bloc.dart';

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

  // ─── Settings Feature ───
  sl.registerLazySingleton<SettingsLocalDataSource>(
      () => SettingsLocalDataSourceImpl(sl()));
  sl.registerLazySingleton<SettingsRepository>(
      () => SettingsRepositoryImpl(sl()));
  sl.registerLazySingleton(() => GetSettingsUseCase(sl()));
  sl.registerLazySingleton(() => SaveSettingsUseCase(sl()));
  sl.registerFactory(() => SettingsCubit(getSettings: sl(), saveSettings: sl()));

  // ─── Calendar Feature ───
  sl.registerLazySingleton<CalendarLocalDataSource>(
      () => CalendarLocalDataSourceImpl(sl()));
  sl.registerLazySingleton<CalendarRepository>(
      () => CalendarRepositoryImpl(sl()));
  sl.registerLazySingleton(() => GetDailyNoteUseCase(sl()));
  sl.registerLazySingleton(() => SaveDailyNoteUseCase(sl()));
  sl.registerFactory(() => CalendarCubit(getDailyNoteUseCase: sl(), saveDailyNoteUseCase: sl()));

  // ─── Notes Feature ───
  sl.registerLazySingleton(() => NotesLocalDataSource(sl()));
  sl.registerLazySingleton<NotesRepository>(
      () => NotesRepositoryImpl(sl()));
  sl.registerFactory(() => NotesBloc(repository: sl()));
}
