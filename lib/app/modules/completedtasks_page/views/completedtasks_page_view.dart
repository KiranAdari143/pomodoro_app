// lib/app/modules/completedtasks_page/views/completed_tasks_page_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pomedaro_app/app/modules/completedtasks_page/controllers/completedtasks_page_controller.dart';

class CompletedTasksPageView extends StatelessWidget {
  final CompletedtasksPageController controller =
      Get.find<CompletedtasksPageController>();

  CompletedTasksPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Completed Tasks'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.completedTasks.isEmpty) {
          return const Center(child: Text('No completed tasks yet.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.completedTasks.length,
          itemBuilder: (context, index) {
            final task = controller.completedTasks[index];
            return Card(
              elevation: 8.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: Text(
                  task['title'] ?? "",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${task['date']} • Work: ${task['workDuration']} • Break: ${task['breakDuration']} • Interval: ${task['timeIntervalDuration']}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    final confirmDelete = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Confirm Deletion'),
                        content: const Text(
                            'Are you sure you want to remove this task?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: const Text('Remove'),
                          ),
                        ],
                      ),
                    );

                    if (confirmDelete == true) {
                      controller.deleteCompletedTask(task['id']);
                    }
                  },
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
