part of camera_common;

enum CameraType {
  camera,
  video,
}

List<CameraDescription> cameras = <CameraDescription>[];

extension RouterExt on BuildContext {
  Future<dynamic> to(Widget widget) =>
      Navigator.of(this).push(MaterialPageRoute(builder: (_) => widget));
}

// ignore: must_be_immutable
class CameraPicker extends StatefulWidget {
  final int cameraQuarterTurns;
  final bool enableRecording;
  final bool onlyEnableRecording;
  late bool enableAudio;
  final bool enableSetExposure;
  final bool enableExposureControl;
  final bool enablePinchToZoom;
  final bool enablePullToZoomInRecord;
  final bool shouldAutoPreviewVideo;
  final Duration? maximumRecordingDuration;
  final ThemeData? theme;
  final ResolutionPreset resolutionPreset;

  CameraPicker({
    Key? key,
    this.cameraQuarterTurns = 0,
    this.enableRecording = true,
    this.onlyEnableRecording = false,
    this.enableAudio = true,
    this.enableSetExposure = true,
    this.enableExposureControl = false,
    this.enablePinchToZoom = false,
    this.enablePullToZoomInRecord = false,
    this.shouldAutoPreviewVideo = false,
    this.maximumRecordingDuration = const Duration(seconds: 15),
    this.theme,
    this.resolutionPreset = ResolutionPreset.max,
  }) : super(key: key);

  @override
  _CameraPickerState createState() {
    return _CameraPickerState();
  }

  static Future<File?> pickCamera(
    BuildContext context, {
    int cameraQuarterTurns = 0,
    bool enableRecording = false,
    bool onlyEnableRecording = false,
    bool enableAudio = false,
    bool enableSetExposure = false,
    bool enableExposureControl = false,
    bool enablePinchToZoom = false,
    bool enablePullToZoomInRecord = false,
    bool shouldAutoPreviewVideo = false,
    Duration? maximumRecordingDuration = const Duration(seconds: 15),
    ResolutionPreset resolutionPreset = ResolutionPreset.max,
  }) async {
    cameras = await availableCameras();
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CameraPicker(
          cameraQuarterTurns: cameraQuarterTurns,
          enableRecording: enableRecording,
          onlyEnableRecording: onlyEnableRecording,
          enableAudio: enableAudio,
          enableSetExposure: enableSetExposure,
          enableExposureControl: enableExposureControl,
          enablePinchToZoom: enablePinchToZoom,
          enablePullToZoomInRecord: enablePullToZoomInRecord,
          shouldAutoPreviewVideo: shouldAutoPreviewVideo,
          maximumRecordingDuration: maximumRecordingDuration,
          resolutionPreset: resolutionPreset,
        ),
      ),
    );
  }
}

/// Returns a suitable camera icon for [direction].
IconData getCameraLensIcon(CameraLensDirection direction) {
  switch (direction) {
    case CameraLensDirection.back:
      return Icons.camera_rear;
    case CameraLensDirection.front:
      return Icons.camera_front;
    case CameraLensDirection.external:
      return Icons.camera;
    default:
      throw ArgumentError('Unknown lens direction');
  }
}

void logError(String code, String? message) {
  if (message != null) {
    print('Error: $code\nError Message: $message');
  } else {
    print('Error: $code');
  }
}

