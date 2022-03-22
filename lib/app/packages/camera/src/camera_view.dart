import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../camera.dart';

enum CameraType {
  camera,
  video,
}

T? _ambiguate<T>(T? value) => value;

List<CameraDescription> cameras = <CameraDescription>[];

class CameraCommon extends StatefulWidget {
  @override
  _CameraCommonState createState() {
    return _CameraCommonState();
  }

  static Future<void> initialCamera() async {
    cameras = await availableCameras();
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

class _CameraCommonState extends State<CameraCommon>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  late CameraController controller;
  XFile? imageFile;
  XFile? videoFile;
  VideoPlayerController? videoController;
  VoidCallback? videoPlayerListener;
  bool enableAudio = true;
  double _minAvailableExposureOffset = 0.0;
  double _maxAvailableExposureOffset = 0.0;
  double _currentExposureOffset = 0.0;
  late AnimationController _flashModeControlRowAnimationController;
  late Animation<double> _flashModeControlRowAnimation;
  late AnimationController _exposureModeControlRowAnimationController;
  late Animation<double> _exposureModeControlRowAnimation;
  late AnimationController _focusModeControlRowAnimationController;
  late Animation<double> _focusModeControlRowAnimation;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _currentScale = 1.0;
  double _baseScale = 1.0;
  // Counting pointers (number of user fingers on screen)
  int _pointers = 0;

  //* initial lens description camera
  int lensCamera = 0;
  double angle = 0.0;
  bool flashOn = false;
  CameraType cameraType = CameraType.camera;
  bool isRecording = false;
  bool _showBlur = false;

  late TabController tabController;

  bool _showExposure = false;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    onNewCameraSelected(cameras[lensCamera]);
    _ambiguate(WidgetsBinding.instance)?.addObserver(this);

    _flashModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _flashModeControlRowAnimation = CurvedAnimation(
      parent: _flashModeControlRowAnimationController,
      curve: Curves.easeInCubic,
    );
    _exposureModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _exposureModeControlRowAnimation = CurvedAnimation(
      parent: _exposureModeControlRowAnimationController,
      curve: Curves.easeInCubic,
    );
    _focusModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _focusModeControlRowAnimation = CurvedAnimation(
      parent: _focusModeControlRowAnimationController,
      curve: Curves.easeInCubic,
    );
  }

  @override
  void dispose() {
    _ambiguate(WidgetsBinding.instance)?.removeObserver(this);
    _flashModeControlRowAnimationController.dispose();
    _exposureModeControlRowAnimationController.dispose();
    controller.dispose();
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
                    child: IconButton(
                      onPressed: () {
                        setState(() => flashOn = !flashOn);
                        onSetFlashModeButtonPressed(
                            flashOn ? FlashMode.torch : FlashMode.off);
                      },
                      icon: Icon(
                        flashOn
                            ? Icons.flash_on_rounded
                            : Icons.flash_off_rounded,
                        color: flashOn ? Colors.yellow : Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                  _ExposureOffsetBuilder(
                    onPointerDown: (_) => _pointers++,
                    onPointerUp: (_) {
                      _pointers--;
                      _pointers = _pointers < 0 ? 0 : _pointers;
                      timOutShowExposure();
                    },
                    showExposure: _showExposure,
                    onChanged: setExposureOffset,
                    currentExposureOffset: _currentExposureOffset,
                    minAvailableExposureOffset: _minAvailableExposureOffset,
                    maxAvailableExposureOffset: _maxAvailableExposureOffset,
                  ),
                  _BlurSwitcherBuilder(showBlur: _showBlur),
                ],
              ),
            ),
            // const Spacer(),
            _TabBarBuilder(
              tabController: tabController,
              onTap: (index) async {
                setState(() {
                  _showBlur = true;
                  cameraType = CameraType.values[index];
                });
                await Future.delayed(Duration(milliseconds: 400));
                setState(() => _showBlur = false);
              },
            ),

