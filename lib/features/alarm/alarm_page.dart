import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/services/alarm_service.dart';

/// Full-screen alarm page shown when a task alarm fires.
/// - Rings continuously (audioplayers loop) + vibrates
/// - Swipe RIGHT → Done (stop alarm)
/// - Swipe LEFT  → Snooze 5 minutes (reschedule + stop)
class AlarmPage extends StatefulWidget {
  final String taskId;
  final String taskTitle;

  const AlarmPage({
    super.key,
    required this.taskId,
    required this.taskTitle,
  });

  @override
  State<AlarmPage> createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage>
    with SingleTickerProviderStateMixin {
  final _player = AudioPlayer();
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnim;

  // Drag state
  double _dragOffset = 0;
  static const double _swipeThreshold = 100.0;

  // Clock tick
  late Timer _clockTimer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _startRing();
    _startClock();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _startRing() async {
    try {
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.play(AssetSource(AppAssets.soundAlarm));
    } catch (_) {}

    // Start vibration pattern loop
    try {
      final hasVibrator = await Vibration.hasVibrator();

      if (hasVibrator) {
        Vibration.vibrate(
          pattern: [0, 600, 400, 600, 400, 600, 1000],
          intensities: [0, 200, 0, 200, 0, 200, 0],
          repeat: 0, // repeat from index 0
        );
      }
    } catch (_) {
      // Fallback to HapticFeedback every 2 seconds
      _startHapticFallback();
    }
  }

  void _startHapticFallback() {
    Timer.periodic(const Duration(seconds: 2), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      HapticFeedback.heavyImpact();
    });
  }

