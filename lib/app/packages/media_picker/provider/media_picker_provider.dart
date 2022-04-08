part of media_picker;

const int _pageSize = 80;

class MediaPickerProvider extends ChangeNotifier {
  final Duration routeDuration;
  final RequestType type;
  final int limit;
  final bool enableMultiple, enableReview;

  MediaPickerProvider({
    required this.routeDuration,
    this.type = RequestType.common,
    this.limit = 10,
    this.enableMultiple = false,
    this.enableReview = false,
  }) {
    Future<void>.delayed(routeDuration).then((_) {
      getAssetPathList().whenComplete(() {
        getAssetList();
        registerObserve(_onLimitedAssetsUpdated);
      });
    });
    scrollController.addListener(_listenerLoadMore);
  }

  final scrollController = ScrollController();
  var selects = <AssetEntity>[];
  var assets = <AssetEntity>[];
  final pathEntityList = <AssetPathEntity?, Uint8List?>{};
  AssetPathEntity? currentPath;

  //switch Path media
  bool switchPath = false;
  int _quantityAssets = 0;
  bool isAssetsEmpty = false;

  bool get hasMoreToLoad => assets.length < _quantityAssets;
  int get currentPage => (math.max(1, assets.length) / _pageSize).ceil();
  double get position => scrollController.position.pixels;
  double get maxScrollExtent => scrollController.position.maxScrollExtent;
  bool get _loadMore => position / maxScrollExtent > .33;
  bool isLoadMore = true;

  bool _hasAssetsToDisplay = false;
  bool get hasAssetsToDisplay => _hasAssetsToDisplay;
  set hasAssetsToDisplay(bool value) {
    if (value == _hasAssetsToDisplay) {
      return;
    }
    _hasAssetsToDisplay = value;
    notifyListeners();
  }

  //save path in list
  final pathListNotifier = ValueNotifier<List<AssetPathEntity>>([]);
  var pathList = <AssetPathEntity>[];

  togglePath() {
    switchPath = !switchPath;
    notifyListeners();
  }

  Future<void> getAssetPathList() async {
    final _list = await PhotoManager.getAssetPathList(type: type);

    _list.sort((path1, path2) {
      if (path1.isAll) {
        return -1;
      }
      if (path2.isAll) {
        return 1;
      }
      return path1.name.toUpperCase().compareTo(path2.name.toUpperCase());
    });

    for (var pathEntity in _list) {
      pathEntityList[pathEntity] = null;
      if (type != RequestType.audio) {
        getFirstThumbFromPathEntity(pathEntity).then((Uint8List? data) {
          pathEntityList[pathEntity] = data;
        });
      }
    }
  }

  Future<Uint8List?> getFirstThumbFromPathEntity(pathEntity) async {
    final AssetEntity asset = (await pathEntity.getAssetListRange(
      start: 0,
      end: 1,
    ))
        .elementAt(0);
    if (asset.type == AssetType.image || asset.type == AssetType.video) {
      final assetData =
          await asset.thumbnailDataWithSize(const ThumbnailSize.square(80));
      return assetData;
    } else {
      return null;
    }
  }

  void _onLimitedAssetsUpdated(MethodCall methodCall) async {
    if (currentPath != null) {
      await currentPath?.fetchPathProperties();
      getAssetsFromEntity(currentPath!);
    }
  }

  Future<void> getAssetsFromEntity(AssetPathEntity pathEntity) async {
    switchPath = false;
    selects = [];
    if (currentPath == pathEntity) {
      return;
    }
    currentPath = pathEntity;
    _quantityAssets = pathEntity.assetCount;

    final items = await pathEntity.getAssetListPaged(
      page: 0,
      size: _pageSize,
    );
    assets = items;
    _hasAssetsToDisplay = assets.isNotEmpty;

    notifyListeners();
  }

  Future<void> getAssetList() async {
    if (pathEntityList.isNotEmpty) {
      await getAssetsFromEntity(pathEntityList.keys.elementAt(0)!);
    } else {
      assets = [];
      isAssetsEmpty = true;
    }
  }

  void _listenerLoadMore() {
    if (isLoadMore && _loadMore) {
      isLoadMore = false;
      onLoadMore().then((value) => isLoadMore = true);
    }
  }

  Future<void> onLoadMore() async {
    if (hasMoreToLoad) {
      final items = await currentPath?.getAssetListPaged(
        page: currentPage,
        size: _pageSize,
      );
    }
  }

  void registerObserve([ValueChanged<MethodCall>? callback]) {
    if (callback == null) {
      return;
    }
    try {
      PhotoManager.addChangeCallback(callback);
      PhotoManager.startChangeNotify();
    } catch (e) {
      throw Exception();
    }
  }
}