            _bottomBuilder(),
          ],
        ),
      ),
    );
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
                onPressedRecord: controller.value.isRecordingPaused
                    ? onResumeButtonPressed
                    : onPauseButtonPressed,
                onPressSwapLens: swapLensCamera,
              ),
            )
          : _RecordItemBuilder(
              videoController: videoController,
              videoFile: videoFile,
              isRecording: controller.value.isRecordingVideo,
              childRight: _IconButtonBuilder(
                controller,
                onPressedRecord: controller.value.isRecordingPaused
                    ? onResumeButtonPressed
                    : onPauseButtonPressed,
                onPressSwapLens: swapLensCamera,
              ),
              onStopButtonPressed: onStopButtonPressed,
              onVideoRecordButtonPressed: onVideoRecordButtonPressed,
            ),
    );
  }

  void _flip() {
    setState(() {
      angle = (angle + pi) % (2 * pi);
    });
  }

  void swapLensCamera() async {
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
              setState(() => _showExposure = true);
            },
            onLongPressMoveUpdate: (value) => timOutShowExposure(),
            onTapDown: (TapDownDetails details) =>
                onViewFinderTap(details, constraints),
          );
        }),
      ),
    );
  }

  void timOutShowExposure() {
    Timer(Duration(seconds: 3), () {
      if (_pointers == 0) {
        setState(() {
          _showExposure = false;
        });
      }
    });
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _baseScale = _currentScale;
  }

  Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
    // When there are not exactly two fingers on screen don't scale
    if (_pointers != 2) {
      return;
    }

    _currentScale = (_baseScale * details.scale)
        .clamp(_minAvailableZoom, _maxAvailableZoom);

    await controller.setZoomLevel(_currentScale);
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void showInSnackBar(String message) {
    // ignore: deprecated_member_use
    _scaffoldKey.currentState?.showSnackBar(SnackBar(content: Text(message)));
  }

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    final CameraController cameraController = controller;

    final Offset offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    cameraController.setExposurePoint(offset);
    cameraController.setFocusPoint(offset);
  }

  Future<void> onNewCameraSelected(CameraDescription cameraDescription) async {
    controller = CameraController(
      cameraDescription,
      ResolutionPreset.max,
      enableAudio: enableAudio,
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
          videoController?.dispose();
          videoController = null;
        });
        if (file != null) {
          showInSnackBar('Picture saved to ${file.path}');
        }
      }
    });
  }

  void onFlashModeButtonPressed() {
    if (_flashModeControlRowAnimationController.value == 1) {
      _flashModeControlRowAnimationController.reverse();
    } else {
      _flashModeControlRowAnimationController.forward();
      _exposureModeControlRowAnimationController.reverse();
      _focusModeControlRowAnimationController.reverse();
    }
  }

  void onExposureModeButtonPressed() {
    if (_exposureModeControlRowAnimationController.value == 1) {
      _exposureModeControlRowAnimationController.reverse();
    } else {
      _exposureModeControlRowAnimationController.forward();
      _flashModeControlRowAnimationController.reverse();
      _focusModeControlRowAnimationController.reverse();
    }
  }

  void onFocusModeButtonPressed() {
    if (_focusModeControlRowAnimationController.value == 1) {
      _focusModeControlRowAnimationController.reverse();
    } else {
      _focusModeControlRowAnimationController.forward();
      _flashModeControlRowAnimationController.reverse();
      _exposureModeControlRowAnimationController.reverse();
    }
  }

  void onAudioModeButtonPressed() {
    enableAudio = !enableAudio;
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
        setState(() {});
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
    startVideoRecording().then((_) {
      if (mounted) {
        isRecording = true;
        setState(() {});
      }
    });
  }

  void onStopButtonPressed() {
    stopVideoRecording().then((XFile? file) {
      if (mounted) {
        setState(() {});
      }
      if (file != null) {
        showInSnackBar('Video recorded to ${file.path}');
        videoFile = file;
        _startVideoPlayer();
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
      await controller.startVideoRecording();
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

  Future<void> _startVideoPlayer() async {
    if (videoFile == null) {
      return;
    }

    final VideoPlayerController vController = kIsWeb
        ? VideoPlayerController.network(videoFile!.path)
        : VideoPlayerController.file(File(videoFile!.path));

    videoPlayerListener = () {
      if (videoController != null) {
        // Refreshing the state to update video player with the correct ratio.
        if (mounted) {
          setState(() {});
        }
        videoController!.removeListener(videoPlayerListener!);
      }
    };
    vController.addListener(videoPlayerListener!);
    await vController.setLooping(true);
    await vController.initialize();
    await videoController?.dispose();
    if (mounted) {
      setState(() {
        imageFile = null;
        videoController = vController;
      });
    }
    await vController.play();
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
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CacheImageCustom(imageFile!.path),
                    ),
                  );
                },
        ),
        InkWell(
          onTap: onTakePictureButtonPressed,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: Colors.white,
                width: 5.0,
              ),
            ),
            position: DecorationPosition.foreground,
            child: CircleAvatar(
              radius: 35,
              backgroundColor: Colors.transparent,
            ),
          ),
        ),
        childRight ?? const SizedBox(),
      ],
    );
  }
}

