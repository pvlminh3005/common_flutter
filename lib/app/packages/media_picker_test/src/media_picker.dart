part of gallery_media_picker;

///The MediaPicker widget that will select media files form storage
class MediaPicker extends StatefulWidget {
  MediaPicker({
    required this.onPick,
    required this.mediaList,
    required this.onCancel,
    this.mediaCount = MediaCount.multiple,
    this.mediaType = MediaType.other,
    this.decoration,
    this.scrollController,
  });

  final ValueChanged<List<MediaModel>> onPick;

  final List<MediaModel> mediaList;

  final VoidCallback onCancel;

  final MediaCount mediaCount;

  final MediaType mediaType;

  final PickerDecoration? decoration;

  final ScrollController? scrollController;

  @override
  _MediaPickerState createState() => _MediaPickerState();

  static void picker(
    BuildContext context, {
    required ValueChanged<List<MediaModel>> onPick,
    required List<MediaModel> mediaList,
    required VoidCallback onCancel,
    MediaCount mediaCount = MediaCount.multiple,
    MediaType mediaType = MediaType.other,
    PickerDecoration? decoration,
    ScrollController? scrollController,
  }) async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          body: MediaPicker(
            onPick: onPick,
            mediaList: mediaList,
            onCancel: onCancel,
          ),
        ),
      ),
    );
  }
}

class _MediaPickerState extends State<MediaPicker> {
  final PanelController _albumController = PanelController();
  final HeaderController _headerController = HeaderController();
  final _selectedAlbum = ValueNotifier<AssetPathEntity?>(null);
  final _albums = ValueNotifier<List<AssetPathEntity>?>(null);

  List<MediaModel> selectedMedia = [];
  PickerDecoration? _decoration;

  @override
  void initState() {
    _fetchAlbums();
    _decoration = widget.decoration ??
        PickerDecoration(
          actionBarPosition: ActionBarPosition.top,
          blurStrength: 2,
        );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _albums,
      builder: (BuildContext context, List<AssetPathEntity>? _albumValue,
          Widget? child) {
        if (_albumValue?.length == 0) return NoMedia();
        return ValueListenableBuilder(
          valueListenable: _selectedAlbum,
          builder:
              (BuildContext context, AssetPathEntity? value, Widget? child) {
            if (value == null) return LoadingWidget(decoration: _decoration!);
            return Scaffold(
              appBar: _AppBarCustom(
                onBack: handleBackPress,
                onDone: widget.onPick,
                albumController: _albumController,
                selectedAlbum: value,
                controller: _headerController,
                mediaCount: widget.mediaCount,
                decoration: _decoration,
              ),
              body: Material(
                color: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          _albumValue == null
                              ? LoadingWidget(decoration: _decoration!)
                              : Positioned.fill(
                                  child: MediaList(
                                    album: value,
                                    headerController: _headerController,
                                    previousList: widget.mediaList,
                                    mediaCount: widget.mediaCount,
                                    decoration: _decoration,
                                    scrollController: widget.scrollController,
                                  ),
                                ),
                          AlbumSelector(
                            panelController: _albumController,
                            albums: _albumValue!,
                            decoration: _decoration!,
                            onSelect: (album) {
                              _headerController.closeAlbumDrawer!();
                              _selectedAlbum.value = album;
                              print(_selectedAlbum.value);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHeader() {
    return ValueListenableBuilder(
      valueListenable: _selectedAlbum,
      builder: (BuildContext context, AssetPathEntity? value, Widget? child) {
        return Header(
          onBack: handleBackPress,
          onDone: widget.onPick,
          albumController: _albumController,
          selectedAlbum: value!,
          controller: _headerController,
          mediaCount: widget.mediaCount,
          decoration: _decoration,
        );
      },
    );
  }

  _fetchAlbums() async {
    RequestType type = RequestType.common;
    if (widget.mediaType == MediaType.other)
      type = RequestType.common;
    else if (widget.mediaType == MediaType.video)
      type = RequestType.video;
    else if (widget.mediaType == MediaType.image)
      type = RequestType.image;
    else
      type = RequestType.audio;

    var result = await PhotoManager.requestPermissionExtend();
    if (result.isAuth) {
      List<AssetPathEntity> albums =
          await PhotoManager.getAssetPathList(type: type);
      _albums.value = albums;
      _selectedAlbum.value = _albums.value?[0];
    } else {
      PhotoManager.openSetting();
    }
  }

  void handleBackPress() {
    if (_albumController.isPanelOpen)
      _albumController.close();
    else
      widget.onCancel();
  }
}

class _AppBarCustom extends StatefulWidget with PreferredSizeWidget {
  final AssetPathEntity selectedAlbum;
  final MediaCount mediaCount;
  final PickerDecoration? decoration;
  final PanelController albumController;
  final HeaderController controller;
  final VoidCallback onBack;
  final ValueChanged<List<MediaModel>> onDone;

  const _AppBarCustom({
    required this.selectedAlbum,
    required this.mediaCount,
    required this.albumController,
    required this.controller,
    required this.onBack,
    required this.onDone,
    this.decoration,
    Key? key,
  }) : super(key: key);

  @override
  State<_AppBarCustom> createState() => _AppBarCustomState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AppBarCustomState extends State<_AppBarCustom>
    with TickerProviderStateMixin {
  var _arrowAnimation;
  AnimationController? _arrowAnimController;
  List<MediaModel> selectedMedia = [];

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
  void dispose() {
    _arrowAnimController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: CloseButton(onPressed: widget.onBack),
      title: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        decoration: BoxDecoration(
          color: Theme.of(context).backgroundColor,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: ScaleMedia(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: kTabScrollDuration,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return SlideTransition(
                    child: child,
                    position: Tween<Offset>(
                            begin: Offset(0.0, -0.5), end: Offset(0.0, 0.0))
                        .animate(animation),
                  );
                },
                child: Text(
                  widget.selectedAlbum.name,
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(),
                  key: ValueKey<String>(widget.selectedAlbum.id),
                ),
              ),
              const SizedBox(width: 5),
              CircleAvatar(
                radius: 10,
                backgroundColor: Colors.black,
                child: AnimatedBuilder(
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
                          Colors.white,
                    ),
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
      ),
      actions: [
        if (widget.mediaCount == MediaCount.multiple)
          AnimatedSwitcher(
            duration: Duration(milliseconds: 100),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return SlideTransition(
                child: child,
                position:
                    Tween<Offset>(begin: Offset(1, 0.0), end: Offset(0.0, 0.0))
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
                              color:
                                  widget.decoration!.completeTextStyle?.color ??
                                      Theme.of(context).backgroundColor,
                              fontSize: widget.decoration!.completeTextStyle
                                          ?.fontSize !=
                                      null
                                  ? widget.decoration!.completeTextStyle!
                                          .fontSize! *
                                      0.8
                                  : 12.0,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Icon(
                            Icons.send_rounded,
                            color: Theme.of(context).backgroundColor,
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
    );
  }
}

///call this function to capture and get media from camera
// openCamera({required ValueChanged<MediaModel> onCapture}) async {
//   final ImagePicker _picker = ImagePicker();
//   final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);

//   if (pickedFile != null) {
//     MediaModel converted = MediaModel(
//       id: UniqueKey().toString(),
//       thumbnail: await pickedFile.readAsBytes(),
//       creationTime: DateTime.now(),
//       mediaByte: await pickedFile.readAsBytes(),
//       title: 'capturedImage',
//     );

//     onCapture(converted);
//   }
// }
