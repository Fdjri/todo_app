import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/services/sound_service.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/bow_divider.dart';
import '../../../../core/widgets/pearl_checkbox.dart';
import '../../../../injection_container.dart';
import '../../../category/domain/entities/category_entity.dart';
import '../../../category/presentation/bloc/category_bloc.dart';
import '../../../gamification/presentation/bloc/gamification_bloc.dart';
import '../../domain/entities/task_entity.dart';
import '../bloc/task_bloc.dart';

class TaskDetailPage extends StatelessWidget {
  final TaskEntity task;

  const TaskDetailPage({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, taskState) {
        // Find the latest version of this task
        TaskEntity currentTask = task;
        if (taskState is TaskLoaded) {
          currentTask = taskState.allTasks
                  .where((t) => t.id == task.id)
                  .firstOrNull ??
              task;
        }

        // Get category
        final catState = context.read<CategoryBloc>().state;
        CategoryEntity? category;
        if (catState is CategoryLoaded) {
          category = catState.categories
              .where((c) => c.id == currentTask.categoryId)
              .firstOrNull;
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('Task Details',
                style: AppTypography.h2(color: theme.colorScheme.primary)),
            actions: [
              // shadcn Button.ghost variant destructive for delete
              shadcn.Button.ghost(
                onPressed: () => _showDeleteDialog(context, currentTask),
                child: Icon(Icons.delete_rounded,
                    color: theme.colorScheme.error),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Title + Completion ───
                Row(
                  children: [
                    PearlCheckbox(
                      isChecked: currentTask.isCompleted,
                      size: 32,
                      onChanged: (_) {
                        context
                            .read<TaskBloc>()
                            .add(ToggleTaskCompletion(currentTask.id));
                        if (!currentTask.isCompleted) {
                          context
                              .read<GamificationBloc>()
                              .add(TaskCompleted());
                          sl<SoundService>().playTaskComplete();
                        }
                      },
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        currentTask.title,
                        style: currentTask.isCompleted
                            ? AppTypography.h1(
                                    color: theme.textTheme.bodySmall?.color)
                                .copyWith(
                                    decoration: TextDecoration.lineThrough)
                            : AppTypography.h1(
                                color: theme.colorScheme.onSurface),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // ─── Category + Priority ───
                Row(
                  children: [
                    if (category != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Color(category.colorValue).withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${category.emoji} ${category.name}',
                          style: AppTypography.small(
                              color: theme.colorScheme.onSurface),
                        ),
                      ),
                    const SizedBox(width: 8),
                    _buildPriorityBadge(currentTask.priority, theme),
                  ],
                ),

                const BowDivider(),

                // ─── Description ───
                if (currentTask.description != null &&
                    currentTask.description!.isNotEmpty) ...[
                  Text('Description',
                      style: AppTypography.bodyBold(
                          color: theme.colorScheme.onSurface)),
                  const SizedBox(height: 8),
                  Text(
                    currentTask.description!,
                    style: AppTypography.body(
                        color: theme.textTheme.bodyMedium?.color),
                  ),
                  const SizedBox(height: 16),
                ],

                // ─── Due Date ───
                if (currentTask.dueDate != null) ...[
                  _buildInfoRow(
                    icon: Icons.calendar_today_rounded,
                    label: 'Due',
                    value: DateFormatter.formatDateTime(currentTask.dueDate!),
                    isOverdue: DateFormatter.isOverdue(currentTask.dueDate) &&
                        !currentTask.isCompleted,
                    theme: theme,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                ],

                // ─── Created ───
                _buildInfoRow(
                  icon: Icons.access_time_rounded,
                  label: 'Created',
                  value: DateFormatter.formatDateTime(currentTask.createdAt),
                  theme: theme,
                  isDark: isDark,
                ),

                if (currentTask.completedAt != null) ...[
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    icon: Icons.check_circle_rounded,
                    label: 'Completed',
                    value:
                        DateFormatter.formatDateTime(currentTask.completedAt!),
                    theme: theme,
                    isDark: isDark,
                  ),
                ],

                // ─── Sub-tasks ───
                if (currentTask.subTasks.isNotEmpty) ...[
                  const BowDivider(),
                  Text(
                    'Sub-tasks (${currentTask.subTasks.where((s) => s.isCompleted).length}/${currentTask.subTasks.length})',
                    style: AppTypography.h3(
                        color: theme.colorScheme.onSurface),
                  ),
                  const SizedBox(height: 8),

                  // Progress bar — shadcn LinearProgressIndicator
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: shadcn.LinearProgressIndicator(
                      value: currentTask.subTaskProgress,
                    ),
                  ),
                  const SizedBox(height: 12),

                  ...currentTask.subTasks.map((sub) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          PearlCheckbox(
                            isChecked: sub.isCompleted,
                            size: 20,
                            onChanged: (_) {
                              context.read<TaskBloc>().add(
                                    ToggleSubtaskCompletion(
                                        currentTask.id, sub.id),
                                  );
                              if (!sub.isCompleted) {
                                context
                                    .read<GamificationBloc>()
                                    .add(SubtaskCompleted());
                              }
                            },
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              sub.title,
                              style: sub.isCompleted
                                  ? AppTypography.body(
                                          color: theme
                                              .textTheme.bodySmall?.color)
                                      .copyWith(
                                          decoration:
                                              TextDecoration.lineThrough)
                                  : AppTypography.body(
                                      color: theme.colorScheme.onSurface),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPriorityBadge(TaskPriority priority, ThemeData theme) {
    Color bgColor;
    String label;
    switch (priority) {
      case TaskPriority.low:
        bgColor = AppColors.priorityLow;
        label = '💚 Low';
        break;
      case TaskPriority.medium:
        bgColor = AppColors.priorityMedium;
        label = '💛 Medium';
        break;
      case TaskPriority.high:
        bgColor = AppColors.priorityHigh;
        label = '🧡 High';
        break;
      case TaskPriority.urgent:
        bgColor = AppColors.priorityUrgent;
        label = '❤️ Urgent';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTypography.small(color: theme.colorScheme.onSurface),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
    required bool isDark,
    bool isOverdue = false,
  }) {
    return Row(
      children: [
        Icon(icon,
            size: 18,
            color: isOverdue
                ? (isDark ? AppColors.warningDark : AppColors.warningLight)
                : theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text('$label: ',
            style: AppTypography.bodyBold(
                color: theme.colorScheme.onSurface)),
        Expanded(
          child: Text(
            value,
            style: AppTypography.body(
              color: isOverdue
                  ? (isDark ? AppColors.warningDark : const Color(0xFFBF6A1E))
                  : theme.textTheme.bodyMedium?.color,
            ),
          ),
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context, TaskEntity task) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        return AlertDialog(
          title: Text('Delete Task',
              style: AppTypography.h2(color: theme.colorScheme.onSurface)),
          content: Text(
            'Are you sure you want to delete "${task.title}"?',
            style: AppTypography.body(color: theme.textTheme.bodyMedium?.color),
          ),
          actions: [
            // shadcn Button.outline for cancel
            shadcn.Button.outline(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel',
                  style: AppTypography.bodyBold(
                      color: theme.colorScheme.onSurface)),
            ),
            // shadcn Button.destructive for delete
            shadcn.Button.destructive(
              onPressed: () {
                context.read<TaskBloc>().add(DeleteTask(task.id));
                sl<SoundService>().playDelete();
                Navigator.pop(dialogContext);
                Navigator.pop(context);
              },
              child: Text('Delete',
                  style: AppTypography.bodyBold(
                      color: theme.colorScheme.onError)),
            ),
          ],
        );
      },
    );
  }
}
