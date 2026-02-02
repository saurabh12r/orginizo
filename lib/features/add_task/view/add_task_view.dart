import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/colors.dart';
import '../controller/add_task_contoller.dart';

class AddTaskPage extends StatelessWidget {
  AddTaskPage({super.key});

  final AddTaskController controller = Get.put(AddTaskController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(controller.isEditMode ? "Edit Task" : "Add Task"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// -------- Title ----------
            const Text("Task Title", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            _input(),

            const SizedBox(height: 20),

            /// -------- Date ----------
            const Text("Date", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Obx(() {
              final d = controller.selectedDate.value;
              return InkWell(
                onTap: () => controller.pickDate(context),
                child: _picker("${d.day} ${_month(d.month)}"),
              );
            }),

            const SizedBox(height: 20),

            /// -------- Time ----------
            Row(
              children: [
                Expanded(
                  child: Obx(() => InkWell(
                    onTap: () => controller.pickStartTime(context),
                    child: _timePicker(
                      "Start",
                      controller.startTime.value.format(context),
                    ),
                  )),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Obx(() => InkWell(
                    onTap: () => controller.pickEndTime(context),
                    child: _timePicker(
                      "End",
                      controller.endTime.value.format(context),
                    ),
                  )),
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// -------- Remind me ----------
            const Text(
              "Remind me",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                for (final minutes in reminderOptionMinutes)
                  Obx(() => _ReminderChip(
                    label: minutes == 60 ? 'Before 1 hr' : 'Before $minutes min',
                    isSelected: controller.isReminderSelected(minutes),
                    onTap: () => controller.toggleReminder(minutes),
                  )),
              ],
            ),

            const SizedBox(height: 24),

            /// -------- Save ----------
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: OrColors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: controller.saveTask,
                child: Text(
                  controller.isEditMode ? "Update Task" : "Save Task",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ---------- Widgets ----------

  Widget _input() {
    return TextField(
      controller: controller.titleController,
      decoration: InputDecoration(
        hintText: "Design UI",
        filled: true,
        fillColor: OrColors.bg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _picker(String text) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: OrColors.bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text),
          const Icon(Icons.arrow_drop_down),
        ],
      ),
    );
  }

  Widget _timePicker(String label, String time) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 6),
        _picker(time),
      ],
    );
  }

  String _month(int m) {
    const months = [
      "",
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    return months[m];
  }
}

class _ReminderChip extends StatelessWidget {
  const _ReminderChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? OrColors.primaryGreen : OrColors.bg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected ? OrColors.primaryGreenDark : OrColors.textGrey.withOpacity(0.4),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : OrColors.textDark,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
