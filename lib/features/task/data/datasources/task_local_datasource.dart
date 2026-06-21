import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_model.dart';

/// SharedPreferences CRUD operations for tasks
class TaskLocalDataSource {
  static const String _tasksKey = 'tasks_data';
  final SharedPreferences _prefs;

  TaskLocalDataSource(this._prefs);

  Future<List<TaskModel>> getAllTasks() async {
    final jsonStr = _prefs.getString(_tasksKey);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    return TaskModel.decodeList(jsonStr);
  }

  Future<void> saveTasks(List<TaskModel> tasks) async {
    await _prefs.setString(_tasksKey, TaskModel.encodeList(tasks));
  }

  Future<void> addTask(TaskModel task) async {
    final tasks = await getAllTasks();
    tasks.add(task);
    await saveTasks(tasks);
  }

  Future<void> updateTask(TaskModel task) async {
    final tasks = await getAllTasks();
    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      tasks[index] = task;
      await saveTasks(tasks);
    }
  }

  Future<void> deleteTask(String taskId) async {
    final tasks = await getAllTasks();
    tasks.removeWhere((t) => t.id == taskId);
    await saveTasks(tasks);
  }
}
