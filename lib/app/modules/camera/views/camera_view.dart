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
            _CounterTime(),
          ],
        ),
      ),
    );
  }
}

class _CounterTime extends StatefulWidget {
  const _CounterTime({Key? key}) : super(key: key);

  @override
  State<_CounterTime> createState() => __CounterTimeState();
}

class __CounterTimeState extends State<_CounterTime> {
  late AnimationController animationController;
  Timer? _timer;
  final _recordIcon = ValueNotifier<bool>(true);
  final second = ValueNotifier<int>(50);
  int minute = 59;
  int hour = 0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ValueListenableBuilder(
              valueListenable: _recordIcon,
              builder: (ctx, bool value, child) {
                return AnimatedOpacity(
                  opacity: value ? 1 : 0,
                  duration: kTabScrollDuration,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.red, width: 2.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child:
                          CircleAvatar(radius: 6, backgroundColor: Colors.red),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 10),
            ValueListenableBuilder(
              valueListenable: second,
              builder: (BuildContext context, int value, Widget? child) {
                return Row(
                  children: [
                    _buildCountText(hour),
                    _buildCountText(minute),
                    _buildCountText(value, last: true),
                  ],
                );
              },
            ),
          ],
        ),
        ElevatedButton(
          onPressed: startCounterTime,
          child: Text('Start'),
        ),
      ],
    );
  }

  Widget _buildCountText(int count, {bool last = false}) {
    final strLast = !last ? ' : ' : '';
    return Text(count > 9
        ? '${count.toString() + strLast}'
        : '0${count.toString() + strLast}');
  }

  void timeOut() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
      changeStatusRecordIcon();
      second.value++;
      if (second.value == 60) {
        second.value = 0;
        minute++;
        if (minute == 60) {
          minute = 0;
          hour++;
        }
      }
    });
  }

  changeStatusRecordIcon() async {
    _recordIcon.value = false;
    await Future.delayed(Duration(milliseconds: 300), () {
      _recordIcon.value = true;
    });
  }

  void startCounterTime() {
    timeOut();
  }
}
