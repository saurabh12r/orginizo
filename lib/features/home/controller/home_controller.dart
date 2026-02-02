import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../core/services/local_storage_services/pref_service.dart';
import '../../../core/services/notification_services.dart';
import '../../../core/services/username_service.dart';
import '../../../data/models/task_model.dart';
import '../../../data/repository/task_repository.dart';
import '../../../data/repository/user_repository.dart';
import '../../../routes/app_routes.dart';

/// Today's day epoch (midnight) for filtering.
int _todayEpoch() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
}

class HomeController extends GetxController {
  final TaskRepository _repo = TaskRepository();
  final UserRepository _userRepo = UserRepository();

  /// Today's tasks; updates when Hive box changes.
  final todayTasks = <TaskModel>[].obs;

  /// User display name from Firestore (users/{uid}/name). Empty until loaded or on error.
  final userName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadTodayTasks();
    _repo.listenable().addListener(_loadTodayTasks);
    _loadUserName();
  }

  /// Loads user name from Firestore. Does not block; fallback greeting if unavailable.
  Future<void> _loadUserName() async {
    try {
      final name = await _userRepo.getCurrentUserName();
      if (name != null && name.trim().isNotEmpty) {
        userName.value = name.trim();
      }
    } catch (_) {
      // Firestore failure must not crash Home; keep default greeting
    }
  }

  /// Greeting text with name if loaded, else default. Reactive for Obx.
  String get greetingText {
    final hour = DateTime.now().hour;
    String base;
    String emoji;
    if (hour < 12) {
      base = 'Good Morning';
      emoji = '☀️';
    } else if (hour < 17) {
      base = 'Good Afternoon';
      emoji = '🌤️';
    } else {
      base = 'Good Evening';
      emoji = '🌙';
    }
    final name = userName.value.trim();
    if (name.isNotEmpty) {
      return '$base, $name $emoji';
    }
    return '$base $emoji';
  }

  void _loadTodayTasks() {
    final epoch = _todayEpoch();
    todayTasks.value = _repo.getTasksForDay(epoch)
      ..sort((a, b) => a.startMinutes.compareTo(b.startMinutes));
  }

  int get taskCount => todayTasks.length;

  /// Formatted date for subtitle, e.g. "Monday, Feb 2".
  String get todaySubtitle {
    final now = DateTime.now();
    const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final weekday = weekdays[now.weekday - 1];
    final month = months[now.month - 1];
    return '$weekday, $month ${now.day}';
  }

  void goToAddTask() {
    Get.toNamed(Routes.addTask);
  }

  /// Signs out from Firebase, clears local auth state, navigates to login.
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    await PrefService().setLoggedIn(false);
    await UsernameService().clear();
    Get.offAllNamed(Routes.login);
  }

  /// Delete task and cancel its notifications. List updates reactively via Hive listener.
  Future<void> deleteTask(TaskModel task) async {
    await NotificationService().cancelAllForTask(task.id, task.reminderOffsets);
    _repo.deleteTask(task.id);
  }

  @override
  void onClose() {
    _repo.listenable().removeListener(_loadTodayTasks);
    super.onClose();
  }
}
