library media_picker;

import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:developer' as developer;
import 'dart:typed_data';
import 'dart:ui';

import 'package:custom_common/app/utilities/formatters/currency_input_formatter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:extended_image/extended_image.dart';
import 'package:photo_manager/photo_manager.dart';

export 'package:photo_manager/photo_manager.dart';

part 'provider/media_picker_provider.dart';
part 'provider/asset_entity_image_provider.dart';
part 'builder/image_review_builder.dart';
part 'builder/audio_review_builder.dart';
part 'builder/media_builder_preview.dart';
part 'builder/video_page_builder.dart';
part 'builder/video_process.dart';
part 'widgets/header.dart';
part 'widgets/loading_decoration.dart';
part 'widgets/media_selector.dart';
part 'widgets/selected_button.dart';
part 'widgets/path_entity_list.dart';
part 'widgets/select_indicator.dart';
part 'widgets/duration_indicator.dart';
part 'widgets/audio_item_viewer.dart';
part 'widgets/gallery_grid_builder.dart';
part 'widgets/confirm_button.dart';
part 'media_picker_builder.dart';

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
    int gridCount = 3,
    MultiCallback? multiCallback,
    SingleCallBack? singleCallback,
    VoidCallback? onCancel,
    Duration routeDuration = kTabScrollDuration,
  }) async {
    final request = await PhotoManager.requestPermissionExtend();

    if (request.isAuth) {
      final MediaPickerProvider mediaPickerProvider = MediaPickerProvider(
        type: type,
        limit: limit,
        gridCount: gridCount,
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
          .then((value) {
        if (value != null) {
          if (multiCallback != null && enableMultiple) {
            multiCallback(value as List<AssetEntity>);
          } else if (singleCallback != null && !enableMultiple) {
            singleCallback.call(value.first as AssetEntity);
          }
        } else {
          onCancel?.call();
        }
      });
    } else {
      PhotoManager.openSetting();
    }
  }

  static String formatDuration(Duration duration) {
    return <int>[duration.inMinutes, duration.inSeconds]
        .map((int e) => e.remainder(60).toString().padLeft(2, "0"))
        .join(':');
  }

  static void log(dynamic message, {String tag = ''}) {
    developer.log(message.toString(), name: tag);
  }
}

extension ContextExt on BuildContext {
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  ThemeData get theme => Theme.of(this);
  Size get size => mediaQuery.size;
  double get width => size.width;
  double get height => size.height;
  int gridCount({int gridCount = 4}) =>
      (width / 200) ~/ math.min(1, (width / 200) / gridCount);

  EdgeInsets get padding => mediaQuery.padding;
}
