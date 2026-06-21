import '../../domain/entities/task_entity.dart';

/// Abstract repository interface for task operations
abstract class TaskRepository {
  Future<List<TaskEntity>> getAllTasks();
  Future<List<TaskEntity>> getTasksByCategory(String categoryId);
  Future<void> addTask(TaskEntity task);
  Future<void> updateTask(TaskEntity task);
  Future<void> deleteTask(String taskId);
  Future<TaskEntity> toggleTaskCompletion(String taskId);
  Future<TaskEntity> toggleSubtaskCompletion(String taskId, String subtaskId);
}
