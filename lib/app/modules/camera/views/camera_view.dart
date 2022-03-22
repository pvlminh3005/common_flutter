import 'package:custom_common/app/packages/camera/src/camera_view.dart';
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
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => CameraCommon(
                            // onlyEnableRecording: true,
                            // enablePinchToZoom: true,
                            // shouldAutoPreviewVideo: true,
                            // enableRecording: true,
                            enableSetExposure: false,
                          )),
                  // MaterialPageRoute(builder: (_) => CameraExampleHome()),
                );
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
