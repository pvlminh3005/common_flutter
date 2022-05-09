import 'package:custom_common/app/widgets/common/input_custom.dart';
import 'package:flutter/material.dart';

import '../../../packages/webview/webview_builder.dart';

class WebviewView extends StatefulWidget {
  @override
  State<WebviewView> createState() => _WebviewViewState();
}

class _WebviewViewState extends State<WebviewView>
    with AutomaticKeepAliveClientMixin {
  String url = 'https://flutter.dev';
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            InputCustom(
              hintText: 'URL: ',
              showClear: true,
              margin: const EdgeInsets.all(8.0),
              onSubmitted: (value) {
                url = value!;
                setState(() {});
              },
            ),
            Expanded(
              child: WebviewCustom(
                url: url,
                showAppBar: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
