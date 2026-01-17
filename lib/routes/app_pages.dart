import 'package:get/get.dart';

import '../features/add_task/view/add_task_view.dart';
import '../features/login/view/login_screen_view.dart';
import '../features/login/view/signup_screen_view.dart';
import '../features/schedule/view/schedule_view.dart';
import '../features/splash/view/splash_screen_view.dart';
import '../features/splash/controller/splash_screen_controller.dart';
import '../features/test/testui.dart';
import 'app_routes.dart';

class Pages {
  static final page = [
    GetPage(
      name: Routes.splash,
      page: () => SplashScreen(),
      binding: BindingsBuilder(() => Get.put(SplashController())),
    ),
    GetPage(name: Routes.schedule, page: () => ScheduleView()),
    GetPage(name: Routes.addTask, page: () => AddTaskPage()),
    GetPage(name: Routes.test, page: () => TasksTestPage()),
    GetPage(name: Routes.login, page: () => LoginScreen()),
    GetPage(name: Routes.signup, page: () => SignUpScreen()),
  ];
}
