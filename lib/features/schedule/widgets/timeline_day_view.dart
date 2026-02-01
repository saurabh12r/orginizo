import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/colors.dart';
import '../../../data/models/task_model.dart';
import '../../../data/repository/task_repository.dart';
import '../controller/schedule_controller.dart';
import '../utils/overlap_utils.dart' as ov;

final List<List<Color>> timelinePalettes = [
  [Color(0xFFC7D66D), Color(0xFFB7CC4F)], // Green
  [Color(0xFF9A95D6), Color(0xFF7E7AC4)], // Purple
  [Color(0xFFF6C1A1), Color(0xFFF0A878)], // Peach
  [Color(0xFF8FD3F4), Color(0xFF6FBFEA)], // Blue
  [Color(0xFFE8A1C4), Color(0xFFD982AE)], // Pink
];

class TimelineDayView extends StatelessWidget {
  const TimelineDayView({super.key, required this.day});

  final int day;

  static const double hourHeight = 80;

  int _normalizeDay(int value) {
    final d = DateTime.fromMillisecondsSinceEpoch(value);
    return DateTime(d.year, d.month, d.day).millisecondsSinceEpoch;
  }

  List<Color> getTaskGradient(String id) {
    final index = id.hashCode.abs() % timelinePalettes.length;
    return timelinePalettes[index];
  }

  @override
  Widget build(BuildContext context) {
    final repo = TaskRepository();
    final selectedDay = _normalizeDay(day);

    return ValueListenableBuilder(
      valueListenable: repo.listenable(),
      builder: (context, box, _) {
        final tasks = repo
            .getTasksForDay(selectedDay)
            .where((t) => _normalizeDay(t.day) == selectedDay)
            .toList();
        final groups = ov.overlapGroups(tasks);

        return SingleChildScrollView(
          child: SizedBox(
            height: 24 * hourHeight,
            child: Stack(
              children: [
                _grid(tasks),
                ...groups.map((group) => _groupCard(context, group)),
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

  // ---------------- GROUP CARD (single task or overlapping group) ----------------

  Widget _groupCard(BuildContext context, List<TaskModel> group) {
    final topPadding = (hourHeight / 2) - 30;
    final earliestStart = group.map((t) => t.startMinutes).reduce((a, b) => a < b ? a : b);
    final top = topPadding + (earliestStart / 60) * hourHeight;

    if (group.length == 1) {
      return Positioned(
        top: top,
        left: 65,
        right: 20,
        child: _singleTaskCard(group.single),
      );
    }

    return Positioned(
      top: top,
      left: 65,
      right: 20,
      child: _overlapGroupCard(context, group),
    );
  }

  Widget _singleTaskCard(TaskModel task) {
    final colors = getTaskGradient(task.id);
    return Container(
      height: 65,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(37),
        gradient: LinearGradient(colors: colors),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
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
    );
  }

  Widget _overlapGroupCard(BuildContext context, List<TaskModel> group) {
    final count = group.length;
    final colors = [OrColors.purple, OrColors.purple.withOpacity(0.8)];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          final controller = Get.find<ScheduleController>();
          controller.openDayBottomSheet(DateTime.fromMillisecondsSinceEpoch(day));
        },
        borderRadius: BorderRadius.circular(37),
        child: Container(
          height: 65,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(37),
            gradient: LinearGradient(colors: colors),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.event_note_rounded,
                      color: Colors.white.withOpacity(0.9),
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      count == 1 ? "1 task" : "$count tasks",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Tap to view",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.95),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
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
