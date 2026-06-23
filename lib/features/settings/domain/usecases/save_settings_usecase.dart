import '../repositories/settings_repository.dart';

class SaveSettingsUseCase {
  final SettingsRepository repository;

  SaveSettingsUseCase(this.repository);

  Future<void> saveDailyReminders(bool value) => repository.saveDailyReminders(value);
  Future<void> saveUrgentAlarms(bool value) => repository.saveUrgentAlarms(value);
}
