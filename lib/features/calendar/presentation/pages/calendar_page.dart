import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../task/domain/entities/task_entity.dart';
import '../../../task/presentation/bloc/task_bloc.dart';
import '../../../category/presentation/bloc/category_bloc.dart';
import '../../../task/presentation/pages/add_task_page.dart';
import '../cubit/calendar_cubit.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

enum MonthMode {
  badges, // Gambar 2 (full grid, text badges, no event list)
  list,   // Gambar 1 (full grid, dots, event list)
  week,   // Gambar 3 (1-row week grid, dots, event list)
}

class _CalendarPageState extends State<CalendarPage> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  final int _centerPage = 240; // represents current month
  late DateTime _currentMonth;
  DateTime? _selectedDate;
  String _currentView = 'Month'; // 'Year', 'Month', 'Week', 'Day'

  // Collapsible mode for Month View
  MonthMode _monthMode = MonthMode.list;
  
  // Height & gesture interpolation
  double _calendarHeight = 300.0;
  late AnimationController _heightAnimationController;
  double _heightStart = 300.0;
  double _heightTarget = 300.0;
  final ScrollController _monthScrollController = ScrollController();
  
  // Drag pointer variables
  int? _dragPointerId;
  double _dragStartHeight = 300.0;
  double _dragStartPointerY = 0.0;
  bool _isDraggingHeight = false;
  int _dragStartTime = 0;

  // Mock holidays
  final Map<String, List<Map<String, String>>> _indonesianHolidays = {
    '01-01': [{'title': 'Tahun Baru Masehi', 'desc': 'Hari libur nasional'}],
    '05-01': [{'title': 'Hari Buruh Internasional', 'desc': 'Hari libur nasional'}],
    '06-01': [{'title': 'Hari Lahir Pancasila', 'desc': 'Hari libur nasional. Tanggal Lahir Ideologi Bangsa.'}],
    '06-16': [{'title': 'Satu Muharram / Tahun Baru Hijriah 1448 H', 'desc': 'Hari libur nasional\nTanggal bersifat tentatif dan dapat berubah.'}],
    '08-17': [{'title': 'Hari Kemerdekaan RI', 'desc': 'Hari libur nasional. HUT Republik Indonesia.'}],
    '12-25': [{'title': 'Hari Raya Natal', 'desc': 'Hari libur nasional. Hari Raya Natal.'}],
  };

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month);
    _selectedDate = now;
    _pageController = PageController(initialPage: _centerPage);

    _heightAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _heightAnimationController.addListener(() {
      setState(() {
        _calendarHeight = Tween<double>(
          begin: _heightStart,
          end: _heightTarget,
        ).evaluate(_heightAnimationController);
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _heightAnimationController.dispose();
    _monthScrollController.dispose();
    super.dispose();
  }

  DateTime _getMonthForPage(int page) {
    final offset = page - _centerPage;
    final now = DateTime.now();
    return DateTime(now.year, now.month + offset);
  }

  List<Map<String, String>> _getHolidaysForDate(DateTime date) {
    final key = DateFormat('MM-dd').format(date);
    return _indonesianHolidays[key] ?? [];
  }

  void _onDateTap(BuildContext cellContext, DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    if (_monthMode == MonthMode.badges) {
      // Check if this date has events or tasks
      final holidays = _getHolidaysForDate(date);
      final dayTasks = context.read<TaskBloc>().state is TaskLoaded
          ? (context.read<TaskBloc>().state as TaskLoaded).allTasks.where((t) {
              if (t.dueDate == null) return false;
              return t.dueDate!.year == date.year &&
                  t.dueDate!.month == date.month &&
                  t.dueDate!.day == date.day;
            }).toList()
          : <TaskEntity>[];
      final hasEvents = holidays.isNotEmpty || dayTasks.isNotEmpty;

      if (hasEvents) {
        final renderBox = cellContext.findRenderObject() as RenderBox?;
        Alignment alignment = Alignment.bottomCenter; // default: popover is above cell
        Alignment anchorAlignment = Alignment.topCenter;

        if (renderBox != null) {
          final position = renderBox.localToGlobal(Offset.zero);
          // If the cell is in the upper part of the screen, show popover below it
          if (position.dy < 310.0) {
            alignment = Alignment.topCenter;
            anchorAlignment = Alignment.bottomCenter;
          }
        }

        shadcn.showPopover(
          context: cellContext,
          alignment: alignment,
          anchorAlignment: anchorAlignment,
          builder: (popoverContext) {
            return _buildPopoverContent(popoverContext, date);
          },
        );
      }
    }
  }

  void _snapCalendarHeight(double maxCalendarHeight, [double velocityY = 0.0]) {
    double target;
    if (velocityY.abs() > 200) {
      if (velocityY > 200) {
        // Swiping down (expanding)
        if (_calendarHeight < 300.0) {
          target = 300.0;
          _monthMode = MonthMode.list;
        } else {
          target = maxCalendarHeight;
          _monthMode = MonthMode.badges;
        }
      } else {
        // Swiping up (collapsing)
        if (_calendarHeight > 300.0) {
          target = 300.0;
          _monthMode = MonthMode.list;
        } else {
          target = 85.0;
          _monthMode = MonthMode.week;
        }
      }
    } else {
      // Snapping to nearest midpoint
      final midPointLow = (85.0 + 300.0) / 2; // 192.5
      final midPointHigh = (300.0 + maxCalendarHeight) / 2;
      if (_calendarHeight < midPointLow) {
        target = 85.0;
        _monthMode = MonthMode.week;
      } else if (_calendarHeight < midPointHigh) {
        target = 300.0;
        _monthMode = MonthMode.list;
      } else {
        target = maxCalendarHeight;
        _monthMode = MonthMode.badges;
      }
    }

    _heightStart = _calendarHeight;
    _heightTarget = target;
    _heightAnimationController.forward(from: 0.0);
  }

  int _getSelectedRowIndex(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final startOffset = firstDay.weekday % 7;
    final selected = _selectedDate ?? DateTime.now();
    
    if (selected.year != month.year || selected.month != month.month) {
      final today = DateTime.now();
      if (today.year == month.year && today.month == month.month) {
        final todayOffset = startOffset + today.day - 1;
        return (todayOffset / 7).floor();
      }
      return 2; // Default to 3rd row
    }
    
    final gridIndex = startOffset + selected.day - 1;
    return (gridIndex / 7).floor();
  }

  void _changeYear(int offset) {
    final current = _selectedDate ?? DateTime.now();
    final newDate = DateTime(current.year + offset, current.month, current.day);
    setState(() {
      _selectedDate = newDate;
      _currentMonth = DateTime(newDate.year, newDate.month);
    });
  }

  void _changeSelectedDate(int offsetDays) {
    debugPrint('CALENDAR_PAGE: _changeSelectedDate called with offsetDays=$offsetDays');
    final current = _selectedDate ?? DateTime.now();
    final newDate = current.add(Duration(days: offsetDays));
    debugPrint('CALENDAR_PAGE: _changeSelectedDate current=$current, newDate=$newDate');
    setState(() {
      _selectedDate = newDate;
      _currentMonth = DateTime(newDate.year, newDate.month);
    });
    debugPrint('CALENDAR_PAGE: _changeSelectedDate finished');
  }

  void _jumpToToday() {
    final now = DateTime.now();
    setState(() {
      _selectedDate = now;
      _currentMonth = DateTime(now.year, now.month);
    });
    if (_currentView == 'Month') {
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _centerPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      } else {
        _pageController.dispose();
        _pageController = PageController(initialPage: _centerPage);
      }
    }
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
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
    debugPrint('CALENDAR_PAGE: build() called, _currentView=$_currentView, _selectedDate=$_selectedDate');
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final background = theme.scaffoldBackgroundColor;
    final primary = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: background, // Matched to user theme background
      body: SafeArea(
        child: BlocBuilder<TaskBloc, TaskState>(
          builder: (context, taskState) {
            final allTasks = taskState is TaskLoaded ? taskState.allTasks : <TaskEntity>[];
            return Column(
              children: [
                _buildHeader(isDark),
                Expanded(
                  child: _buildMainCalendarView(allTasks, isDark),
                ),
                _buildBottomSelectorBar(),
              ],
            );
          },
        ),
      ),
      // Floating badge to Jump to Today
      floatingActionButton: _currentView == 'Month'
          ? Padding(
              padding: const EdgeInsets.only(bottom: 72, right: 8),
              child: FloatingActionButton(
                mini: false,
                backgroundColor: primary,
                shape: const CircleBorder(),
                onPressed: _jumpToToday,
                child: Text(
                  '${DateTime.now().day}',
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildHeader(bool isDark) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    String title = '';
    if (_currentView == 'Month') {
      title = '${_currentMonth.year} / ${_currentMonth.month}';
    } else if (_currentView == 'Week') {
      title = 'Weekly Planner 📅';
    } else if (_currentView == 'Day') {
      title = DateFormat('EEEE, d MMMM').format(_selectedDate ?? DateTime.now());
    } else {
      title = '${_selectedDate?.year ?? DateTime.now().year}';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTypography.display(
              color: onSurface,
            ).copyWith(fontSize: 26, fontWeight: FontWeight.w800),
          ),
          if (_currentView == 'Month')
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.chevron_left_rounded, color: onSurface),
                  onPressed: () {
                    if (_pageController.hasClients) {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                ),
                IconButton(
                  icon: Icon(Icons.chevron_right_rounded, color: onSurface),
                  onPressed: () {
                    if (_pageController.hasClients) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildMainCalendarView(List<TaskEntity> allTasks, bool isDark) {
    debugPrint('CALENDAR_PAGE: _buildMainCalendarView() called, _currentView=$_currentView');
    final theme = Theme.of(context);
    if (_currentView == 'Month') {
      return LayoutBuilder(
        builder: (context, constraints) {
          final maxAvailableHeight = constraints.maxHeight;
          final maxCalendarHeight = maxAvailableHeight - 20.0; // Subtract drag handle height (20px) to prevent bottom overflow
          final displayHeight = _calendarHeight.clamp(85.0, maxCalendarHeight);
          return Listener(
            onPointerDown: (event) {
              if (_heightAnimationController.isAnimating) {
                _heightAnimationController.stop();
              }
              final isAtScrollTop = !_monthScrollController.hasClients || _monthScrollController.offset <= 0;
              if (displayHeight > 85.0 || isAtScrollTop) {
                _isDraggingHeight = true;
                _dragStartHeight = displayHeight;
                _dragStartPointerY = event.position.dy;
                _dragPointerId = event.pointer;
                _dragStartTime = DateTime.now().millisecondsSinceEpoch;
              }
            },
            onPointerMove: (event) {
              if (_isDraggingHeight && event.pointer == _dragPointerId) {
                final deltaY = event.position.dy - _dragStartPointerY;
                double newHeight = _dragStartHeight + deltaY;
                newHeight = newHeight.clamp(85.0, maxCalendarHeight);
                
                if (newHeight != _calendarHeight) {
                  setState(() {
                    _calendarHeight = newHeight;
                  });
                  if (_calendarHeight > 85.0 && _monthScrollController.hasClients) {
                    _monthScrollController.jumpTo(0);
                  }
                }
              }
            },
            onPointerUp: (event) {
              if (_isDraggingHeight && event.pointer == _dragPointerId) {
                _isDraggingHeight = false;
                _dragPointerId = null;
                final dragDuration = DateTime.now().millisecondsSinceEpoch - _dragStartTime;
                final totalDeltaY = event.position.dy - _dragStartPointerY;
                final velocityY = totalDeltaY / (dragDuration / 1000.0);
                _snapCalendarHeight(maxCalendarHeight, velocityY);
              }
            },
            onPointerCancel: (event) {
              if (_isDraggingHeight && event.pointer == _dragPointerId) {
                _isDraggingHeight = false;
                _dragPointerId = null;
                _snapCalendarHeight(maxCalendarHeight);
              }
            },
            child: Column(
              children: [
                SizedBox(
                  height: displayHeight,
                  child: ClipRect(
                    child: displayHeight == 85.0
                        ? _buildWeekRowView(allTasks, isDark)
                        : PageView.builder(
                            scrollDirection: Axis.horizontal,
                            controller: _pageController,
                            onPageChanged: (page) {
                              setState(() {
                                _currentMonth = _getMonthForPage(page);
                              });
                            },
                            itemBuilder: (context, index) {
                              final month = _getMonthForPage(index);
                              final denominator = maxCalendarHeight - 300.0;
                              final expandProgress = denominator > 0
                                  ? ((displayHeight - 300.0) / denominator).clamp(0.0, 1.0)
                                  : 0.0;
                              return _MonthView(
                                month: month,
                                selectedDate: _selectedDate,
                                allTasks: allTasks,
                                onDateTap: _onDateTap,
                                isDark: isDark,
                                calendarHeight: displayHeight,
                                expandProgress: expandProgress,
                                selectedRowIndex: _getSelectedRowIndex(month),
                                maxCalendarHeight: maxCalendarHeight,
                              );
                            },
                          ),
                  ),
                ),
                // Drag handle/divider
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  color: Colors.transparent,
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
                // Bottom event list
                if (displayHeight < maxCalendarHeight)
                  Expanded(
                    child: Opacity(
                      opacity: displayHeight <= 300.0
                          ? 1.0
                          : (maxCalendarHeight - 300.0 > 0
                              ? ((maxCalendarHeight - displayHeight) / (maxCalendarHeight - 300.0)).clamp(0.0, 1.0)
                              : 0.0),
                      child: _buildMonthEventList(allTasks),
                    ),
                  ),
              ],
            ),
          );
        },
      );
    } else if (_currentView == 'Week') {
      return _buildWeeklyView(allTasks);
    } else if (_currentView == 'Day') {
      return _buildDailyView(allTasks);
    } else {
      return _buildYearlyView();
    }
  }

  Widget _buildWeekRowView(List<TaskEntity> allTasks, bool isDark) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final onSurface = theme.colorScheme.onSurface;
    
    final weekdayLabels = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
    final now = _selectedDate ?? DateTime.now();
    // Get start of week (Sunday first)
    final startOfWeek = now.subtract(Duration(days: now.weekday % 7));
    final days = List.generate(7, (i) => startOfWeek.add(Duration(days: i)));

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity == null) return;
        if (details.primaryVelocity! > 100) {
          // Swipe right -> Go to previous week (-7 days)
          _changeSelectedDate(-7);
        } else if (details.primaryVelocity! < -100) {
          // Swipe left -> Go to next week (+7 days)
          _changeSelectedDate(7);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Weekday Row
            Row(
              children: weekdayLabels.map((lbl) {
                final isWeekend = lbl == 'SUN' || lbl == 'SAT';
                return Expanded(
                  child: Center(
                    child: Text(
                      lbl,
                      style: TextStyle(
                        color: isWeekend ? primary : onSurface.withValues(alpha: 0.5),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            // Days Row
            Expanded(
              child: Row(
                children: days.map((cellDate) {
                  final isToday = cellDate.day == DateTime.now().day &&
                      cellDate.month == DateTime.now().month &&
                      cellDate.year == DateTime.now().year;
                  final isSelected = _selectedDate != null &&
                      cellDate.year == _selectedDate!.year &&
                      cellDate.month == _selectedDate!.month &&
                      cellDate.day == _selectedDate!.day;
                  final isWeekend = cellDate.weekday == 7 || cellDate.weekday == 6;

                  // Load events & tasks
                  final holidays = _getHolidaysForDate(cellDate);
                  final dayTasks = allTasks.where((t) {
                    if (t.dueDate == null) return false;
                    return t.dueDate!.year == cellDate.year &&
                        t.dueDate!.month == cellDate.month &&
                        t.dueDate!.day == cellDate.day;
                  }).toList();

                  final hasEvents = holidays.isNotEmpty || dayTasks.isNotEmpty;

                  return Expanded(
                    child: _CalendarCellWidget(
                      date: cellDate,
                      isCurrentMonth: cellDate.month == _currentMonth.month,
                      isToday: isToday,
                      isSelected: isSelected,
                      isWeekend: isWeekend,
                      badges: const [], // No badges in week row view
                      hasEvents: hasEvents,
                      expandProgress: 0.0, // Collasped in week row view
                      onTap: _onDateTap,
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyView(List<TaskEntity> allTasks) {
    debugPrint('CALENDAR_PAGE: _buildWeeklyView() called, _selectedDate=$_selectedDate');
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final onSurface = theme.colorScheme.onSurface;
    final now = _selectedDate ?? DateTime.now();
    // Get start of week (Sunday first)
    final startOfWeek = now.subtract(Duration(days: now.weekday % 7));
    final days = List.generate(7, (i) => startOfWeek.add(Duration(days: i)));

    return Column(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onHorizontalDragEnd: (details) {
            debugPrint('CALENDAR_PAGE: Week row drag end, velocity=${details.primaryVelocity}');
            if (details.primaryVelocity == null) return;
            if (details.primaryVelocity! > 100) {
              // Swipe right -> Go to previous week (-7 days)
              _changeSelectedDate(-7);
            } else if (details.primaryVelocity! < -100) {
              // Swipe left -> Go to next week (+7 days)
              _changeSelectedDate(7);
            }
          },
          child: Container(
            height: 80,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: days.map((date) {
                final isSelected = _selectedDate != null &&
                    date.year == _selectedDate!.year &&
                    date.month == _selectedDate!.month &&
                    date.day == _selectedDate!.day;
                final isToday = date.day == DateTime.now().day &&
                    date.month == DateTime.now().month &&
                    date.year == DateTime.now().year;

                final weekdayLabel = DateFormat('E').format(date).toUpperCase();

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDate = date;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? primary
                            : isToday
                                ? primary.withValues(alpha: 0.15)
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: isToday && !isSelected
                            ? Border.all(color: primary, width: 1.5)
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            weekdayLabel,
                            style: TextStyle(
                              color: isSelected
                                  ? theme.colorScheme.onPrimary
                                  : (date.weekday == 7 || date.weekday == 6)
                                      ? primary
                                      : onSurface.withValues(alpha: 0.6),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${date.day}',
                            style: TextStyle(
                              color: isSelected
                                  ? theme.colorScheme.onPrimary
                                  : onSurface.withValues(alpha: 0.85),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const Divider(color: Colors.white24, height: 1),
        Expanded(
          child: _buildDailyView(allTasks),
        ),
      ],
    );
  }

  Widget _buildDailyView(List<TaskEntity> allTasks) {
    debugPrint('CALENDAR_PAGE: _buildDailyView() called, _selectedDate=$_selectedDate');
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final primary = theme.colorScheme.primary;

    final targetDate = _selectedDate ?? DateTime.now();
    final dayTasks = allTasks.where((t) {
      if (t.dueDate == null) return false;
      return t.dueDate!.year == targetDate.year &&
          t.dueDate!.month == targetDate.month &&
          t.dueDate!.day == targetDate.day;
    }).toList();

    final holidays = _getHolidaysForDate(targetDate);

    Widget content;

    if (dayTasks.isEmpty && holidays.isEmpty) {
      content = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎀', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              'No events or tasks on this day, bestie!',
              style: AppTypography.quote(color: onSurface.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 16),
            if (targetDate.isBefore(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)))
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
                icon: const Icon(Icons.note_add_rounded),
                label: const Text('Add Daily Note'),
                onPressed: () => _openNoteDetailPage(targetDate, null),
              ),
          ],
        ),
      );
    } else {
      content = ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Holidays Section
          if (holidays.isNotEmpty) ...[
            Text('Holidays', style: AppTypography.bodyBold(color: primary)),
            const SizedBox(height: 8),
            ...holidays.map((h) {
              return Card(
                color: theme.colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
                ),
                child: ListTile(
                  leading: const Text('🇮🇩', style: TextStyle(fontSize: 24)),
                  title: Text(
                    h['title'] ?? '',
                    style: TextStyle(color: onSurface, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('All day', style: TextStyle(color: onSurface.withValues(alpha: 0.6))),
                  onTap: () {
                    _openHolidayDetailPage(targetDate, h['title'] ?? '', h['desc'] ?? '');
                  },
                ),
              );
            }),
            const SizedBox(height: 24),
          ],

          // Tasks Section
          if (dayTasks.isNotEmpty) ...[
            Text('Tasks', style: AppTypography.bodyBold(color: primary)),
            const SizedBox(height: 8),
            ...dayTasks.map((t) {
              return Card(
                color: theme.colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
                ),
                child: ListTile(
                  leading: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: t.isCompleted ? AppColors.successDark : _getPriorityColor(t.priority),
                    ),
                  ),
                  title: Text(
                    t.title,
                    style: TextStyle(
                      color: onSurface,
                      fontWeight: FontWeight.bold,
                      decoration: t.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  subtitle: Text(
                    t.dueDate != null ? DateFormat('jm').format(t.dueDate!) : '',
                    style: TextStyle(color: onSurface.withValues(alpha: 0.6)),
                  ),
                  trailing: t.isCompleted
                      ? const Icon(Icons.check_circle, color: AppColors.successDark)
                      : null,
                  onTap: () {
                    _openTaskDetailPage(t);
                  },
                ),
              );
            }),
          ],
        ],
      );
    }

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        debugPrint('CALENDAR_PAGE: Daily view drag end, velocity=${details.primaryVelocity}');
        if (details.primaryVelocity == null) return;
        if (details.primaryVelocity! > 100) {
          // Swipe right -> Go to previous day (-1 day)
          _changeSelectedDate(-1);
        } else if (details.primaryVelocity! < -100) {
          // Swipe left -> Go to next day (+1 day)
          _changeSelectedDate(1);
        }
      },
      child: content,
    );
  }

  Widget _buildYearlyView() {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final now = DateTime.now();
    final year = _selectedDate?.year ?? now.year;
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity == null) return;
        if (details.primaryVelocity! > 100) {
          // Swipe right -> Go to previous year (-1 year)
          _changeYear(-1);
        } else if (details.primaryVelocity! < -100) {
          // Swipe left -> Go to next year (+1 year)
          _changeYear(1);
        }
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.72,
          mainAxisSpacing: 16,
          crossAxisSpacing: 12,
        ),
        itemCount: 12,
        itemBuilder: (context, index) {
          final monthDate = DateTime(year, index + 1);
          final monthName = DateFormat('MMMM').format(monthDate);
          return GestureDetector(
            onTap: () {
              setState(() {
                _currentMonth = monthDate;
                _currentView = 'Month';
              });
              final diff = (monthDate.year - now.year) * 12 + (monthDate.month - now.month);
              if (_pageController.hasClients) {
                _pageController.jumpToPage(_centerPage + diff);
              } else {
                _pageController.dispose();
                _pageController = PageController(initialPage: _centerPage + diff);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.outlineVariant, width: 0.5),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    monthName.substring(0, 3).toUpperCase(),
                    style: TextStyle(
                      color: primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildMiniWeekdaysRow(theme, primary),
                  const SizedBox(height: 2),
                  Expanded(
                    child: _buildMiniMonthDatesGrid(year, index + 1, theme, primary),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMiniWeekdaysRow(ThemeData theme, Color primary) {
    final weekdayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    final onSurface = theme.colorScheme.onSurface;
    return Row(
      children: List.generate(7, (i) {
        final label = weekdayLabels[i];
        final isWeekend = i == 0 || i == 6; // Sunday or Saturday
        return Expanded(
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isWeekend ? primary : onSurface.withValues(alpha: 0.4),
                fontSize: 6,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildMiniMonthDatesGrid(int year, int month, ThemeData theme, Color primary) {
    final firstDay = DateTime(year, month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(year, month);
    final startOffset = firstDay.weekday % 7; // Sunday start (Sunday is 0)
    const totalCells = 42;
    final onSurface = theme.colorScheme.onSurface;

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
        mainAxisSpacing: 1,
        crossAxisSpacing: 1,
      ),
      itemCount: totalCells,
      itemBuilder: (context, index) {
        if (index < startOffset || index >= startOffset + daysInMonth) {
          return const SizedBox.shrink();
        }
        final day = index - startOffset + 1;
        final isToday = day == DateTime.now().day && month == DateTime.now().month && year == DateTime.now().year;
        final isSelected = _selectedDate != null &&
            day == _selectedDate!.day &&
            month == _selectedDate!.month &&
            year == _selectedDate!.year;

        final weekdayIdx = index % 7;
        final isWeekend = weekdayIdx == 0 || weekdayIdx == 6;

        Color textColor = onSurface;
        if (isWeekend) {
          textColor = primary;
        }

        return Container(
          decoration: isToday || isSelected
              ? BoxDecoration(
                  color: isToday ? primary.withValues(alpha: 0.3) : primary,
                  shape: BoxShape.circle,
                )
              : null,
          alignment: Alignment.center,
          child: Text(
            '$day',
            style: TextStyle(
              color: isSelected ? theme.colorScheme.onPrimary : textColor,
              fontSize: 6,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomSelectorBar() {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final onSurface = theme.colorScheme.onSurface;
    final views = ['Year', 'Month', 'Week', 'Day'];

    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: views.map((v) {
          final isSelected = _currentView == v;
          return GestureDetector(
            onTap: () {
              setState(() {
                _currentView = v;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: isSelected
                  ? BoxDecoration(
                      border: Border(bottom: BorderSide(color: primary, width: 3)),
                    )
                  : null,
              child: Text(
                v,
                style: TextStyle(
                  color: isSelected ? primary : onSurface.withValues(alpha: 0.6),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMonthEventList(List<TaskEntity> allTasks) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    final targetDate = _selectedDate ?? DateTime.now();
    final dayTasks = allTasks.where((t) {
      if (t.dueDate == null) return false;
      return t.dueDate!.year == targetDate.year &&
          t.dueDate!.month == targetDate.month &&
          t.dueDate!.day == targetDate.day;
    }).toList();

    final holidays = _getHolidaysForDate(targetDate);

    if (dayTasks.isEmpty && holidays.isEmpty) {
      return Center(
        child: Text(
          'No events or tasks on this day, bestie!',
          style: TextStyle(color: onSurface.withValues(alpha: 0.6), fontSize: 14),
        ),
      );
    }

    return ListView(
      controller: _monthScrollController,
      physics: _calendarHeight > 85.0
          ? const NeverScrollableScrollPhysics()
          : const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      children: [
        ...holidays.map((h) {
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            color: theme.colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
            ),
            child: ListTile(
              leading: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blueAccent,
                ),
              ),
              title: Text(
                h['title'] ?? '',
                style: TextStyle(color: onSurface, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              subtitle: Text(
                h['desc'] ?? 'Hari libur nasional',
                style: TextStyle(color: onSurface.withValues(alpha: 0.6), fontSize: 12),
              ),
              onTap: () {
                _openHolidayDetailPage(targetDate, h['title'] ?? '', h['desc'] ?? '');
              },
            ),
          );
        }),
        ...dayTasks.map((t) {
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            color: theme.colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
            ),
            child: ListTile(
              leading: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: t.isCompleted ? AppColors.successDark : _getPriorityColor(t.priority),
                ),
              ),
              title: Text(
                t.title,
                style: TextStyle(
                  color: onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  decoration: t.isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
              subtitle: Text(
                t.dueDate != null ? DateFormat('jm').format(t.dueDate!) : '',
                style: TextStyle(color: onSurface.withValues(alpha: 0.6), fontSize: 12),
              ),
              onTap: () {
                _openTaskDetailPage(t);
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPopoverContent(BuildContext popoverContext, DateTime date) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final onSurface = theme.colorScheme.onSurface;

    final dateLabel = DateFormat('M/d EEE').format(date);
    final holidays = _getHolidaysForDate(date);
    
    final taskState = context.read<TaskBloc>().state;
    final allTasks = taskState is TaskLoaded ? taskState.allTasks : <TaskEntity>[];
    
    final dayTasks = allTasks.where((t) {
      if (t.dueDate == null) return false;
      return t.dueDate!.year == date.year &&
          t.dueDate!.month == date.month &&
          t.dueDate!.day == date.day;
    }).toList();

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 260,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: theme.brightness == Brightness.dark ? 0.45 : 0.12),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                dateLabel,
                style: TextStyle(
                  color: onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            Divider(color: theme.colorScheme.outlineVariant, height: 1),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 180),
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 4),
                children: [
                  ...holidays.map((h) => ListTile(
                        visualDensity: VisualDensity.compact,
                        dense: true,
                        leading: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: primary),
                        ),
                        title: Text(
                          h['title'] ?? '',
                          style: TextStyle(color: onSurface, fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text('All day', style: TextStyle(color: onSurface.withValues(alpha: 0.6))),
                        onTap: () {
                          shadcn.closeOverlay(popoverContext);
                          _openHolidayDetailPage(date, h['title'] ?? '', h['desc'] ?? '');
                        },
                      )),
                  ...dayTasks.map((t) => ListTile(
                        visualDensity: VisualDensity.compact,
                        dense: true,
                        leading: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: t.isCompleted ? AppColors.successDark : _getPriorityColor(t.priority),
                          ),
                        ),
                        title: Text(
                          t.title,
                          style: TextStyle(color: onSurface, fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          t.dueDate != null ? DateFormat('jm').format(t.dueDate!) : '',
                          style: TextStyle(color: onSurface.withValues(alpha: 0.6)),
                        ),
                        onTap: () {
                          shadcn.closeOverlay(popoverContext);
                          _openTaskDetailPage(t);
                        },
                      )),
                  if (holidays.isEmpty && dayTasks.isEmpty)
                    ListTile(
                      dense: true,
                      title: Text('No tasks or holidays', style: TextStyle(color: onSurface.withValues(alpha: 0.6))),
                      subtitle: Text('Tap to view daily notes', style: TextStyle(color: primary)),
                      onTap: () {
                        shadcn.closeOverlay(popoverContext);
                        _openNoteDetailPage(date, null);
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openHolidayDetailPage(DateTime date, String title, String desc) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<CalendarCubit>(),
        child: _CalendarEventDetailDialog(
          title: title,
          date: date,
          description: desc,
          isHoliday: true,
        ),
      ),
    );
  }

  void _openTaskDetailPage(TaskEntity task) {
    showDialog(
      context: context,
      builder: (dialogContext) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<TaskBloc>()),
          BlocProvider.value(value: context.read<CategoryBloc>()),
          BlocProvider.value(value: context.read<CalendarCubit>()),
        ],
        child: _CalendarEventDetailDialog(
          title: task.title,
          date: task.dueDate ?? DateTime.now(),
          description: task.description ?? 'No description provided.',
          isHoliday: false,
          task: task,
        ),
      ),
    );
  }

  void _openNoteDetailPage(DateTime date, String? initialNote) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<CalendarCubit>(),
        child: _CalendarEventDetailDialog(
          title: 'Daily Note Summary',
          date: date,
          description: 'Mencatat apa saja yang sudah dilakukan di hari ini.',
          isHoliday: false,
          isDailyNoteOnly: true,
        ),
      ),
    );
  }
}

// ─── Month View Grid ─────────────────────────────────────────────────────────

class _MonthView extends StatelessWidget {
  final DateTime month;
  final DateTime? selectedDate;
  final List<TaskEntity> allTasks;
  final void Function(BuildContext cellContext, DateTime date) onDateTap;
  final bool isDark;
  final double calendarHeight;
  final double expandProgress;
  final int selectedRowIndex;
  final double maxCalendarHeight;

  const _MonthView({
    required this.month,
    required this.selectedDate,
    required this.allTasks,
    required this.onDateTap,
    required this.isDark,
    required this.calendarHeight,
    required this.expandProgress,
    required this.selectedRowIndex,
    required this.maxCalendarHeight,
  });

  bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  bool _isSelected(DateTime d) =>
      selectedDate != null &&
      d.year == selectedDate!.year &&
      d.month == selectedDate!.month &&
      d.day == selectedDate!.day;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final onSurface = theme.colorScheme.onSurface;

    final firstDay = DateTime(month.year, month.month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);

    final startOffset = firstDay.weekday % 7;
    final weekdayLabels = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];

    final totalCells = startOffset + daysInMonth;
    final totalGridRows = (totalCells / 7).ceil();
    final gridCellCount = totalGridRows * 7;

    double childAspectRatio;
    if (calendarHeight <= 300.0) {
      childAspectRatio = 1.15;
    } else {
      double ratioT = ((calendarHeight - 300.0) / (maxCalendarHeight - 300.0)).clamp(0.0, 1.0);
      childAspectRatio = 1.15 - ratioT * (1.15 - 0.65);
    }

    double t = ((calendarHeight - 85.0) / (300.0 - 85.0)).clamp(0.0, 1.0);
    double fullGridHeight = 300.0 - 23.0; // grid height at list mode
    double rowHeight = fullGridHeight / totalGridRows;
    double yTarget = -selectedRowIndex * rowHeight;
    double yTranslate = yTarget * (1.0 - t);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          // Weekday Row
          Row(
            children: weekdayLabels.map((lbl) {
              final isWeekend = lbl == 'SUN' || lbl == 'SAT';
              return Expanded(
                child: Center(
                  child: Text(
                    lbl,
                    style: TextStyle(
                      color: isWeekend ? primary : onSurface.withValues(alpha: 0.5),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),

          // Days Grid
          Expanded(
            child: ClipRect(
              child: Transform.translate(
                offset: Offset(0, yTranslate),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    childAspectRatio: childAspectRatio,
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 6,
                  ),
                  itemCount: gridCellCount,
                  itemBuilder: (context, index) {
                    DateTime cellDate;
                    bool isCurrentMonth = true;

                    if (index < startOffset) {
                      final prevMonth = DateTime(month.year, month.month - 1);
                      final prevDays = DateUtils.getDaysInMonth(prevMonth.year, prevMonth.month);
                      cellDate = DateTime(prevMonth.year, prevMonth.month, prevDays - startOffset + index + 1);
                      isCurrentMonth = false;
                    } else if (index >= startOffset + daysInMonth) {
                      final nextMonth = DateTime(month.year, month.month + 1);
                      cellDate = DateTime(nextMonth.year, nextMonth.month, index - startOffset - daysInMonth + 1);
                      isCurrentMonth = false;
                    } else {
                      cellDate = DateTime(month.year, month.month, index - startOffset + 1);
                    }

                    final isToday = _isToday(cellDate);
                    final isSelected = _isSelected(cellDate);
                    final columnIdx = index % 7;
                    final isWeekend = columnIdx == 0 || columnIdx == 6;

                    // Load events & tasks
                    final holidays = _getHolidaysForDate(cellDate);
                    final dayTasks = allTasks.where((t) {
                      if (t.dueDate == null) return false;
                      return t.dueDate!.year == cellDate.year &&
                          t.dueDate!.month == cellDate.month &&
                          t.dueDate!.day == cellDate.day;
                    }).toList();

                    final hasEvents = holidays.isNotEmpty || dayTasks.isNotEmpty;

                    final List<Map<String, dynamic>> badges = [];
                    for (final h in holidays) {
                      badges.add({
                        'text': h['title']!.contains('Satu Muharram') ? 'Satu Mu' : (h['title']!.contains('Pancasila') ? 'Tahun' : 'Hari'),
                        'isBlue': h['title']!.contains('Satu Muharram') || h['title']!.contains('Pancasila'),
                      });
                    }
                    for (final t in dayTasks) {
                      if (badges.length < 2) {
                        badges.add({
                          'text': t.title,
                          'isBlue': t.priority == TaskPriority.high || t.priority == TaskPriority.urgent,
                        });
                      }
                    }

                    return _CalendarCellWidget(
                      date: cellDate,
                      isCurrentMonth: isCurrentMonth,
                      isToday: isToday,
                      isSelected: isSelected,
                      isWeekend: isWeekend,
                      badges: badges,
                      hasEvents: hasEvents,
                      expandProgress: expandProgress,
                      onTap: onDateTap,
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, String>> _getHolidaysForDate(DateTime date) {
    final key = DateFormat('MM-dd').format(date);
    final Map<String, List<Map<String, String>>> indonesianHolidays = {
      '01-01': [{'title': 'Tahun Baru Masehi'}],
      '05-01': [{'title': 'Hari Buruh'}],
      '06-01': [{'title': 'Hari Lahir Pancasila'}],
      '06-16': [{'title': 'Satu Muharram / Tahun Baru Hijriah'}],
      '08-17': [{'title': 'Hari Kemerdekaan RI'}],
      '12-25': [{'title': 'Hari Raya Natal'}],
    };
    return indonesianHolidays[key] ?? [];
  }
}

class _CalendarCellWidget extends StatelessWidget {
  final DateTime date;
  final bool isCurrentMonth;
  final bool isToday;
  final bool isSelected;
  final bool isWeekend;
  final List<Map<String, dynamic>> badges;
  final bool hasEvents;
  final double expandProgress;
  final void Function(BuildContext cellContext, DateTime date) onTap;

  const _CalendarCellWidget({
    required this.date,
    required this.isCurrentMonth,
    required this.isToday,
    required this.isSelected,
    required this.isWeekend,
    required this.badges,
    required this.hasEvents,
    required this.expandProgress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final onSurface = theme.colorScheme.onSurface;

    Color textColor = onSurface;
    if (!isCurrentMonth) {
      textColor = onSurface.withValues(alpha: 0.22);
    } else if (isSelected) {
      textColor = theme.colorScheme.onPrimary;
    } else if (isWeekend) {
      textColor = primary; // Pink columns for weekends
    }

    return GestureDetector(
      onTapDown: (details) => onTap(context, date),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? primary // Active theme primary color background
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isToday && !isSelected
              ? Border.all(color: primary, width: 1.5)
              : null,
        ),
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: Stack(
          children: [
            // Date number aligned to the top center
            Align(
              alignment: Alignment.topCenter,
              child: Text(
                '${date.day}',
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            // Dots/Badges in remaining space below date number text
            Positioned(
              top: 20,
              left: 0,
              right: 0,
              bottom: 0,
              child: ClipRect(
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    if (expandProgress > 0.0)
                      Opacity(
                        opacity: expandProgress,
                        child: OverflowBox(
                          minHeight: 0,
                          maxHeight: double.infinity,
                          alignment: Alignment.topCenter,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: badges.take(2).map((badge) {
                              final isBlue = badge['isBlue'] as bool;
                              return Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 2),
                                padding: const EdgeInsets.symmetric(vertical: 1.5, horizontal: 3),
                                decoration: BoxDecoration(
                                  color: isBlue
                                      ? primary // primary color badge
                                      : onSurface.withValues(alpha: 0.1), // greyish theme badge
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  badge['text'] as String,
                                  style: TextStyle(
                                    color: isBlue ? theme.colorScheme.onPrimary : onSurface,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    if (expandProgress < 1.0 && hasEvents)
                      Opacity(
                        opacity: 1.0 - expandProgress,
                        child: Container(
                          margin: const EdgeInsets.only(top: 2),
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? theme.colorScheme.onPrimary : primary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Detail View Screen (Gambar 3 style) ─────────────────────────────────────

class _CalendarEventDetailDialog extends StatefulWidget {
  final String title;
  final DateTime date;
  final String description;
  final bool isHoliday;
  final bool isDailyNoteOnly;
  final TaskEntity? task;

  const _CalendarEventDetailDialog({
    required this.title,
    required this.date,
    required this.description,
    required this.isHoliday,
    this.isDailyNoteOnly = false,
    this.task,
  });

  @override
  State<_CalendarEventDetailDialog> createState() => _CalendarEventDetailDialogState();
}

class _CalendarEventDetailDialogState extends State<_CalendarEventDetailDialog> {
  String? _noteText;

  @override
  void initState() {
    super.initState();
    final dateKey = DateFormat('yyyy_MM_dd').format(widget.date);
    context.read<CalendarCubit>().loadNote(dateKey);
    _noteText = context.read<CalendarCubit>().state.dailyNotes[dateKey];
  }

  Future<void> _saveNote(String text) async {
    final dateKey = DateFormat('yyyy_MM_dd').format(widget.date);
    await context.read<CalendarCubit>().saveNote(dateKey, text);
    setState(() {
      _noteText = text.trim().isEmpty ? null : text.trim();
    });
  }

  void _showNoteDialog() {
    final controller = TextEditingController(text: _noteText);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text('Add Daily Note', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: controller,
            maxLines: 4,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Tulis aktivitas yang sudah diselesaikan hari ini...',
              hintStyle: TextStyle(color: Colors.white24),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF2563EB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white12),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
              onPressed: () {
                _saveNote(controller.text);
                Navigator.pop(context);
              },
              child: const Text('Save Note', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final onSurface = theme.colorScheme.onSurface;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDate = DateTime(widget.date.year, widget.date.month, widget.date.day);

    final isPast = eventDate.isBefore(today);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 400,
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor, // Theme matched
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.colorScheme.outlineVariant, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: theme.brightness == Brightness.dark ? 0.5 : 0.15),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card in Solid Theme Primary color (Gambar 3 style)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                color: primary, // Matched with active primary theme
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.title,
                          style: TextStyle(
                            color: theme.colorScheme.onPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Close button
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.colorScheme.onPrimary.withValues(alpha: 0.15),
                          ),
                          child: Icon(Icons.close_rounded, color: theme.colorScheme.onPrimary, size: 20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Date
                  Text(
                    DateFormat('EEEE, d MMMM').format(widget.date),
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary.withValues(alpha: 0.8),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Content body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Description
                    Text(
                      'Description',
                      style: TextStyle(
                        color: primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.description,
                      style: TextStyle(
                        color: onSurface.withValues(alpha: 0.8),
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Reminders row (only shown if not in the past)
                    if (!isPast && !widget.isHoliday && !widget.isDailyNoteOnly) ...[
                      Text(
                        'Reminders',
                        style: TextStyle(
                          color: primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.task?.hasAlarm == true ? 'Ring alarm at due time' : 'Don\'t remind',
                            style: TextStyle(color: onSurface, fontSize: 13),
                          ),
                          Icon(Icons.chevron_right_rounded, color: primary, size: 20),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Daily notes section (especially for past dates)
                    if (isPast || widget.isDailyNoteOnly) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Daily Notes',
                            style: TextStyle(
                              color: primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.edit_note_rounded, color: primary, size: 22),
                            onPressed: _showNoteDialog,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      if (_noteText != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: theme.colorScheme.outlineVariant),
                          ),
                          child: Text(
                            _noteText!,
                            style: TextStyle(color: onSurface, fontSize: 13, height: 1.4),
                          ),
                        )
                      else
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.secondaryContainer,
                            foregroundColor: theme.colorScheme.onSecondaryContainer,
                            minimumSize: const Size(double.infinity, 44),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.note_add_rounded, size: 16),
                          label: const Text('Add Note', style: TextStyle(fontSize: 13)),
                          onPressed: _showNoteDialog,
                        ),
                      const SizedBox(height: 20),
                    ],
                  ],
                ),
              ),
            ),

            // Bottom Buttons (Circular edit & delete, only for tasks that are not past)
            if (!isPast && !widget.isHoliday && widget.task != null)
              Container(
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Edit button
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        shadcn.openDrawer(
                          context: context,
                          position: shadcn.OverlayPosition.bottom,
                          builder: (_) => MultiBlocProvider(
                            providers: [
                              BlocProvider.value(value: context.read<TaskBloc>()),
                              BlocProvider.value(value: context.read<CategoryBloc>()),
                            ],
                            child: AddTaskPage(taskToEdit: widget.task),
                          ),
                        );
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.secondaryContainer,
                        ),
                        child: Icon(Icons.edit_rounded, color: primary, size: 20),
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Delete button
                    GestureDetector(
                      onTap: () {
                        context.read<TaskBloc>().add(DeleteTask(widget.task!.id));
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.secondaryContainer,
                        ),
                        child: Icon(Icons.delete_rounded, color: theme.colorScheme.error, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
