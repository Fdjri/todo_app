import '../../domain/repositories/calendar_repository.dart';
import '../datasources/calendar_local_datasource.dart';

class CalendarRepositoryImpl implements CalendarRepository {
  final CalendarLocalDataSource localDataSource;

  CalendarRepositoryImpl(this.localDataSource);

  @override
  String? getDailyNote(String dateKey) {
    return localDataSource.getDailyNote(dateKey);
  }

  @override
  Future<void> saveDailyNote(String dateKey, String note) async {
    await localDataSource.saveDailyNote(dateKey, note);
  }

  @override
  Future<void> deleteDailyNote(String dateKey) async {
    await localDataSource.deleteDailyNote(dateKey);
  }
}
