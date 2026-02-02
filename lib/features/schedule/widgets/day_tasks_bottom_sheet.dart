import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/colors.dart';
import '../../../core/services/notification_services.dart';
import '../../../data/models/task_model.dart';
import '../../../data/repository/task_repository.dart';
import '../../../routes/app_routes.dart';
import '../controller/schedule_controller.dart';
import '../utils/overlap_utils.dart' as ov;

/// Modal bottom sheet showing all tasks for a single day.
/// Each task has Edit and Delete; overlapping tasks show a conflict indicator.
class DayTasksBottomSheet extends StatelessWidget {
  const DayTasksBottomSheet({
    super.key,
    required this.dayEpoch,
    required this.date,
  });

  final int dayEpoch;
  final DateTime date;

  static String _formatTime(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    final hour = h > 12 ? h - 12 : h == 0 ? 12 : h;
    final suffix = h >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')} $suffix';
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ScheduleController>();
    final maxHeight = MediaQuery.sizeOf(context).height * 0.7;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: OrColors.bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHandle(),
            Obx(() {
              final tasks = controller.getTasksForDay(dayEpoch);
              final hasOverlap = ov.dayHasOverlappingTasks(tasks);
              if (tasks.isEmpty) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                      child: Row(
                        children: [
                          Text(
                            _dateTitle(date),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: OrColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'No tasks this day',
                        style: TextStyle(
                          color: OrColors.textGrey,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                );
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    child: Row(
                      children: [
                        Text(
                          _dateTitle(date),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: OrColors.textDark,
                          ),
                        ),
                        if (hasOverlap) ...[
                          const SizedBox(width: 8),
                          _conflictChip(),
                        ],
                      ],
                    ),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: maxHeight - 120,
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: tasks.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        final inConflict =
                            ov.isTaskInConflict(task, tasks);
                        return _TaskTile(
                          task: task,
                          inConflict: inConflict,
                          onEdit: () => _navigateToEdit(task),
                          onDelete: () => _deleteTask(task),
                        );
                      },
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: OrColors.textGrey.withOpacity(0.4),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _conflictChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning_amber_rounded,
              size: 16, color: Colors.orange.shade800),
          const SizedBox(width: 4),
          Text(
            'Overlapping',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.orange.shade800,
            ),
          ),
        ],
      ),
    );
  }

  String _dateTitle(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  void _navigateToEdit(TaskModel task) {
    Get.back();
    Get.toNamed(Routes.addTask, arguments: task);
  }

  void _deleteTask(TaskModel task) {
    NotificationService().cancelAllForTask(task.id, task.reminderOffsets);
    TaskRepository().deleteTask(task.id);
    final controller = Get.find<ScheduleController>();
    final remaining = controller.getTasksForDay(dayEpoch);
    if (remaining.isEmpty) Get.back();
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({
    required this.task,
    required this.inConflict,
    required this.onEdit,
    required this.onDelete,
  });

  final TaskModel task;
  final bool inConflict;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.06),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            if (inConflict)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(
                  Icons.warning_amber_rounded,
                  size: 20,
                  color: Colors.orange.shade700,
                ),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    task.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: OrColors.textDark,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${DayTasksBottomSheet._formatTime(task.startMinutes)} – '
                    '${DayTasksBottomSheet._formatTime(task.endMinutes)}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: OrColors.textGrey,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined, color: OrColors.primaryGreen),
              tooltip: 'Edit',
            ),
            IconButton(
              onPressed: onDelete,
              icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
              tooltip: 'Delete',
            ),
          ],
        ),
      ),
    );
  }
}
