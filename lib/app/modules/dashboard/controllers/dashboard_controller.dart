import 'package:custom_common/app/modules/camera/views/camera_view.dart';
import 'package:custom_common/app/modules/media/views/media_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../home/views/home_view.dart';
import '../../webview/views/webview_view.dart';

class DashboardController extends GetxController
    with GetSingleTickerProviderStateMixin {
  List<Widget> pages = [
    HomeView(),
    CameraView(),
    MediaView(),
    WebviewView(),
  ];

  late TabController tabController;
  final _currentIndex = 0.obs;
  int get currentIndex => _currentIndex.value;
  set currentIndex(int val) => _currentIndex.value = val;

  @override
  void onInit() {
    tabController = TabController(length: pages.length, vsync: this);
    super.onInit();
  }

  void changeTab(int index) {
    currentIndex = index;
    tabController.animateTo(index);
  }

  @override
  void onClose() {}
}
