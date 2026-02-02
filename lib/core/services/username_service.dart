import 'package:shared_preferences/shared_preferences.dart';

/// Stores and resolves the current username locally.
/// Username is set at signup (from name field) and reused for Firestore sync.
/// No UI dependency; no Firestore writes. Single responsibility.
class UsernameService {
  static const String _keyUsername = 'username';

  Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUsername);
  }

  Future<void> setUsername(String username) async {
    if (username.trim().isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUsername, username.trim());
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUsername);
  }
}
