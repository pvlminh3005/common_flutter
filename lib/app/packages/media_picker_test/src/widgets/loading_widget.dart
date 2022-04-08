import 'package:flutter/material.dart';

import '../../gallery_media_picker.dart';

class LoadingWidget extends StatelessWidget {
  LoadingWidget({required this.decoration});

  final PickerDecoration decoration;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: (decoration.loadingWidget != null)
          ? decoration.loadingWidget
          : CircularProgressIndicator(
              color: Theme.of(context).backgroundColor,
            ),
    );
  }
}
