import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ScheduleController extends GetxController
    with GetSingleTickerProviderStateMixin {

  late TabController tabController;

  final dates = <DateTime>[].obs;
  final selectedDay = DateTime.now().obs;

  static const int loadCount = 5;

  @override
  void onInit() {
    super.onInit();

    final today = _onlyDate(DateTime.now());

    dates.value = List.generate(7, (i) => today.add(Duration(days: i)));
    selectedDay.value = dates.first;

    tabController = TabController(length: 7, vsync: this);
    tabController.addListener(_onTabChanged);
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

  void _shiftForward() {
    final last = dates.last;

    final newDays = List.generate(
      loadCount,
          (i) => last.add(Duration(days: i + 1)),
    );

    dates.removeRange(0, loadCount);
    dates.addAll(newDays);

    tabController.animateTo(6 - loadCount);
  }

  void _shiftBackward() {
    final first = dates.first;

    final newDays = List.generate(
      loadCount,
          (i) => first.subtract(Duration(days: loadCount - i)),
    );

    dates.insertAll(0, newDays);
    dates.removeRange(dates.length - loadCount, dates.length);

    tabController.animateTo(loadCount);
  }

  int get selectedEpoch => _dayEpoch(selectedDay.value);

  DateTime _onlyDate(DateTime d) => DateTime(d.year, d.month, d.day);

  int _dayEpoch(DateTime date) =>
      DateTime(date.year, date.month, date.day).millisecondsSinceEpoch;

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}
