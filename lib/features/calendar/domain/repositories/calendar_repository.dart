abstract class CalendarRepository {
  String? getDailyNote(String dateKey);
  Future<void> saveDailyNote(String dateKey, String note);
  Future<void> deleteDailyNote(String dateKey);
}
