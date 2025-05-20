// lib/app/modules/home/views/home_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    const List<int> minuteOptions = [5, 10, 15, 20, 25, 30, 60, 80, 100, 200];

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pomodoro Tasks'),
          centerTitle: true,
          backgroundColor: Colors.deepPurple,
          elevation: 0,
          bottom: TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 4,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: const [
              Tab(text: 'Dashboard'),
              Tab(text: 'Tasks'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.assignment_turned_in_rounded,
                color: Colors.white,
              ),
              tooltip: 'View Completed Tasks',
              onPressed: () => Get.toNamed('/completedtasks-page'),
            ),
          ],
        ),
        body: TabBarView(
          children: [
            // Dashboard Tab (reactive)
            Obx(
              () => Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // This Week
                      Card(
                        color: Colors.deepPurple.shade50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        child: ListTile(
                          leading: const Icon(
                            Icons.calendar_view_week,
                            color: Colors.deepPurple,
                          ),
                          title: const Text(
                            'This Week',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                          subtitle: Text(
                            'Added Tasks: ${controller.weeklyStats['added']}\n'
                            'Completed Tasks: ${controller.weeklyStats['completed']}',
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // This Month
                      Card(
                        color: Colors.deepPurple.shade50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        child: ListTile(
                          leading: const Icon(
                            Icons.calendar_month,
                            color: Colors.deepPurple,
                          ),
                          title: const Text(
                            'This Month',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                          subtitle: Text(
                            'Added Tasks: ${controller.monthlyStats['added']}\n'
                            'Completed Tasks: ${controller.monthlyStats['completed']}',
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // This Year
                      Card(
                        color: Colors.deepPurple.shade50,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                        child: ListTile(
                          leading: const Icon(Icons.calendar_today,
                              color: Colors.deepPurple),
                          title: const Text('This Year',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple)),
                          subtitle: Text(
                            'Added Tasks: ${controller.yearlyStats['added']}\n'
                            'Completed Tasks: ${controller.yearlyStats['completed']}',
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Overall Completion Rate
                      Card(
                        color: Colors.deepPurple.shade50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 24, horizontal: 16),
                          child: Column(
                            children: [
                              const Text(
                                'Overall Completion',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 100,
                                    height: 100,
                                    child: CircularProgressIndicator(
                                      value: controller.completionRate,
                                      strokeWidth: 8,
                                      backgroundColor: Colors.red,
                                      valueColor: AlwaysStoppedAnimation(
                                          Colors.deepPurple),
                                    ),
                                  ),
                                  Text(
                                    '${(controller.completionRate * 100).toStringAsFixed(0)}%',
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                controller.productivityLabel,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Tasks Tab
            Column(
              children: [
                GestureDetector(
                  onTap: () => _showAddTaskDialog(context, minuteOptions),
                  child: Card(
                    margin: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: Colors.deepPurple.shade100,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      width: double.infinity,
                      child: Row(
                        children: const [
                          Icon(
                            Icons.add_circle,
                            size: 30,
                            color: Colors.deepPurple,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Add New Task',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Obx(() {
                    final tasks = controller.incompleteTasks;
                    if (tasks.isEmpty) {
                      return const Center(child: Text('No tasks added.'));
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: tasks.length,
                      itemBuilder: (ctx, i) {
                        final t = tasks[i];
                        final taskDate =
                            DateFormat('yyyy-MM-dd').parse(t['date'] as String);
                        final isPast = taskDate.isBefore(
                          DateTime(
                            DateTime.now().year,
                            DateTime.now().month,
                            DateTime.now().day,
                          ),
                        );
                        final icon = isPast
                            ? Icons.block
                            : (t['isTicked'] == true
                                ? Icons.check_circle
                                : Icons.check_circle_outline);
                        final iconColor = isPast
                            ? Colors.redAccent
                            : (t['isTicked'] == true
                                ? Colors.green
                                : Colors.grey);

                        return Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: IconButton(
                              icon: Icon(icon, color: iconColor),
                              onPressed: isPast
                                  ? null
                                  : () => controller.toggleTaskTicked(i),
                            ),
                            title: Text(
                              t['title'] ?? "",
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              '${t['date']} • Work: ${t['workDuration']} • '
                              'Break: ${t['breakDuration']} • '
                              'Interval: ${t['timeIntervalDuration']}',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.redAccent),
                              onPressed: () => controller.removeTask(i),
                            ),
                            onTap: isPast
                                ? null
                                : () => Get.toNamed(
                                      '/pomedaro-page',
                                      arguments: {
                                        'id': t['id'],
                                        'title': t['title'],
                                        'workDuration': t['workDuration'],
                                        'breakDuration': t['breakDuration'],
                                        'timeInterval':
                                            t['timeIntervalDuration'],
                                        'audioLocalPath': t['audioLocalPath'],
                                      },
                                    ),
                          ),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context, List<int> minuteOptions) {
    final titleCtl = TextEditingController();
    DateTime? pickDate;
    int? w, b, i;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Add New Task',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: StatefulBuilder(
          builder: (ctx, setSt) {
            return SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextField(
                  controller: titleCtl,
                  decoration: const InputDecoration(
                      labelText: 'Task Title', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: Text(pickDate == null
                      ? 'Pick Date'
                      : DateFormat('yyyy-MM-dd').format(pickDate!)),
                  onPressed: () async {
                    final d = await showDatePicker(
                        context: ctx,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100));
                    if (d != null) setSt(() => pickDate = d);
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Work Duration (mins)'),
                  value: w,
                  items: minuteOptions
                      .map((m) =>
                          DropdownMenuItem(value: m, child: Text('$m mins')))
                      .toList(),
                  onChanged: (v) => setSt(() => w = v),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Break Duration (mins)'),
                  value: b,
                  items: minuteOptions
                      .map((m) =>
                          DropdownMenuItem(value: m, child: Text('$m mins')))
                      .toList(),
                  onChanged: (v) => setSt(() => b = v),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Interval Duration (mins)'),
                  value: i,
                  items: minuteOptions
                      .map((m) =>
                          DropdownMenuItem(value: m, child: Text('$m mins')))
                      .toList(),
                  onChanged: (v) => setSt(() => i = v),
                ),
              ]),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleCtl.text.isEmpty ||
                  pickDate == null ||
                  w == null ||
                  b == null ||
                  i == null) {
                // show snack only in dialog context to avoid flicker
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(
                    content: const Text('Please fill in all fields'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              Navigator.of(dialogContext).pop();
              await controller.addTask(
                title: titleCtl.text,
                date: DateFormat('yyyy-MM-dd').format(pickDate!),
                workDuration: '${w!} mins',
                breakDuration: '${b!} mins',
                timeIntervalDuration: '${i!} mins',
              );
            },
            child: const Text('Add Task'),
          ),
        ],
      ),
    );
  }
}
