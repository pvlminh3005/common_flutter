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
          fixedColor: Colors.black,
          selectedLabelStyle: TextStyle(fontSize: 11.0),
          items: [
            _itemBuilder(
              title: 'Input',
              icon: CupertinoIcons.square_favorites_fill,
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
              title: 'Map',
              icon: CupertinoIcons.map_fill,
            ),
            _itemBuilder(
              title: 'WebView',
              icon: Icons.web,
            ),
            _itemBuilder(
              title: 'Profile',
              icon: CupertinoIcons.person_crop_circle_fill,
            ),
          ],
        ));
  }

  BottomNavigationBarItem _itemBuilder({String? title, IconData? icon}) {
    return BottomNavigationBarItem(
      icon: Icon(
        icon,
        color: Colors.black,
      ),
      label: title,
    );
  }
}
