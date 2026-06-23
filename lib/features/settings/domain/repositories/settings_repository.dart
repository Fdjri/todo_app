abstract class SettingsRepository {
  bool getDailyReminders();
  Future<void> saveDailyReminders(bool value);
  
  bool getUrgentAlarms();
  Future<void> saveUrgentAlarms(bool value);
}
