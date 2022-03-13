import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/camera_controller.dart';

class CameraView extends GetView<CameraController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CameraView'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {},
              child: Text(
                'Open Camera Picker',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
