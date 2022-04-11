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
      duration: Duration(milliseconds: 300),
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
    final provider = Provider.of<MediaPickerProvider>(context, listen: false);

    return GestureDetector(
      onTap: () {
        provider.togglePath();
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 5.0,
            horizontal: 6.0,
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
                  builder: (_, switchPath, child) {
                    return AnimatedBuilder(
                      animation: _arrowAnimation,
                      builder: (context, _) {
                        if (provider.switchPath) {
                          _arrowAnimController!.forward();
                        } else {
                          _arrowAnimController!.reverse();
                        }
                        return Transform.rotate(
                          angle: _arrowAnimation.value * math.pi,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.white,
                            size: 20,
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
