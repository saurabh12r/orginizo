import 'package:flutter/foundation.dart';

import '../../core/services/firestore_task_service.dart';
import '../../core/services/username_service.dart';
import '../models/task_model.dart';
import '../../core/services/local_storage_services/hive_services.dart';

/// Orchestrates Firestore sync: push after Hive write, pull and merge on launch.
/// Firestore failure must never block Hive. Sync is invisible to UI.
class TaskRemoteRepository {
  final FirestoreTaskService _firestore = FirestoreTaskService();
  final UsernameService _usernameService = UsernameService();

  /// Pushes task to Firestore under current username. Fire-and-forget; errors logged.
  Future<void> pushTask(TaskModel task) async {
    final username = await _usernameService.getUsername();
    if (username == null || username.isEmpty) return;
    try {
      await _firestore.setTask(username, task);
    } catch (e, st) {
      debugPrint('TaskRemoteRepository.pushTask error: $e\n$st');
    }
  }

  /// Pushes update to Firestore. Fire-and-forget; errors logged.
  Future<void> pushUpdate(TaskModel task) async {
    await pushTask(task);
  }

  /// Deletes task from Firestore. Fire-and-forget; errors logged.
  Future<void> pushDelete(String taskId) async {
    final username = await _usernameService.getUsername();
    if (username == null || username.isEmpty) return;
    try {
      await _firestore.deleteTask(username, taskId);
    } catch (e, st) {
      debugPrint('TaskRemoteRepository.pushDelete error: $e\n$st');
    }
  }

  /// Fetches tasks from Firestore, merges with Hive (last-write-wins: Firestore overwrites same id),
  /// keeps Hive-only tasks, then overwrites Hive with merged list.
  /// Firestore is authoritative only when Hive is empty or task exists in Firestore (overwrite same id).
  Future<void> syncFromRemote(HiveService hive) async {
    final username = await _usernameService.getUsername();
    if (username == null || username.isEmpty) return;
    try {
      final remoteMaps = await _firestore.fetchTasks(username);
      final remoteTasks = remoteMaps
          .map((m) => FirestoreTaskService.mapToTask(m))
          .where((t) => t.id.isNotEmpty)
          .toList();
      final localTasks = hive.getAll();
      final localIds = localTasks.map((t) => t.id).toSet();
      final remoteIds = remoteTasks.map((t) => t.id).toSet();
      // Merge: Firestore overwrites same id; keep local-only tasks.
      final merged = <TaskModel>[];
      for (final t in remoteTasks) {
        merged.add(t);
      }
      for (final t in localTasks) {
        if (!remoteIds.contains(t.id)) {
          merged.add(t);
        }
      }
      hive.putAll(merged);
    } catch (e, st) {
      debugPrint('TaskRemoteRepository.syncFromRemote error: $e\n$st');
    }
  }
}
