import '../repositories/calendar_repository.dart';

class GetDailyNoteUseCase {
  final CalendarRepository repository;

  GetDailyNoteUseCase(this.repository);

  String? call(String dateKey) => repository.getDailyNote(dateKey);
}
