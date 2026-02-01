import 'package:flutter/foundation.dart';
import '../../core/services/local_storage_services/hive_services.dart';
import '../models/task_model.dart';


class TaskRepository {
  final HiveService _hive = HiveService();

  List<TaskModel> getAll() {
    return _hive.getAll();
  }

  List<TaskModel> getTasksForDay(int dayEpoch) {
    final normalized = _normalizeDay(dayEpoch);
    return _hive.getAll().where((t) => _normalizeDay(t.day) == normalized).toList();
  }

  static int _normalizeDay(int epochMs) {
    final d = DateTime.fromMillisecondsSinceEpoch(epochMs);
    return DateTime(d.year, d.month, d.day).millisecondsSinceEpoch;
  }

  void addTask(TaskModel task) {
    _hive.save(task);
  }

  void deleteTask(String id) {
    _hive.delete(id);
  }

  void updateTask(TaskModel task) {
    _hive.save(task);
  }


  ValueListenable listenable() {
    return _hive.listenable();
  }
}
