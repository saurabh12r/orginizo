import 'package:get/get.dart';

import '../features/add_task/view/add_task_view.dart';
import '../features/schedule/view/schedule_view.dart';
import '../features/test/testui.dart';
import 'app_routes.dart';

class Pages{

  static final page = [
    GetPage(name: Routes.schedule, page: () => ScheduleView()),
    GetPage(name: Routes.addTask, page: () => AddTaskPage()),
    GetPage(name: Routes.test, page: () => TasksTestPage()),
  ];




}