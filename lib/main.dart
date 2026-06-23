import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'injection_container.dart';
import 'core/services/alarm_service.dart';
import 'features/alarm/presentation/pages/alarm_page.dart';
import 'app.dart';

/// Global navigator key used by AlarmService to navigate from background
/// notification callbacks.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  try {
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
  } catch (e, stack) {
    debugPrint("Initialization error: $e\n$stack");
    runApp(InitializationErrorApp(error: e, stack: stack));
  }
}

class InitializationErrorApp extends StatefulWidget {
  final Object error;
  final StackTrace stack;

  const InitializationErrorApp({
    super.key,
    required this.error,
    required this.stack,
  });

  @override
  State<InitializationErrorApp> createState() => _InitializationErrorAppState();
}

class _InitializationErrorAppState extends State<InitializationErrorApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFFFDF6F8),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.error_outline, color: Color(0xFFE8A0BF), size: 56),
                  const SizedBox(height: 16),
                  const Text(
                    "App Initialization Failed 😭",
                    style: TextStyle(
                      fontSize: 22, 
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A0F12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      widget.error.toString(),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Stacktrace:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A0F12),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                    ),
                    child: Text(
                      widget.stack.toString(),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
