import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/task_model.dart';
import '../../../data/repository/task_repository.dart';
import '../utils/overlap_utils.dart' as ov;
import '../widgets/day_tasks_bottom_sheet.dart';

class ScheduleController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final TaskRepository _repo = TaskRepository();
  late TabController tabController;

  final dates = <DateTime>[].obs;
  final selectedDay = DateTime.now().obs;

  /// All tasks; updated when Hive box changes. Used for day grouping and overlap.
  final allTasks = <TaskModel>[].obs;

  static const int loadCount = 3;

  @override
  void onInit() {
    super.onInit();
    _refreshTasks();
    _repo.listenable().addListener(_refreshTasks);

    final today = _onlyDate(DateTime.now());
    dates.value = List.generate(
      7,
      (i) => today.add(Duration(days: i - 3)),
    );
    selectedDay.value = today;

    tabController = TabController(
      length: 7,
      vsync: this,
      initialIndex: 3,
    );
    tabController.addListener(_onTabChanged);
  }

  void _refreshTasks() {
    allTasks.value = _repo.getAll();
  }

  void _onTabChanged() {
    if (!tabController.indexIsChanging) {
      selectedDay.value = dates[tabController.index];

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (tabController.index >= dates.length - 1) {
          _shiftForward();
        } else if (tabController.index <= 0) {
          _shiftBackward();
        }
      });
    }
  }

  /// Move forward in time
  void _shiftForward() {
    final lastDate = dates.last;

    final newDates = List.generate(
      loadCount,
          (i) => lastDate.add(Duration(days: i + 1)),
    );

    dates.removeRange(0, loadCount);
    dates.addAll(newDates);

    tabController.animateTo(3);
  }

  /// Move backward in time
  void _shiftBackward() {
    final firstDate = dates.first;

    final newDates = List.generate(
      loadCount,
          (i) => firstDate.subtract(Duration(days: loadCount - i)),
    );

    dates.insertAll(0, newDates);
    dates.removeRange(dates.length - loadCount, dates.length);

    tabController.animateTo(3);
  }

  int get selectedEpoch => _dayEpoch(selectedDay.value);

  DateTime _onlyDate(DateTime d) => DateTime(d.year, d.month, d.day);

  int _dayEpoch(DateTime date) =>
      DateTime(date.year, date.month, date.day).millisecondsSinceEpoch;

  /// Tasks for a day (grouped by day-epoch key).
  List<TaskModel> getTasksForDay(int dayEpoch) {
    final normalized = ov.normalizeDayEpoch(dayEpoch);
    return allTasks
        .where((t) => ov.normalizeDayEpoch(t.day) == normalized)
        .toList()
      ..sort((a, b) => a.startMinutes.compareTo(b.startMinutes));
  }

  /// True if this day has at least two tasks with overlapping time ranges.
  bool dayHasOverlappingTasks(int dayEpoch) {
    return ov.dayHasOverlappingTasks(getTasksForDay(dayEpoch));
  }

  /// True if [task] overlaps with another task on the same day.
  bool isTaskInConflict(TaskModel task, int dayEpoch) {
    return ov.isTaskInConflict(task, getTasksForDay(dayEpoch));
  }

  /// Opens modal bottom sheet with all tasks for [date]; Edit and Delete per task.
  void openDayBottomSheet(DateTime date) {
    final dayEpoch = _dayEpoch(date);
    Get.bottomSheet(
      DayTasksBottomSheet(dayEpoch: dayEpoch, date: date),
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      ignoreSafeArea: false,
    );
  }

  @override
  void onClose() {
    _repo.listenable().removeListener(_refreshTasks);
    tabController.dispose();
    super.onClose();
  }
}