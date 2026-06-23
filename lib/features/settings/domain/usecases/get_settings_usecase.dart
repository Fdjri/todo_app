import '../repositories/settings_repository.dart';

class GetSettingsUseCase {
  final SettingsRepository repository;

  GetSettingsUseCase(this.repository);

  bool getDailyReminders() => repository.getDailyReminders();
  bool getUrgentAlarms() => repository.getUrgentAlarms();
}
