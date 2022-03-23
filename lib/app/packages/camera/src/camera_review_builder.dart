import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../widgets/camera.dart';
import '../camera.dart';

class CameraReviewBuilder extends StatefulWidget {
  final XFile file;
  final bool isVideo;

  const CameraReviewBuilder({
    required this.file,
    this.isVideo = false,
    Key? key,
  }) : super(key: key);

  @override
  State<CameraReviewBuilder> createState() => _CameraReviewBuilderState();
}

class _CameraReviewBuilderState extends State<CameraReviewBuilder> {
  VideoPlayerController? videoController;
  Timer? _timer;
  bool _showButton = true;

  @override
  void initState() {
    videoController = VideoPlayerController.file(File(widget.file.path))
      ..initialize().then((value) {
        setState(() {});
      });

    videoController?.addListener(() {
      if (videoController!.value.isBuffering) {
        _showButton = true;
      }
      setState(() {});
    });
    super.initState();
  }

  void autoHideButton() {
    _timer?.cancel();

    _timer = Timer(Duration(seconds: 2), () {
      setState(() {
        _showButton = false;
      });
    });
  }

  void togglePlayPause() {
    setState(() => _showButton = true);
    if (videoController != null) {
      if (videoController!.value.isPlaying) {
        videoController!.pause();
      } else {
        videoController!.play();
      }
    }
    autoHideButton();
  }

  @override
  void dispose() {
    _timer?.cancel();
    videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          leading: BackButton(),
        ),
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            if (widget.isVideo) ...[
              VideoPlayer(videoController!),
              Center(
                child: AnimatedOpacity(
                  opacity: _showButton ? 1 : 0,
                  duration: kTabScrollDuration,
                  child: IconButton(
                    iconSize: 50,
                    color: Colors.white,
                    icon: Icon(
                      videoController!.value.isPlaying
                          ? Icons.pause_circle_filled_sharp
                          : Icons.play_arrow,
                    ),
                    onPressed: togglePlayPause,
                  ),
                ),
              ),
            ] else
              Positioned.fill(child: Image.file(File(widget.file.path))),
            Positioned(
              bottom: 10.0,
              right: 10.0,
              child: ElevatedButton(
                child: SizedBox(
                  height: 40,
                  width: 60,
                  child: Center(child: Text('Save')),
                ),
                onPressed: () {
                  Navigator.pop(context, true);
                },
              ),
            ),
          ],
        ));
  }
}
