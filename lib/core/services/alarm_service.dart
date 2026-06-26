import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import '../../features/task/domain/entities/task_entity.dart';

/// Background isolate top-level handler (required by flutter_local_notifications)
@pragma('vm:entry-point')
void onBackgroundNotificationResponse(NotificationResponse response) {
  // Cannot navigate here — AlarmService.onAlarmTriggered handles it
}

/// Singleton service for scheduling and cancelling task alarms.
/// Uses flutter_local_notifications exact alarms + full-screen intent.
class AlarmService {
  static final AlarmService _instance = AlarmService._internal();
  factory AlarmService() => _instance;
  AlarmService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'workaholic_alarm';
  static const String _channelName = 'Workaholic Alarms 🎀';
  static const String _reminderChannelId = 'workaholic_reminder';
  static const String _reminderChannelName = 'Savings & Goals Reminders 🌸';

  /// Called when a notification fires while app is foreground/background.
  /// Set this in main.dart to navigate to AlarmPage.
  static void Function(String taskId, String taskTitle)? onAlarmTriggered;

  // ─── Init ────────────────────────────────────────────────────────────────

  Future<void> init() async {
    // Init timezone data
    tz_data.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/launcher_icon');
    await _plugin.initialize(
      const InitializationSettings(android: androidInit),
      onDidReceiveNotificationResponse: _handleNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
          onBackgroundNotificationResponse,
    );

    // Create high-priority alarm channel
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: 'Full-screen alarm notifications for Workaholic tasks',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      enableLights: true,
      showBadge: true,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Create high-priority floating notification channel for reminders (no full screen intent)
    const reminderChannel = AndroidNotificationChannel(
      _reminderChannelId,
      _reminderChannelName,
      description: 'Daily savings reminders and encouragement notifications',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(reminderChannel);
  }

  // ─── Permission helpers ───────────────────────────────────────────────────

  /// Check if exact alarm permission is granted (Android 12+)
  Future<bool> canScheduleExactAlarms() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    return await android?.canScheduleExactNotifications() ?? true;
  }

