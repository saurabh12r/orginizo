class TaskModel {
  final String id;
  final String title;
  final int day;
  final int startMinutes;
  final int endMinutes;

  TaskModel({
    required this.id,
    required this.title,
    required this.day,
    required this.startMinutes,
    required this.endMinutes,
  });
}
