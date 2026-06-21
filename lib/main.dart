import 'dart:convert';
import 'package:flutter/material.dart';
import 'injection_container.dart';
import 'core/services/alarm_service.dart';
import 'features/alarm/alarm_page.dart';
import 'app.dart';

/// Global navigator key used by AlarmService to navigate from background
/// notification callbacks.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();

  // ─── Init AlarmService ───
  final alarmService = AlarmService();
  await alarmService.init();

  // ─── Wire notification → AlarmPage navigation ───
  AlarmService.onAlarmTriggered = (taskId, taskTitle) {
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        settings: const RouteSettings(name: '/alarm'),
        builder: (_) => AlarmPage(taskId: taskId, taskTitle: taskTitle),
      ),
    );
  };

  // ─── Handle app launched by tapping notification (cold start) ───
  final launchDetails = await alarmService.getLaunchDetails();
  String? coldStartTaskId;
  String? coldStartTaskTitle;
  if (launchDetails != null &&
      launchDetails.didNotificationLaunchApp &&
      launchDetails.notificationResponse?.payload != null) {
    try {
      final data = jsonDecode(
              launchDetails.notificationResponse!.payload!) as Map<String, dynamic>;
      coldStartTaskId = data['id'] as String?;
      coldStartTaskTitle = data['title'] as String?;
    } catch (_) {}
  }

  runApp(WorkaholicApp(
    coldStartAlarmTaskId: coldStartTaskId,
    coldStartAlarmTitle: coldStartTaskTitle,
  ));
}
