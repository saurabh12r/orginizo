import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/notification_services.dart';
import '../../../data/models/task_model.dart';
import '../../../data/repository/task_repository.dart';
import '../../schedule/utils/overlap_utils.dart' as ov;

/// Reminder options (minutes before task start) shown in add/edit task UI.
const List<int> reminderOptionMinutes = [15, 30, 45, 60];

/// Minimum task duration in minutes before showing a warning.
const int minDurationWarningMinutes = 5;

/// Date range: no tasks before today or after this year.
DateTime get _todayStart => DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
DateTime get _maxDate => DateTime(DateTime.now().year + 1, 12, 31);

class AddTaskController extends GetxController {
  final titleController = TextEditingController();
  final TaskRepository _repo = TaskRepository();

  var selectedDate = DateTime.now().obs;
  var startTime = const TimeOfDay(hour: 9, minute: 0).obs;
  var endTime = const TimeOfDay(hour: 11, minute: 0).obs;

  /// Selected advance reminder offsets (minutes before start). Default [15, 30].
  final selectedReminderOffsets = <int>[15, 30].obs;

  TaskModel? _editingTask;
  bool get isEditMode => _editingTask != null;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is TaskModel) {
      _editingTask = args;
      titleController.text = args.title;
      selectedDate.value = DateTime.fromMillisecondsSinceEpoch(args.day);
      startTime.value = TimeOfDay(
        hour: args.startMinutes ~/ 60,
        minute: args.startMinutes % 60,
      );
      endTime.value = TimeOfDay(
        hour: args.endMinutes ~/ 60,
        minute: args.endMinutes % 60,
      );
      selectedReminderOffsets.value = args.reminderOffsets.isEmpty
          ? List.from(reminderOptionMinutes.take(2))
          : List.from(args.reminderOffsets);
    }
  }

  void toggleReminder(int offsetMinutes) {
    if (selectedReminderOffsets.contains(offsetMinutes)) {
      selectedReminderOffsets.remove(offsetMinutes);
    } else {
      selectedReminderOffsets.add(offsetMinutes);
      selectedReminderOffsets.sort();
    }
    selectedReminderOffsets.refresh();
  }

  bool isReminderSelected(int offsetMinutes) =>
      selectedReminderOffsets.contains(offsetMinutes);

  // ---------------- PICKERS ----------------

  Future<void> pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value.isBefore(_todayStart) ? _todayStart : selectedDate.value,
      firstDate: _todayStart,
      lastDate: _maxDate,
    );
    if (picked != null) {
      selectedDate.value = picked;
    }
  }

  Future<void> pickStartTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: startTime.value,
    );
    if (picked != null) {
      startTime.value = picked;
      final startMin = picked.hour * 60 + picked.minute;
      final endMin = endTime.value.hour * 60 + endTime.value.minute;
      if (endMin <= startMin) {
        endTime.value = TimeOfDay(
          hour: (startMin ~/ 60 + 1) % 24,
          minute: startMin % 60,
        );
      }
    }
  }

  Future<void> pickEndTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: endTime.value,
    );
    if (picked != null) {
      endTime.value = picked;
    }
  }

  // ---------------- VALIDATION (centralized, reusable for Add & Edit) ----------------

  /// Returns error message or null if valid.
  String? validateTitle() {
    final t = titleController.text.trim();
    if (t.isEmpty) return 'Please enter a task title.';
    return null;
  }

  /// Returns error message or null if valid.
  String? validateDate() {
    final d = selectedDate.value;
    final today = DateTime(d.year, d.month, d.day);
    final start = DateTime(_todayStart.year, _todayStart.month, _todayStart.day);
    if (today.isBefore(start)) return 'Please select today or a future date.';
    if (today.isAfter(DateTime(_maxDate.year, _maxDate.month, _maxDate.day))) {
      return 'Please select a date within the allowed range.';
    }
    return null;
  }

  /// Returns error message or null if valid. Call only when date is today.
  String? validateStartTimeNotInPast() {
    final d = selectedDate.value;
    final today = DateTime(d.year, d.month, d.day);
    final now = DateTime.now();
    if (today.year != now.year || today.month != now.month || today.day != now.day) {
      return null;
    }
    final startMin = startTime.value.hour * 60 + startTime.value.minute;
    final nowMin = now.hour * 60 + now.minute;
    if (startMin < nowMin) return 'Task start time has already passed.';
    return null;
  }

  /// Returns error message or null if valid.
  String? validateEndTime(int startMin, int endMin) {
    if (endMin <= startMin) return 'End time must be after start time.';
    return null;
  }

  /// Returns true if user confirms to proceed, false if cancel.
  Future<bool> confirmShortDuration(int startMin, int endMin) async {
    final duration = endMin - startMin;
    if (duration >= minDurationWarningMinutes) return true;
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Short task'),
        content: Text(
          'This task is only $duration minutes. Do you want to save it anyway?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Save anyway'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
    return result ?? false;
  }

  /// Returns true if user chooses to proceed, false if cancel.
  Future<bool> confirmOverlap(int dayEpoch, int startMin, int endMin) async {
    final dayTasks = _repo.getTasksForDay(dayEpoch);
    final others = _editingTask != null
        ? dayTasks.where((t) => t.id != _editingTask!.id).toList()
        : dayTasks;
    for (final t in others) {
      if (ov.timeRangesOverlap(t.startMinutes, t.endMinutes, startMin, endMin)) {
        final result = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Overlapping task'),
            content: const Text(
              'This task overlaps with another task on the same day. Do you want to save it anyway?',
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: const Text('Proceed anyway'),
              ),
            ],
          ),
          barrierDismissible: false,
        );
        return result ?? false;
      }
    }
    return true;
  }

  void _showValidationError(String message) {
    Get.snackbar(
      'Cannot save',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFE57373),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  // ---------------- SAVE ----------------

  Future<void> saveTask() async {
    final titleError = validateTitle();
    if (titleError != null) {
      _showValidationError(titleError);
      return;
    }

    final dateError = validateDate();
    if (dateError != null) {
      _showValidationError(dateError);
      return;
    }

    final startMin = startTime.value.hour * 60 + startTime.value.minute;
    final endMin = endTime.value.hour * 60 + endTime.value.minute;

    final startTimeError = validateStartTimeNotInPast();
    if (startTimeError != null) {
      _showValidationError(startTimeError);
      return;
    }

    final endTimeError = validateEndTime(startMin, endMin);
    if (endTimeError != null) {
      _showValidationError(endTimeError);
      return;
    }

    final durationOk = await confirmShortDuration(startMin, endMin);
    if (!durationOk) return;

    final day = DateTime(
      selectedDate.value.year,
      selectedDate.value.month,
      selectedDate.value.day,
    ).millisecondsSinceEpoch;

    final overlapOk = await confirmOverlap(day, startMin, endMin);
    if (!overlapOk) return;

    final offsets = selectedReminderOffsets.isEmpty
        ? <int>[15, 30]
        : List<int>.from(selectedReminderOffsets);
    final reminderCsv = offsets.join(',');

    if (_editingTask != null) {
      final updated = TaskModel(
        id: _editingTask!.id,
        title: titleController.text.trim(),
        day: day,
        startMinutes: startMin,
        endMinutes: endMin,
        isCompleted: _editingTask!.isCompleted,
        reminderOffsetsCsv: reminderCsv,
      );
      await NotificationService().cancelAllForTask(
        updated.id,
        _editingTask!.reminderOffsets,
      );
      _repo.updateTask(updated);
      final scheduled = await NotificationService().scheduleTaskReminders(updated);
      if (scheduled == 0) {
        Get.snackbar(
          'Reminders',
          'Task updated, but all reminder times are in the past.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } else {
      final task = TaskModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: titleController.text.trim(),
        day: day,
        startMinutes: startMin,
        endMinutes: endMin,
        reminderOffsetsCsv: reminderCsv,
      );
      _repo.addTask(task);
      final scheduled = await NotificationService().scheduleTaskReminders(task);
      if (scheduled == 0) {
        Get.snackbar(
          'Reminders',
          'Task saved, but all reminder times are in the past.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
    Get.back();
  }

  @override
  void onClose() {
    titleController.dispose();
    super.onClose();
  }
}
