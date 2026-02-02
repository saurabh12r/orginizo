import 'package:firebase_auth/firebase_auth.dart';

import '../../core/services/firestore_service.dart';

/// Repository for current user's display name. Uses Firebase Auth uid + Firestore.
/// No Firestore calls in UI; no changes to task layer.
class UserRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestore = FirestoreService();

  String? get currentUid => _auth.currentUser?.uid;

  /// Fetches display name from Firestore for current user. Returns null if not signed in or error.
  Future<String?> getCurrentUserName() async {
    final uid = currentUid;
    if (uid == null || uid.isEmpty) return null;
    return _firestore.getUserName(uid);
  }

  /// Saves display name to Firestore for current user. No-op if not signed in.
  Future<void> saveCurrentUserName(String name) async {
    final uid = currentUid;
    if (uid == null || uid.isEmpty) return;
    await _firestore.saveUserName(uid, name);
  }
}
