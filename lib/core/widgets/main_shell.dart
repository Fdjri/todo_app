import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import 'neon_navbar.dart';
import 'confetti_overlay.dart';
import '../../features/task/presentation/bloc/task_bloc.dart';
import '../../features/task/presentation/pages/home_page.dart';
import '../../features/task/presentation/pages/add_task_page.dart';
import '../../features/category/presentation/bloc/category_bloc.dart';
import '../../features/gamification/presentation/bloc/gamification_bloc.dart';
import '../../features/calendar/presentation/pages/calendar_page.dart';
import '../../features/notes/presentation/pages/notes_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';

/// Root shell that holds the 3-tab navigation (Home / History / Settings)
/// with a shared neon navbar and FAB.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  bool _showConfetti = false;

  void _onTaskComplete(BuildContext ctx, String taskId) {
    ctx.read<TaskBloc>().add(ToggleTaskCompletion(taskId));
    ctx.read<GamificationBloc>().add(TaskCompleted());
    ctx.read<GamificationBloc>().add(UpdateStreak());
    setState(() => _showConfetti = true);
  }

  void _showAddTask(BuildContext ctx) {
    shadcn.openDrawer(
      context: ctx,
      position: shadcn.OverlayPosition.bottom,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: ctx.read<TaskBloc>()),
          BlocProvider.value(value: ctx.read<CategoryBloc>()),
        ],
        child: const AddTaskPage(),
      ),
    );
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return HomePage(
          onTaskComplete: _onTaskComplete,
          onShowAddTask: _showAddTask,
        );
      case 1:
        return const CalendarPage();
      case 2:
        return const NotesPage();
      case 3:
        return const SettingsPage();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return shadcn.DrawerOverlay(
      child: Builder(
        builder: (context) {
          return Scaffold(
            body: Stack(
              children: [
                // Main content — IndexedStack keeps each page alive
                IndexedStack(
                  index: _currentIndex,
                  children: List.generate(4, (i) => _buildPage(i)),
                ),

                // Confetti overlay (only on home tab)
                if (_currentIndex == 0)
                  ConfettiOverlay(
                    play: _showConfetti,
                    onComplete: () => setState(() => _showConfetti = false),
                  ),
              ],
            ),

            // FAB only on Home tab
            floatingActionButton: _currentIndex == 0
                ? _buildFAB(context)
                : null,

            bottomNavigationBar: NeonNavBar(
              currentIndex: _currentIndex,
              onTap: (i) => setState(() => _currentIndex = i),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    final theme = Theme.of(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      builder: (context, value, _) {
        return Transform.scale(
          scale: value,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.4),
                  blurRadius: 16,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: shadcn.Button(
              style: const shadcn.ButtonStyle.primary(
                shape: shadcn.ButtonShape.circle,
              ),
              onPressed: () => _showAddTask(context),
              child: const Icon(Icons.add_rounded, size: 28),
            ),
          ),
        );
      },
    );
  }
}