class _RecordItemBuilder extends StatelessWidget {
  final VideoPlayerController? videoController;
  final XFile? videoFile;
  final Widget? childRight;
  final bool isRecording;
  final VoidCallback? onStopButtonPressed, onVideoRecordButtonPressed;

  const _RecordItemBuilder({
    this.videoController,
    this.videoFile,
    this.childRight,
    this.isRecording = false,
    this.onStopButtonPressed,
    this.onVideoRecordButtonPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (videoController != null) {
      videoController!.pause();
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        InkWell(
          child: Hero(
            tag: videoFile?.path ?? '',
            child: CircleAvatar(
              radius: 25,
              backgroundColor: Colors.black54,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: videoController == null
                    ? const SizedBox.shrink()
                    : VideoPlayer(videoController!),
              ),
            ),
          ),
          onTap: videoFile == null
              ? null
              : () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => CacheVideoCustom(videoController!),
                  ));
                },
        ),
        _buttonRecordBuilder(),
        childRight ?? const SizedBox(),
      ],
    );
  }

  Widget _buttonRecordBuilder() {
    if (isRecording) {
      return InkWell(
        onTap: onStopButtonPressed,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
              color: Colors.white,
              width: 5.0,
            ),
          ),
          position: DecorationPosition.foreground,
          child: CircleAvatar(
            radius: 35,
            backgroundColor: Colors.transparent,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: const Color(0xFFDD4A30),
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
          ),
        ),
      );
    }
    return InkWell(
      onTap: onVideoRecordButtonPressed,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: Colors.white,
            width: 5.0,
          ),
        ),
        position: DecorationPosition.foreground,
        child: CircleAvatar(
          radius: 35,
          backgroundColor: const Color(0xFFDD4A30),
        ),
      ),
    );
  }
}

class _ExposureOffsetBuilder extends StatelessWidget {
  final bool showExposure;
  final double currentExposureOffset,
      minAvailableExposureOffset,
      maxAvailableExposureOffset;
  final Function(double)? onChanged;
  final Function(dynamic)? onPointerDown, onPointerUp;

  const _ExposureOffsetBuilder({
    this.showExposure = false,
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
    return Positioned(
      top: MediaQuery.of(context).size.height / 2.5,
      right: -30,
      child: Transform.rotate(
        angle: -pi / 2,
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: 400),
          child: showExposure
              ? Listener(
                  onPointerDown: onPointerDown,
                  onPointerUp: onPointerUp,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.yellow, width: .5),
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
                          thumbShape:
                              RoundSliderThumbShape(enabledThumbRadius: 5.0),
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
        ),
      ),
    );
  }
}

class _IconButtonBuilder extends StatelessWidget {
  final CameraController controller;
  final VoidCallback? onPressedRecord, onPressSwapLens;

  const _IconButtonBuilder(
    this.controller, {
    this.onPressedRecord,
    this.onPressSwapLens,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (controller.value.isRecordingVideo) {
      return IconButton(
        iconSize: 32,
        icon: Icon(
          controller.value.isRecordingPaused
              ? CupertinoIcons.play_circle
              : CupertinoIcons.pause_circle,
          color: Colors.white.withOpacity(.7),
        ),
        onPressed: onPressedRecord,
      );
    }
    return IconButton(
      icon: Icon(
        CupertinoIcons.camera_rotate_fill,
        color: Colors.white,
        size: 30,
      ),
      onPressed: onPressSwapLens,
    );
  }
}

class _BlurSwitcherBuilder extends StatelessWidget {
  final bool showBlur;
  const _BlurSwitcherBuilder({this.showBlur = false, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double _begin = showBlur ? 5.0 : 0.0;
    double _end = showBlur ? 5.0 : 0.0;

    return Positioned.fill(
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: _begin, end: _end),
        duration: Duration(milliseconds: 100),
        curve: Curves.easeIn,
        builder: (ctx, value, _) {
          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: value, sigmaY: value),
            child: showBlur
                ? Container(color: Colors.transparent)
                : const SizedBox.shrink(),
          );
        },
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
