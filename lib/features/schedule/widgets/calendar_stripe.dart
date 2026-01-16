import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

class CalendarStrip extends StatelessWidget {
  final TabController controller;
  final List<DateTime> dates;

  final List<String> days = ["S", "M", "T", "W", "T", "F", "S"];

  CalendarStrip({super.key, required this.controller, required this.dates});

  @override
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return TabBar(
            controller: controller,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: OrColors.green,
            labelPadding: const EdgeInsets.symmetric(horizontal: 10),
            tabs: List.generate(7, (index) {
              final date = dates[index];
              final isSelected = controller.index == index;

              return Tab(
                height: 100,
                child: Column(
                  children: [
                    Text(
                      days[index],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

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
                          ),
                        ),
                      )
                          : Text(
                        date.day.toString(),
                        style: TextStyle(
                          color: OrColors.textGrey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          );
        },
      ),
    );
  }

}
