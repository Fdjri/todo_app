import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/id_generator.dart';
import '../../../../core/widgets/bow_divider.dart';
import '../../../category/domain/entities/category_entity.dart';
import '../../../category/presentation/bloc/category_bloc.dart';
import '../../domain/entities/task_entity.dart';
import '../bloc/task_bloc.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

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
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outline,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                '✨ New Task',
                style: AppTypography.h1(color: theme.colorScheme.primary),
              ),

              const BowDivider(),
              const SizedBox(height: 8),

              // Title input
              Text('Title *',
                  style: AppTypography.bodyBold(
                      color: theme.colorScheme.onSurface)),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: AppStrings.quickAddHint,
                ),
                style: AppTypography.body(color: theme.colorScheme.onSurface),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),

              // Description
              Text('Description',
                  style: AppTypography.bodyBold(
                      color: theme.colorScheme.onSurface)),
              const SizedBox(height: 8),
              TextField(
                controller: _descController,
                decoration: InputDecoration(
                  hintText: AppStrings.descriptionHint,
                ),
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

              // Quick date shortcuts
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

              // Alarm toggle
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
                  Switch(
                    value: _hasAlarm,
                    onChanged: (v) => setState(() => _hasAlarm = v),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Sub-tasks
              Text('Sub-tasks',
                  style: AppTypography.bodyBold(
                      color: theme.colorScheme.onSurface)),
              const SizedBox(height: 8),
              ..._subTasks.map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Icon(Icons.circle_outlined,
                            size: 16, color: theme.colorScheme.outline),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(s.title,
                              style: AppTypography.body(
                                  color: theme.colorScheme.onSurface)),
                        ),
                        IconButton(
                          icon: Icon(Icons.close,
                              size: 16, color: theme.colorScheme.error),
                          onPressed: () {
                            setState(() => _subTasks.remove(s));
                          },
                        ),
                      ],
                    ),
                  )),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _subtaskController,
                      decoration: const InputDecoration(
                        hintText: '+ Add sub-task',
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      style:
                          AppTypography.body(color: theme.colorScheme.onSurface),
                      onSubmitted: (_) => _addSubTask(),
                    ),
                  ),
                  IconButton(
                    onPressed: _addSubTask,
                    icon: Icon(Icons.add_circle_rounded,
                        color: theme.colorScheme.primary),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    '✨ Add Task ✨',
                    style: AppTypography.h3(color: theme.colorScheme.onPrimary),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryDropdown(ThemeData theme) {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        final categories =
            state is CategoryLoaded ? state.categories : CategoryEntity.defaults;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outline),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCategoryId,
              isExpanded: true,
              dropdownColor: theme.cardTheme.color,
              items: categories.map((cat) {
                return DropdownMenuItem(
                  value: cat.id,
                  child: Text('${cat.emoji} ${cat.name}',
                      style: AppTypography.body(
                          color: theme.colorScheme.onSurface)),
                );
              }).toList(),
              onChanged: (v) {
                if (v != null) setState(() => _selectedCategoryId = v);
              },
            ),
          ),
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<TaskPriority>(
          value: _selectedPriority,
          isExpanded: true,
          dropdownColor: theme.cardTheme.color,
          items: priorities.entries.map((e) {
            return DropdownMenuItem(
              value: e.key,
              child: Text(e.value,
                  style:
                      AppTypography.body(color: theme.colorScheme.onSurface)),
            );
          }).toList(),
          onChanged: (v) {
            if (v != null) setState(() => _selectedPriority = v);
          },
        ),
      ),
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

    return ActionChip(
      label: Text(label),
      onPressed: () => setState(() => _dueDate = date),
      backgroundColor:
          isSelected ? theme.colorScheme.primary : theme.colorScheme.surface,
      labelStyle: AppTypography.small(
        color: isSelected
            ? theme.colorScheme.onPrimary
            : theme.colorScheme.onSurface,
      ),
    );
  }
}
