import 'package:flutter/material.dart';
import '../../domain/entities/task_entity.dart';
import 'task_card_widget.dart';
import '../../../category/domain/entities/category_entity.dart';

/// Scrollable task list that renders TaskCardWidgets with slide animations
class TaskListWidget extends StatelessWidget {
  final List<TaskEntity> tasks;
  final List<CategoryEntity> categories;
  final void Function(String taskId) onToggle;
  final void Function(String taskId) onDelete;
  final void Function(TaskEntity task) onTap;

  const TaskListWidget({
    super.key,
    required this.tasks,
    required this.categories,
    required this.onToggle,
    required this.onDelete,
    required this.onTap,
  });

  CategoryEntity? _findCategory(String categoryId) {
    try {
      return categories.firstWhere((c) => c.id == categoryId);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Dismissible(
            key: Key(task.id),
            direction: DismissDirection.endToStart,
            onDismissed: (_) => onDelete(task.id),
            background: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: Icon(Icons.delete_rounded,
                  color: theme.colorScheme.error, size: 28),
            ),
            child: TaskCardWidget(
              task: task,
              category: _findCategory(task.categoryId),
              onToggle: (_) => onToggle(task.id),
              onTap: () => onTap(task),
            ),
          ),
        );
      },
    );
  }
}
