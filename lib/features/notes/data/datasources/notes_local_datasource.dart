import 'package:shared_preferences/shared_preferences.dart';
import '../models/note_model.dart';

class NotesLocalDataSource {
  static const String _notesKey = 'notes_data';
  final SharedPreferences _prefs;

  NotesLocalDataSource(this._prefs);

  Future<List<NoteModel>> getAllNotes() async {
    final jsonStr = _prefs.getString(_notesKey);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final list = NoteModel.decodeList(jsonStr);
      // Sort by creation date descending (newest first)
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    } catch (_) {
      return [];
    }
  }

  Future<void> saveNotes(List<NoteModel> notes) async {
    await _prefs.setString(_notesKey, NoteModel.encodeList(notes));
  }

  Future<void> addNote(NoteModel note) async {
    final notes = await getAllNotes();
    notes.add(note);
    await saveNotes(notes);
  }

  Future<void> updateNote(NoteModel note) async {
    final notes = await getAllNotes();
    final index = notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      notes[index] = note;
      await saveNotes(notes);
    }
  }

  Future<void> deleteNote(String noteId) async {
    final notes = await getAllNotes();
    notes.removeWhere((n) => n.id == noteId);
    await saveNotes(notes);
  }
}
