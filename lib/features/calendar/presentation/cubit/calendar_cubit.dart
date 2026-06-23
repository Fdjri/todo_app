import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_daily_note_usecase.dart';
import '../../domain/usecases/save_daily_note_usecase.dart';

class CalendarState {
  final Map<String, String> dailyNotes;
  final bool isLoading;

  CalendarState({
    required this.dailyNotes,
    this.isLoading = false,
  });

  CalendarState copyWith({
    Map<String, String>? dailyNotes,
    bool? isLoading,
  }) {
    return CalendarState(
      dailyNotes: dailyNotes ?? this.dailyNotes,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class CalendarCubit extends Cubit<CalendarState> {
  final GetDailyNoteUseCase getDailyNoteUseCase;
  final SaveDailyNoteUseCase saveDailyNoteUseCase;

  CalendarCubit({
    required this.getDailyNoteUseCase,
    required this.saveDailyNoteUseCase,
  }) : super(CalendarState(dailyNotes: {}));

  void loadNote(String dateKey) {
    final note = getDailyNoteUseCase(dateKey);
    final updatedNotes = Map<String, String>.from(state.dailyNotes);
    if (note != null) {
      updatedNotes[dateKey] = note;
    } else {
      updatedNotes.remove(dateKey);
    }
    emit(state.copyWith(dailyNotes: updatedNotes));
  }

  Future<void> saveNote(String dateKey, String note) async {
    emit(state.copyWith(isLoading: true));
    await saveDailyNoteUseCase(dateKey, note);
    final updatedNotes = Map<String, String>.from(state.dailyNotes);
    if (note.trim().isNotEmpty) {
      updatedNotes[dateKey] = note.trim();
    } else {
      updatedNotes.remove(dateKey);
    }
    emit(state.copyWith(dailyNotes: updatedNotes, isLoading: false));
  }
}
