import 'package:flutter/foundation.dart';

import '../../core/services/local_storage_services/hive_services.dart';
import '../models/task_model.dart';
import 'task_remote_repository.dart';

class TaskRepository {
  final HiveService _hive = HiveService();
  final TaskRemoteRepository _remote = TaskRemoteRepository();

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
    _remote.pushTask(task); // Fire-and-forget; Firestore failure must not block Hive
  }

  void deleteTask(String id) {
    _hive.delete(id);
    _remote.pushDelete(id);
  }

  void updateTask(TaskModel task) {
    _hive.save(task);
    _remote.pushUpdate(task);
  }

  /// Fetches tasks from Firestore by username, merges with Hive (last-write-wins), overwrites Hive.
  /// Call on app launch (e.g. MainShellController.onInit). Non-blocking; errors logged.
  Future<void> syncFromRemote() async {
    await _remote.syncFromRemote(_hive);
  }

  ValueListenable listenable() {
    return _hive.listenable();
  }
}
