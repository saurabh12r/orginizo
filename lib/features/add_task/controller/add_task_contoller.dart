import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/notification_services.dart';
import '../../../data/models/task_model.dart';
import '../../../data/repository/task_repository.dart';

class AddTaskController extends GetxController {
  final titleController = TextEditingController();
  final TaskRepository _repo = TaskRepository();

  var selectedDate = DateTime.now().obs;
  var startTime = const TimeOfDay(hour: 9, minute: 0).obs;
  var endTime = const TimeOfDay(hour: 11, minute: 0).obs;

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
    }
  }

  // ---------------- PICKERS ----------------

  Future<void> pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
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

  // ---------------- SAVE ----------------

  void saveTask() {
    if (titleController.text.trim().isEmpty) return;

    final startMin = startTime.value.hour * 60 + startTime.value.minute;
    final endMin = endTime.value.hour * 60 + endTime.value.minute;

    final day = DateTime(
      selectedDate.value.year,
      selectedDate.value.month,
      selectedDate.value.day,
    ).millisecondsSinceEpoch;

    if (_editingTask != null) {
      final updated = TaskModel(
        id: _editingTask!.id,
        title: titleController.text.trim(),
        day: day,
        startMinutes: startMin,
        endMinutes: endMin,
        isCompleted: _editingTask!.isCompleted,
      );
      _repo.updateTask(updated);
      NotificationService().scheduleTaskNotification(
        id: updated.id,
        title: updated.title,
        date: DateTime.fromMillisecondsSinceEpoch(updated.day),
        startMinutes: updated.startMinutes,
      );
    } else {
      final task = TaskModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: titleController.text.trim(),
        day: day,
        startMinutes: startMin,
        endMinutes: endMin,
      );
      _repo.addTask(task);
      NotificationService().scheduleTaskNotification(
        id: task.id,
        title: task.title,
        date: DateTime.fromMillisecondsSinceEpoch(task.day),
        startMinutes: task.startMinutes,
      );
    }
    Get.back();
  }

  @override
  void onClose() {
    titleController.dispose();
    super.onClose();
  }
}
