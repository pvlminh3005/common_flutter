part of media_picker;

class MediaSelector extends StatefulWidget {
  const MediaSelector({Key? key}) : super(key: key);

  @override
  State<MediaSelector> createState() => _MediaSelectorState();
}

class _MediaSelectorState extends State<MediaSelector>
    with TickerProviderStateMixin {
  var _arrowAnimation;
  AnimationController? _arrowAnimController;

  @override
  void initState() {
    _arrowAnimController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 100),
    );
    _arrowAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_arrowAnimController!);

    super.initState();
  }

  @override
  void dispose() {
    _arrowAnimController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 12.0,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              //rebuild UI when currentPath in provider change
              Selector<MediaPickerProvider, AssetPathEntity?>(
                selector: (_, provider) => provider.currentPath,
                builder: (context, currentPath, child) {
                  return Text(
                    currentPath?.name ?? ' ',
                    style: TextStyle(
                      fontSize: 13.0,
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                    ),
                  );
                },
              ),
              const SizedBox(width: 5.0),
              DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black,
                ),
                child: Selector<MediaPickerProvider, bool>(
                  selector: (_, provider) => provider.switchPath,
                  builder: (_, bool switchPath, __) {
                    return AnimatedBuilder(
                      animation: _arrowAnimation,
                      builder: (context, _) {
                        return Transform.rotate(
                          angle: switchPath
                              ? _arrowAnimation.value * math.pi
                              : 0.0,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.white,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
