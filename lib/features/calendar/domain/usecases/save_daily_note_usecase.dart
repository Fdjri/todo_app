import '../repositories/calendar_repository.dart';

class SaveDailyNoteUseCase {
  final CalendarRepository repository;

  SaveDailyNoteUseCase(this.repository);

  Future<void> call(String dateKey, String note) {
    if (note.trim().isEmpty) {
      return repository.deleteDailyNote(dateKey);
    }
    return repository.saveDailyNote(dateKey, note.trim());
  }
}
