import 'package:get/get.dart';

import '../features/add_task/view/add_task_view.dart';
import '../features/login/controller/login_controller.dart';
import '../features/login/controller/signup_screen_controller.dart';
import '../features/login/view/login_screen_view.dart';
import '../features/login/view/signup_screen_view.dart';
import '../features/schedule/controller/schedule_controller.dart';
import '../features/schedule/view/schedule_view.dart';
import '../features/splash/controller/splash_screen_controller.dart';
import '../features/splash/view/splash_screen_view.dart';
import '../features/test/testui.dart';
import 'app_routes.dart';

class Pages {
  static final List<GetPage> page = [
    GetPage(
      name: Routes.splash,
      page: () => const SplashScreen(),
      binding: BindingsBuilder(() => Get.put(SplashController())),
    ),
    GetPage(
      name: Routes.login,
      page: () => const LoginScreen(),
      binding: BindingsBuilder(() => Get.put(LoginController())),
    ),
    GetPage(
      name: Routes.signup,
      page: () => const SignUpScreen(),
      binding: BindingsBuilder(() => Get.put(SignUpController())),
    ),
    GetPage(
      name: Routes.schedule,
      page: () => const ScheduleView(),
      binding: BindingsBuilder(() => Get.put(ScheduleController())),
    ),
    GetPage(name: Routes.addTask, page: () => AddTaskPage()),
    GetPage(name: Routes.test, page: () => TasksTestPage()),
  ];
}
