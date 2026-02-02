import 'package:get/get.dart';

import '../../../data/repository/task_repository.dart';
import '../../../routes/app_routes.dart';

class MainShellController extends GetxController {
  /// true = Schedule view, false = Home view.
  final isSchedulePage = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Sync from Firestore on launch (Hive already loaded → UI shows; then merge remote into Hive).
    TaskRepository().syncFromRemote();
  }

  void goToSchedule() {
    isSchedulePage.value = true;
  }

  void goToHome() {
    isSchedulePage.value = false;
  }

  /// Toggle between Home and Schedule (single nav target).
  void toggleSchedule() {
    isSchedulePage.toggle();
  }

  void goToAddTask() {
    Get.toNamed(Routes.addTask);
  }
}
