// lib/app/modules/pomedaro_page/controllers/pomedaro_page_controller.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pomedaro_app/app/modules/home/controllers/home_controller.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:audioplayers/audioplayers.dart';

class PomedaroPageController extends GetxController {
  late int fullWorkDuration; // total session seconds
  late int breakDuration; // break seconds
  late int intervalSeconds; // timeInterval * 60
  RxBool isSessionCompleted = false.obs;

  RxInt remainingTotalWork = 0.obs; // session time left
  RxInt remainingCycle = 0.obs; // current chunk or break countdown
  RxBool isBreak = false.obs;
  RxBool isRunning = false.obs;

  Timer? _timer;

  // Audio player for alerts
  final AudioPlayer _audioPlayer = AudioPlayer();
  late final String taskId;

  @override
  void onInit() {
    super.onInit();
    taskId = Get.arguments['id'] as String;
  }

  void initDurations({
    required String workText,
    required String breakText,
    required String timeduration,
  }) {
    fullWorkDuration = _toSeconds(workText);
    breakDuration = _toSeconds(breakText);
    final mins = _toSeconds(timeduration) ~/ 60;
    intervalSeconds = (mins > 0 ? mins * 60 : fullWorkDuration);

    remainingTotalWork.value = fullWorkDuration;
    remainingCycle.value = intervalSeconds;
    isBreak.value = false;
  }

  int _toSeconds(String label) {
    final n = int.tryParse(label.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    return n * 60;
  }

  void startTimer() {
    if (isRunning.value) return;

    // play focus start sound
    _playAlert('sounds/focus.mp3');

    isRunning.value = true;
    WakelockPlus.enable();
    _timer?.cancel();

    isBreak.value = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (isBreak.value)
        _tickBreak();
      else
        _tickFocus();
    });
  }

  void _tickFocus() {
    if (remainingCycle.value > 0 && remainingTotalWork.value > 0) {
      remainingCycle.value--;
      remainingTotalWork.value--;

      if (remainingCycle.value == 0 && remainingTotalWork.value > 0) {
        // play break start sound
        _playAlert('sounds/break.mp3');
        isBreak.value = true;
        remainingCycle.value = breakDuration;
      }
    } else {
      _completeSession();
    }
  }

  void _tickBreak() {
    if (remainingCycle.value > 0) {
      remainingCycle.value--;
    } else {
      // break over → next work chunk
      // play focus start sound
      _playAlert('sounds/focus.mp3');
      isBreak.value = false;
      final next = remainingTotalWork.value < intervalSeconds
          ? remainingTotalWork.value
          : intervalSeconds;
      remainingCycle.value = next;
    }
  }

  void _completeSession() async {
    _timer?.cancel();
    isSessionCompleted.value = true;
    isRunning.value = false;
    WakelockPlus.disable();

    await FirebaseFirestore.instance
        .collection('tasks')
        .doc(taskId)
        .update({'isCompleted': true});

    Get.find<HomeController>().fetchTasks();
    _playAlert('sounds/achievement.mp3');

    Get.snackbar('Session Complete', 'Great job! You’ve finished.',
        backgroundColor: Colors.green, colorText: Colors.white);
  }

  void pauseTimer() {
    _timer?.cancel();
    isRunning.value = false;
    WakelockPlus.disable();
    _stopAlert();
  }

  void resetTimer() {
    _timer?.cancel();
    isRunning.value = false;
    isBreak.value = false;
    WakelockPlus.disable();
    remainingTotalWork.value = fullWorkDuration;
    remainingCycle.value = intervalSeconds;
    _stopAlert();
  }

  @override
  void onClose() {
    _timer?.cancel();
    WakelockPlus.disable();
    _stopAlert();
    super.onClose();
  }

  Future<void> _playAlert(String assetPath) async {
    try {
      await _audioPlayer.play(AssetSource(assetPath));
    } catch (e) {
      debugPrint('Error playing alert: \$e');
    }
  }

  Future<void> _stopAlert() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      debugPrint('Error stopping alert: \$e');
    }
  }
}
