import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/calendar_stripe.dart';
import '../widgets/timeline_day_view.dart';
import '../widgets/header_bar.dart';
import '../widgets/tittle_bar.dart';
import '../controller/schedule_controller.dart';

class ScheduleView extends StatelessWidget {
  ScheduleView({super.key});

  final ScheduleController controller = Get.put(ScheduleController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HeaderBar(),
      body: Column(
        children: [
          const SizedBox(height: 15),
          const TitleBar(),

          /// Calendar
          Obx(() => CalendarStrip(
            key: ValueKey(controller.dates.first.millisecondsSinceEpoch),
            controller: controller.tabController,
            dates: controller.dates,
          )),

          /// Timeline
          Obx(() => Expanded(
            child: TimelineDayView(
              day: controller.selectedEpoch,
            ),
          )),
        ],
      ),
    );
  }
}
