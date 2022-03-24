part of gallery_media_picker;

///The MediaPicker widget that will select media files form storage
class MediaPicker extends StatefulWidget {
  MediaPicker({
    required this.onPick,
    required this.mediaList,
    required this.onCancel,
    this.mediaCount = MediaCount.multiple,
    this.mediaType = MediaType.all,
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
}

class _MediaPickerState extends State<MediaPicker>
    with AutomaticKeepAliveClientMixin {
  PickerDecoration? _decoration;

  AssetPathEntity? _selectedAlbum;
  List<AssetPathEntity>? _albums;

  final PanelController _albumController = PanelController();
  final HeaderController _headerController = HeaderController();

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
    super.build(context);
    return Material(
      color: Colors.transparent,
      child: _albums == null
          ? LoadingWidget(decoration: _decoration!)
          : _albums!.length == 0
              ? NoMedia()
              : Column(
                  children: [
                    if (_decoration!.actionBarPosition == ActionBarPosition.top)
                      _buildHeader(),
                    Expanded(
                        child: Stack(
                      children: [
                        Positioned.fill(
                          child: MediaList(
                            album: _selectedAlbum!,
                            headerController: _headerController,
                            previousList: widget.mediaList,
                            mediaCount: widget.mediaCount,
                            decoration: _decoration,
                            scrollController: widget.scrollController,
                          ),
                        ),
                        AlbumSelector(
                          panelController: _albumController,
                          albums: _albums!,
                          decoration: _decoration!,
                          onSelect: (album) {
                            _headerController.closeAlbumDrawer!();
                            setState(() => _selectedAlbum = album);
                          },
                        ),
                      ],
                    )),
                    if (_decoration!.actionBarPosition ==
                        ActionBarPosition.bottom)
                      _buildHeader(),
                  ],
                ),
    );
  }

  Widget _buildHeader() {
    return Header(
      onBack: handleBackPress,
      onDone: widget.onPick,
      albumController: _albumController,
      selectedAlbum: _selectedAlbum!,
      controller: _headerController,
      mediaCount: widget.mediaCount,
      decoration: _decoration,
    );
  }

  _fetchAlbums() async {
    RequestType type = RequestType.common;
    if (widget.mediaType == MediaType.all)
      type = RequestType.common;
    else if (widget.mediaType == MediaType.video)
      type = RequestType.video;
    else if (widget.mediaType == MediaType.image) type = RequestType.image;

    var result = await PhotoManager.requestPermissionExtend();
    if (result.isAuth) {
      List<AssetPathEntity> albums =
          await PhotoManager.getAssetPathList(type: type);
      setState(() {
        _albums = albums;
        _selectedAlbum = _albums![0];
      });
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

  @override
  bool get wantKeepAlive => true;
}

///call this function to capture and get media from camera
openCamera({required ValueChanged<MediaModel> onCapture}) async {
  final ImagePicker _picker = ImagePicker();
  final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);

  if (pickedFile != null) {
    MediaModel converted = MediaModel(
      id: UniqueKey().toString(),
      thumbnail: await pickedFile.readAsBytes(),
      creationTime: DateTime.now(),
      mediaByte: await pickedFile.readAsBytes(),
      title: 'capturedImage',
    );

    onCapture(converted);
  }
}
