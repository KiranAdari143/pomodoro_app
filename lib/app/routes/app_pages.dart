import 'package:get/get.dart';

import '../modules/completedtasks_page/bindings/completedtasks_page_binding.dart';
import '../modules/completedtasks_page/views/completedtasks_page_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/pomedaro_page/bindings/pomedaro_page_binding.dart';
import '../modules/pomedaro_page/views/pomedaro_page_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
      children: [
        GetPage(
          name: _Paths.HOME,
          page: () => const HomeView(),
          binding: HomeBinding(),
        ),
      ],
    ),
    GetPage(
      name: _Paths.POMEDARO_PAGE,
      page: () {
        final args = Get.arguments as Map<String, dynamic>;
        return PomedaroPageView(
          title: args['title'] as String,
          workDuration: args['workDuration'] as String,
          breakDuration: args['breakDuration'] as String,
          timeInterval: args['timeInterval'] as String, // ← match this key
        );
      },
      binding: PomedaroPageBinding(),
    ),
    GetPage(
      name: _Paths.COMPLETEDTASKS_PAGE,
      page: () =>
          CompletedTasksPageView(), // 👈 Must match class name in your View file
      binding: CompletedtasksPageBinding(),
    ),
  ];
}
