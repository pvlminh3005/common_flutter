part of media_picker;

@immutable
class AssetEntityImageProvider extends ImageProvider<AssetEntityImageProvider> {
  const AssetEntityImageProvider(
    this.entity, {
    this.isOriginal = true,
    this.thumbnailSize = const ThumbnailSize.square(80),
    this.thumbnailFormat = ThumbnailFormat.jpeg,
  }) : assert(
          isOriginal || thumbnailSize != null,
          "thumbSize must not be null when it's not original",
        );

  final AssetEntity entity;

  final bool isOriginal;

  final ThumbnailSize? thumbnailSize;

  final ThumbnailFormat thumbnailFormat;

  ImageFileType get imageFileType => _getType();

  @override
  ImageStreamCompleter load(
    AssetEntityImageProvider key,
    DecoderCallback decode,
  ) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: 1.0,
      informationCollector: () {
        return <DiagnosticsNode>[
          DiagnosticsProperty<ImageProvider>('Image provider', this),
          DiagnosticsProperty<AssetEntityImageProvider>('Image key', key),
        ];
      },
    );
  }

  @override
  Future<AssetEntityImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<AssetEntityImageProvider>(this);
  }

  Future<Codec> _loadAsync(
    AssetEntityImageProvider key,
    DecoderCallback decode,
  ) async {
    try {
      assert(key == this);
      if (key.entity.type == AssetType.audio ||
          key.entity.type == AssetType.other) {
        throw UnsupportedError(
          'Image data for the ${key.entity.type} is not supported.',
        );
      }

      // Define the image type.
      final ImageFileType _type;
      if (key.imageFileType == ImageFileType.other) {
        // Assume the title is invalid here, try again with the async getter.
        _type = _getType(await key.entity.titleAsync);
      } else {
        _type = key.imageFileType;
      }

      Uint8List? data;
      if (isOriginal) {
        if (key.entity.type == AssetType.video) {
          data = await key.entity.thumbnailDataWithOption(
            _thumbOption(thumbnailSize!),
          );
        } else if (_type == ImageFileType.heic) {
          data = await (await key.entity.file)?.readAsBytes();
        } else {
          data = await key.entity.originBytes;
        }
      } else {
        data = await key.entity.thumbnailDataWithOption(
          _thumbOption(thumbnailSize!),
        );
      }
      if (data == null) {
        throw StateError('The data of the entity is null: $entity');
      }
      return decode(data);
    } catch (e) {
      Future<void>.microtask(() {
        PaintingBinding.instance?.imageCache?.evict(key);
      });
      rethrow;
    }
  }

  ThumbnailOption _thumbOption(ThumbnailSize size) {
    if (Platform.isIOS || Platform.isMacOS) {
      return ThumbnailOption.ios(size: size, format: thumbnailFormat);
    }
    return ThumbnailOption(size: size, format: thumbnailFormat);
  }

  ImageFileType _getType([String? filename]) {
    ImageFileType? type;
    final String? extension = filename?.split('.').last ??
        entity.mimeType?.split('/').last ??
        entity.title?.split('.').last;
    if (extension != null) {
      switch (extension.toLowerCase()) {
        case 'jpg':
        case 'jpeg':
          type = ImageFileType.jpg;
          break;
        case 'png':
          type = ImageFileType.png;
          break;
        case 'gif':
          type = ImageFileType.gif;
          break;
        case 'tiff':
          type = ImageFileType.tiff;
          break;
        case 'heic':
          type = ImageFileType.heic;
          break;
        default:
          type = ImageFileType.other;
          break;
      }
    }
    return type ?? ImageFileType.other;
  }

  @override
  bool operator ==(Object other) {
    if (other is! AssetEntityImageProvider) {
      return false;
    }
    if (identical(this, other)) {
      return true;
    }
    return entity == other.entity &&
        thumbnailSize == other.thumbnailSize &&
        thumbnailFormat == other.thumbnailFormat &&
        isOriginal == other.isOriginal;
  }

  @override
  int get hashCode => hashValues(
        entity,
        isOriginal,
        thumbnailSize,
        thumbnailFormat,
      );
}

class AssetEntityImage extends Image {
  AssetEntityImage(
    this.entity, {
    this.isOriginal = true,
    this.thumbnailSize = const ThumbnailSize.square(80),
    this.thumbnailFormat = ThumbnailFormat.jpeg,
    Key? key,
    ImageFrameBuilder? frameBuilder,
    ImageLoadingBuilder? loadingBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = false,
    bool isAntiAlias = false,
    FilterQuality filterQuality = FilterQuality.low,
  }) : super(
          key: key,
          image: AssetEntityImageProvider(
            entity,
            isOriginal: isOriginal,
            thumbnailSize: thumbnailSize,
            thumbnailFormat: thumbnailFormat,
          ),
          frameBuilder: frameBuilder,
          loadingBuilder: loadingBuilder,
          errorBuilder: errorBuilder,
          semanticLabel: semanticLabel,
          excludeFromSemantics: excludeFromSemantics,
          width: width,
          height: height,
          color: color,
          opacity: opacity,
          colorBlendMode: colorBlendMode,
          fit: fit,
          alignment: alignment,
          repeat: repeat,
          centerSlice: centerSlice,
          matchTextDirection: matchTextDirection,
          gaplessPlayback: gaplessPlayback,
          isAntiAlias: isAntiAlias,
          filterQuality: filterQuality,
        );

  final AssetEntity entity;
  final bool isOriginal;
  final ThumbnailSize? thumbnailSize;
  final ThumbnailFormat thumbnailFormat;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<AssetEntity>('entity', entity));
    properties.add(DiagnosticsProperty<bool>('isOriginal', isOriginal));
    properties.add(
      DiagnosticsProperty<ThumbnailSize>('thumbnailSize', thumbnailSize),
    );
    properties.add(
      DiagnosticsProperty<ThumbnailFormat>('thumbnailFormat', thumbnailFormat),
    );
  }
}
