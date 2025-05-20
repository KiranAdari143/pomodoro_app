import 'package:get/get.dart';

import '../controllers/pomedaro_page_controller.dart';

class PomedaroPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PomedaroPageController>(
      () => PomedaroPageController(),
    );
  }
}
