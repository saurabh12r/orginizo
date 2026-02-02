import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../data/models/task_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  static const String _channelId = 'task_channel_id';
  static const String _channelName = 'Task Reminders';

  /// Unique notification id per (taskId, offset). Offset 0 = at task start.
  static int _notificationId(String taskId, int offsetMinutes) {
    return Object.hash(taskId, offsetMinutes);
  }

  Future<void> init() async {
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);

    await _plugin.initialize(settings);

    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// Cancel all scheduled notifications for a task (at-start + all advance reminders).
  Future<void> cancelAllForTask(String taskId, List<int> reminderOffsets) async {
    await _plugin.cancel(_notificationId(taskId, 0));
    for (final offset in reminderOffsets) {
      await _plugin.cancel(_notificationId(taskId, offset));
    }
    debugPrint('Cancelled all notifications for task $taskId');
  }

  /// Schedule at-start + advance reminders. Skips past times. Returns count scheduled.
  /// Call [cancelAllForTask] for this task before calling when updating.
  Future<int> scheduleTaskReminders(TaskModel task) async {
    final date = DateTime.fromMillisecondsSinceEpoch(task.day);
    final taskStart = DateTime(
      date.year,
      date.month,
      date.day,
      task.startMinutes ~/ 60,
      task.startMinutes % 60,
    );
    final now = DateTime.now();
    int scheduled = 0;

    // 1) At exact task start — "Task starting now"
    if (!taskStart.isBefore(now)) {
      await _scheduleOne(
        id: _notificationId(task.id, 0),
        title: '📅 ${task.title}',
        body: 'Task starting now',
        scheduledTime: taskStart,
      );
      scheduled++;
    }

    // 2) Advance reminders — "Task starts in X minutes"
    final offsets = task.reminderOffsets;
    final seenMinute = <int>{};
    for (final offsetMinutes in offsets) {
      final reminderTime = taskStart.subtract(Duration(minutes: offsetMinutes));
      if (reminderTime.isBefore(now)) continue;
      final minuteKey = reminderTime.millisecondsSinceEpoch ~/ 60000;
      if (seenMinute.contains(minuteKey)) continue;
      seenMinute.add(minuteKey);

      await _scheduleOne(
        id: _notificationId(task.id, offsetMinutes),
        title: '📅 ${task.title}',
        body: _reminderBody(offsetMinutes),
        scheduledTime: reminderTime,
      );
      scheduled++;
    }

    debugPrint('Scheduled $scheduled notifications for task ${task.id}');
    return scheduled;
  }

  String _reminderBody(int offsetMinutes) {
    if (offsetMinutes >= 60) {
      final hours = offsetMinutes ~/ 60;
      return hours == 1
          ? 'Task starts in 1 hour'
          : 'Task starts in $hours hours';
    }
    return 'Task starts in $offsetMinutes minutes';
  }

  Future<void> _scheduleOne({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    final zoned = tz.TZDateTime.from(scheduledTime, tz.local);
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      zoned,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: 'Task and meeting reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> scheduleAfterSeconds(int seconds) async {
    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Task and meeting reminders',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    final details = NotificationDetails(android: androidDetails);
    final time = tz.TZDateTime.now(tz.local).add(Duration(seconds: seconds));

    await _plugin.zonedSchedule(
      0,
      '⏰ Time is up!',
      'Your $seconds second timer finished',
      time,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
}
