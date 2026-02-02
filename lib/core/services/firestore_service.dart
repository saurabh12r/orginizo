import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Firestore access for user profile only. Path: users/{uid}.
/// Fields: name, createdAt (optional). No task data.
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _collectionUsers = 'users';

  /// Fetches display name for [uid]. Returns null if doc missing or error.
  Future<String?> getUserName(String uid) async {
    if (uid.isEmpty) return null;
    try {
      final doc = await _firestore.collection(_collectionUsers).doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return doc.data()!['name'] as String?;
      }
      return null;
    } catch (e, st) {
      debugPrint('FirestoreService.getUserName error: $e\n$st');
      return null;
    }
  }

  /// Saves display name for [uid]. Sets name and createdAt.
  Future<void> saveUserName(String uid, String name) async {
    if (uid.isEmpty || name.trim().isEmpty) return;
    try {
      await _firestore.collection(_collectionUsers).doc(uid).set({
        'name': name.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e, st) {
      debugPrint('FirestoreService.saveUserName error: $e\n$st');
      rethrow;
    }
  }
}
