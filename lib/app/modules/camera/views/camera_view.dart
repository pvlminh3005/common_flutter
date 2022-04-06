import 'dart:async';

import '/app/modules/camera/controllers/camera_controller.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../packages/camera/camera.dart';

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
              onPressed: () async {
                await CameraPicker.pickCamera(
                  context,
                  enableSetExposure: true,
                  enableRecording: true,
                  enablePinchToZoom: true,
                  onlyEnableRecording: true,
                ).then((value) {
                  Get.log('$value');
                });
              },
              child: Text(
                'Open Camera Picker',
              ),
              style: ElevatedButton.styleFrom(
                primary: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
