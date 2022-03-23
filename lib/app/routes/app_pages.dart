import 'package:get/get.dart';

import '../modules/camera/bindings/camera_binding.dart';
import '../modules/dashboard/bindings/dashboard_binding.dart';
import '../modules/dashboard/views/dashboard_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/media/bindings/media_binding.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/webview/bindings/webview_binding.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.DASHBOARD;

  static final routes = [
    GetPage(
      name: _Paths.DASHBOARD,
      page: () => DashboardView(),
      binding: DashboardBinding(),
      bindings: [
        HomeBinding(),
        MediaBinding(),
        CameraBinding(),
        WebviewBinding(),
        ProfileBinding(),
      ],
    ),
  ];
}
