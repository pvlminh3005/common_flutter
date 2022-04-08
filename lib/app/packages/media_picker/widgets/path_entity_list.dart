part of media_picker;

class PathEntityList extends StatelessWidget {
  const PathEntityList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final height =
        context.height - context.padding.bottom - context.padding.top;
    return Selector<MediaPickerProvider, bool>(
      selector: (BuildContext _, MediaPickerProvider e) => e.switchPath,
      builder: (context, bool switchPath, child) {
        return AnimatedPositioned(
          duration: switchingPathDuration,
          curve: switchingPathCurve,
          top: isAppleOS
              ? !switchPath
                  ? -height
                  : 0
              : -(!switchPath ? height : 1.0),
          child: AnimatedOpacity(
            duration: switchingPathDuration,
            curve: switchingPathCurve,
            opacity: !isAppleOS || switchPath ? 1.0 : 0.0,
            child: Container(
              width: context.width,
              height: height,
              padding: const EdgeInsets.all(3.0),
              decoration: BoxDecoration(
                borderRadius: isAppleOS
                    ? const BorderRadius.only(
                        bottomLeft: Radius.circular(10.0),
                        bottomRight: Radius.circular(10.0),
                      )
                    : null,
              ),
              child: Selector<MediaPickerProvider,
                  Map<AssetPathEntity?, Uint8List?>>(
                selector: (BuildContext _, MediaPickerProvider provider) =>
                    provider.pathEntityList,
                builder: (_, pathEntityList, child) {
                  return ListView.separated(
                    padding: const EdgeInsets.only(top: 1.0),
                    itemCount: pathEntityList.length,
                    itemBuilder: (BuildContext _, int index) {
                      return _PathEntityWidget(
                        path: pathEntityList.keys.elementAt(index)!,
                        isAppleOS: isAppleOS,
                      );
                    },
                    separatorBuilder: (_, int __) {
                      return const Divider(thickness: .4);
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PathEntityWidget extends StatelessWidget {
  const _PathEntityWidget({
    Key? key,
    required this.path,
    required this.isAppleOS,
  }) : super(key: key);
  final AssetPathEntity path;
  final bool isAppleOS;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MediaPickerProvider>(context, listen: false);
    Widget builder() {
      if (provider.type == RequestType.audio) {
        return ColoredBox(
          color: Colors.white.withOpacity(0.12),
          child: const Center(
            child: Icon(Icons.audiotrack_rounded),
          ),
        );
      }

      final thumbData = provider.pathEntityList[path];
      if (thumbData != null) {
        return Image.memory(thumbData, fit: BoxFit.cover);
      } else {
        return ColoredBox(
          color: Colors.black.withOpacity(.5),
        );
      }
    }

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () {
          provider.getAssetsFromEntity(path);
        },
        splashFactory: InkSplash.splashFactory,
        child: SizedBox(
          height: isAppleOS ? 65.0 : 60.0,
          child: Row(
            children: <Widget>[
              RepaintBoundary(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: builder(),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 15.0, right: 20.0),
                  child: Row(
                    children: <Widget>[
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 6.0),
                          child: Text(
                            path.name,
                            style: const TextStyle(fontSize: 17.0),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      Text(
                        '(${path.assetCount})',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 17.0,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              if (provider.currentPath == path)
                AspectRatio(
                  aspectRatio: 1.0,
                  child: Icon(
                    Icons.check,
                    size: 26.0,
                    color: Theme.of(context).primaryColor,
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
