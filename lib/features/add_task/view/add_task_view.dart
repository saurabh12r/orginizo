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
        title: const Text("Add Task"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
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

            const Spacer(),

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
                child: const Text(
                  "Save Task",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
