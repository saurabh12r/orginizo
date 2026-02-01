import 'package:flutter/material.dart';

import '../../../core/constants/colors.dart';
import '../controller/schedule_controller.dart';

class CalendarStrip extends StatelessWidget {
  const CalendarStrip({
    super.key,
    required this.tabController,
    required this.dates,
    required this.scheduleController,
  });

  final TabController tabController;
  final List<DateTime> dates;
  final ScheduleController scheduleController;

  static const List<String> _days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: AnimatedBuilder(
        animation: tabController,
        builder: (context, _) {
          return TabBar(
              controller: tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorColor: OrColors.green,
              labelPadding: const EdgeInsets.symmetric(horizontal: 10),
              tabs: List.generate(7, (index) {
                final date = dates[index];
                final isSelected = tabController.index == index;

                return Tab(
                  height: 110,
                  child: GestureDetector(
                    onDoubleTap: () {
                      scheduleController.openDayBottomSheet(dates[index]);
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _days[index % 7],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 6),
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: isSelected
                            ? OrColors.green.withOpacity(0.5)
                            : OrColors.bg,
                        child: isSelected
                            ? CircleAvatar(
                                radius: 18,
                                backgroundColor: OrColors.green,
                                child: Text(
                                  date.day.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              )
                            : Text(
                                date.day.toString(),
                                style: TextStyle(
                                  color: OrColors.textGrey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ],
                  ),
                  ),
                );
              }),
            );
        },
      ),
    );
  }
}
