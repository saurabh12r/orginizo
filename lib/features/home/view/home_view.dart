import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/colors.dart';
import '../../../data/models/task_model.dart';
import '../../../routes/app_routes.dart';
import '../controller/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  HomeController get controller =>
      Get.isRegistered<HomeController>()
          ? Get.find<HomeController>()
          : Get.put(HomeController());

  static String _formatTime(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    final hour = h > 12 ? h - 12 : h == 0 ? 12 : h;
    final suffix = h >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')} $suffix';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OrColors.bg,
      body: Obx(() {
        final tasks = controller.todayTasks;

        return CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            /// 🌤️ SLIVER APP BAR – only greeting vanishes; Today/subtitle/chip always visible, never overlapped by cards
            SliverAppBar(
              expandedHeight: 180,
              toolbarHeight: 118,
              pinned: true,
              stretch: true,
              backgroundColor: OrColors.bg,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              actions: [
                IconButton(
                  onPressed: controller.logout,
                  icon: Icon(Icons.logout_rounded, color: OrColors.textDark),
                  tooltip: 'Logout',
                ),
              ],
              flexibleSpace: LayoutBuilder(
                builder: (context, constraints) {
                  final appBarHeight = constraints.biggest.height;
                  const expandedH = 180.0;

                  // Greeting only visible when fully expanded; totally invisible as soon as user scrolls
                  final showGreeting = appBarHeight >= expandedH - 2;

                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          OrColors.primaryGreen.withOpacity(0.06),
                          OrColors.primaryGreen.withOpacity(0.02),
                        ],
                      ),
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: Stack(
                        children: [
                          /// 🌤️ GREETING – Good Morning, {name} ☀️ or fallback; reactive via Obx
                          if (showGreeting)
                            Positioned(
                              left: 20,
                              right: 20,
                              top: 12,
                              child: Obx(() => Text(
                                controller.greetingText,
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: OrColors.textDark,
                                  letterSpacing: -0.5,
                                  height: 1.2,
                                ),
                              )),
                            ),
                          /// 📅 TODAY BLOCK – always on top, overlaps greeting (not task cards)
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    OrColors.primaryGreen.withOpacity(0.06),
                                    OrColors.primaryGreen.withOpacity(0.02),
                                  ],
                                  stops: const [0.0, 0.5, 1.0],
                                ),
                              ),
                              child: SingleChildScrollView(
                                physics: const NeverScrollableScrollPhysics(),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Today',
                                      style: TextStyle(
                                        color: OrColors.textDark,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      controller.todaySubtitle,
                                      style: TextStyle(
                                        color: OrColors.textGrey,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    _TaskCountChip(count: controller.taskCount),
                                    const SizedBox(height: 5),

                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            /// EMPTY STATE
            if (tasks.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyState(
                  onAddTap: controller.goToAddTask,
                ),
              )
            else ...[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final task = tasks[index];
                      return Dismissible(
                        key: ValueKey(task.id),
                        direction: DismissDirection.endToStart,
                        background: _DismissBackground(),
                        onDismissed: (_) => controller.deleteTask(task),
                        child: _TaskCard(task: task),
                      );
                    },
                    childCount: tasks.length,
                  ),
                ),
              ),
            ],
          ],
        );
      }),

      /// ➕ ADD TASK FAB – rounded pill, soft green, slight elevation
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.goToAddTask,
        backgroundColor: OrColors.primaryGreen,
        foregroundColor: OrColors.textDark,
        elevation: 2,
        focusElevation: 3,
        icon: const Icon(Icons.add_rounded, size: 22),
        label: const Text(
          'Add Task',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

/// 🔹 TASK COUNT CHIP
/// Task count chip – rounded pill, soft green background, dark green text
class _TaskCountChip extends StatelessWidget {
  const _TaskCountChip({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: count > 0
            ? OrColors.primaryGreen.withOpacity(0.18)
            : OrColors.textGrey.withOpacity(0.12),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        count == 0 ? 'No tasks' : count == 1 ? '1 task' : '$count tasks',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: count > 0 ? OrColors.primaryGreenDark : OrColors.textGrey,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAddTap});
  final VoidCallback onAddTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: OrColors.primaryGreen.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.today_rounded,
                size: 56,
                color: OrColors.primaryGreenDark.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'No tasks for today',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                color: OrColors.textDark,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Add a task and it will show up here',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: OrColors.textGrey,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: onAddTap,
              icon: const Icon(Icons.add_rounded, size: 22),
              label: const Text('Add Task'),
              style: FilledButton.styleFrom(
                backgroundColor: OrColors.primaryGreen,
                foregroundColor: OrColors.textDark,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DismissBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      decoration: BoxDecoration(
        color: OrColors.textGrey.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(
        Icons.delete_outline_rounded,
        color: OrColors.bg,
        size: 28,
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task});
  final TaskModel task;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: OrColors.primaryGreen.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => Get.toNamed(Routes.addTask, arguments: task),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 48,
                  decoration: BoxDecoration(
                    color: OrColors.primaryGreenDark,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        task.title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: OrColors.textDark,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 16,
                            color: OrColors.textGrey.withOpacity(0.9),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${HomeView._formatTime(task.startMinutes)} – ${HomeView._formatTime(task.endMinutes)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: OrColors.textGrey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: OrColors.textGrey.withOpacity(0.5),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}