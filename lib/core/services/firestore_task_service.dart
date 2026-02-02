import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../data/models/task_model.dart';

/// Firestore path: tasks_by_user/{username}/tasks/{taskId}
/// Fields: title, day, startMinutes, endMinutes, isCompleted, reminderOffsetsCsv, updatedAt
/// No UID/email stored; Firebase Auth UID used only for security rules.
class FirestoreTaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _collectionUsers = 'tasks_by_user';
  static const String _subcollectionTasks = 'tasks';

  /// Fetches all tasks for [username]. Returns list of maps with task data + id.
  /// Map keys: id, title, day, startMinutes, endMinutes, isCompleted, reminderOffsetsCsv, updatedAt
  Future<List<Map<String, dynamic>>> fetchTasks(String username) async {
    if (username.trim().isEmpty) return [];
    try {
      final snapshot = await _firestore
          .collection(_collectionUsers)
          .doc(username.trim())
          .collection(_subcollectionTasks)
          .get();
      final list = <Map<String, dynamic>>[];
      for (final doc in snapshot.docs) {
        final data = doc.data();
        list.add({
          'id': doc.id,
          'title': data['title'] as String? ?? '',
          'day': data['day'] as int? ?? 0,
          'startMinutes': data['startMinutes'] as int? ?? 0,
          'endMinutes': data['endMinutes'] as int? ?? 0,
          'isCompleted': data['isCompleted'] as bool? ?? false,
          'reminderOffsetsCsv': data['reminderOffsetsCsv'] as String? ?? '15,30',
          'updatedAt': data['updatedAt'] is Timestamp
              ? (data['updatedAt'] as Timestamp).millisecondsSinceEpoch
              : data['updatedAt'] as int? ?? 0,
        });
      }
      return list;
    } catch (e, st) {
      debugPrint('FirestoreTaskService.fetchTasks error: $e\n$st');
      rethrow;
    }
  }

  /// Adds or overwrites task under [username]. Sets updatedAt to now.
  Future<void> setTask(String username, TaskModel task) async {
    if (username.trim().isEmpty) return;
    try {
      final docRef = _firestore
          .collection(_collectionUsers)
          .doc(username.trim())
          .collection(_subcollectionTasks)
          .doc(task.id);
      await docRef.set({
        'title': task.title,
        'day': task.day,
        'startMinutes': task.startMinutes,
        'endMinutes': task.endMinutes,
        'isCompleted': task.isCompleted,
        'reminderOffsetsCsv': task.reminderOffsetsCsv,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e, st) {
      debugPrint('FirestoreTaskService.setTask error: $e\n$st');
      rethrow;
    }
  }

  /// Deletes task [taskId] under [username].
  Future<void> deleteTask(String username, String taskId) async {
    if (username.trim().isEmpty) return;
    try {
      await _firestore
          .collection(_collectionUsers)
          .doc(username.trim())
          .collection(_subcollectionTasks)
          .doc(taskId)
          .delete();
    } catch (e, st) {
      debugPrint('FirestoreTaskService.deleteTask error: $e\n$st');
      rethrow;
    }
  }

  /// Converts Firestore map (with id, updatedAt) to [TaskModel]. updatedAt is not stored on model.
  static TaskModel mapToTask(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      day: map['day'] as int? ?? 0,
      startMinutes: map['startMinutes'] as int? ?? 0,
      endMinutes: map['endMinutes'] as int? ?? 0,
      isCompleted: map['isCompleted'] as bool? ?? false,
      reminderOffsetsCsv: map['reminderOffsetsCsv'] as String? ?? '15,30',
    );
  }
}
