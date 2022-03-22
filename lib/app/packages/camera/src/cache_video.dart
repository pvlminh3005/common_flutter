import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CacheVideoCustom extends StatelessWidget {
  final VideoPlayerController controller;
  const CacheVideoCustom(this.controller, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: BackButton(),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
      ),
      body: InkWell(
          onTap: () {
            if (controller.value.isPlaying) {
              controller.pause();
            } else {
              controller.play();
            }
          },
          child: VideoPlayer(controller)),
    );
  }
}
