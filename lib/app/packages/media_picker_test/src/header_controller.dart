import 'package:flutter/material.dart';

import '../gallery_media_picker.dart';

class HeaderController {
  HeaderController();

  ValueChanged<List<MediaModel>>? updateSelection;
  VoidCallback? closeAlbumDrawer;
}
