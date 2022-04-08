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
  final _selected = ValueNotifier<bool>(false);
  bool get selected => _selected.value;

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
    _selected.value = widget.isSelected;
    if (selected) _animationController!.forward();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (media != null) {
      return Padding(
        padding: const EdgeInsets.all(0.5),
        child: ValueListenableBuilder(
          valueListenable: _selected,
          builder: ((context, bool value, child) {
            return ScaleMedia(
              onTap: () async {
                context
                    .to(
                  MediaReviewBuilder(
                    file: media!.file!,
                    isVideo: widget.media.type == AssetType.video,
                    isSelected: _selected.value,
                  ),
                )
                    .then((value) {
                  if (value != null) {
                    handleSelectMedia(value: value);
                  }
                });
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
                                            sigmaX: widget
                                                    .decoration!.blurStrength *
                                                amount,
                                            sigmaY: widget
                                                    .decoration!.blurStrength *
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
                                  opacity: value ? 1 : 0,
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
                                    padding:
                                        EdgeInsets.only(right: 5, bottom: 5),
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
                        child: GestureDetector(
                          onTap: handleSelectMedia,
                          child: AnimatedSwitcher(
                            duration: _duration,
                            child: Container(
                              decoration: BoxDecoration(
                                color: value
                                    ? Theme.of(context).primaryColor
                                    : Colors.white.withOpacity(.5),
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(5),
                              child: Icon(
                                Icons.done,
                                size: 15,
                                color:
                                    value ? Colors.white : Colors.transparent,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
      );
    } else {
      convertToMedia(media: widget.media)
          .then((_media) => setState(() => media = _media));
      return widget.decoration!.loadingWidget ?? const SizedBox();
    }
  }

  void handleSelectMedia({bool? value}) {
    _selected.value = value ?? !_selected.value;
    if (selected)
      _animationController!.forward();
    else
      _animationController!.reverse();
    widget.onSelected(selected, media!);
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

  MediaType mediaType = MediaType.other;
  if (media.type == AssetType.video) mediaType = MediaType.video;
  if (media.type == AssetType.image) mediaType = MediaType.image;
  convertedMedia.mediaType = mediaType;

  return convertedMedia;
}

extension RouterExt on BuildContext {
  Future<dynamic> to(Widget widget) =>
      Navigator.of(this).push(MaterialPageRoute(builder: (_) => widget));
}

void _reviewMedia(BuildContext context, File file, {bool isVideo = false}) {
  context.to(MediaReviewBuilder(file: file, isVideo: isVideo)).then((value) {
    if (value != null) {
      Navigator.pop(context, file);
    }
  });
}
