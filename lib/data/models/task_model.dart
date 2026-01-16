import 'package:hive/hive.dart';
part 'task_model.g.dart';

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

  TaskModel({
    required this.id,
    required this.title,
    required this.day,
    required this.startMinutes,
    required this.endMinutes,
    this.isCompleted = false,
  });
}