  /// Opens system settings for exact alarm permission (Android 12+)
  Future<void> openExactAlarmSettings() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestExactAlarmsPermission();
  }

  /// Request POST_NOTIFICATIONS permission (Android 13+)
  Future<bool> requestNotificationPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final granted = await android?.requestNotificationsPermission();
    return granted ?? false;
  }

  // ─── Schedule / Cancel ───────────────────────────────────────────────────

  /// Schedule an exact alarm for [task]. No-op if task has no dueDate.
  Future<void> scheduleAlarm(TaskEntity task) async {
    if (task.dueDate == null) return;

    final payload = jsonEncode({'id': task.id, 'title': task.title});

    // Use local timezone
    final scheduledDate = tz.TZDateTime.from(task.dueDate!, tz.local);

    // Skip if already in the past
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) return;

    try {
      await _plugin.zonedSchedule(
        _notifId(task.id),
        '⏰ ${task.title}',
        "Time for your task, bestie! Swipe to dismiss ✨",
        scheduledDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            importance: Importance.max,
            priority: Priority.max,
            fullScreenIntent: true,
            category: AndroidNotificationCategory.alarm,
            autoCancel: false,
            ongoing: true,
            vibrationPattern: Int64List.fromList(
                [0, 500, 300, 500, 300, 500, 300, 500]),
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
    } catch (e) {
      debugPrint('[AlarmService] Failed to schedule exact alarm: $e. Falling back to inexact.');
      try {
        await _plugin.zonedSchedule(
          _notifId(task.id),
          '⏰ ${task.title}',
          "Time for your task, bestie! Swipe to dismiss ✨",
          scheduledDate,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _channelId,
              _channelName,
              importance: Importance.max,
              priority: Priority.max,
              fullScreenIntent: true,
              category: AndroidNotificationCategory.alarm,
              autoCancel: false,
              ongoing: true,
              vibrationPattern: Int64List.fromList(
                  [0, 500, 300, 500, 300, 500, 300, 500]),
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: payload,
        );
      } catch (innerErr) {
        debugPrint('[AlarmService] Failed to schedule fallback inexact alarm: $innerErr');
      }
    }

    debugPrint('[AlarmService] Scheduled alarm for "${task.title}" at $scheduledDate');
  }

  /// Cancel scheduled alarm for [taskId].
  Future<void> cancelAlarm(String taskId) async {
    await _plugin.cancel(_notifId(taskId));
    debugPrint('[AlarmService] Cancelled alarm for $taskId');
  }

  /// Returns all pending scheduled alarm IDs.
  Future<List<PendingNotificationRequest>> pendingAlarms() async {
    return _plugin.pendingNotificationRequests();
  }

  /// Schedule a raw alarm by id/title/time (used for snooze).
  Future<void> scheduleAlarmRaw({
    required String taskId,
    required String taskTitle,
    required DateTime scheduledAt,
  }) async {
    final payload = jsonEncode({'id': taskId, 'title': taskTitle});
    final scheduledDate = tz.TZDateTime.from(scheduledAt, tz.local);
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) return;

    try {
      await _plugin.zonedSchedule(
        _notifId(taskId),
        '⏰ $taskTitle',
        "Your snoozed alarm is ready, bestie! ✨",
        scheduledDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            importance: Importance.max,
            priority: Priority.max,
            fullScreenIntent: true,
            category: AndroidNotificationCategory.alarm,
            autoCancel: false,
            ongoing: true,
            vibrationPattern: Int64List.fromList(
                [0, 500, 300, 500, 300, 500, 300, 500]),
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
    } catch (e) {
      debugPrint('[AlarmService] Failed to schedule raw exact alarm: $e. Falling back to inexact.');
      try {
        await _plugin.zonedSchedule(
          _notifId(taskId),
          '⏰ $taskTitle',
          "Your snoozed alarm is ready, bestie! ✨",
          scheduledDate,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _channelId,
              _channelName,
              importance: Importance.max,
              priority: Priority.max,
              fullScreenIntent: true,
              category: AndroidNotificationCategory.alarm,
              autoCancel: false,
              ongoing: true,
              vibrationPattern: Int64List.fromList(
                  [0, 500, 300, 500, 300, 500, 300, 500]),
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: payload,
        );
      } catch (innerErr) {
        debugPrint('[AlarmService] Failed to schedule fallback raw inexact alarm: $innerErr');
      }
    }
  }

  /// Schedule daily savings reminder at 6:00 PM (18:00) as a floating notification
  Future<void> scheduleDailySavingsReminder() async {
    const int notifId = 888888; // Unique ID for daily savings reminder
    
    // Check/request permission
    await requestNotificationPermission();

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      18, // 18:00 (6:00 PM)
      0,
    );

    // If 6 PM has already passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    try {
      await _plugin.zonedSchedule(
        notifId,
        'Savings Time, Bestie! 🌸',
        "Don't forget to set aside some money for your dream life goals today! 🎀✨",
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _reminderChannelId,
            _reminderChannelName,
            importance: Importance.high,
            priority: Priority.high,
            autoCancel: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      debugPrint('[AlarmService] Scheduled daily savings reminder at $scheduledDate (repeating daily at 6 PM)');
    } catch (e) {
      debugPrint('[AlarmService] Failed to schedule exact daily savings reminder: $e. Falling back to inexact.');
      try {
        await _plugin.zonedSchedule(
          notifId,
          'Savings Time, Bestie! 🌸',
          "Don't forget to set aside some money for your dream life goals today! 🎀✨",
          scheduledDate,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              _reminderChannelId,
              _reminderChannelName,
              importance: Importance.high,
              priority: Priority.high,
              autoCancel: true,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );
        debugPrint('[AlarmService] Scheduled fallback daily savings reminder at $scheduledDate (repeating daily at 6 PM)');
      } catch (innerErr) {
        debugPrint('[AlarmService] Failed to schedule fallback daily savings reminder: $innerErr');
      }
    }
  }

  // ─── Check launch from notification ──────────────────────────────────────

  /// Call this in main() to handle app launched by tapping a notification.
  Future<NotificationAppLaunchDetails?> getLaunchDetails() async {
    return _plugin.getNotificationAppLaunchDetails();
  }

  // ─── Internal ─────────────────────────────────────────────────────────────

  static int _notifId(String taskId) => taskId.hashCode.abs() % 2147483647;

  static void _handleNotificationResponse(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;
    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      final id = data['id'] as String? ?? '';
      final title = data['title'] as String? ?? '';
      AlarmService.onAlarmTriggered?.call(id, title);
    } catch (e) {
      debugPrint('[AlarmService] Failed to parse payload: $e');
    }
  }
}
