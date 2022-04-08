library media_picker;

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';

part 'provider/media_picker_provider.dart';
part 'media_picker_builder.dart';
part 'widgets/header.dart';
part 'widgets/loading_decoration.dart';
part 'widgets/media_selector.dart';
part 'widgets/selected_button.dart';

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
    required Duration routeDuration,
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
    } else {
      PhotoManager.openSetting();
    }
  }
}
