part of media_picker;

Duration get switchingPathDuration => kThemeAnimationDuration * 1.5;
bool get isAppleOS => Platform.isIOS || Platform.isMacOS;
Curve get switchingPathCurve => Curves.easeInOut;

class MediaPickerBuilder extends StatelessWidget {
  const MediaPickerBuilder({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(),
      body: Selector<MediaPickerProvider, bool>(
        selector: (_, provider) => provider.hasAssetsToDisplay,
        builder: (_, bool hasAssetsToDisplay, child) {
          return hasAssetsToDisplay
              ? Stack(
                  children: [
                    PathEntityList(),
                  ],
                )
              : const SizedBox.shrink();
        },
      ),
    );
  }
}
