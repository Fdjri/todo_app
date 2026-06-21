import 'dart:convert';
import '../../domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.emoji,
    required super.colorValue,
    super.isDefault,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      emoji: json['emoji'] as String,
      colorValue: json['colorValue'] as int,
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'emoji': emoji,
      'colorValue': colorValue,
      'isDefault': isDefault,
    };
  }

  factory CategoryModel.fromEntity(CategoryEntity entity) {
    return CategoryModel(
      id: entity.id,
      name: entity.name,
      emoji: entity.emoji,
      colorValue: entity.colorValue,
      isDefault: entity.isDefault,
    );
  }

  static String encodeList(List<CategoryModel> categories) {
    return jsonEncode(categories.map((c) => c.toJson()).toList());
  }

  static List<CategoryModel> decodeList(String source) {
    final list = jsonDecode(source) as List<dynamic>;
    return list.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
