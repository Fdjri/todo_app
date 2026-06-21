import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/coquette_card.dart';
import '../../../../core/widgets/pearl_checkbox.dart';
import '../../../category/domain/entities/category_entity.dart';
import '../../domain/entities/task_entity.dart';

/// Reusable task card widget with checkbox, title, category, priority, and subtask progress
class TaskCardWidget extends StatelessWidget {
  final TaskEntity task;
  final CategoryEntity? category;
  final ValueChanged<bool>? onToggle;
  final VoidCallback? onTap;

  const TaskCardWidget({
    super.key,
    required this.task,
    this.category,
    this.onToggle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isOverdue = DateFormatter.isOverdue(task.dueDate) && !task.isCompleted;

    return CoquetteCard(
      isCompleted: task.isCompleted,
      onTap: onTap,
      child: Row(
        children: [
          PearlCheckbox(
            isChecked: task.isCompleted,
            onChanged: (v) => onToggle?.call(v),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + category emoji
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        task.title,
                        style: task.isCompleted
                            ? AppTypography.h3(
                                    color: theme.textTheme.bodySmall?.color)
                                .copyWith(
                                    decoration: TextDecoration.lineThrough)
                            : AppTypography.h3(
                                color: theme.colorScheme.onSurface),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (category != null)
                      Text(category!.emoji,
                          style: const TextStyle(fontSize: 18)),
                  ],
                ),

                // Due date + priority
                if (task.dueDate != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isOverdue
                              ? (isDark
                                  ? AppColors.warningDark
                                      .withValues(alpha: 0.2)
                                  : AppColors.warningLight
                                      .withValues(alpha: 0.5))
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          DateFormatter.formatDate(task.dueDate!),
                          style: AppTypography.small(
                            color: isOverdue
                                ? (isDark
                                    ? AppColors.warningDark
                                    : const Color(0xFFBF6A1E))
                                : theme.textTheme.bodySmall?.color,
                          ),
                        ),
                      ),
                      const Spacer(),
                      _buildPriorityDot(task.priority),
                    ],
                  ),
                ],

                // Subtask progress
                if (task.subTasks.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: task.subTaskProgress,
                            minHeight: 4,
                            backgroundColor: isDark
                                ? AppColors.blushDark
                                : AppColors.blushLight,
                            valueColor: AlwaysStoppedAnimation(
                                theme.colorScheme.primary),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${task.subTasks.where((s) => s.isCompleted).length}/${task.subTasks.length}',
                        style: AppTypography.small(
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityDot(TaskPriority priority) {
    Color color;
    switch (priority) {
      case TaskPriority.low:
        color = AppColors.priorityLow;
      case TaskPriority.medium:
        color = AppColors.priorityMedium;
      case TaskPriority.high:
        color = AppColors.priorityHigh;
      case TaskPriority.urgent:
        color = AppColors.priorityUrgent;
    }

    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
