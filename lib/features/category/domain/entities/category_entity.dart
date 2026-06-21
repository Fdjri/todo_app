import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final String emoji;
  final int colorValue;
  final bool isDefault;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.emoji,
    required this.colorValue,
    this.isDefault = false,
  });

  CategoryEntity copyWith({
    String? id,
    String? name,
    String? emoji,
    int? colorValue,
    bool? isDefault,
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      colorValue: colorValue ?? this.colorValue,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  @override
  List<Object?> get props => [id, name, emoji, colorValue, isDefault];

  /// Pre-defined default categories
  static const List<CategoryEntity> defaults = [
    CategoryEntity(id: 'self_care', name: 'Self Care', emoji: '🧖', colorValue: 0xFFF5D5E0, isDefault: true),
    CategoryEntity(id: 'work', name: 'Work', emoji: '💼', colorValue: 0xFFD4C5F9, isDefault: true),
    CategoryEntity(id: 'study', name: 'Study', emoji: '📚', colorValue: 0xFFB8CCE3, isDefault: true),
    CategoryEntity(id: 'errands', name: 'Errands', emoji: '🛒', colorValue: 0xFFFFD4A8, isDefault: true),
    CategoryEntity(id: 'social', name: 'Social', emoji: '👯', colorValue: 0xFFFFB3BA, isDefault: true),
    CategoryEntity(id: 'health', name: 'Health', emoji: '🏃‍♀️', colorValue: 0xFFA8D8B9, isDefault: true),
    CategoryEntity(id: 'creative', name: 'Creative', emoji: '🎨', colorValue: 0xFFF9E4B7, isDefault: true),
    CategoryEntity(id: 'home', name: 'Home', emoji: '🏠', colorValue: 0xFFC9DCD2, isDefault: true),
  ];
}
