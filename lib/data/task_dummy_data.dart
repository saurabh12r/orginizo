import '../features/schedule/model/task_model.dart';

final today = DateTime.now();
final todayEpoch =
    DateTime(today.year, today.month, today.day).millisecondsSinceEpoch;

final tomorrowEpoch =
    DateTime(today.year, today.month, today.day + 1).millisecondsSinceEpoch;

final yesterdayEpoch =
    DateTime(today.year, today.month, today.day - 1).millisecondsSinceEpoch;

final List<TaskModel> dummyTasks = [
  TaskModel(
    id: "1",
    title: "Morning Review",
    day: todayEpoch,
    startMinutes: 8 * 60,  // 8:00 AM
    endMinutes: 10 * 60,
  ),
  TaskModel(
    id: "2",
    title: "Client Sync",
    day: todayEpoch,
    startMinutes: 11 * 60, // 11:00 AM
    endMinutes: 12 * 60,
  ),
  TaskModel(
    id: "3",
    title: "Deep Work",
    day: tomorrowEpoch,
    startMinutes: 9 * 60, // 9:00 AM
    endMinutes: 12 * 60,
  ),
  TaskModel(
    id: "4",
    title: "Yesterday Task",
    day: yesterdayEpoch,
    startMinutes: 14 * 60, // 2:00 PM
    endMinutes: 16 * 60,
  ),
];
