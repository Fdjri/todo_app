import 'dart:convert';
import '../../domain/entities/task_entity.dart';

class TaskModel extends TaskEntity {
  const TaskModel({
    required super.id,
    required super.title,
    super.description,
    required super.categoryId,
    super.priority,
    super.dueDate,
    super.isCompleted,
    required super.createdAt,
    super.completedAt,
    super.subTasks,
    super.hasAlarm,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      categoryId: json['categoryId'] as String? ?? 'all',
      priority: TaskPriority.values[json['priority'] as int? ?? 1],
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      isCompleted: json['isCompleted'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      subTasks: (json['subTasks'] as List<dynamic>?)
              ?.map((e) => SubTaskModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      hasAlarm: json['hasAlarm'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'categoryId': categoryId,
      'priority': priority.index,
      'dueDate': dueDate?.toIso8601String(),
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'subTasks': subTasks.map((e) => SubTaskModel.fromEntity(e).toJson()).toList(),
      'hasAlarm': hasAlarm,
    };
  }

  factory TaskModel.fromEntity(TaskEntity entity) {
    return TaskModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      categoryId: entity.categoryId,
      priority: entity.priority,
      dueDate: entity.dueDate,
      isCompleted: entity.isCompleted,
      createdAt: entity.createdAt,
      completedAt: entity.completedAt,
      subTasks: entity.subTasks,
      hasAlarm: entity.hasAlarm,
    );
  }

  static String encodeList(List<TaskModel> tasks) {
    return jsonEncode(tasks.map((t) => t.toJson()).toList());
  }

  static List<TaskModel> decodeList(String source) {
    final list = jsonDecode(source) as List<dynamic>;
    return list.map((e) => TaskModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}

class SubTaskModel extends SubTaskEntity {
  const SubTaskModel({
    required super.id,
    required super.title,
    super.isCompleted,
    required super.order,
  });

  factory SubTaskModel.fromJson(Map<String, dynamic> json) {
    return SubTaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
      order: json['order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'order': order,
    };
  }

  factory SubTaskModel.fromEntity(SubTaskEntity entity) {
    return SubTaskModel(
      id: entity.id,
      title: entity.title,
      isCompleted: entity.isCompleted,
      order: entity.order,
    );
  }
}
