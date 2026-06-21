import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';

// ─── Events ───
abstract class TaskEvent extends Equatable {
  const TaskEvent();
  @override
  List<Object?> get props => [];
}

class LoadTasks extends TaskEvent {}

class FilterByCategory extends TaskEvent {
  final String categoryId;
  const FilterByCategory(this.categoryId);
  @override
  List<Object?> get props => [categoryId];
}

class AddTask extends TaskEvent {
  final TaskEntity task;
  const AddTask(this.task);
  @override
  List<Object?> get props => [task];
}

class UpdateTask extends TaskEvent {
  final TaskEntity task;
  const UpdateTask(this.task);
  @override
  List<Object?> get props => [task];
}

class DeleteTask extends TaskEvent {
  final String taskId;
  const DeleteTask(this.taskId);
  @override
  List<Object?> get props => [taskId];
}

class ToggleTaskCompletion extends TaskEvent {
  final String taskId;
  const ToggleTaskCompletion(this.taskId);
  @override
  List<Object?> get props => [taskId];
}

class ToggleSubtaskCompletion extends TaskEvent {
  final String taskId;
  final String subtaskId;
  const ToggleSubtaskCompletion(this.taskId, this.subtaskId);
  @override
  List<Object?> get props => [taskId, subtaskId];
}

// ─── States ───
abstract class TaskState extends Equatable {
  const TaskState();
  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskLoaded extends TaskState {
  final List<TaskEntity> tasks;
  final List<TaskEntity> allTasks;
  final String activeCategoryId;
  final String? lastCompletedTaskId;

  const TaskLoaded({
    required this.tasks,
    required this.allTasks,
    this.activeCategoryId = 'all',
    this.lastCompletedTaskId,
  });

  int get completedCount => allTasks.where((t) => t.isCompleted).length;
  int get totalCount => allTasks.length;
  double get completionProgress =>
      totalCount > 0 ? completedCount / totalCount : 0.0;

  TaskLoaded copyWith({
    List<TaskEntity>? tasks,
    List<TaskEntity>? allTasks,
    String? activeCategoryId,
    String? lastCompletedTaskId,
  }) {
    return TaskLoaded(
      tasks: tasks ?? this.tasks,
      allTasks: allTasks ?? this.allTasks,
      activeCategoryId: activeCategoryId ?? this.activeCategoryId,
      lastCompletedTaskId: lastCompletedTaskId,
    );
  }

  @override
  List<Object?> get props => [tasks, allTasks, activeCategoryId, lastCompletedTaskId];
}

class TaskError extends TaskState {
  final String message;
  const TaskError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─── BLoC ───
class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository repository;

  TaskBloc({required this.repository}) : super(TaskInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<FilterByCategory>(_onFilterByCategory);
    on<AddTask>(_onAddTask);
    on<UpdateTask>(_onUpdateTask);
    on<DeleteTask>(_onDeleteTask);
    on<ToggleTaskCompletion>(_onToggleTaskCompletion);
    on<ToggleSubtaskCompletion>(_onToggleSubtaskCompletion);
  }

  Future<void> _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      final allTasks = await repository.getAllTasks();
      emit(TaskLoaded(tasks: allTasks, allTasks: allTasks));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onFilterByCategory(
      FilterByCategory event, Emitter<TaskState> emit) async {
    try {
      final allTasks = await repository.getAllTasks();
      final filtered = await repository.getTasksByCategory(event.categoryId);
      emit(TaskLoaded(
        tasks: filtered,
        allTasks: allTasks,
        activeCategoryId: event.categoryId,
      ));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onAddTask(AddTask event, Emitter<TaskState> emit) async {
    try {
      await repository.addTask(event.task);
      add(LoadTasks());
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onUpdateTask(UpdateTask event, Emitter<TaskState> emit) async {
    try {
      await repository.updateTask(event.task);
      if (state is TaskLoaded) {
        add(FilterByCategory((state as TaskLoaded).activeCategoryId));
      } else {
        add(LoadTasks());
      }
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    try {
      await repository.deleteTask(event.taskId);
      if (state is TaskLoaded) {
        add(FilterByCategory((state as TaskLoaded).activeCategoryId));
      } else {
        add(LoadTasks());
      }
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onToggleTaskCompletion(
      ToggleTaskCompletion event, Emitter<TaskState> emit) async {
    try {
      final updated = await repository.toggleTaskCompletion(event.taskId);
      final allTasks = await repository.getAllTasks();
      final currentState = state;
      if (currentState is TaskLoaded) {
        final filtered =
            await repository.getTasksByCategory(currentState.activeCategoryId);
        emit(TaskLoaded(
          tasks: filtered,
          allTasks: allTasks,
          activeCategoryId: currentState.activeCategoryId,
          lastCompletedTaskId: updated.isCompleted ? event.taskId : null,
        ));
      }
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onToggleSubtaskCompletion(
      ToggleSubtaskCompletion event, Emitter<TaskState> emit) async {
    try {
      await repository.toggleSubtaskCompletion(event.taskId, event.subtaskId);
      final allTasks = await repository.getAllTasks();
      final currentState = state;
      if (currentState is TaskLoaded) {
        final filtered =
            await repository.getTasksByCategory(currentState.activeCategoryId);
        emit(TaskLoaded(
          tasks: filtered,
          allTasks: allTasks,
          activeCategoryId: currentState.activeCategoryId,
        ));
      }
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }
}
