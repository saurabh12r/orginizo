import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/colors.dart';
import '../../home/view/home_view.dart';
import '../../schedule/view/schedule_view.dart';
import '../controller/main_shell_controller.dart';

class MainShellView extends GetView<MainShellController> {
  const MainShellView({super.key});

  static const double _navHeight = 68;
  static const double _navMargin = 20;

  @override
  MainShellController get controller =>
      Get.isRegistered<MainShellController>()
          ? Get.find<MainShellController>()
          : Get.put(MainShellController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSchedule = controller.isSchedulePage.value;

      return Scaffold(
        extendBody: true,
        backgroundColor: OrColors.bg,

        /// 🌤️ APP BAR (HOME ONLY)

        /// 📄 BODY (THIS FIXES THE OVERLAP)
        body: Padding(
          padding: const EdgeInsets.only(
            bottom: _navHeight + _navMargin + 16,
          ),
          child: IndexedStack(
            index: isSchedule ? 1 : 0,
            children: const [
              HomeView(),
              ScheduleView(),
            ],
          ),
        ),

        /// 🧭 FLOATING PREMIUM BOTTOM NAV
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(
            _navMargin,
            0,
            _navMargin,
            _navMargin,
          ),
          child: SafeArea(
            child: Container(
              height: _navHeight,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: OrColors.primaryGreen.withOpacity(0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _NavItem(
                    icon: Icons.calendar_month_rounded,
                    label: 'Schedule',
                    isSelected: isSchedule,
                    onTap: controller.toggleSchedule,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  /// 🌅 Greeting logic
  String _greetingText() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning ☀️';
    if (hour < 17) return 'Good Afternoon 🌤️';
    return 'Good Evening 🌙';
  }
}

/// 🔹 NAV ITEM
class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        splashColor: OrColors.primaryGreen.withOpacity(0.1),
        highlightColor: OrColors.primaryGreen.withOpacity(0.05),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          decoration: BoxDecoration(
            color: isSelected
                ? OrColors.primaryGreen.withOpacity(0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
            border: isSelected
                ? Border.all(
              color: OrColors.primaryGreen.withOpacity(0.25),
              width: 1.5,
            )
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 24,
                color: isSelected
                    ? OrColors.primaryGreenDark
                    : OrColors.textGrey,
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight:
                  isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected
                      ? OrColors.primaryGreenDark
                      : OrColors.textGrey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}