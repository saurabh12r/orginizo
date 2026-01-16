import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models/task_model.dart';
import '../../../data/repository/task_repository.dart';


final List<List<Color>> timelinePalettes = [
  [Color(0xFFC7D66D), Color(0xFFB7CC4F)], // Green
  [Color(0xFF9A95D6), Color(0xFF7E7AC4)], // Purple
  [Color(0xFFF6C1A1), Color(0xFFF0A878)], // Peach
  [Color(0xFF8FD3F4), Color(0xFF6FBFEA)], // Blue
  [Color(0xFFE8A1C4), Color(0xFFD982AE)], // Pink
];

class TimelineDayView extends StatelessWidget {
  final int day;
  TimelineDayView({required this.day, super.key});

  final double hourHeight = 80;
  final TaskRepository repo = TaskRepository();

  // Normalize epoch to midnight
  int _normalizeDay(int value) {
    final d = DateTime.fromMillisecondsSinceEpoch(value);
    return DateTime(d.year, d.month, d.day).millisecondsSinceEpoch;
  }

  // Stable color for each task
  List<Color> getTaskGradient(String id) {
    final index = id.hashCode.abs() % timelinePalettes.length;
    return timelinePalettes[index];
  }

  @override
  Widget build(BuildContext context) {
    final selectedDay = _normalizeDay(day);

    return ValueListenableBuilder(
      valueListenable: repo.listenable(),
      builder: (context, box, _) {
        final tasks = repo
            .getTasksForDay(selectedDay)
            .where((t) => _normalizeDay(t.day) == selectedDay)
            .toList();

        return SingleChildScrollView(
          child: SizedBox(
            height: 24 * hourHeight,
            child: Stack(
              children: [
                _grid(tasks),
                ...tasks.map(_taskCard),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------------- GRID ----------------

  Widget _grid(List<TaskModel> tasks) {
    return Column(
      children: List.generate(24, (i) {
        final hourStart = i * 60;
        final hourEnd = (i + 1) * 60;

        final hasTask = tasks.any((t) =>
        t.startMinutes >= hourStart &&
            t.startMinutes < hourEnd);

        final hour = i == 0 ? 12 : i > 12 ? i - 12 : i;
        final period = i < 12 ? "AM" : "PM";

        return Padding(
          padding: const EdgeInsets.only(left: 10),
          child: SizedBox(
            height: hourHeight,
            child: Row(
              children: [
                SizedBox(width: 70, child: Text("$hour $period")),
                Expanded(
                  child: hasTask
                      ? const SizedBox()
                      : Divider(color: Colors.grey.shade300),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ---------------- TASK CARD ----------------

  Widget _taskCard(TaskModel task) {
    final topPadding = (hourHeight / 2) - 30;
    final colors = getTaskGradient(task.id);

    return Positioned(
      top: topPadding + (task.startMinutes / 60) * hourHeight,
      left: 65,
      right: 20,
      child: Container(
        height: 65,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(37),
          gradient: LinearGradient(colors: colors),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Task Title
            Expanded(
              child: Text(
                task.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(width: 10),

            // Time pill (like the design)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.4)),
              ),
              child: Text(
                "${_formatTime(task.startMinutes)} - ${_formatTime(task.endMinutes)}",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;

    final hour = h > 12 ? h - 12 : h == 0 ? 12 : h;
    final suffix = h >= 12 ? "PM" : "AM";

    return "${hour.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')} $suffix";
  }

}
