part of gallery_media_picker;

class MediaTile extends StatefulWidget {
  MediaTile({
    Key? key,
    required this.media,
    required this.onSelected,
    this.mediaCount = MediaCount.single,
    this.isSelected = false,
    this.decoration,
  }) : super(key: key);

  final AssetEntity media;
  final Function(bool, MediaModel) onSelected;
  final MediaCount? mediaCount;
  final bool isSelected;
  final PickerDecoration? decoration;

  @override
  _MediaTileState createState() => _MediaTileState();
}

class _MediaTileState extends State<MediaTile>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  bool? selected;

  MediaModel? media;

  Duration _duration = Duration(milliseconds: 100);
  AnimationController? _animationController;
  Animation? _animation;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: _duration);
    _animation =
        Tween<double>(begin: 1.0, end: 1.3).animate(_animationController!);
    selected = widget.isSelected;
    if (selected!) _animationController!.forward();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (media != null) {
      return Padding(
        padding: const EdgeInsets.all(0.5),
        child: ScaleMedia(
          onTap: () {
            setState(() => selected = !selected!);
            if (selected!)
              _animationController!.forward();
            else
              _animationController!.reverse();
            widget.onSelected(selected!, media!);
          },
          child: Stack(
            children: [
              Positioned.fill(
                child: media!.thumbnail != null
                    ? Stack(
                        children: [
                          Positioned.fill(
                            child: ClipRect(
                              child: AnimatedBuilder(
                                  animation: _animation!,
                                  builder: (context, child) {
                                    double amount =
                                        (_animation!.value - 1) * 3.33;

                                    return ImageFiltered(
                                      imageFilter: ImageFilter.blur(
                                        sigmaX:
                                            widget.decoration!.blurStrength *
                                                amount,
                                        sigmaY:
                                            widget.decoration!.blurStrength *
                                                amount,
                                      ),
                                      child: Transform.scale(
                                        scale: _animation!.value,
                                        child: Image.memory(
                                          media!.thumbnail!,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    );
                                  }),
                            ),
                          ),
                          Positioned.fill(
                            child: AnimatedOpacity(
                              opacity: selected! ? 1 : 0,
                              curve: Curves.easeOut,
                              duration: _duration,
                              child: ClipRect(
                                child: Container(color: Colors.black26),
                              ),
                            ),
                          ),
                          if (widget.media.type == AssetType.video)
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Padding(
                                padding: EdgeInsets.only(right: 5, bottom: 5),
                                child: Icon(
                                  Icons.videocam,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      )
                    : Center(
                        child: Icon(
                          Icons.error_outline,
                          color: Colors.grey.shade400,
                          size: 40,
                        ),
                      ),
              ),
              if (widget.mediaCount == MediaCount.multiple)
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: AnimatedSwitcher(
                      duration: _duration,
                      child: Container(
                        decoration: BoxDecoration(
                          color: selected!
                              ? Theme.of(context).primaryColor
                              : Colors.white.withOpacity(.5),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(5),
                        child: Icon(
                          Icons.done,
                          size: 15,
                          color: selected! ? Colors.white : Colors.transparent,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    } else {
      convertToMedia(media: widget.media)
          .then((_media) => setState(() => media = _media));
      return LoadingWidget(decoration: widget.decoration!);
    }
  }

  @override
  bool get wantKeepAlive => true;
}

Future<MediaModel> convertToMedia({required AssetEntity media}) async {
  MediaModel convertedMedia = MediaModel();
  convertedMedia.file = await media.file;
  convertedMedia.mediaByte = await media.originBytes;
  convertedMedia.thumbnail =
      await media.thumbnailDataWithSize(ThumbnailSize.square(200));
  convertedMedia.id = media.id;
  convertedMedia.size = media.size;
  convertedMedia.title = media.title;
  convertedMedia.creationTime = media.createDateTime;

  MediaType mediaType = MediaType.all;
  if (media.type == AssetType.video) mediaType = MediaType.video;
  if (media.type == AssetType.image) mediaType = MediaType.image;
  convertedMedia.mediaType = mediaType;

  return convertedMedia;
}
