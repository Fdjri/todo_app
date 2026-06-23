import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/id_generator.dart';
import '../../../../core/widgets/bow_divider.dart';
import '../../../category/domain/entities/category_entity.dart';
import '../../../category/presentation/bloc/category_bloc.dart';
import '../../domain/entities/task_entity.dart';
import '../bloc/task_bloc.dart';
import '../../../../core/widgets/shining_effect.dart';

class AddTaskPage extends StatefulWidget {
  final TaskEntity? taskToEdit;
  const AddTaskPage({super.key, this.taskToEdit});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _subtaskController = TextEditingController();

  String _selectedCategoryId = 'work';
  TaskPriority _selectedPriority = TaskPriority.medium;
  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  bool _hasAlarm = false;
  final List<SubTaskEntity> _subTasks = [];

  @override
  void initState() {
    super.initState();
    if (widget.taskToEdit != null) {
      final task = widget.taskToEdit!;
      _titleController.text = task.title;
      _descController.text = task.description ?? '';
      _selectedCategoryId = task.categoryId;
      _selectedPriority = task.priority;
      _hasAlarm = task.hasAlarm;
      _subTasks.addAll(task.subTasks);
      if (task.dueDate != null) {
        _dueDate = task.dueDate;
        _dueTime = TimeOfDay.fromDateTime(task.dueDate!);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _subtaskController.dispose();
    super.dispose();
  }

  void _addSubTask() {
    final text = _subtaskController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _subTasks.add(SubTaskEntity(
        id: IdGenerator.generate(),
        title: text,
        order: _subTasks.length,
      ));
      _subtaskController.clear();
    });
  }

  void _submit() {
    if (_titleController.text.trim().isEmpty) return;

    DateTime? fullDueDate;
    if (_dueDate != null) {
      final time = _dueTime ?? const TimeOfDay(hour: 23, minute: 59);
      fullDueDate = DateTime(
        _dueDate!.year,
        _dueDate!.month,
        _dueDate!.day,
        time.hour,
        time.minute,
      );
    }

    if (widget.taskToEdit != null) {
      final task = widget.taskToEdit!.copyWith(
        title: _titleController.text.trim(),
        description: _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
        categoryId: _selectedCategoryId,
        priority: _selectedPriority,
        dueDate: fullDueDate,
        subTasks: _subTasks,
        hasAlarm: _hasAlarm,
      );
      context.read<TaskBloc>().add(UpdateTask(task));
    } else {
      final task = TaskEntity(
        id: IdGenerator.generate(),
        title: _titleController.text.trim(),
        description: _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
        categoryId: _selectedCategoryId,
        priority: _selectedPriority,
        dueDate: fullDueDate,
        createdAt: DateTime.now(),
        subTasks: _subTasks,
        hasAlarm: _hasAlarm,
      );
      context.read<TaskBloc>().add(AddTask(task));
    }
    shadcn.closeOverlay(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.82,
      ),
      child: shadcn.OverlayManagerLayer(
        popoverHandler: shadcn.OverlayHandler.popover,
        menuHandler: shadcn.OverlayHandler.popover,
        tooltipHandler: shadcn.OverlayHandler.popover,
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            // Title
            Text(
              widget.taskToEdit != null ? '✨ Edit Task' : '✨ New Task',
              style: AppTypography.h1(color: theme.colorScheme.primary),
            ),

            const BowDivider(),
            const SizedBox(height: 8),

            // Title input
            Text('Title *',
                style: AppTypography.bodyBold(
                    color: theme.colorScheme.onSurface)),
            const SizedBox(height: 8),
            shadcn.TextField(
              controller: _titleController,
              placeholder: Text(AppStrings.quickAddHint),
              style: AppTypography.body(color: theme.colorScheme.onSurface),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),

            // Description input
            Text('Description',
                style: AppTypography.bodyBold(
                    color: theme.colorScheme.onSurface)),
            const SizedBox(height: 8),
            shadcn.TextField(
              controller: _descController,
              placeholder: Text(AppStrings.descriptionHint),
              style: AppTypography.body(color: theme.colorScheme.onSurface),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),

            // Category + Priority row
            Row(
              children: [
                // Category
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Category',
                          style: AppTypography.bodyBold(
                              color: theme.colorScheme.onSurface)),
                      const SizedBox(height: 8),
                      _buildCategoryDropdown(theme),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Priority
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Priority',
                          style: AppTypography.bodyBold(
                              color: theme.colorScheme.onSurface)),
                      const SizedBox(height: 8),
                      _buildPriorityDropdown(theme),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Date + Time row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Due Date',
                          style: AppTypography.bodyBold(
                              color: theme.colorScheme.onSurface)),
                      const SizedBox(height: 8),
                      _buildDatePicker(theme),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Due Time',
                          style: AppTypography.bodyBold(
                              color: theme.colorScheme.onSurface)),
                      const SizedBox(height: 8),
                      _buildTimePicker(theme),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Quick date shortcuts — shadcn Button.outline (toggle-like)
            Row(
              children: [
                _buildDateChip(AppStrings.today, DateTime.now(), theme),
                const SizedBox(width: 8),
                _buildDateChip(AppStrings.tomorrow,
                    DateTime.now().add(const Duration(days: 1)), theme),
                const SizedBox(width: 8),
                _buildDateChip(AppStrings.nextWeek,
                    DateTime.now().add(const Duration(days: 7)), theme),
              ],
            ),
            const SizedBox(height: 16),

