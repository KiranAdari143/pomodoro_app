import 'package:get/get.dart';

import '../controllers/completedtasks_page_controller.dart';

class CompletedtasksPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CompletedtasksPageController>(
      () => CompletedtasksPageController(),
    );
  }
}