  void _startClock() {
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  Future<void> _stopAlarm() async {
    try {
      await _player.stop();
      Vibration.cancel();
    } catch (_) {}
  }

  Future<void> _done() async {
    await _stopAlarm();
    await AlarmService().cancelAlarm(widget.taskId);
    if (mounted) Navigator.of(context).pop(AlarmResult.done);
  }

  Future<void> _snooze() async {
    await _stopAlarm();
    await AlarmService().cancelAlarm(widget.taskId);
    // Reschedule 5 minutes later
    final snoozeTime = DateTime.now().add(const Duration(minutes: 5));
    // We don't have the full TaskEntity here, so we schedule manually
    // by reusing AlarmService internal logic via a fake-minimal task.
    // We'll use a simplified direct call to the plugin:
    await _scheduleSnooze(snoozeTime);
    if (mounted) Navigator.of(context).pop(AlarmResult.snoozed);
  }

  Future<void> _scheduleSnooze(DateTime at) async {
    // Create a minimal temporary task entity for snooze
    // We import the entity and build a minimal version
    await AlarmService().scheduleAlarmRaw(
      taskId: '${widget.taskId}_snooze',
      taskTitle: '🔔 Snooze: ${widget.taskTitle}',
      scheduledAt: at,
    );
  }

  @override
  void dispose() {
    _player.dispose();
    _pulseController.dispose();
    _clockTimer.cancel();
    Vibration.cancel();
    super.dispose();
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = theme.scaffoldBackgroundColor;
    final primary = theme.colorScheme.primary;
    final blush = theme.colorScheme.primaryContainer;
    final textPrimary = theme.colorScheme.onSurface;
    final textHint = theme.hintColor;

    final hour = _now.hour.toString().padLeft(2, '0');
    final min = _now.minute.toString().padLeft(2, '0');

    return PopScope(
      canPop: false, // prevent back-button dismiss
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: GestureDetector(
          onHorizontalDragUpdate: (d) {
            setState(() => _dragOffset += d.delta.dx);
          },
          onHorizontalDragEnd: (d) {
            if (_dragOffset > _swipeThreshold) {
              _done();
            } else if (_dragOffset < -_swipeThreshold) {
              _snooze();
            } else {
              setState(() => _dragOffset = 0);
            }
          },
          child: Stack(
            children: [
              // ─── Background gradient ───
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        bg,
                        blush.withValues(alpha: 0.8),
                        bg,
                      ],
                    ),
                  ),
                ),
              ),

              // ─── Drag tint overlay (left=snooze=blue, right=done=green) ───
              if (_dragOffset != 0)
                Positioned.fill(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 50),
                    color: _dragOffset > 0
                        ? AppColors.successDark.withValues(
                            alpha: (_dragOffset / _swipeThreshold)
                                .clamp(0, 0.35))
                        : AppColors.infoDark.withValues(
                            alpha: (-_dragOffset / _swipeThreshold)
                                .clamp(0, 0.35)),
                  ),
                ),

              // ─── Main content ───
              SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 40),

                    // ── Clock ──
                    Text(
                      '$hour:$min',
                      style: AppTypography.display(
                        color: primary,
                      ).copyWith(fontSize: 72, fontWeight: FontWeight.w700),
                    ),

                    const SizedBox(height: 8),
                    Text(
                      'Alarm ringed!',
                      style: AppTypography.caption(
                          color: textHint),
                    ),

                    const Spacer(),

                    // ── Pulse icon ──
                    ScaleTransition(
                      scale: _pulseAnim,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              primary.withValues(alpha: 0.6),
                              primary.withValues(alpha: 0.1),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  primary.withValues(alpha: 0.55),
                              blurRadius: 32,
                              spreadRadius: 8,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text('⏰',
                              style: TextStyle(fontSize: 52)),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── Task title ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        widget.taskTitle,
                        style: AppTypography.h1(
                            color: textPrimary),
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    const Spacer(),

                    // ── Swipe indicator ──
                    _buildSwipeIndicator(),

                    const SizedBox(height: 48),
                  ],
                ),
              ),

              // ─── Drag knob that moves with finger ───
              if (_dragOffset != 0)
                Positioned(
                  left: MediaQuery.of(context).size.width / 2 +
                      _dragOffset -
                      30,
                  top: MediaQuery.of(context).size.height * 0.78,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _dragOffset > 0
                          ? AppColors.successDark
                          : AppColors.infoDark,
                      boxShadow: [
                        BoxShadow(
                          color: (_dragOffset > 0
                                  ? AppColors.successDark
                                  : AppColors.infoDark)
                              .withValues(alpha: 0.6),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      _dragOffset > 0
                          ? Icons.check_rounded
                          : Icons.snooze_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeIndicator() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Snooze hint
          _SwipeHint(
            icon: Icons.snooze_rounded,
            label: '← Snooze',
            sublabel: '5 min',
            color: AppColors.infoDark,
            isActive: _dragOffset < -20,
          ),

          // Centre drag bar
          Expanded(
            child: Center(
              child: Container(
                height: 4,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.infoDark.withValues(alpha: 0.6),
                      theme.colorScheme.primary.withValues(alpha: 0.4),
                      AppColors.successDark.withValues(alpha: 0.6),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Done hint
          _SwipeHint(
            icon: Icons.check_circle_rounded,
            label: 'Done →',
            sublabel: 'Complete',
            color: AppColors.successDark,
            isActive: _dragOffset > 20,
          ),
        ],
      ),
    );
  }
}

class _SwipeHint extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final Color color;
  final bool isActive;

  const _SwipeHint({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.color,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: isActive ? 1.15 : 1.0,
      duration: const Duration(milliseconds: 150),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              color: isActive ? color : color.withValues(alpha: 0.5),
              size: 28),
          const SizedBox(height: 4),
          Text(label,
              style: AppTypography.small(
                  color: isActive ? color : color.withValues(alpha: 0.5))),
          Text(sublabel,
              style: AppTypography.small(
                  color:
                      isActive ? color.withValues(alpha: 0.8) : color.withValues(alpha: 0.35))),
        ],
      ),
    );
  }
}

/// Result returned by AlarmPage when popped.
enum AlarmResult { done, snoozed }
