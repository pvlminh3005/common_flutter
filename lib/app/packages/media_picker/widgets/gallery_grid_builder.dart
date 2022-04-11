part of media_picker;

class GalleryGridBuilder extends StatelessWidget {
  const GalleryGridBuilder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MediaPickerProvider>(context, listen: false);
    return Selector<MediaPickerProvider, List<AssetEntity>>(
      selector: (_, MediaPickerProvider e) => e.assets,
      builder: (_, assets, child) {
        return GridView.builder(
          controller: provider.scrollController,
          padding: const EdgeInsets.all(10),
          itemCount: assets.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: context.gridCount(gridCount: provider.gridCount),
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
          ),
          itemBuilder: (_, int index) {
            if (index == 0 && provider.leadingBuilder != null) {
              return provider.leadingBuilder!(context);
            }
            if (provider.leadingBuilder != null) {
              index = index - 1;
            }
            final asset = provider.assets[index];
            return _ItemBuilder(asset: asset, index: index);
          },
        );
      },
    );
  }
}

class _ItemBuilder extends StatelessWidget {
  const _ItemBuilder({
    Key? key,
    required this.asset,
    required this.index,
  }) : super(key: key);
  final AssetEntity asset;
  final int index;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MediaPickerProvider>(context, listen: false);
    final size =
        context.width / context.gridCount(gridCount: provider.gridCount);
    final scale = math.min(1, size / 100);
    final _size = ThumbnailSize(size ~/ scale, size ~/ scale);
    return Stack(
      children: [
        Positioned.fill(
          child: asset.type == AssetType.audio
              ? AudioItemViewer(title: asset.title)
              : AssetEntityImage(
                  asset,
                  thumbnailSize: _size,
                  isOriginal: false,
                  fit: BoxFit.cover,
                ),
        ),
        if (asset.type == AssetType.audio || asset.type == AssetType.video)
          DurationIndicator(duration: asset.duration),
        Selector<MediaPickerProvider, List<AssetEntity>>(
          selector: (_, MediaPickerProvider e) => e.selects,
          builder: (_, selects, child) {
            return SelectedBackdrop(
              selected: selects.contains(asset),
              onReview: () {
                if (provider.enableReview) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MediaBuilderPreviewBuilder(
                        assets: context.watch<MediaPickerProvider>().assets,
                        index: index,
                        checked: selects.contains(asset),
                      ),
                    ),
                  );
                } else {
                  provider.onSelectItem(asset);
                }
              },
            );
          },
        ),
        Selector<MediaPickerProvider, List<AssetEntity>>(
          selector: (_, MediaPickerProvider e) => e.selects,
          builder: (_, selects, child) {
            return SelectIndicator(
              selected: selects.contains(asset),
              onTap: () {
                provider.onSelectItem(asset);
              },
              isMulti: provider.enableMultiple,
              gridCount: context.gridCount(gridCount: provider.gridCount),
              selectText: (selects.indexOf(asset) + 1).toString(),
            );
          },
        )
      ],
    );
  }
}
