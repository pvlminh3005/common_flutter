part of media_picker;

class MediaBuilderPreviewBuilder extends StatefulWidget {
  const MediaBuilderPreviewBuilder({
    Key? key,
    required this.assets,
    this.index = 0,
    this.checked = false,
  }) : super(key: key);
  final List<AssetEntity> assets;
  final int index;
  final bool checked;

  @override
  _MediaBuilderPreviewBuilderState createState() =>
      _MediaBuilderPreviewBuilderState();
}

class _MediaBuilderPreviewBuilderState extends State<MediaBuilderPreviewBuilder>
    with SingleTickerProviderStateMixin {
  ExtendedPageController get pageController => _pageController;
  late final ExtendedPageController _pageController = ExtendedPageController(
    initialPage: currentIndex,
  );
  late AnimationController _doubleTapAnimationController;
  late Animation<double> _doubleTapCurveAnimation;
  Animation<double>? _doubleTapAnimation;
  late VoidCallback _doubleTapListener;

  final _pageStreamController = StreamController<int>.broadcast();
  final _showAppBar = ValueNotifier<bool>(true);
  late int _currentIndex;
  int get currentIndex => _currentIndex;
  int get total => widget.assets.length;
  final checkedNotifier = ValueNotifier(false);

  set currentIndex(int value) {
    if (_currentIndex == value) {
      return;
    }
    _currentIndex = value;
  }

  @override
  void initState() {
    _doubleTapAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _doubleTapCurveAnimation = CurvedAnimation(
      parent: _doubleTapAnimationController,
      curve: Curves.easeInOut,
    );
    _currentIndex = widget.index;
    checkedNotifier.value = widget.checked;
    super.initState();
  }

  @override
  void dispose() {
    pageController.dispose();
    _doubleTapAnimationController
      ..stop()
      ..reset()
      ..dispose();
    _showAppBar.dispose();
    _pageStreamController.close();
    super.dispose();
  }

  void updateAnimation(ExtendedImageGestureState? state) {
    final double? begin = state?.gestureDetails?.totalScale;
    final double end = state?.gestureDetails?.totalScale == 1.0 ? 3.0 : 1.0;
    final Offset? pointerDownPosition = state?.pointerDownPosition;

    _doubleTapAnimation?.removeListener(_doubleTapListener);
    _doubleTapAnimationController
      ..stop()
      ..reset();
    _doubleTapListener = () {
      state?.handleDoubleTap(
        scale: _doubleTapAnimation!.value,
        doubleTapPosition: pointerDownPosition,
      );
    };
    _doubleTapAnimation = Tween<double>(
      begin: begin,
      end: end,
    ).animate(_doubleTapCurveAnimation)
      ..addListener(_doubleTapListener);

    _doubleTapAnimationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: ExtendedImageGesturePageView.builder(
              canScrollPage: (val) {
                return val?.totalScale == 1.0 || val?.totalScale == null;
              },
              physics: const AlwaysScrollableScrollPhysics(),
              controller: pageController,
              itemCount: total,
              scrollDirection: Axis.horizontal,
              itemBuilder: assetPageBuilder,
              onPageChanged: (int index) {
                currentIndex = index;
                _pageStreamController.add(index);
                _showAppBar.value = true;
              },
            ),
          ),
          appBar(context),
        ],
      ),
    );
  }

  Widget appBar(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _showAppBar,
      builder: (_, bool value, Widget? child) {
        return AnimatedPositioned(
          duration: kThemeAnimationDuration,
          curve: Curves.easeInOut,
          top: value ? 0.0 : -(context.padding.top + kToolbarHeight),
          left: 0.0,
          right: 0.0,
          height: context.padding.top + kToolbarHeight,
          child: child!,
        );
      },
      child: Container(
        padding: EdgeInsets.only(top: context.padding.top, right: 12.0),
        child: Row(
          children: <Widget>[
            const CloseButton(color: Colors.white),
            StreamBuilder<int>(
              initialData: currentIndex,
              stream: _pageStreamController.stream,
              builder: (_, AsyncSnapshot<int> snapshot) {
                return Text(
                  '${snapshot.data! + 1}/$total',
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget assetPageBuilder(BuildContext context, int index) {
    final AssetEntity asset = widget.assets.elementAt(index);
    switch (asset.type) {
      case AssetType.audio:
        return AudioPageBuilder(asset: asset);
      case AssetType.image:
        return ImagePageBuilder(asset: asset, updateAnimation: updateAnimation);
      case AssetType.video:
        return VideoPageBuilder(
          asset: asset,
          toggleShowAppBar: (bool value) {
            _showAppBar.value = value;
          },
        );
      default:
        return const Center(child: Text('Not support type'));
    }
  }
}
