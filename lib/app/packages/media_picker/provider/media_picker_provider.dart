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
    Future<void>.delayed(routeDuration).then((_) {});
  }

  final scrollController = ScrollController();
  var selects = <AssetEntity>[];
  var assets = <AssetEntity>[];
  AssetPathEntity? currentPath;

  //switch Path media
  bool switchPath = false;
  int _quantityAssets = 0;
  bool isAssetEmpty = false;

  bool get hasMoreToLoad => assets.length < _quantityAssets;
  int get currentPage => (math.max(1, assets.length) / _pageSize).ceil();
  double get position => scrollController.position.pixels;
  double get maxScrollExtent => scrollController.position.maxScrollExtent;
  bool get _loadMore => position / maxScrollExtent > .33;
  bool isLoadMore = true;

  //save path in list
  final pathListNotifier = ValueNotifier<List<AssetPathEntity>>([]);
  var pathList = <AssetPathEntity>[];

  Future<void> onLoadMore() async {
    if (hasMoreToLoad) {
      final items = await currentPath?.getAssetListPaged(
        page: currentPage,
        size: _pageSize,
      );
    }
  }

  Future<void> getAssetPathList() async {}

  Future<void> getAssetList() async {}

  void onBack() {}
}
