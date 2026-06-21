import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_local_datasource.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalDataSource localDataSource;

  TaskRepositoryImpl(this.localDataSource);

  @override
  Future<List<TaskEntity>> getAllTasks() async {
    return await localDataSource.getAllTasks();
  }

  @override
  Future<List<TaskEntity>> getTasksByCategory(String categoryId) async {
    final tasks = await localDataSource.getAllTasks();
    if (categoryId == 'all') return tasks;
    return tasks.where((t) => t.categoryId == categoryId).toList();
  }

  @override
  Future<void> addTask(TaskEntity task) async {
    await localDataSource.addTask(TaskModel.fromEntity(task));
  }

  @override
  Future<void> updateTask(TaskEntity task) async {
    await localDataSource.updateTask(TaskModel.fromEntity(task));
  }

  @override
  Future<void> deleteTask(String taskId) async {
    await localDataSource.deleteTask(taskId);
  }

  @override
  Future<TaskEntity> toggleTaskCompletion(String taskId) async {
    final tasks = await localDataSource.getAllTasks();
    final index = tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) throw Exception('Task not found');

    final task = tasks[index];
    final updated = TaskModel.fromEntity(task.copyWith(
      isCompleted: !task.isCompleted,
      completedAt: !task.isCompleted ? DateTime.now() : null,
    ));
    tasks[index] = updated;
    await localDataSource.saveTasks(tasks);
    return updated;
  }

  @override
  Future<TaskEntity> toggleSubtaskCompletion(String taskId, String subtaskId) async {
    final tasks = await localDataSource.getAllTasks();
    final taskIndex = tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex == -1) throw Exception('Task not found');

    final task = tasks[taskIndex];
    final updatedSubtasks = task.subTasks.map((s) {
      if (s.id == subtaskId) {
        return s.copyWith(isCompleted: !s.isCompleted);
      }
      return s;
    }).toList();

    // Auto-complete parent if all subtasks done
    final allDone = updatedSubtasks.every((s) => s.isCompleted);
    final updated = TaskModel.fromEntity(task.copyWith(
      subTasks: updatedSubtasks,
      isCompleted: allDone && updatedSubtasks.isNotEmpty ? true : task.isCompleted,
      completedAt: allDone && updatedSubtasks.isNotEmpty ? DateTime.now() : task.completedAt,
    ));

    tasks[taskIndex] = updated;
    await localDataSource.saveTasks(tasks);
    return updated;
  }
}
