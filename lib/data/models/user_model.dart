/// Minimal user profile for display name. No task data.
/// Stored in Firestore users/{uid}; optional createdAt for future use.
class UserModel {
  final String name;
  final DateTime? createdAt;

  UserModel({required this.name, this.createdAt});
}
