part of gallery_media_picker;

class MediaList extends StatefulWidget {
  MediaList({
    required this.album,
    required this.headerController,
    required this.previousList,
    this.mediaCount,
    this.decoration,
    this.scrollController,
  });

  final AssetPathEntity album;
  final HeaderController headerController;
  final List<MediaModel> previousList;
  final MediaCount? mediaCount;
  final PickerDecoration? decoration;
  final ScrollController? scrollController;

  @override
  _MediaListState createState() => _MediaListState();
}

class _MediaListState extends State<MediaList> {
  List<Widget> _mediaList = [];
  int currentPage = 0;
  int? lastPage;
  AssetPathEntity? album;

  List<MediaModel> selectedMedias = [];

  @override
  void initState() {
    album = widget.album;
    if (widget.mediaCount == MediaCount.multiple) {
      selectedMedias.addAll(widget.previousList);
      WidgetsBinding.instance!.addPostFrameCallback(
          (_) => widget.headerController.updateSelection!(selectedMedias));
    }
    _fetchNewMedia();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant MediaList oldWidget) {
    if (widget.album.name != oldWidget.album.name) {
      _fetchNewMedia();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scroll) {
        _handleScrollEvent(scroll);
        return true;
      },
      child: GridView.builder(
        controller: widget.scrollController,
        itemCount: _mediaList.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: widget.decoration!.columnCount),
        itemBuilder: (BuildContext context, int index) {
          return _mediaList[index];
        },
      ),
    );
  }

  // _resetAlbum() {
  //   if (album != null) {
  //     if (album!.id != widget.album.id) {
  //       _mediaList.clear();
  //       album = widget.album;
  //       currentPage = 0;
  //       _fetchNewMedia();
  //     }
  //   }
  // }

  _handleScrollEvent(ScrollNotification scroll) {
    if (scroll.metrics.pixels / scroll.metrics.maxScrollExtent > 0.33) {
      if (currentPage != lastPage) {
        _fetchNewMedia();
      }
    }
  }

  _fetchNewMedia() async {
    lastPage = currentPage;
    var result = await PhotoManager.requestPermissionExtend();
    if (result.isAuth) {
      List<AssetEntity> media =
          await album!.getAssetListPaged(page: currentPage, size: 60);
      List<Widget> temp = [];

      for (var asset in media) {
        temp.add(MediaTile(
          mediaCount: widget.mediaCount,
          media: asset,
          onSelected: (isSelected, media) {
            if (isSelected)
              setState(() => selectedMedias.add(media));
            else
              setState(() => selectedMedias
                  .removeWhere((_media) => _media.id == media.id));
            widget.headerController.updateSelection!(selectedMedias);
          },
          isSelected: isPreviouslySelected(asset),
          decoration: widget.decoration,
        ));
      }

      setState(() {
        _mediaList.addAll(temp);
        currentPage++;
      });
    } else {
      PhotoManager.openSetting();
    }
  }

  bool isPreviouslySelected(AssetEntity media) {
    bool isSelected = false;
    for (var asset in selectedMedias) {
      if (asset.id == media.id) isSelected = true;
    }
    return isSelected;
  }
}
