import 'package:flutter/material.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/pearl_checkbox.dart';
import '../../domain/entities/task_entity.dart';

/// Sub-task item with pearl checkbox, strikethrough on completion
class SubTaskItemWidget extends StatelessWidget {
  final SubTaskEntity subTask;
  final ValueChanged<bool>? onToggle;
  final VoidCallback? onDelete;

  const SubTaskItemWidget({
    super.key,
    required this.subTask,
    this.onToggle,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          PearlCheckbox(
            isChecked: subTask.isCompleted,
            size: 20,
            onChanged: (v) => onToggle?.call(v),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              subTask.title,
              style: subTask.isCompleted
                  ? AppTypography.body(
                          color: theme.textTheme.bodySmall?.color)
                      .copyWith(decoration: TextDecoration.lineThrough)
                  : AppTypography.body(
                      color: theme.colorScheme.onSurface),
            ),
          ),
          if (onDelete != null)
            IconButton(
              onPressed: onDelete,
              icon: Icon(
                Icons.close_rounded,
                size: 16,
                color: theme.textTheme.bodySmall?.color,
              ),
              iconSize: 16,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            ),
        ],
      ),
    );
  }
}
