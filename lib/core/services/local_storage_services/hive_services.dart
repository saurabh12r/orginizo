import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import '../../../data/models/task_model.dart';

class HiveService {
  final Box<TaskModel> _box = Hive.box<TaskModel>('tasks');

  void save(TaskModel task) {
    _box.put(task.id, task); // key = task.id
  }

  void delete(String id) {
    _box.delete(id);
  }

  /// Replaces all tasks in the box (used when syncing from Firestore).
  /// Does not change Hive schema; same box, same TaskModel type.
  void putAll(List<TaskModel> tasks) {
    _box.clear();
    for (final task in tasks) {
      _box.put(task.id, task);
    }
  }

  List<TaskModel> getAll() {
    return _box.values.toList();
  }

  ValueListenable<Box<TaskModel>> listenable() {
    return _box.listenable();
  }
}
