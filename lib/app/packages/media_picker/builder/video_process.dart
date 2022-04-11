part of media_picker;

class VideoProgress extends StatefulWidget {
  const VideoProgress(this.controller, {Key? key, required this.seekTo})
      : super(key: key);
  final VideoPlayerController controller;
  final Function(Duration) seekTo;
  @override
  _VideoProgressState createState() => _VideoProgressState();
}

class _VideoProgressState extends State<VideoProgress> {
  _VideoProgressState() {
    listener = () {
      if (!mounted) {
        return;
      }
      setState(() {});
    };
  }

  late VoidCallback listener;
  @override
  void initState() {
    super.initState();
    controller.addListener(listener);
  }

  @override
  void deactivate() {
    controller.removeListener(listener);
    super.deactivate();
  }

  VideoPlayerController get controller => widget.controller;
  @override
  Widget build(BuildContext context) {
    bool _controllerWasPlaying = false;
    void seekToRelativePosition(Offset globalPosition) {
      final box = context.findRenderObject()! as RenderBox;
      final Offset tapPos = box.globalToLocal(globalPosition);
      final double relative = tapPos.dx / box.size.width;
      final Duration position = controller.value.duration * relative;
      controller.seekTo(position);
      widget.seekTo.call(position);
    }

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: 12.0),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          child: Center(
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: Colors.transparent,
              child: CustomPaint(
                painter: _ProgressBarPainter(controller.value),
              ),
            ),
          ),
          onHorizontalDragStart: (DragStartDetails details) {
            if (!controller.value.isInitialized) {
              return;
            }
            _controllerWasPlaying = controller.value.isPlaying;
            if (_controllerWasPlaying) {
              controller.pause();
            }
          },
          onHorizontalDragUpdate: (DragUpdateDetails details) {
            if (!controller.value.isInitialized) {
              return;
            }
            seekToRelativePosition(details.globalPosition);
          },
          onHorizontalDragEnd: (DragEndDetails details) {
            if (_controllerWasPlaying) {
              controller.play();
            }
          },
          onTapDown: (TapDownDetails details) {
            if (!controller.value.isInitialized) {
              return;
            }
            seekToRelativePosition(details.globalPosition);
          },
        ),
      ),
    );
  }
}

class _ProgressBarPainter extends CustomPainter {
  _ProgressBarPainter(this.value);
  VideoPlayerValue value;

  @override
  bool shouldRepaint(CustomPainter painter) {
    return true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    const double barHeight = 5.0;
    const double handleHeight = 6.0;
    final double baseOffset = size.height / 2 - barHeight / 2.0;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromPoints(
          Offset(0.0, baseOffset),
          Offset(size.width, baseOffset + barHeight),
        ),
        const Radius.circular(4.0),
      ),
      Paint()..color = const Color.fromARGB(20, 255, 255, 255),
    );
    if (!value.isInitialized) {
      return;
    }
    final double playedPartPercent =
        value.position.inMilliseconds / value.duration.inMilliseconds;
    final double playedPart =
        playedPartPercent > 1 ? size.width : playedPartPercent * size.width;
    for (final DurationRange range in value.buffered) {
      final double start = range.startFraction(value.duration) * size.width;
      final double end = range.endFraction(value.duration) * size.width;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromPoints(
            Offset(start, baseOffset),
            Offset(end, baseOffset + barHeight),
          ),
          const Radius.circular(4.0),
        ),
        Paint()..color = const Color.fromARGB(60, 255, 255, 255),
      );
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromPoints(
          Offset(0.0, baseOffset),
          Offset(playedPart, baseOffset + barHeight),
        ),
        const Radius.circular(4.0),
      ),
      Paint()..color = const Color.fromARGB(120, 255, 255, 255),
    );

    final Path shadowPath = Path()
      ..addOval(Rect.fromCircle(
          center: Offset(playedPart, baseOffset + barHeight / 2),
          radius: handleHeight));

    canvas.drawShadow(shadowPath, Colors.black, 0.2, false);
    canvas.drawCircle(
      Offset(playedPart, baseOffset + barHeight / 2),
      handleHeight,
      Paint()..color = const Color.fromARGB(255, 255, 255, 255),
    );
  }
}
