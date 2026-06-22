import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/date_formatter.dart';
import '../../features/task/domain/entities/task_entity.dart';
import '../../features/task/presentation/bloc/task_bloc.dart';
import '../../features/category/domain/entities/category_entity.dart';
import '../../features/category/presentation/bloc/category_bloc.dart';
import '../../features/gamification/presentation/bloc/gamification_bloc.dart';
import '../../features/gamification/domain/entities/user_stats_entity.dart';

/// History page — scrollable calendar showing past months up to current month.
/// Tapping a date reveals the tasks for that day in a bottom sheet.
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  DateTime? _selectedDate;

  // Build list of months from app epoch to today (no future months)
  List<DateTime> _buildMonths() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month);
    // Show up to 12 past months + current
    const maxMonths = 12;
    final months = <DateTime>[];
    for (int i = maxMonths - 1; i >= 0; i--) {
      final m = DateTime(today.year, today.month - i);
      months.add(DateTime(m.year, m.month));
    }
    return months;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final months = _buildMonths();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, isDark),
            Expanded(
              child: BlocBuilder<TaskBloc, TaskState>(
                builder: (context, taskState) {
                  final allTasks = taskState is TaskLoaded ? taskState.allTasks : <TaskEntity>[];
                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 100),
                    itemCount: months.length,
                    itemBuilder: (context, index) {
                      return _MonthCalendar(
                        month: months[index],
                        allTasks: allTasks,
                        selectedDate: _selectedDate,
                        onDateTap: (date) {
                          setState(() => _selectedDate = date);
                          _showDayDetail(context, date, allTasks);
                        },
                        isDark: isDark,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final primaryDarker = HSLColor.fromColor(primary)
        .withLightness((HSLColor.fromColor(primary).lightness - 0.15).clamp(0.0, 1.0))
        .toColor();

    return BlocBuilder<GamificationBloc, GamificationState>(
      builder: (context, gamState) {
        final stats = gamState is GamificationLoaded
            ? gamState.stats
            : const UserStatsEntity();
        final streak = stats.currentStreak;

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            children: [
              // Avatar circle
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [primary, primaryDarker],
                  ),
                ),
                child: const Center(
                  child: Text('👸', style: TextStyle(fontSize: 20)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Hey, queen! 👑',
                  style: AppTypography.h2(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              // Streak badge
              if (streak > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: theme.colorScheme.primaryContainer,
                  ),
                  child: Text(
                    '$streak 🔥',
                    style: AppTypography.bodyBold(
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showDayDetail(
    BuildContext context,
    DateTime date,
    List<TaskEntity> allTasks,
  ) {
    final dayTasks = allTasks.where((t) {
      if (t.dueDate == null && t.completedAt == null) return false;
      final ref = t.completedAt ?? t.dueDate!;
      return ref.year == date.year &&
          ref.month == date.month &&
          ref.day == date.day;
    }).toList();

    shadcn.openDrawer(
      context: context,
      position: shadcn.OverlayPosition.bottom,
      builder: (ctx) => BlocBuilder<CategoryBloc, CategoryState>(
        builder: (ctx, catState) {
          final categories =
              catState is CategoryLoaded ? catState.categories : <CategoryEntity>[];
          return _DayDetailSheet(
            date: date,
            tasks: dayTasks,
            categories: categories,
          );
        },
      ),
    );
  }
}

// ─── Month Calendar Grid ───────────────────────────────────────────────────

class _MonthCalendar extends StatelessWidget {
  final DateTime month;
  final List<TaskEntity> allTasks;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateTap;
  final bool isDark;

  const _MonthCalendar({
    required this.month,
    required this.allTasks,
    required this.selectedDate,
    required this.onDateTap,
    required this.isDark,
  });

  bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  bool _isFuture(DateTime d) {
    final today = DateTime.now();
    return d.isAfter(DateTime(today.year, today.month, today.day));
  }

  bool _isSelected(DateTime d) =>
      selectedDate != null &&
      d.year == selectedDate!.year &&
      d.month == selectedDate!.month &&
      d.day == selectedDate!.day;

  /// Count tasks on a given day (by dueDate or completedAt)
  int _taskCount(DateTime d) {
    return allTasks.where((t) {
      final ref = t.completedAt ?? t.dueDate;
      if (ref == null) return false;
      return ref.year == d.year && ref.month == d.month && ref.day == d.day;
    }).length;
  }

  bool _hasCompletedTask(DateTime d) {
    return allTasks.any((t) {
      if (!t.isCompleted) return false;
      final ref = t.completedAt ?? t.dueDate;
      if (ref == null) return false;
      return ref.year == d.year && ref.month == d.month && ref.day == d.day;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final textPrimary = theme.colorScheme.onSurface;
    final textHint = theme.hintColor;

    // First day of month
    final firstDay = DateTime(month.year, month.month, 1);
    // Days in month
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    // Weekday offset (Mon=0)
    final startOffset = (firstDay.weekday - 1) % 7;

    final weekLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Month title
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              DateFormatter.formatMonthYear(month),
              style: AppTypography.h1(color: textPrimary),
            ),
          ),

          // Week header
          Row(
            children: weekLabels.map((label) {
              return Expanded(
                child: Center(
                  child: Text(
                    label,
                    style: AppTypography.small(color: textHint),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),

          // Calendar grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
              mainAxisSpacing: 4,
              crossAxisSpacing: 2,
            ),
            itemCount: startOffset + daysInMonth,
            itemBuilder: (context, index) {
              if (index < startOffset) return const SizedBox.shrink();

              final day = index - startOffset + 1;
              final date = DateTime(month.year, month.month, day);
              final isFuture = _isFuture(date);
              final isToday = _isToday(date);
              final isSelected = _isSelected(date);
              final taskCount = _taskCount(date);
              final hasCompleted = _hasCompletedTask(date);

              return GestureDetector(
                onTap: isFuture ? null : () => onDateTap(date),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? primary
                        : isToday
                            ? primary.withValues(alpha: 0.25)
                            : taskCount > 0
                                ? (hasCompleted
                                    ? AppColors.successLight.withValues(alpha: isDark ? 0.25 : 0.45)
                                    : primary.withValues(alpha: 0.14))
                                : Colors.transparent,
                    border: isToday && !isSelected
                        ? Border.all(color: primary, width: 1.5)
                        : null,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: primary.withValues(alpha: isDark ? 0.45 : 0.30),
                              blurRadius: isDark ? 10 : 6,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        '$day',
                        style: AppTypography.small(
                          color: isFuture
                              ? textHint.withValues(alpha: 0.35)
                              : isSelected
                                  ? Colors.white
                                  : isToday
                                      ? primary
                                      : textPrimary,
                        ),
                      ),
                      // Dot indicator for tasks
                      if (taskCount > 0 && !isSelected)
                        Positioned(
                          bottom: 3,
                          child: Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: hasCompleted
                                  ? AppColors.successDark
                                  : primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 8),
          // Subtle divider
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  primary.withValues(alpha: 0.25),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Day Detail Bottom Sheet ───────────────────────────────────────────────

class _DayDetailSheet extends StatelessWidget {
  final DateTime date;
  final List<TaskEntity> tasks;
  final List<CategoryEntity> categories;

  const _DayDetailSheet({
    required this.date,
    required this.tasks,
    required this.categories,
  });

  CategoryEntity? _findCategory(String id) {
    try {
      return categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final textPrimary = theme.colorScheme.onSurface;
    final textBody = theme.textTheme.bodyMedium?.color ?? Colors.black;
    final surface = theme.colorScheme.surface;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 16),

          // Date header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.calendar_today_rounded,
                      color: primary, size: 20),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormatter.formatFullDate(date),
                      style: AppTypography.h2(color: textPrimary),
                    ),
                    Text(
                      '${tasks.length} task${tasks.length != 1 ? 's' : ''}',
                      style: AppTypography.caption(color: textBody),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Tasks list
          Flexible(
            child: tasks.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('🎀', style: const TextStyle(fontSize: 48)),
                        const SizedBox(height: 12),
                        Text(
                          'No tasks this day, bestie!',
                          style: AppTypography.quote(color: textBody),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      final cat = _findCategory(task.categoryId);
                      return _TaskHistoryTile(
                        task: task,
                        category: cat,
                        isDark: isDark,
                        primary: primary,
                        textPrimary: textPrimary,
                        textBody: textBody,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _TaskHistoryTile extends StatelessWidget {
  final TaskEntity task;
  final CategoryEntity? category;
  final bool isDark;
  final Color primary;
  final Color textPrimary;
  final Color textBody;

  const _TaskHistoryTile({
    required this.task,
    required this.category,
    required this.isDark,
    required this.primary,
    required this.textPrimary,
    required this.textBody,
  });

  Color get _priorityColor {
    switch (task.priority) {
      case TaskPriority.low:
        return AppColors.priorityLow;
      case TaskPriority.medium:
        return AppColors.priorityMedium;
      case TaskPriority.high:
        return AppColors.priorityHigh;
      case TaskPriority.urgent:
        return AppColors.priorityUrgent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.colorScheme.secondaryContainer;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: task.isCompleted
              ? AppColors.successLight.withValues(alpha: 0.5)
              : primary.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Status dot
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: task.isCompleted ? AppColors.successDark : _priorityColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: task.isCompleted
                      ? AppTypography.body(color: textBody).copyWith(
                          decoration: TextDecoration.lineThrough,
                          color: textBody.withValues(alpha: 0.6),
                        )
                      : AppTypography.body(color: textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (category != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${category!.emoji} ${category!.name}',
                    style: AppTypography.small(
                      color: textBody.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Completed badge
          if (task.isCompleted)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.successLight.withValues(alpha: isDark ? 0.2 : 0.4),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '✓ Done',
                style: AppTypography.small(
                  color: isDark ? AppColors.successDark : const Color(0xFF2E7D52),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
