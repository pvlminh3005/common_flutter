import 'package:custom_common/app/widgets/common/input_custom.dart';
import 'package:custom_common/app/widgets/common/webview_custom.dart';
import 'package:flutter/material.dart';

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
      appBar: AppBar(
        title: Text('WebviewView'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          InputCustom(
            hintText: 'URL: ',
            margin: const EdgeInsets.all(8.0),
            onSubmitted: (value) {
              url = value!;
              setState(() {});
            },
          ),
          Expanded(
            child: WebviewCustom(url: url),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
