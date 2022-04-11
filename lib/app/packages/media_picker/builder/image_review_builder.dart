part of media_picker;

class ImagePageBuilder extends StatelessWidget {
  const ImagePageBuilder({
    Key? key,
    required this.asset,
    this.previewThumbSize,
    this.updateAnimation,
  }) : super(key: key);
  final AssetEntity asset;
  final List<int>? previewThumbSize;
  final Function(ExtendedImageGestureState)? updateAnimation;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: RepaintBoundary(
        child: ExtendedImage(
          image: AssetEntityImageProvider(
            asset,
            isOriginal: previewThumbSize == null,
          ),
          fit: BoxFit.contain,
          mode: ExtendedImageMode.gesture,
          initGestureConfigHandler: (ExtendedImageState state) {
            return GestureConfig(
              initialScale: 1.0,
              minScale: 1.0,
              maxScale: 3.0,
              animationMinScale: 0.6,
              animationMaxScale: 4.0,
              cacheGesture: false,
              inPageView: true,
            );
          },
          onDoubleTap: updateAnimation,
          loadStateChanged: (ExtendedImageState state) {
            Widget loader = const SizedBox.shrink();
            switch (state.extendedImageLoadState) {
              case LoadState.loading:
                loader = const ColoredBox(color: Color(0x10ffffff));
                break;
              case LoadState.completed:
                loader = RepaintBoundary(
                  child: Hero(tag: asset.id, child: state.completedWidget),
                );
                break;
              case LoadState.failed:
                loader = failedItemBuilder(context);
                break;
            }
            return loader;
          },
        ),
      ),
    );
  }

  Widget failedItemBuilder(BuildContext context) {
    return const Center(
      child: Text(
        'Not load image',
        textAlign: TextAlign.center,
      ),
    );
  }
}
