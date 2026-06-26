import '../entities/note_entity.dart';

abstract class NotesRepository {
  Future<List<NoteEntity>> getAllNotes();
  Future<void> addNote(NoteEntity note);
  Future<void> updateNote(NoteEntity note);
  Future<void> deleteNote(String noteId);
}