            // Alarm toggle — shadcn Switch
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text('⏰ Alarm',
                        style: AppTypography.bodyBold(
                            color: theme.colorScheme.onSurface)),
                    const SizedBox(width: 8),
                    Text('(full-screen alert)',
                        style: AppTypography.caption(
                            color: theme.textTheme.bodySmall?.color)),
                  ],
                ),
                shadcn.Switch(
                  value: _hasAlarm,
                  onChanged: (v) => setState(() => _hasAlarm = v),
                ),
              ],
            ),
            const SizedBox(height: 16),

            const BowDivider(),
            const SizedBox(height: 8),

            // Sub-tasks header
            Text('Sub-tasks',
                style: AppTypography.bodyBold(
                    color: theme.colorScheme.onSurface)),
            const SizedBox(height: 12),

            // List of existing sub-tasks
            if (_subTasks.isNotEmpty) ...[
              ..._subTasks.map((s) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(Icons.subdirectory_arrow_right_rounded,
                          size: 16, color: theme.colorScheme.outline),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(s.title,
                            style: AppTypography.body(
                                color: theme.colorScheme.onSurface)),
                      ),
                      shadcn.Button(
                        style: const shadcn.ButtonStyle.ghost(
                          size: shadcn.ButtonSize.xSmall,
                        ),
                        onPressed: () {
                          setState(() => _subTasks.remove(s));
                        },
                        child: Icon(Icons.close_rounded,
                            size: 16, color: theme.colorScheme.error),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 12),
            ],

            // Input to add new sub-task
            Row(
              children: [
                Expanded(
                  child: shadcn.TextField(
                    controller: _subtaskController,
                    placeholder: const Text('+ Add sub-task'),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    style:
                        AppTypography.body(color: theme.colorScheme.onSurface),
                    onSubmitted: (_) => _addSubTask(),
                  ),
                ),
                // shadcn Button.ghost for add
                shadcn.Button.ghost(
                  onPressed: _addSubTask,
                  child: Icon(Icons.add_circle_rounded,
                      color: theme.colorScheme.primary),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Submit button — shadcn Button.primary
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ShiningBorder(
                child: shadcn.Button.primary(
                  onPressed: _submit,
                  alignment: Alignment.center,
                  child: Text(
                    widget.taskToEdit != null ? '✨ Save Task ✨' : '✨ Add Task ✨',
                    style: AppTypography.h3(color: theme.colorScheme.onPrimary),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown(ThemeData theme) {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        final categories = (state is CategoryLoaded
                ? state.categories
                : CategoryEntity.defaults)
            .cast<CategoryEntity>();

        final selectedCat = categories.firstWhere((cat) => cat.id == _selectedCategoryId, orElse: () => categories.first);

        return shadcn.Select<String>(
          value: _selectedCategoryId,
          onChanged: (v) {
            if (v != null) setState(() => _selectedCategoryId = v);
          },
          popupWidthConstraint: shadcn.PopoverConstraint.flexible,
          popupConstraints: const BoxConstraints(
            minWidth: 120,
            maxWidth: 160,
          ),
          itemBuilder: (context, val) {
            final cat = categories.firstWhere((c) => c.id == val, orElse: () => selectedCat);
            return Text('${cat.emoji} ${cat.name}',
                style: AppTypography.body(color: theme.colorScheme.onSurface));
          },
          popup: (context) {
            return shadcn.SelectPopup(
              items: shadcn.SelectItemList(
                children: categories.map((cat) {
                  return shadcn.SelectItemButton(
                    value: cat.id,
                    child: Text('${cat.emoji} ${cat.name}',
                        style: AppTypography.body(color: theme.colorScheme.onSurface)),
                  );
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPriorityDropdown(ThemeData theme) {
    final priorities = {
      TaskPriority.low: '💚 Low',
      TaskPriority.medium: '💛 Medium',
      TaskPriority.high: '🧡 High',
      TaskPriority.urgent: '❤️ Urgent',
    };

    return shadcn.Select<TaskPriority>(
      value: _selectedPriority,
      onChanged: (v) {
        if (v != null) setState(() => _selectedPriority = v);
      },
      popupWidthConstraint: shadcn.PopoverConstraint.flexible,
      popupConstraints: const BoxConstraints(
        minWidth: 120,
        maxWidth: 160,
      ),
      itemBuilder: (context, val) {
        return Text(priorities[val] ?? '',
            style: AppTypography.body(color: theme.colorScheme.onSurface));
      },
      popup: (context) {
        return shadcn.SelectPopup(
          items: shadcn.SelectItemList(
            children: priorities.entries.map((e) {
              return shadcn.SelectItemButton(
                value: e.key,
                child: Text(e.value,
                    style: AppTypography.body(color: theme.colorScheme.onSurface)),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildDatePicker(ThemeData theme) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _dueDate ?? DateTime.now(),
          firstDate: DateTime.now().subtract(const Duration(days: 1)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) setState(() => _dueDate = date);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Text('📅 ', style: const TextStyle(fontSize: 16)),
            Text(
              _dueDate != null
                  ? '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'
                  : 'Select',
              style: AppTypography.body(color: theme.colorScheme.onSurface),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker(ThemeData theme) {
    return InkWell(
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: _dueTime ?? TimeOfDay.now(),
        );
        if (time != null) setState(() => _dueTime = time);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Text('🕐 ', style: const TextStyle(fontSize: 16)),
            Text(
              _dueTime != null
                  ? _dueTime!.format(context)
                  : 'Select',
              style: AppTypography.body(color: theme.colorScheme.onSurface),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateChip(String label, DateTime date, ThemeData theme) {
    final isSelected = _dueDate != null &&
        _dueDate!.year == date.year &&
        _dueDate!.month == date.month &&
        _dueDate!.day == date.day;

    // Use shadcn Button with toggle-like styling
    return isSelected
        ? shadcn.Button(
            style: const shadcn.ButtonStyle.primary(
              size: shadcn.ButtonSize.small,
            ),
            onPressed: () => setState(() => _dueDate = date),
            child: Text(label),
          )
        : shadcn.Button(
            style: const shadcn.ButtonStyle.outline(
              size: shadcn.ButtonSize.small,
            ),
            onPressed: () => setState(() => _dueDate = date),
            child: Text(label),
          );
  }
}
