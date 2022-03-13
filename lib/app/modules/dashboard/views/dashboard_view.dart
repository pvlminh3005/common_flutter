import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: controller.pages.length,
      child: Scaffold(
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          controller: controller.tabController,
          children: controller.pages,
        ),
        bottomNavigationBar: _BottomNavigatorCustom(),
      ),
    );
  }
}

class _BottomNavigatorCustom extends StatelessWidget {
  const _BottomNavigatorCustom({Key? key}) : super(key: key);

  DashboardController get ctrl => Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() => BottomNavigationBar(
          currentIndex: ctrl.currentIndex,
          onTap: ctrl.changeTab,
          backgroundColor: Colors.grey.shade200,
          fixedColor: Colors.grey.shade400,
          iconSize: 20,
          items: [
            _itemBuilder(
              title: 'Common Input',
              icon: CupertinoIcons.pencil_ellipsis_rectangle,
            ),
            _itemBuilder(
              title: 'Camera Picker',
              icon: CupertinoIcons.camera_fill,
            ),
            _itemBuilder(
              title: 'Media Picker',
              icon: CupertinoIcons.square_fill_on_square_fill,
            ),
            _itemBuilder(
              title: 'Common WebView',
              icon: Icons.web,
            ),
          ],
        ));
  }

  BottomNavigationBarItem _itemBuilder({String? title, IconData? icon}) {
    return BottomNavigationBarItem(
      icon: Icon(
        icon,
        color: Colors.grey.shade500,
      ),
      label: title,
    );
  }
}
