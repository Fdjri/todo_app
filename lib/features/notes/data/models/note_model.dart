import 'dart:convert';
import '../../domain/entities/note_entity.dart';

class NoteModel extends NoteEntity {
  const NoteModel({
    required super.id,
    required super.title,
    required super.content,
    required super.mood,
    required super.createdAt,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      mood: json['mood'] as String? ?? 'happy',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'mood': mood,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory NoteModel.fromEntity(NoteEntity entity) {
    return NoteModel(
      id: entity.id,
      title: entity.title,
      content: entity.content,
      mood: entity.mood,
      createdAt: entity.createdAt,
    );
  }

  static String encodeList(List<NoteModel> notes) {
    return jsonEncode(notes.map((n) => n.toJson()).toList());
  }

  static List<NoteModel> decodeList(String source) {
    final list = jsonDecode(source) as List<dynamic>;
    return list.map((e) => NoteModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
