import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

class HomeController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GetStorage _box = GetStorage();

  // all tasks fetched (completed & incomplete)
  var _allTasks = <Map<String, dynamic>>[].obs;
  // showable incomplete tasks
  var incompleteTasks = <Map<String, dynamic>>[].obs;
  // persistently store locally deleted task IDs as a list
  var locallyDeleted = <String>[].obs;

  late final String deviceId;
  static const String cacheKey = 'cachedTasks';

  @override
  Future<void> onInit() async {
    super.onInit();

    // Initialize GetStorage
    await GetStorage.init();

    // Load any previously deleted IDs from storage
    final saved = _box.read<List>('locallyDeleted') ?? <dynamic>[];
    locallyDeleted.assignAll(saved.cast<String>());

    // Persist whenever locallyDeleted changes
    ever<List<String>>(locallyDeleted, (_) {
      _box.write('locallyDeleted', locallyDeleted);
    });

    await _initDeviceId();
    await fetchTasks();
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

  /// Fetch all tasks for this device and filter out completed & locally deleted
  Future<void> fetchTasks() async {
    final connectivity = Connectivity();
    final status = await connectivity.checkConnectivity();

    if (status == ConnectivityResult.none) {
      // Offline: load from local cache
      final cached = _box.read<List>(cacheKey) ?? <dynamic>[];
      final raw = cached.cast<Map<String, dynamic>>();
      _allTasks.value = raw;
      incompleteTasks.value = raw
          .where((t) =>
              t['isCompleted'] == false && !locallyDeleted.contains(t['id']))
          .toList();
    } else {
      // Online: fetch from Firestore
      final snap = await _firestore
          .collection('tasks')
          .where('deviceId', isEqualTo: deviceId)
          .get();

      final raw = snap.docs.map((d) {
        final m = d.data();
        m['id'] = d.id;
        m['isTicked'] = m['isTicked'] ?? false;
        m['isCompleted'] = m['isCompleted'] ?? false;
        return m;
      }).toList();

      // Update local cache
      _box.write(HomeController.cacheKey, raw);
      print('Cached tasks: ${_box.read(HomeController.cacheKey)}');

      _allTasks.value = raw;
      incompleteTasks.value = raw
          .where((t) =>
              t['isCompleted'] == false && !locallyDeleted.contains(t['id']))
          .toList();
    }
  }

  /// Locally delete an incomplete task (persisted across sessions)
  void removeTask(int i) {
    final id = incompleteTasks[i]['id'] as String;
    if (!locallyDeleted.contains(id)) {
      locallyDeleted.add(id);
    }
    incompleteTasks.removeAt(i);
  }

  Future<void> toggleTaskTicked(int i) async {
    final task = incompleteTasks[i];
    final newVal = !(task['isTicked'] as bool);
    await _firestore
        .collection('tasks')
        .doc(task['id'])
        .update({'isTicked': newVal});
    await fetchTasks();
  }

  Future<void> addTask({
    required String title,
    required String date,
    required String workDuration,
    required String breakDuration,
    required String timeIntervalDuration,
  }) async {
    await _firestore.collection('tasks').add({
      'title': title,
      'date': date,
      'workDuration': workDuration,
      'breakDuration': breakDuration,
      'timeIntervalDuration': timeIntervalDuration,
      'isCompleted': false,
      'isTicked': false,
      'deviceId': deviceId,
    });
    await fetchTasks();
  }

  Future<void> addSelectedTasksToCompleted() async {
    for (var t in incompleteTasks.where((t) => t['isTicked'] == true)) {
      await _firestore
          .collection('tasks')
          .doc(t['id'])
          .update({'isCompleted': true});
    }
    await fetchTasks();
  }

  /// Weekly stats
  Map<String, int> get weeklyStats {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: now.weekday - 1));
    final weekTasks = _allTasks.where((t) {
      final d = DateFormat('yyyy-MM-dd').parse(t['date']);
      return d.isAfter(start.subtract(const Duration(days: 1))) &&
          d.isBefore(now.add(const Duration(days: 1)));
    });
    final added = weekTasks.length;
    final completed = weekTasks.where((t) => t['isCompleted'] == true).length;
    return {'added': added, 'completed': completed};
  }

  /// Monthly stats
  Map<String, int> get monthlyStats {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final monthTasks = _allTasks.where((t) {
      final d = DateFormat('yyyy-MM-dd').parse(t['date']);
      return d.isAfter(start.subtract(const Duration(days: 1))) &&
          d.isBefore(now.add(const Duration(days: 1)));
    });
    final added = monthTasks.length;
    final completed = monthTasks.where((t) => t['isCompleted'] == true).length;
    return {'added': added, 'completed': completed};
  }

  /// Yearly stats
  Map<String, int> get yearlyStats {
    final now = DateTime.now();
    final start = DateTime(now.year, 1, 1);
    final yearTasks = _allTasks.where((t) {
      final d = DateFormat('yyyy-MM-dd').parse(t['date']);
      return d.isAfter(start.subtract(const Duration(days: 1))) &&
          d.isBefore(now.add(const Duration(days: 1)));
    });
    final added = yearTasks.length;
    final completed = yearTasks.where((t) => t['isCompleted'] == true).length;
    return {'added': added, 'completed': completed};
  }

  /// Overall completion ratio
  double get completionRate {
    final total = _allTasks.length;
    if (total == 0) return 0;
    final done = _allTasks.where((t) => t['isCompleted'] == true).length;
    return done / total;
  }

  /// Productivity label
  String get productivityLabel {
    final total = _allTasks.length;
    if (total == 0) {
      return 'Please start adding tasks; I will check productivity.';
    }
    return completionRate >= 0.5 ? 'Productive 👍' : 'Needs Improvement 👎';
  }
}
