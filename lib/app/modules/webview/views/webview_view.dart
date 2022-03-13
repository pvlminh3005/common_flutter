import 'package:custom_common/app/widgets/common/webview_custom.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/webview_controller.dart';

class WebviewView extends StatefulWidget {
  @override
  State<WebviewView> createState() => _WebviewViewState();
}

class _WebviewViewState extends State<WebviewView>
    with AutomaticKeepAliveClientMixin {
  WebviewController get controller => Get.find();
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('WebviewView'),
        centerTitle: true,
      ),
      body: Obx(
        () => WebviewCustom(
          controller: controller.inputController,
          onSubmitted: (value) => controller.handleSubmit(),
          url: controller.url,
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
