part of gallery_media_picker;

class MediaReviewBuilder extends StatefulWidget {
  final File file;
  final bool isVideo;
  final bool isSelected;

  const MediaReviewBuilder({
    required this.file,
    this.isVideo = false,
    this.isSelected = false,
    Key? key,
  }) : super(key: key);

  @override
  State<MediaReviewBuilder> createState() => _MediaReviewBuilderState();
}

class _MediaReviewBuilderState extends State<MediaReviewBuilder> {
  final _showButton = ValueNotifier<bool>(true);
  late ValueNotifier<bool> _selected;

  VideoPlayerController? videoController;
  Timer? _timer;
  // bool _showButton = true;

  @override
  void initState() {
    _selected = ValueNotifier<bool>(widget.isSelected);

    if (widget.isVideo) {
      videoController = VideoPlayerController.file(widget.file)
        ..initialize().then((value) {
          setState(() {});
        });

      videoController?.addListener(() {
        if (videoController!.value.isBuffering) {
          _showButton.value = true;
        }
        setState(() {});
      });
    }
    super.initState();
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        leading: BackButton(
          onPressed: () {
            Navigator.pop(context, _selected.value);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () {},
        child: Icon(
          Icons.send,
          size: 25,
          color: Colors.blue,
        ),
      ),
      body: GestureDetector(
        onTap: () {
          _showButton.value = !_showButton.value;
          autoHideButton();
        },
        child: Stack(
          children: [
            if (widget.isVideo) ...[
              VideoPlayer(videoController!),
              ValueListenableBuilder(
                valueListenable: _showButton,
                builder: (BuildContext context, bool value, Widget? child) {
                  return Center(
                    child: AnimatedOpacity(
                      opacity: value ? 1 : 0,
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
                  );
                },
              ),
            ] else
              Positioned.fill(child: Image.file(File(widget.file.path))),
            ValueListenableBuilder(
              valueListenable: _selected,
              builder: (BuildContext context, dynamic value, Widget? child) {
                return Positioned(
                  bottom: 20.0,
                  left: 15.0,
                  child: GestureDetector(
                    onTap: handleSelectItem,
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: value
                                ? Colors.blue
                                : Colors.white.withOpacity(.5),
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(5),
                          child: Icon(
                            Icons.done,
                            size: 15,
                            color: value ? Colors.white : Colors.transparent,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Select',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void handleSelectItem() {
    _selected.value = !_selected.value;
  }

  void autoHideButton() {
    _timer?.cancel();

    _timer = Timer(Duration(seconds: 2), () {
      _showButton.value = false;
    });
  }

  void togglePlayPause() {
    _showButton.value = true;
    if (videoController != null) {
      if (videoController!.value.isPlaying) {
        videoController!.pause();
      } else {
        videoController!.play();
      }
    }
    autoHideButton();
  }
}
