// lib/app/modules/pomedaro_page/views/pomedaro_page_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/pomedaro_page_controller.dart';

class PomedaroPageView extends StatefulWidget {
  final String title;
  final String workDuration; // e.g. "30"
  final String breakDuration; // e.g. "5"
  final String timeInterval; // e.g. "2"

  const PomedaroPageView({
    super.key,
    required this.title,
    required this.workDuration,
    required this.breakDuration,
    required this.timeInterval,
  });

  @override
  State<PomedaroPageView> createState() => _PomedaroPageViewState();
}

class _PomedaroPageViewState extends State<PomedaroPageView> {
  late final PomedaroPageController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(PomedaroPageController());
    controller.initDurations(
      workText: widget.workDuration,
      breakText: widget.breakDuration,
      timeduration: widget.timeInterval,
    );
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Obx(() {
            final displayText = controller.isBreak.value
                ? _formatTime(controller.remainingCycle.value)
                : _formatTime(controller.remainingTotalWork.value);

            return Column(
              // shrink to contents vertically
              mainAxisSize: MainAxisSize.min,
              // center children horizontally
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // header & session-left only while not completed
                if (!controller.isSessionCompleted.value) ...[
                  Text(
                    controller.isBreak.value ? 'Break Time' : 'Focus Time',
                    style: textTheme.headlineLarge?.copyWith(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Session left: ${_formatTime(controller.remainingTotalWork.value)}',
                    style: textTheme.headlineSmall?.copyWith(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),
                ],

                // always show the timer circle
                Container(
                  width: 200,
                  height: 200,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.deepPurple.shade100,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurple.withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Text(
                    displayText,
                    style: textTheme.displaySmall?.copyWith(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                // celebration message once completed
                if (controller.isSessionCompleted.value) ...[
                  const SizedBox(height: 24),
                  Text(
                    '🎉 Session complete!',
                    style: textTheme.titleMedium?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],

                const SizedBox(height: 40),

                // buttons only while session running/not completed
                if (!controller.isSessionCompleted.value)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        icon: Icon(
                          controller.isRunning.value
                              ? Icons.pause
                              : Icons.play_arrow,
                        ),
                        label: Text(
                          controller.isRunning.value ? 'Pause' : 'Start',
                          style: textTheme.bodyLarge
                              ?.copyWith(color: Colors.white),
                        ),
                        onPressed: () {
                          controller.isRunning.value
                              ? controller.pauseTimer()
                              : controller.startTimer();
                        },
                      ),
                      const SizedBox(width: 20),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: Text(
                          'Reset',
                          style: textTheme.bodyLarge
                              ?.copyWith(color: Colors.deepPurple),
                        ),
                        onPressed: controller.resetTimer,
                      ),
                    ],
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
