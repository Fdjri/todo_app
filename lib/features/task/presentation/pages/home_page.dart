import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/services/sound_service.dart';
import '../../../../core/theme/theme_bloc.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/bow_divider.dart';
import '../../../../core/widgets/coquette_card.dart';
import '../../../../core/widgets/confetti_overlay.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/pearl_checkbox.dart';
import '../../../../core/widgets/progress_ring.dart';
import '../../../../injection_container.dart';
import '../../../category/domain/entities/category_entity.dart';
import '../../../category/presentation/bloc/category_bloc.dart';
import '../../../gamification/domain/entities/user_stats_entity.dart';
import '../../../gamification/presentation/bloc/gamification_bloc.dart';
import '../../domain/entities/task_entity.dart';
import '../bloc/task_bloc.dart';
import 'add_task_page.dart';
import 'task_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  bool _showConfetti = false;
  late AnimationController _fabController;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  void _onTaskComplete(String taskId) {
    context.read<TaskBloc>().add(ToggleTaskCompletion(taskId));
    context.read<GamificationBloc>().add(TaskCompleted());
    context.read<GamificationBloc>().add(UpdateStreak());
    sl<SoundService>().playTaskComplete();
    setState(() => _showConfetti = true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: CustomScrollView(
              slivers: [
                // ─── Header ───
                SliverToBoxAdapter(child: _buildHeader(theme, isDark)),

                // ─── Bow Divider ───
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: BowDivider(),
                  ),
                ),

                // ─── Category Filter ───
                SliverToBoxAdapter(child: _buildCategoryFilter(theme)),

                // ─── Task List ───
                _buildTaskList(theme),

                const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
              ],
            ),
          ),

          // ─── Confetti Overlay ───
          ConfettiOverlay(
            play: _showConfetti,
            onComplete: () => setState(() => _showConfetti = false),
          ),
        ],
      ),

      // ─── FAB with bow ───
      floatingActionButton: _buildFAB(theme),

      // ─── Bottom Nav ───
      bottomNavigationBar: _buildBottomNav(theme),
    );
  }

  Widget _buildHeader(ThemeData theme, bool isDark) {
    return BlocBuilder<GamificationBloc, GamificationState>(
      builder: (context, gamState) {
        final stats = gamState is GamificationLoaded
            ? gamState.stats
            : const UserStatsEntity();

        // Show level-up animation
        if (gamState is GamificationLoaded && gamState.justLeveledUp) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            sl<SoundService>().playLevelUp();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Level up! You\'re now ${stats.level.title}! 🎉',
                  style: AppTypography.bodyBold(color: Colors.white),
                ),
                backgroundColor: isDark
                    ? AppColors.goldAccentDark
                    : AppColors.goldAccentLight,
                behavior: SnackBarBehavior.floating,
              ),
            );
          });
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Top row: greeting + dark mode toggle ───
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.randomGreeting,
                          style: AppTypography.display(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormatter.formatDayHeader(DateTime.now()),
                          style: AppTypography.caption(
                            color: theme.textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Streak counter
                  _buildStreakBadge(stats, theme),
                ],
              ),
              const SizedBox(height: 16),

              // ─── Progress + Level row ───
              Row(
                children: [
                  // Progress ring
                  BlocBuilder<TaskBloc, TaskState>(
                    builder: (context, taskState) {
                      final progress = taskState is TaskLoaded
                          ? taskState.completionProgress
                          : 0.0;
                      final percent = (progress * 100).toInt();

                      return ProgressRing(
                        progress: progress,
                        size: 70,
                        strokeWidth: 6,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$percent%',
                              style: AppTypography.bodyBold(
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              '✨',
                              style: const TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 16),

                  // Level info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stats.level.title,
                          style: AppTypography.h3(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // XP Progress bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: stats.xpProgress,
                            minHeight: 8,
                            backgroundColor: isDark
                                ? AppColors.blushDark
                                : AppColors.blushLight,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isDark
                                  ? AppColors.goldAccentDark
                                  : AppColors.goldAccentLight,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${stats.xp}/${stats.level.xpForNextLevel} XP',
                          style: AppTypography.small(
                            color: theme.textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Dark mode toggle
                  IconButton(
                    onPressed: () {
                      context.read<ThemeBloc>().add(ToggleTheme());
                    },
                    icon: Icon(
                      isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStreakBadge(UserStatsEntity stats, ThemeData theme) {
    final streak = stats.currentStreak;
    String fire = '';
    if (streak >= 30) {
      fire = '🔥🔥🔥';
    } else if (streak >= 7) {
      fire = '🔥🔥';
    } else if (streak >= 1) {
      fire = '🔥';
    }

    if (streak == 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          'Start your streak! ✨',
          style: AppTypography.small(color: theme.colorScheme.secondary),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.secondary.withValues(alpha: 0.2),
            theme.colorScheme.secondary.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: theme.colorScheme.secondary.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        '$fire $streak days',
        style: AppTypography.bodyBold(
          color: theme.colorScheme.secondary,
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(ThemeData theme) {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, catState) {
        final categories = catState is CategoryLoaded ? catState.categories : [];

        return BlocBuilder<TaskBloc, TaskState>(
          builder: (context, taskState) {
            final activeId =
                taskState is TaskLoaded ? taskState.activeCategoryId : 'all';

            return SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // "All" chip
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: activeId == 'all',
                      label: Text('All ✨'),
                      onSelected: (_) {
                        context.read<TaskBloc>().add(
                            const FilterByCategory('all'));
                      },
                      selectedColor: theme.colorScheme.primary,
                      labelStyle: AppTypography.small(
                        color: activeId == 'all'
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurface,
                      ),
                      showCheckmark: false,
                    ),
                  ),
                  // Category chips
                  ...categories.map((cat) {
                    final isActive = activeId == cat.id;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: isActive,
                        label: Text('${cat.emoji} ${cat.name}'),
                        onSelected: (_) {
                          context.read<TaskBloc>().add(
                              FilterByCategory(cat.id));
                        },
                        selectedColor: Color(cat.colorValue),
                        labelStyle: AppTypography.small(
                          color: isActive
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurface,
                        ),
                        showCheckmark: false,
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTaskList(ThemeData theme) {
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        if (state is TaskLoading) {
          return SliverFillRemaining(
            child: Center(
              child: Lottie.asset(
                AppAssets.lottieLoadingBow,
                width: 80,
                height: 80,
              ),
            ),
          );
        }

        if (state is TaskLoaded) {
          if (state.tasks.isEmpty) {
            return SliverFillRemaining(
              child: EmptyStateWidget(
                onAddTask: () => _showAddTask(context),
              ),
            );
          }

          // Sort: incomplete first, then by due date
          final sorted = List<TaskEntity>.from(state.tasks)
            ..sort((a, b) {
              if (a.isCompleted != b.isCompleted) {
                return a.isCompleted ? 1 : -1;
              }
              if (a.dueDate != null && b.dueDate != null) {
                return a.dueDate!.compareTo(b.dueDate!);
              }
              return a.createdAt.compareTo(b.createdAt);
            });

          return SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final task = sorted[index];
                  return _buildTaskCard(context, task, theme);
                },
                childCount: sorted.length,
              ),
            ),
          );
        }

        if (state is TaskError) {
          return SliverFillRemaining(
            child: Center(
              child: Text('Oops! ${state.message}',
                  style: AppTypography.body(color: theme.colorScheme.error)),
            ),
          );
        }

        return const SliverFillRemaining(child: SizedBox.shrink());
      },
    );
  }

  Widget _buildTaskCard(BuildContext context, TaskEntity task, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final isOverdue = DateFormatter.isOverdue(task.dueDate) && !task.isCompleted;
    final isDueToday = DateFormatter.isDueToday(task.dueDate);

    // Get category info
    final catState = context.read<CategoryBloc>().state;
    CategoryEntity? category;
    if (catState is CategoryLoaded) {
      category = catState.categories.where((c) => c.id == task.categoryId).firstOrNull;
    }

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Swipe right to complete
          if (!task.isCompleted) {
            _onTaskComplete(task.id);
          }
          return false;
        } else {
          // Swipe left to delete
          sl<SoundService>().playDelete();
          context.read<TaskBloc>().add(DeleteTask(task.id));
          return true;
        }
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.successDark : AppColors.successLight,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Icon(Icons.check_rounded, color: Colors.white, size: 28),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.errorDark : AppColors.errorLight,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 28),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: CoquetteCard(
          isCompleted: task.isCompleted,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MultiBlocProvider(
                  providers: [
                    BlocProvider.value(value: context.read<TaskBloc>()),
                    BlocProvider.value(value: context.read<CategoryBloc>()),
                    BlocProvider.value(value: context.read<GamificationBloc>()),
                  ],
                  child: TaskDetailPage(task: task),
                ),
              ),
            );
          },
          child: Row(
            children: [
              // Checkbox
              PearlCheckbox(
                isChecked: task.isCompleted,
                onChanged: (_) {
                  if (!task.isCompleted) {
                    _onTaskComplete(task.id);
                  } else {
                    context.read<TaskBloc>().add(ToggleTaskCompletion(task.id));
                  }
                },
              ),
              const SizedBox(width: 12),

              // Task content
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
                                    color: theme.textTheme.bodySmall?.color,
                                  ).copyWith(
                                    decoration: TextDecoration.lineThrough,
                                  )
                                : AppTypography.h3(
                                    color: theme.colorScheme.onSurface,
                                  ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (category != null)
                          Text(category.emoji,
                              style: const TextStyle(fontSize: 18)),
                      ],
                    ),

                    // Due date + priority
                    if (task.dueDate != null || task.subTasks.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (task.dueDate != null) ...[
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
                                    : isDueToday
                                        ? (isDark
                                            ? AppColors.primaryDark
                                                .withValues(alpha: 0.2)
                                            : AppColors.primaryLight
                                                .withValues(alpha: 0.2))
                                        : Colors.transparent,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                DateFormatter.formatDateTime(task.dueDate!),
                                style: AppTypography.small(
                                  color: isOverdue
                                      ? (isDark
                                          ? AppColors.warningDark
                                          : const Color(0xFFBF6A1E))
                                      : theme.textTheme.bodySmall?.color,
                                ),
                              ),
                            ),
                          ],
                          const Spacer(),
                          // Priority indicator
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
        ),
      ),
    );
  }

  Widget _buildPriorityDot(TaskPriority priority) {
    Color color;
    String label;
    switch (priority) {
      case TaskPriority.low:
        color = AppColors.priorityLow;
        label = 'Low';
        break;
      case TaskPriority.medium:
        color = AppColors.priorityMedium;
        label = 'Med';
        break;
      case TaskPriority.high:
        color = AppColors.priorityHigh;
        label = 'High';
        break;
      case TaskPriority.urgent:
        color = AppColors.priorityUrgent;
        label = 'Urgent';
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTypography.small(color: color),
        ),
      ],
    );
  }

  Widget _buildFAB(ThemeData theme) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: FloatingActionButton(
            onPressed: () => _showAddTask(context),
            tooltip: AppStrings.fabTooltip,
            elevation: 8,
            child: const Icon(Icons.add_rounded, size: 28),
          ),
        );
      },
    );
  }

  void _showAddTask(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<TaskBloc>()),
          BlocProvider.value(value: context.read<CategoryBloc>()),
        ],
        child: const AddTaskPage(),
      ),
    );
  }

  Widget _buildBottomNav(ThemeData theme) {
    return BottomNavigationBar(
      currentIndex: 0,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart_rounded),
          label: 'Stats',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_rounded),
          label: 'Settings',
        ),
      ],
    );
  }
}
