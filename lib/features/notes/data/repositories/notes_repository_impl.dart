import '../../domain/entities/note_entity.dart';
import '../../domain/repositories/notes_repository.dart';
import '../datasources/notes_local_datasource.dart';
import '../models/note_model.dart';

class NotesRepositoryImpl implements NotesRepository {
  final NotesLocalDataSource _localDataSource;

  NotesRepositoryImpl(this._localDataSource);

  @override
  Future<List<NoteEntity>> getAllNotes() async {
    return await _localDataSource.getAllNotes();
  }

  @override
  Future<void> addNote(NoteEntity note) async {
    await _localDataSource.addNote(NoteModel.fromEntity(note));
  }

  @override
  Future<void> updateNote(NoteEntity note) async {
    await _localDataSource.updateNote(NoteModel.fromEntity(note));
  }

  @override
  Future<void> deleteNote(String noteId) async {
    await _localDataSource.deleteNote(noteId);
  }
}
