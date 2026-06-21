import 'package:equatable/equatable.dart';

enum TaskPriority { low, medium, high, urgent }

class TaskEntity extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String categoryId;
  final TaskPriority priority;
  final DateTime? dueDate;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;
  final List<SubTaskEntity> subTasks;
  final bool hasAlarm;

  const TaskEntity({
    required this.id,
    required this.title,
    this.description,
    required this.categoryId,
    this.priority = TaskPriority.medium,
    this.dueDate,
    this.isCompleted = false,
    required this.createdAt,
    this.completedAt,
    this.subTasks = const [],
    this.hasAlarm = false,
  });

  TaskEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? categoryId,
    TaskPriority? priority,
    DateTime? dueDate,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
    List<SubTaskEntity>? subTasks,
    bool? hasAlarm,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      subTasks: subTasks ?? this.subTasks,
      hasAlarm: hasAlarm ?? this.hasAlarm,
    );
  }

  /// Calculate subtask completion progress (0.0 to 1.0)
  double get subTaskProgress {
    if (subTasks.isEmpty) return isCompleted ? 1.0 : 0.0;
    final completed = subTasks.where((s) => s.isCompleted).length;
    return completed / subTasks.length;
  }

  @override
  List<Object?> get props => [
        id, title, description, categoryId, priority,
        dueDate, isCompleted, createdAt, completedAt,
        subTasks, hasAlarm,
      ];
}

class SubTaskEntity extends Equatable {
  final String id;
  final String title;
  final bool isCompleted;
  final int order;

  const SubTaskEntity({
    required this.id,
    required this.title,
    this.isCompleted = false,
    required this.order,
  });

  SubTaskEntity copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    int? order,
  }) {
    return SubTaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      order: order ?? this.order,
    );
  }

  @override
  List<Object?> get props => [id, title, isCompleted, order];
}