class _CameraPickerState extends State<CameraPicker>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  late CameraController controller;
  XFile? imageFile;
  XFile? videoFile;
  VideoPlayerController? videoController;
  VoidCallback? videoPlayerListener;
  double _minAvailableExposureOffset = 0.0;
  double _maxAvailableExposureOffset = 0.0;
  double _currentExposureOffset = 0.0;
  late AnimationController _swapLensCameraAnimationController;
  late AnimationController _flashModeControlRowAnimationController;
  late AnimationController _exposureModeControlRowAnimationController;
  late AnimationController _focusModeControlRowAnimationController;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _currentScale = 1.0;
  double _baseScale = 1.0;
  // Counting pointers (number of user fingers on screen)
  int _pointers = 0;

  //* initial lens description camera
  int lensCamera = 0;
  double angle = 0.0;
  FlashMode _flashMode = FlashMode.auto;

  final flashOn = ValueNotifier<bool>(false);
  final _showChooseFlashMode = ValueNotifier<bool>(false);
  final isRecording = ValueNotifier<bool>(false);
  final _showBlur = ValueNotifier<bool>(false);
  final _showExposure = ValueNotifier<bool>(false);
  final _showFocus = ValueNotifier<bool>(false);
  final _showCounter = ValueNotifier<bool>(false);
  final _cameraType = ValueNotifier<CameraType>(CameraType.camera);

  CameraType cameraType = CameraType.camera;
  Timer? _timer;
  Timer? _timerExposure;

  //focus offset
  late Offset offsetTap = Offset.zero;

  late TabController tabController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    if (widget.onlyEnableRecording) {
      cameraType = CameraType.video;
    }

    tabController = TabController(length: 2, vsync: this);
    onNewCameraSelected(cameras[lensCamera]);

    _swapLensCameraAnimationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      value: 1,
      lowerBound: 1,
      upperBound: 1.5,
      vsync: this,
    );
    _flashModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      value: 1,
      lowerBound: 1,
      upperBound: 1.5,
      vsync: this,
    );
    _exposureModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _focusModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      value: .8,
      lowerBound: .6,
      vsync: this,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    _timer?.cancel();
    _timerExposure?.cancel();

    _flashModeControlRowAnimationController.dispose();
    _exposureModeControlRowAnimationController.dispose();
    controller.dispose();
    videoController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      onNewCameraSelected(cameraController.description);
    }
  }

  void _timeoutFocus() {
    _timer?.cancel();
    _timer = Timer(Duration(seconds: 2), () {
      if (_pointers == 0) {
        _showChooseFlashMode.value = false;
        _showExposure.value = false;
        _showFocus.value = false;
      }
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        key: _scaffoldKey,
        body: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  _cameraPreviewWidget(),
                  Positioned(
                    top: 45,
                    right: 10,
                    child: Row(
                      children: [
                        ValueListenableBuilder(
                            valueListenable: _showChooseFlashMode,
                            builder: (context, bool value, child) {
                              return AnimatedSwitcher(
                                duration: kTabScrollDuration,
                                child: value
                                    ? Row(
                                        children: [
                                          _FlashModeTextItem(
                                            title: 'Tự động',
                                            isFlashType:
                                                _flashMode == FlashMode.auto,
                                            onPressed: () =>
                                                onSetFlashModeButtonPressed(
                                                    FlashMode.auto),
                                          ),
                                          _FlashModeTextItem(
                                            title: 'Bật',
                                            isFlashType:
                                                _flashMode == FlashMode.torch,
                                            onPressed: () =>
                                                onSetFlashModeButtonPressed(
                                                    FlashMode.torch),
                                          ),
                                          _FlashModeTextItem(
                                            title: 'Tắt',
                                            isFlashType:
                                                _flashMode == FlashMode.off,
                                            onPressed: () =>
                                                onSetFlashModeButtonPressed(
                                                    FlashMode.off),
                                          ),
                                        ],
                                      )
                                    : const SizedBox.shrink(),
                              );
                            }),
                        ScaleTransition(
                          scale: _flashModeControlRowAnimationController,
                          child: IconButton(
                            onPressed: toggleFlashIcon,
                            icon: _buildFlashItem(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _CounterTime(_showCounter),
                  _FocusOffsetBuilder(
                    offset: offsetTap,
                    focusModeController:
                        _focusModeControlRowAnimationController,
                    focusNotifier: _showFocus,
                  ),
                  _ExposureOffsetBuilder(
                    onPointerDown: (_) => _pointers++,
                    onPointerUp: (_) {
                      _pointers--;
                      _pointers = _pointers < 0 ? 0 : _pointers;
                      _timeoutFocus();
                    },
                    exposureNotifier: _showExposure,
                    onChanged: setExposureOffset,
                    currentExposureOffset: _currentExposureOffset,
                    minAvailableExposureOffset: _minAvailableExposureOffset,
                    maxAvailableExposureOffset: _maxAvailableExposureOffset,
                  ),
                  _BlurSwitcherBuilder(blurNotifier: _showBlur),
                ],
              ),
            ),
            // if (!widget.onlyEnableRecording && widget.enableRecording)
            //   _TabBarBuilder(
            //     tabController: tabController,
            //     onTap: (index) async {
            //       _showBlur.value = true;
            //       setState(() {
            //         cameraType = CameraType.values[index];
            //       });
            //       Future.delayed(kTabScrollDuration)
            //           .then((_) => _showBlur.value = false);
            //     },
            //   ),
            _bottomBuilder(),
          ],
        ),
      ),
    );
  }

  Widget _buildFlashItem() {
    switch (_flashMode) {
      case FlashMode.auto:
        return _FlashModeIconItem(icon: Icons.flash_auto_rounded);
      case FlashMode.torch:
        return _FlashModeIconItem(
            icon: Icons.flash_on_outlined, color: Colors.yellow);
      default:
        return _FlashModeIconItem(icon: Icons.flash_off_rounded);
    }
  }

  Widget _bottomBuilder() {
    return Padding(
      padding: const EdgeInsets.only(bottom: kBottomNavigationBarHeight - 10),
      child: cameraType == CameraType.camera
          ? _CameraItemBuilder(
              imageFile: imageFile,
              onTakePictureButtonPressed: onTakePictureButtonPressed,
              childRight: _IconButtonBuilder(
                controller,
                swapLensController: _swapLensCameraAnimationController,
                onPressSwapLens: swapLensCamera,
              ),
            )
          : _RecordItemBuilder(
              shouldAutoPreviewVideo: widget.shouldAutoPreviewVideo,
              videoFile: videoFile,
              recordNotifier: isRecording,
              maximumRecordingDuration: widget.maximumRecordingDuration,
              childRight: _IconButtonBuilder(
                controller,
                swapLensController: _swapLensCameraAnimationController,
                onPressSwapLens: swapLensCamera,
              ),
              onStopButtonPressed: onStopButtonPressed,
              onVideoRecordButtonPressed: onVideoRecordButtonPressed,
            ),
    );
  }

  void toggleFlashIcon() {
    _showChooseFlashMode.value = !_showChooseFlashMode.value;

    _flashModeControlRowAnimationController
        .forward()
        .then((value) => _flashModeControlRowAnimationController.reverse());
  }

  void _flip() {
    setState(() {
      angle = (angle + math.pi) % (2 * math.pi);
    });
  }

  void swapLensCamera() async {
    _swapLensCameraAnimationController
        .forward()
        .then((_) => _swapLensCameraAnimationController.reverse());
    _flip();

    await Future.delayed(Duration(milliseconds: 400), () {
      lensCamera = lensCamera == 1 ? 0 : 1;
      onNewCameraSelected(cameras[lensCamera]);
    });
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    return Listener(
      onPointerDown: (_) => _pointers++,
      onPointerUp: (_) => _pointers--,
      child: CameraPreview(
        controller,
        child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onScaleStart: _handleScaleStart,
            onScaleUpdate: _handleScaleUpdate,
            onLongPress: () {
              if (widget.enableSetExposure) {
                _showExposure.value = true;
              }
            },
            onLongPressMoveUpdate: (_) => _timeoutFocus(),
            onTapDown: (TapDownDetails details) =>
                onViewFinderTap(details, constraints),
            onTapUp: (TapUpDetails details) {
              _timeoutFocus();
            },
          );
        }),
      ),
    );
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _baseScale = _currentScale;
  }

  Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
    // When there are not exactly two fingers on screen don't scale
    if (_pointers != 2 || !widget.enablePinchToZoom) {
      return;
    }

    _currentScale = (_baseScale * details.scale)
        .clamp(_minAvailableZoom, _maxAvailableZoom);

    await controller.setZoomLevel(_currentScale);
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void showInSnackBar(String message) {
    // ignore: deprecated_member_use
    // _scaffoldKey.currentState?.showSnackBar(SnackBar(content: Text(message)));
  }

  void onViewFinderTap(
      TapDownDetails details, BoxConstraints constraints) async {
    if (_showChooseFlashMode.value) {
      return toggleFlashIcon();
    }

    if (_pointers == 2) {
      return;
    }

    _showFocus.value = true;

    final CameraController cameraController = controller;

    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );

    final getOffset =
        Offset(details.localPosition.dx - 55, details.localPosition.dy - 55);

    setState(() {
      offsetTap = getOffset;
    });

    cameraController.setExposurePoint(offset);
    cameraController.setFocusPoint(offset);

    onFocusModeButtonPressed();
  }

  Future<void> onNewCameraSelected(CameraDescription cameraDescription) async {
    controller = CameraController(
      cameraDescription,
      widget.resolutionPreset,
      enableAudio: widget.enableAudio,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    // If the controller is updated then update the UI.
    controller.addListener(() {
      if (mounted) {
        setState(() {});
      }
      if (controller.value.hasError) {
        showInSnackBar('Camera error ${controller.value.errorDescription}');
      }
    });

    try {
      await controller.initialize();
      await Future.wait(<Future<Object?>>[
        // The exposure mode is currently not supported on the web.
        ...!kIsWeb
            ? <Future<Object?>>[
                controller.getMinExposureOffset().then(
                    (double value) => _minAvailableExposureOffset = value),
                controller
                    .getMaxExposureOffset()
                    .then((double value) => _maxAvailableExposureOffset = value)
              ]
            : <Future<Object?>>[],
        controller
            .getMaxZoomLevel()
            .then((double value) => _maxAvailableZoom = value),
        controller
            .getMinZoomLevel()
            .then((double value) => _minAvailableZoom = value),
      ]);
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void onTakePictureButtonPressed() {
    takePicture().then((XFile? file) {
      if (mounted) {
        setState(() {
          imageFile = file;
          _reviewCamera(context, file!);
          videoController?.dispose();
          videoController = null;
        });
        if (file != null) {
          showInSnackBar('Picture saved to ${file.path}');
        }
      }
    });
  }

  // void onFlashModeButtonPressed() {
  //   if (_flashModeControlRowAnimationController.value == 1) {
  //     _flashModeControlRowAnimationController.reverse();
  //   } else {
  //     _flashModeControlRowAnimationController.forward();
  //     _exposureModeControlRowAnimationController.reverse();
  //     _focusModeControlRowAnimationController.reverse();
  //   }
  // }

  // void onExposureModeButtonPressed() {
  //   if (_exposureModeControlRowAnimationController.value == 1) {
  //     _exposureModeControlRowAnimationController.reverse();
  //   } else {
  //     _exposureModeControlRowAnimationController.forward();
  //     _flashModeControlRowAnimationController.reverse();
  //     _focusModeControlRowAnimationController.reverse();
  //   }
  // }

  void onFocusModeButtonPressed() {
    _focusModeControlRowAnimationController
        .forward()
        .then((value) => _focusModeControlRowAnimationController.reverse());

    // if (_focusModeControlRowAnimationController.value == 1) {
    //   _focusModeControlRowAnimationController.reverse();
    // } else {
    //   _flashModeControlRowAnimationController.reverse();
    //   _exposureModeControlRowAnimationController.reverse();
    // }
  }

  void onAudioModeButtonPressed() {
    widget.enableAudio = !widget.enableAudio;
    onNewCameraSelected(controller.description);
  }

  Future<void> onCaptureOrientationLockButtonPressed() async {
    try {
      final CameraController cameraController = controller;
      if (cameraController.value.isCaptureOrientationLocked) {
        await cameraController.unlockCaptureOrientation();
        showInSnackBar('Capture orientation unlocked');
      } else {
        await cameraController.lockCaptureOrientation();
        showInSnackBar(
            'Capture orientation locked to ${cameraController.value.lockedCaptureOrientation.toString().split('.').last}');
      }
    } on CameraException catch (e) {
      _showCameraException(e);
    }
  }

  void onSetFlashModeButtonPressed(FlashMode mode) {
    setFlashMode(mode).then((_) {
      if (mounted) {
        _showChooseFlashMode.value = false;
        setState(() {
          _flashMode = mode;
        });
      }
      // showInSnackBar('Flash mode set to ${mode.toString().split('.').last}');
    });
  }

  void onSetExposureModeButtonPressed(ExposureMode mode) {
    setExposureMode(mode).then((_) {
      if (mounted) {
        setState(() {});
      }
      showInSnackBar('Exposure mode set to ${mode.toString().split('.').last}');
    });
  }

  void onSetFocusModeButtonPressed(FocusMode mode) {
    setFocusMode(mode).then((_) {
      if (mounted) {
        setState(() {});
      }
      showInSnackBar('Focus mode set to ${mode.toString().split('.').last}');
    });
  }

  void onVideoRecordButtonPressed() {
    isRecording.value = true;
    _showCounter.value = true;
    startVideoRecording();
  }

  void onStopButtonPressed() async {
    isRecording.value = false;
    _showCounter.value = false;

    await Future.delayed(Duration(milliseconds: 500));

    stopVideoRecording().then((XFile? file) {
      if (file != null) {
        showInSnackBar('Video recorded to ${file.path}');
        videoFile = file;
        _reviewCamera(context, file, isVideo: true);
        videoController?.dispose();
        videoController = null;
      }
    });
  }

  Future<void> onPausePreviewButtonPressed() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return;
    }

    if (cameraController.value.isPreviewPaused) {
      await cameraController.resumePreview();
    } else {
      await cameraController.pausePreview();
    }

    if (mounted) {
      setState(() {});
    }
  }

  void onPauseButtonPressed() {
    pauseVideoRecording().then((_) {
      if (mounted) {
        setState(() {});
      }
      showInSnackBar('Video recording paused');
    });
  }

  void onResumeButtonPressed() {
    resumeVideoRecording().then((_) {
      if (mounted) {
        setState(() {});
      }
      showInSnackBar('Video recording resumed');
    });
  }

  Future<void> startVideoRecording() async {
    if (!controller.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return;
    }

    if (controller.value.isRecordingVideo) {
      // A recording is already started, do nothing.
      return;
    }

    try {
      controller.startVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return;
    }
  }

  Future<XFile?> stopVideoRecording() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return null;
    }

    try {
      return cameraController.stopVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }

  Future<void> pauseVideoRecording() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return;
    }

    try {
      await cameraController.pauseVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> resumeVideoRecording() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return;
    }

    try {
      await cameraController.resumeVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> setFlashMode(FlashMode mode) async {
    try {
      await controller.setFlashMode(mode);
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> setExposureMode(ExposureMode mode) async {
    try {
      await controller.setExposureMode(mode);
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> setExposureOffset(double offset) async {
    _showFocus.value = false;
    setState(() {
      _currentExposureOffset = offset;
    });
    try {
      offset = await controller.setExposureOffset(offset);
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> setFocusMode(FocusMode mode) async {
    try {
      await controller.setFocusMode(mode);
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<XFile?> takePicture() async {
    final CameraController? cameraController = controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }

    if (cameraController.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      final XFile file = await cameraController.takePicture();
      return file;
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }

  void _showCameraException(CameraException e) {
    logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }
}

class _FlashModeTextItem extends StatelessWidget {
  final VoidCallback? onPressed;
  final String title;
  final bool isFlashType;

  const _FlashModeTextItem({
    this.onPressed,
    this.title = '',
    this.isFlashType = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        title,
        style: TextStyle(
          color: isFlashType ? Colors.blue : Colors.white,
          fontWeight: isFlashType ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

class _FlashModeIconItem extends StatelessWidget {
  final IconData? icon;
  final Color color;

  const _FlashModeIconItem({
    this.icon,
    this.color = Colors.white,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      color: color,
      size: 30,
    );
  }
}

class _CameraItemBuilder extends StatelessWidget {
  final XFile? imageFile;
  final Widget? childRight;
  final VoidCallback? onTakePictureButtonPressed;

  const _CameraItemBuilder({
    this.imageFile,
    this.childRight,
    this.onTakePictureButtonPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        InkWell(
          child: Hero(
            tag: imageFile?.path ?? '',
            child: CircleAvatar(
              radius: 25,
              backgroundColor: Colors.black54,
              backgroundImage:
                  (imageFile == null) ? null : FileImage(File(imageFile!.path)),
            ),
          ),
          onTap: imageFile == null
              ? null
              : () {
                  _reviewCamera(context, imageFile!);
                },
        ),
        _CustomMainButton(
          onTap: onTakePictureButtonPressed,
          child: CircleAvatar(
            radius: 35,
            backgroundColor: Colors.transparent,
          ),
        ),
        childRight ?? const SizedBox(),
      ],
    );
  }
}

class _RecordItemBuilder extends StatefulWidget {
  final bool shouldAutoPreviewVideo;
  final XFile? videoFile;
  final Widget? childRight;
  final ValueNotifier<bool>? recordNotifier;
  final VoidCallback? onStopButtonPressed, onVideoRecordButtonPressed;
  final Duration? maximumRecordingDuration;

  const _RecordItemBuilder({
    this.shouldAutoPreviewVideo = false,
    this.videoFile,
    this.childRight,
    this.recordNotifier,
    this.onStopButtonPressed,
    this.onVideoRecordButtonPressed,
    this.maximumRecordingDuration = const Duration(seconds: 15),
    Key? key,
  }) : super(key: key);

  @override
  State<_RecordItemBuilder> createState() => _RecordItemBuilderState();
}

class _RecordItemBuilderState extends State<_RecordItemBuilder>
    with TickerProviderStateMixin {
  VideoPlayerController? _videoController;
  late AnimationController _recordingDurationController;
  Timer? _maxDurationRecord;

  @override
  void initState() {
    _recordingDurationController = AnimationController(
      duration: widget.maximumRecordingDuration,
      vsync: this,
    )..addListener(() {
        setState(() {});
      });

    super.initState();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _maxDurationRecord?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _RecordItemBuilder oldWidget) {
    if (widget.videoFile != oldWidget.videoFile) {
      _videoController = VideoPlayerController.file(
        File(widget.videoFile!.path),
      )
        ..initialize()
        ..addListener(() {
          setState(() {});
        });
    }
    super.didUpdateWidget(oldWidget);
  }

  void timeoutMaxDurationRecord() {
    _maxDurationRecord?.cancel();
    _maxDurationRecord = Timer(widget.maximumRecordingDuration!, () {
      if (widget.onStopButtonPressed != null) {
        widget.onStopButtonPressed!();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        InkWell(
          child: CircleAvatar(
            radius: 25,
            backgroundColor: Colors.black54,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: _videoController == null
                  ? const SizedBox.shrink()
                  : VideoPlayer(_videoController!),
            ),
          ),
          onTap: widget.videoFile == null
              ? null
              : () {
                  _reviewCamera(context, widget.videoFile!, isVideo: true);
                },
        ),
        _buttonRecordBuilder(),
        widget.childRight ?? const SizedBox(),
      ],
    );
  }

  Widget _buttonRecordBuilder() {
    if (widget.recordNotifier == null) return const SizedBox.shrink();
    return ValueListenableBuilder(
        valueListenable: widget.recordNotifier!,
        builder: (context, bool value, child) {
          return _CustomMainButton(
            onTap: value
                ? () {
                    _recordingDurationController.reset();

                    if (widget.onStopButtonPressed != null) {
                      widget.onStopButtonPressed!();
                    }
                    _maxDurationRecord?.cancel();
                  }
                : () {
                    _recordingDurationController.forward();

                    if (widget.onVideoRecordButtonPressed != null) {
                      widget.onVideoRecordButtonPressed!();
                    }
                    timeoutMaxDurationRecord();
                  },
            child: AnimatedSwitcher(
              duration: kTabScrollDuration,
              child: value
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: 35,
                          backgroundColor: Colors.transparent,
                        ),
                        _buildCircular(),
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: const Color(0xFFDD4A30),
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                        _buildCircular(
                          value: _recordingDurationController.value,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                      ],
                    )
                  : CircleAvatar(
                      radius: 35,
                      backgroundColor: const Color(0xFFDD4A30),
                    ),
            ),
          );
        });
  }

  Widget _buildCircular({
    double value = 1,
    Animation<Color?> valueColor =
        const AlwaysStoppedAnimation<Color>(Colors.transparent),
  }) {
    return SizedBox(
      width: 55.0,
      height: 55.0,
      child: CircularProgressIndicator(
        value: value,
        valueColor: valueColor,
        strokeWidth: 5.0,
      ),
    );
  }
}

class _ExposureOffsetBuilder extends StatelessWidget {
  final ValueNotifier<bool>? exposureNotifier;
  final double currentExposureOffset,
      minAvailableExposureOffset,
      maxAvailableExposureOffset;
  final Function(double)? onChanged;
  final Function(dynamic)? onPointerDown, onPointerUp;

  const _ExposureOffsetBuilder({
    this.exposureNotifier,
    this.currentExposureOffset = 0.0,
    this.minAvailableExposureOffset = 0.0,
    this.maxAvailableExposureOffset = 0.0,
    this.onChanged,
    this.onPointerDown,
    this.onPointerUp,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (exposureNotifier == null) return const SizedBox.shrink();
    return Positioned(
      top: MediaQuery.of(context).size.height / 2.5,
      right: -30,
      child: Transform.rotate(
        angle: -math.pi / 2,
        child: ValueListenableBuilder(
          valueListenable: exposureNotifier!,
          builder: (context, bool value, child) {
            return AnimatedSwitcher(
              duration: Duration(milliseconds: 400),
              child: value
                  ? Listener(
                      onPointerDown: onPointerDown,
                      onPointerUp: onPointerUp,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          DecoratedBox(
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.yellow, width: .5),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Icon(
                                Icons.wb_sunny_rounded,
                                color: Colors.yellow,
                                size: 30,
                              ),
                            ),
                          ),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              thumbColor: Colors.yellow,
                              thumbShape: RoundSliderThumbShape(
                                  enabledThumbRadius: 5.0),
                              activeTickMarkColor: Colors.yellow,
                              inactiveTickMarkColor: Colors.grey,
                              activeTrackColor: Colors.transparent,
                              inactiveTrackColor: Colors.transparent,
                            ),
                            child: Slider(
                              value: currentExposureOffset,
                              min: minAvailableExposureOffset,
                              max: maxAvailableExposureOffset,
                              divisions: 8,
                              onChanged: onChanged,
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            );
          },
        ),
      ),
    );
  }
}

class _FocusOffsetBuilder extends StatelessWidget {
  final Offset offset;
  final ValueNotifier<bool>? focusNotifier;
  final AnimationController focusModeController;

  const _FocusOffsetBuilder({
    required this.offset,
    required this.focusModeController,
    this.focusNotifier,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (focusNotifier == null) return const SizedBox.shrink();
    return Stack(
      children: [
        ValueListenableBuilder(
          valueListenable: focusNotifier!,
          builder: (ctx, bool value, child) {
            return Positioned(
              top: offset.dy,
              left: offset.dx,
              child: value
                  ? ScaleTransition(
                      scale: focusModeController,
                      child: Image.asset(
                        'assets/images/frame.png',
                        color: Colors.yellow,
                      ),
                    )
                  : const SizedBox.shrink(),
            );
          },
        ),
      ],
    );
  }
}

class _IconButtonBuilder extends StatelessWidget {
  final CameraController controller;
  final AnimationController? swapLensController;
  final VoidCallback? onPressSwapLens;

  const _IconButtonBuilder(
    this.controller, {
    this.swapLensController,
    this.onPressSwapLens,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final child = IconButton(
      icon: Icon(
        CupertinoIcons.camera_rotate_fill,
        color: Colors.white,
        size: 30,
      ),
      onPressed: onPressSwapLens,
    );
    if (swapLensController == null) {
      return child;
    }
    return IgnorePointer(
      ignoring: controller.value.isRecordingVideo,
      child: ScaleTransition(
        scale: swapLensController!,
        child: child,
      ),
    );
  }
}

class _BlurSwitcherBuilder extends StatelessWidget {
  final ValueNotifier<bool>? blurNotifier;
  const _BlurSwitcherBuilder({this.blurNotifier, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (blurNotifier == null) return const SizedBox.shrink();

    return Positioned.fill(
      child: ValueListenableBuilder(
        valueListenable: blurNotifier!,
        builder: ((context, bool valueNotifier, child) {
          double _begin = valueNotifier ? 5.0 : 0.0;
          double _end = valueNotifier ? 5.0 : 0.0;
          return TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: _begin, end: _end),
            duration: Duration(milliseconds: 100),
            curve: Curves.easeIn,
            builder: (ctx, value, _) {
              return BackdropFilter(
                filter: ImageFilter.blur(sigmaX: value, sigmaY: value),
                child: valueNotifier
                    ? Container(color: Colors.transparent)
                    : const SizedBox.shrink(),
              );
            },
          );
        }),
      ),
    );
  }
}

class _TabBarBuilder extends StatelessWidget {
  final TabController? tabController;
  final Function(int)? onTap;
  const _TabBarBuilder({
    this.tabController,
    this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: tabController,
      indicatorColor: const Color(0xFFDD4A30),
      indicatorWeight: 2.0,
      indicatorSize: TabBarIndicatorSize.label,
      labelPadding: const EdgeInsets.symmetric(vertical: 3.0),
      padding: EdgeInsets.symmetric(vertical: 10.0),
      tabs: [
        Text('CAMERA'),
        Text('VIDEO'),
      ],
      onTap: onTap,
    );
  }
}

class _CustomMainButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget? child;

  const _CustomMainButton({
    this.onTap,
    this.child,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: CircleBorder(),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
              color: Colors.white,
              width: 5.0,
            ),
          ),
          position: DecorationPosition.foreground,
          child: child,
        ),
      ),
    );
  }
}

class _CounterTime extends StatefulWidget {
  final ValueNotifier<bool> counterNotifier;
  const _CounterTime(this.counterNotifier, {Key? key}) : super(key: key);

  @override
  State<_CounterTime> createState() => _CounterTimeState();
}

class _CounterTimeState extends State<_CounterTime> {
  final recordNotifier = ValueNotifier<bool>(false);
  final duration = ValueNotifier<Duration>(Duration());

  String TwoDigits(int n) => n.toString().padLeft(2, '0');
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _CounterTime oldWidget) {
    if (oldWidget.counterNotifier.value) {
      counterTime();
    } else {
      resetTime();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.counterNotifier,
      builder: (ctx, bool value, child) {
        if (!value) return const SizedBox.shrink();

        return AnimatedOpacity(
          opacity: 1,
          duration: kTabScrollDuration,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                bottom: 15,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ValueListenableBuilder(
                      valueListenable: recordNotifier,
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
                              child: CircleAvatar(
                                  radius: 6, backgroundColor: Colors.red),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 10),
                    ValueListenableBuilder(
                      valueListenable: duration,
                      builder: (ctx, Duration value, child) {
                        final hours = TwoDigits(value.inHours.remainder(60));
                        final minutes =
                            TwoDigits(value.inMinutes.remainder(60));
                        final seconds =
                            TwoDigits(value.inSeconds.remainder(60));
                        return Text(
                          '$hours:$minutes:$seconds',
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.bodyText1?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    decoration: TextDecoration.none,
                                  ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  changeStatusRecordIcon() async {
    recordNotifier.value = false;
    await Future.delayed(Duration(milliseconds: 300), () {
      recordNotifier.value = true;
    });
  }

  void increaseTime() {
    final seconds = duration.value.inSeconds + 1;
    duration.value = Duration(seconds: seconds);
  }

  void counterTime() =>
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        changeStatusRecordIcon();
        increaseTime();
      });

  void resetTime() {
    _timer?.cancel();
    duration.value = Duration(seconds: 0);
  }
}

void _reviewCamera(BuildContext context, XFile file, {bool isVideo = false}) {
  context.to(CameraReviewBuilder(file: file, isVideo: isVideo)).then((value) {
    if (value != null) {
      Navigator.pop(context, File(file.path));
    }
  });
}
