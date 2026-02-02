import 'package:hive/hive.dart';
part 'task_model.g.dart';

/// Default advance reminder offsets (minutes before task start).
const List<int> defaultReminderOffsets = [15, 30];

@HiveType(typeId: 0)
class TaskModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  int day;

  @HiveField(3)
  int startMinutes;

  @HiveField(4)
  int endMinutes;

  @HiveField(5)
  bool isCompleted;

  /// Stored as comma-separated minutes, e.g. "15,30,45". Default "15,30".
  @HiveField(6)
  String reminderOffsetsCsv;

  TaskModel({
    required this.id,
    required this.title,
    required this.day,
    required this.startMinutes,
    required this.endMinutes,
    this.isCompleted = false,
    String? reminderOffsetsCsv,
  }) : reminderOffsetsCsv = reminderOffsetsCsv ?? '15,30';

  /// Advance reminder offsets in minutes before task start. Never null.
  List<int> get reminderOffsets {
    if (reminderOffsetsCsv.trim().isEmpty) return List<int>.from(defaultReminderOffsets);
    return reminderOffsetsCsv
        .split(',')
        .map((e) => int.tryParse(e.trim()))
        .whereType<int>()
        .where((e) => e > 0)
        .toList();
  }

  /// Set reminder offsets; serializes to [reminderOffsetsCsv].
  void setReminderOffsets(List<int> offsets) {
    reminderOffsetsCsv = offsets.join(',');
  }
}
