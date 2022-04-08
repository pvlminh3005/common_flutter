library media_picker;

import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:photo_manager/photo_manager.dart';

export 'package:photo_manager/photo_manager.dart';

part 'provider/media_picker_provider.dart';
part 'media_picker_builder.dart';
part 'widgets/header.dart';
part 'widgets/loading_decoration.dart';
part 'widgets/media_selector.dart';
part 'widgets/selected_button.dart';
part 'widgets/path_entity_list.dart';
part 'widgets/list_thumbnail_builder.dart';
part 'widgets/select_indicator.dart';
part 'widgets/duration_indicator.dart';
part 'widgets/audio_item_viewer.dart';

typedef MultiCallback = void Function(List<AssetEntity>);
typedef SingleCallBack = void Function(AssetEntity);

class MediaPicker {
  MediaPicker._();

  static void picker(
    BuildContext context, {
    RequestType type = RequestType.common,
    bool enableMultiple = false,
    bool enableReview = true,
    int limit = 10,
    MultiCallback? multiCallback,
    SingleCallBack? singleCallback,
    Duration routeDuration = kTabScrollDuration,
  }) async {
    final request = await PhotoManager.requestPermissionExtend();

    if (request.isAuth) {
      final MediaPickerProvider mediaPickerProvider = MediaPickerProvider(
        type: type,
        limit: limit,
        enableMultiple: enableMultiple,
        enableReview: enableReview,
        routeDuration: routeDuration,
      );
      //create provider
      final Widget mediaPicker = ChangeNotifierProvider(
        create: (ctx) => mediaPickerProvider,
        child: const MediaPickerBuilder(),
      );

      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => mediaPicker))
          .then(
        (value) {
          if (value != null) {
          } else {}
        },
      );
    } else {
      PhotoManager.openSetting();
    }
  }
}

extension ContextExt on BuildContext {
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  ThemeData get theme => Theme.of(this);
  Size get size => mediaQuery.size;
  double get width => size.width;
  double get height => size.height;
  int get gridCount => (width / 100) ~/ math.min(1, (width / 100) / 4);
  EdgeInsets get padding => mediaQuery.padding;
}
