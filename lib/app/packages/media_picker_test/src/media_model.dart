part of gallery_media_picker;

class MediaModel {
  File? file;

  String? id;

  Uint8List? thumbnail;

  Uint8List? mediaByte;

  Size? size;

  DateTime? creationTime;

  String? title;

  MediaType? mediaType;

  MediaModel({
    this.id,
    this.file,
    this.thumbnail,
    this.mediaByte,
    this.size,
    this.creationTime,
    this.title,
    this.mediaType,
  });
}
