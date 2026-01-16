import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);

    await _plugin.initialize(settings);

    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> scheduleAfterSeconds(int seconds) async {
    const androidDetails = AndroidNotificationDetails(
      'task_channel_id',
      'Task Reminders',
      channelDescription: 'Task and meeting reminders',
      importance: Importance.max, // This handles the "Pop up" on Android
      priority: Priority.high,    // This handles the "Pop up" on Android
      ticker: 'ticker',
      // No presentAlert or presentSound here
    );
    const details = NotificationDetails(android: androidDetails);
    final time = tz.TZDateTime.now(tz.local).add(Duration(seconds: seconds));

    await _plugin.zonedSchedule(
      0,
      '⏰ Time is up!',
      'Your $seconds second timer finished',
      time,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      // Parameter removed for version 17+
    );

    print("System Local Time: ${DateTime.now()}");
    print("Timezone Local Time: ${tz.TZDateTime.now(tz.local)}");
  }

  Future<void> scheduleTaskNotification({
    required String id,
    required String title,
    required DateTime date,
    required int startMinutes,
  }) async {
    // Create the specific DateTime
    final scheduledDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      startMinutes ~/ 60,
      startMinutes % 60,
    );

    // LOG THIS: If this print says a time that has already passed,
    // the notification will never show.
    debugPrint("Scheduling for: $scheduledDateTime");

    await _plugin.zonedSchedule(
      id.hashCode,
      '📅 $title',
      'Your task is starting now',
      // FIX: Use tz.TZDateTime.from to ensure it maps correctly
      tz.TZDateTime.from(scheduledDateTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_channel_id',
          'Task Reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      // Note: Parameter 'uiLocalNotificationDateInterpretation' is removed in v17+
    );
  }}