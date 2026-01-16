import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/task_model.dart';
import '../../data/repository/task_repository.dart';

class TasksTestPage extends StatelessWidget {
  TasksTestPage({super.key});

  final TaskRepository repo = TaskRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tasks (Test View)"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Get.toNamed('/add');
            },
          ),
        ],
      ),

      body: ValueListenableBuilder(
        valueListenable: repo.listenable(),
        builder: (context, box, _) {
          final tasks = repo.getTasksForDay(_today());

          if (tasks.isEmpty) {
            return const Center(child: Text("No tasks yet"));
          }

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final TaskModel task = tasks[index];

              final start =
                  "${task.startMinutes ~/ 60}:${(task.startMinutes % 60).toString().padLeft(2, '0')}";
              final end =
                  "${task.endMinutes ~/ 60}:${(task.endMinutes % 60).toString().padLeft(2, '0')}";

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(task.title),
                  subtitle: Text("$start - $end"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      repo.deleteTask(task.id);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  int _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
  }
}
