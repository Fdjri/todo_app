import 'package:shared_preferences/shared_preferences.dart';

abstract class SettingsLocalDataSource {
  bool getDailyReminders();
  Future<void> saveDailyReminders(bool value);
  
  bool getUrgentAlarms();
  Future<void> saveUrgentAlarms(bool value);
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  final SharedPreferences sharedPreferences;
  
  static const _keyDailyReminders = 'key_daily_reminders';
  static const _keyUrgentAlarms = 'key_urgent_alarms';

  SettingsLocalDataSourceImpl(this.sharedPreferences);

  @override
  bool getDailyReminders() {
    return sharedPreferences.getBool(_keyDailyReminders) ?? true;
  }

  @override
  Future<void> saveDailyReminders(bool value) async {
    await sharedPreferences.setBool(_keyDailyReminders, value);
  }

  @override
  bool getUrgentAlarms() {
    return sharedPreferences.getBool(_keyUrgentAlarms) ?? true;
  }

  @override
  Future<void> saveUrgentAlarms(bool value) async {
    await sharedPreferences.setBool(_keyUrgentAlarms, value);
  }
}
