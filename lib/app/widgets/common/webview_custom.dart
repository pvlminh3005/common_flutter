import 'dart:async';
import 'dart:io';

import 'package:custom_common/app/widgets/common/input_custom.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebviewCustom extends StatefulWidget {
  final TextEditingController? controller;
  final String? url;
  final Function(String?)? onSubmitted;

  const WebviewCustom({
    this.controller,
    this.url,
    this.onSubmitted,
    Key? key,
  }) : super(key: key);

  @override
  State<WebviewCustom> createState() => _WebviewCustomState();
}

class _WebviewCustomState extends State<WebviewCustom> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InputCustom(
          controller: widget.controller,
          margin: const EdgeInsets.all(12.0),
          prefixIcon: Icon(CupertinoIcons.search),
          keyboardType: TextInputType.phone,
          showClear: true,
          hintText: 'Input URL',
          onSubmitted: widget.onSubmitted,
        ),
        Expanded(
          child: Stack(
            children: [
              WebView(
                initialUrl: widget.url,
                javascriptMode: JavascriptMode.unrestricted,
                onPageFinished: (finish) {
                  setState(() {
                    isLoading = false;
                  });
                },
                onWebViewCreated: (WebViewController webViewController) {
                  _controller.complete(webViewController);
                },
              ),
              isLoading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : Stack(),
            ],
          ),
        ),
      ],
    );
  }
}
