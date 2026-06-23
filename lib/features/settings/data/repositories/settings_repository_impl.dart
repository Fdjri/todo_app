import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_datasource.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource localDataSource;

  SettingsRepositoryImpl(this.localDataSource);

  @override
  bool getDailyReminders() {
    return localDataSource.getDailyReminders();
  }

  @override
  Future<void> saveDailyReminders(bool value) async {
    await localDataSource.saveDailyReminders(value);
  }

  @override
  bool getUrgentAlarms() {
    return localDataSource.getUrgentAlarms();
  }

  @override
  Future<void> saveUrgentAlarms(bool value) async {
    await localDataSource.saveUrgentAlarms(value);
  }
}
