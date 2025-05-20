import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class CompletedtasksPageController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GetStorage _box = GetStorage();

  /// All completed tasks to show in the list
  var completedTasks = <Map<String, dynamic>>[].obs;

  /// Persisted set of locally deleted task IDs
  var locallyDeleted = <String>[].obs;

  late final String deviceId;

  @override
  Future<void> onInit() async {
    super.onInit();
    // ✂️ remove await GetStorage.init();
    final saved = _box.read<List>('completedLocallyDeleted') ?? [];
    locallyDeleted.assignAll(saved.cast<String>());
    ever<List<String>>(locallyDeleted, (_) {
      _box.write('completedLocallyDeleted', locallyDeleted.toList());
    });
    await _initDeviceId();
    await fetchCompletedTasks();
  }

  Future<void> _initDeviceId() async {
    final dpi = DeviceInfoPlugin();
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      final info = await dpi.androidInfo;
      deviceId = info.id;
    } else if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      final info = await dpi.iosInfo;
      deviceId = info.identifierForVendor!;
    } else {
      deviceId = 'web_or_unknown';
    }
  }

  /// Load all completed tasks, then filter out any you've deleted locally
  Future<void> fetchCompletedTasks() async {
    final snapshot = await _firestore
        .collection('tasks')
        .where('isCompleted', isEqualTo: true)
        .where('deviceId', isEqualTo: deviceId)
        .get();

    final all = snapshot.docs.map((doc) {
      final d = doc.data();
      d['id'] = doc.id;
      return d;
    }).toList();

    completedTasks.value =
        all.where((t) => !locallyDeleted.contains(t['id'])).toList();
  }

  /// “Delete” locally (persisted), so it never re‑shows
  void deleteCompletedTask(String id) {
    locallyDeleted.add(id);
    _box.write('completedLocallyDeleted', locallyDeleted.toList());
    print(
        '🗑️ deleted locally, now saved keys= ${_box.read('completedLocallyDeleted')}');
    completedTasks.removeWhere((t) => t['id'] == id);
  }
}
