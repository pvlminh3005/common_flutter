part of media_picker;

class AudioPageBuilder extends StatefulWidget {
  const AudioPageBuilder({
    Key? key,
    required this.asset,
  }) : super(key: key);

  final AssetEntity asset;

  @override
  State<StatefulWidget> createState() => _AudioPageBuilderState();
}

class _AudioPageBuilderState extends State<AudioPageBuilder> {
  final _durationStream = StreamController<Duration>.broadcast();
  VideoPlayerController? _controller;
  bool isLoaded = false;
  bool isPlaying = false;
  bool get isControllerPlaying => _controller?.value.isPlaying ?? false;
  late Duration assetDuration;

  @override
  void initState() {
    super.initState();
    _openAudioFile();
  }

  @override
  void dispose() {
    _controller?.pause();
    _controller?.removeListener(audioPlayerListener);
    _controller?.dispose();
    _durationStream.close();
    super.dispose();
  }

  Future<void> _openAudioFile() async {
    try {
      final url = await widget.asset.getMediaUrl();
      assetDuration = Duration(seconds: widget.asset.duration);
      _controller = VideoPlayerController.network(url!);
      await _controller?.initialize();
      _controller?.addListener(audioPlayerListener);
    } catch (e) {
      MediaPicker.log('Error when opening audio file: $e');
    } finally {
      isLoaded = true;
      if (mounted) {
        setState(() {});
      }
    }
  }

  void audioPlayerListener() {
    if (isControllerPlaying != isPlaying) {
      isPlaying = isControllerPlaying;
      if (mounted) {
        setState(() {});
      }
    }

    if (_controller?.value.position != null) {
      _durationStream.add(_controller!.value.position);
    }
  }

  Widget get titleWidget => Text(
        widget.asset.title ?? '',
        style: const TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.normal,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      );

  Widget get audioControlButton => GestureDetector(
        onTap: () {
          if (isPlaying) {
            _controller?.pause();
          } else {
            _controller?.play();
          }
        },
        child: Container(
          margin: const EdgeInsets.all(20.0),
          decoration: const BoxDecoration(
            boxShadow: <BoxShadow>[BoxShadow(color: Colors.black12)],
            shape: BoxShape.circle,
          ),
          child: Icon(
            isPlaying ? Icons.pause_circle_outline : Icons.play_circle_filled,
            size: 70.0,
            color: Colors.white,
          ),
        ),
      );

  Widget get durationIndicator => StreamBuilder<Duration>(
        initialData: Duration.zero,
        stream: _durationStream.stream,
        builder: (BuildContext _, AsyncSnapshot<Duration> data) {
          return Text(
            '${MediaPicker.formatDuration(data.data!)}'
            ' / '
            '${MediaPicker.formatDuration(assetDuration)}',
            style: const TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.normal,
              color: Colors.white,
            ),
          );
        },
      );

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: isLoaded
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                titleWidget,
                audioControlButton,
                durationIndicator,
              ],
            )
          : const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
            ),
    );
  }
}
