import 'package:equatable/equatable.dart';

class NoteEntity extends Equatable {
  final String id;
  final String title;
  final String content;
  final String mood; // 'dreamy', 'happy', 'peaceful', 'tired', 'sparkly'
  final DateTime createdAt;

  const NoteEntity({
    required this.id,
    required this.title,
    required this.content,
    required this.mood,
    required this.createdAt,
  });

  NoteEntity copyWith({
    String? id,
    String? title,
    String? content,
    String? mood,
    DateTime? createdAt,
  }) {
    return NoteEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      mood: mood ?? this.mood,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, title, content, mood, createdAt];
}
