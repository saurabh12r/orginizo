import 'package:flutter/foundation.dart';
import '../../core/services/local_storage_services/hive_services.dart';
import '../models/task_model.dart';


class TaskRepository {
  final HiveService _hive = HiveService();

  List<TaskModel> getTasksForDay(int day) {
    return _hive.getAll().where((t) => t.day == day).toList();
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
