import 'package:shared_preferences/shared_preferences.dart';

abstract class CalendarLocalDataSource {
  String? getDailyNote(String dateKey);
  Future<void> saveDailyNote(String dateKey, String note);
  Future<void> deleteDailyNote(String dateKey);
}

class CalendarLocalDataSourceImpl implements CalendarLocalDataSource {
  final SharedPreferences sharedPreferences;

  CalendarLocalDataSourceImpl(this.sharedPreferences);

  @override
  String? getDailyNote(String dateKey) {
    return sharedPreferences.getString('note_date_$dateKey');
  }

  @override
  Future<void> saveDailyNote(String dateKey, String note) async {
    await sharedPreferences.setString('note_date_$dateKey', note);
  }

  @override
  Future<void> deleteDailyNote(String dateKey) async {
    await sharedPreferences.remove('note_date_$dateKey');
  }
}
