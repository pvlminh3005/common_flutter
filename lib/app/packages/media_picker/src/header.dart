part of gallery_media_picker;

class Header extends StatefulWidget {
  Header({
    required this.selectedAlbum,
    required this.onBack,
    required this.onDone,
    required this.albumController,
    required this.controller,
    this.mediaCount,
    this.decoration,
  });

  final AssetPathEntity selectedAlbum;
  final VoidCallback onBack;
  final PanelController albumController;
  final ValueChanged<List<MediaModel>> onDone;
  final HeaderController controller;
  final MediaCount? mediaCount;
  final PickerDecoration? decoration;

  @override
  _HeaderState createState() => _HeaderState();
}

class _HeaderState extends State<Header> with TickerProviderStateMixin {
  List<MediaModel> selectedMedia = [];

  var _arrowAnimation;
  AnimationController? _arrowAnimController;

  @override
  void initState() {
    _arrowAnimController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 100));
    _arrowAnimation =
        Tween<double>(begin: 0, end: 1).animate(_arrowAnimController!);

    widget.controller.updateSelection = (selectedMediaList) {
      if (widget.mediaCount == MediaCount.multiple)
        setState(() => selectedMedia = selectedMediaList.cast<MediaModel>());
      else if (selectedMediaList.length == 1) widget.onDone(selectedMediaList);
    };

    widget.controller.closeAlbumDrawer = () {
      widget.albumController.close();
      _arrowAnimController!.reverse();
    };

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Material(
            color: Colors.transparent,
            clipBehavior: Clip.hardEdge,
            shape: CircleBorder(),
            child: InkWell(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: widget.decoration!.cancelIcon ??
                    Icon(Icons.arrow_back_outlined),
              ),
              onTap: () {
                if (_arrowAnimation.value == 1) _arrowAnimController!.reverse();
                widget.onBack();
              },
            ),
          ),
          ScaleMedia(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: Duration(milliseconds: 200),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return SlideTransition(
                      child: child,
                      position: Tween<Offset>(
                              begin: Offset(0.0, -0.5), end: Offset(0.0, 0.0))
                          .animate(animation),
                    );
                  },
                  child: Text(
                    widget.selectedAlbum.name,
                    style: widget.decoration!.albumTitleStyle,
                    key: ValueKey<String>(widget.selectedAlbum.id),
                  ),
                ),
                AnimatedBuilder(
                  animation: _arrowAnimation,
                  builder: (context, child) => Transform.rotate(
                    angle: _arrowAnimation.value * math.pi,
                    child: Icon(
                      Icons.keyboard_arrow_up_outlined,
                      size: (widget.decoration!.albumTitleStyle?.fontSize) !=
                              null
                          ? widget.decoration!.albumTitleStyle!.fontSize! * 1.5
                          : 20,
                      color: widget.decoration!.albumTitleStyle?.color ??
                          Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            onTap: () {
              if (widget.albumController.isPanelOpen) {
                widget.albumController.close();
                _arrowAnimController!.reverse();
              }
              if (widget.albumController.isPanelClosed) {
                widget.albumController.open();
                _arrowAnimController!.forward();
              }
            },
          ),
          if (widget.mediaCount == MediaCount.multiple)
            AnimatedSwitcher(
              duration: Duration(milliseconds: 100),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return SlideTransition(
                  child: child,
                  position: Tween<Offset>(
                          begin: Offset(1, 0.0), end: Offset(0.0, 0.0))
                      .animate(animation),
                );
              },
              child: (selectedMedia.length > 0)
                  ? InkWell(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              ' (${selectedMedia.length})',
                              style: TextStyle(
                                color: widget
                                        .decoration!.completeTextStyle?.color ??
                                    Colors.black,
                                fontSize: widget.decoration!.completeTextStyle
                                            ?.fontSize !=
                                        null
                                    ? widget.decoration!.completeTextStyle!
                                            .fontSize! *
                                        0.8
                                    : 11,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Icon(
                              Icons.send_rounded,
                              color: Theme.of(context).primaryColor,
                              size: (widget.decoration!.albumTitleStyle
                                          ?.fontSize) !=
                                      null
                                  ? widget.decoration!.albumTitleStyle!
                                          .fontSize! *
                                      1.5
                                  : 25,
                            ),
                          ],
                        ),
                      ),
                      onTap: () => widget.onDone(selectedMedia),
                    )
                  : const SizedBox.shrink(),
            ),
        ],
      ),
    );
  }
}
