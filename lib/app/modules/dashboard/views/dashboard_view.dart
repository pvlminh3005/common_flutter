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
        bottomNavigationBar: _BottomNavigatorCustom(controller.currentIndex),
      ),
    );
  }
}

class _BottomNavigatorCustom extends StatelessWidget {
  final int currentIndex;
  const _BottomNavigatorCustom(this.currentIndex, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      items: [
        _itemBuilder(
          title: 'CustomInput',
          icon: CupertinoIcons.pencil_ellipsis_rectangle,
        ),
        _itemBuilder(
          title: 'CustomInput',
          icon: Icons.input,
        ),
        _itemBuilder(
          title: 'CustomInput',
          icon: Icons.input,
        ),
      ],
    );
  }

  BottomNavigationBarItem _itemBuilder({String? title, IconData? icon}) {
    return BottomNavigationBarItem(
      icon: Icon(icon),
      label: title,
    );
  }
}
