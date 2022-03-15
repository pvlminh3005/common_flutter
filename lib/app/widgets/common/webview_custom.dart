import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebviewCustom extends StatefulWidget {
  final String? url, title;

  const WebviewCustom({
    this.url,
    this.title,
    Key? key,
  }) : super(key: key);

  @override
  State<WebviewCustom> createState() => _WebviewCustomState();
}

class _WebviewCustomState extends State<WebviewCustom> {
  late WebViewController _controller;
  late String? initialURL;

  final isLoading = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    updateUrl();
    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
    }
  }

  @override
  void didUpdateWidget(covariant WebviewCustom oldWidget) {
    if (oldWidget.url != widget.url) {
      updateUrl();
    }
    super.didUpdateWidget(oldWidget);
  }

  void updateUrl() async {
    if (widget.url!.contains('https://')) {
      initialURL = widget.url;
    } else {
      initialURL = 'https://${widget.url}';
    }
    _controller.loadUrl(initialURL!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          WebView(
            initialUrl: initialURL,
            onPageStarted: (start) => isLoading.value = true,
            onPageFinished: (finished) => isLoading.value = false,
            onWebViewCreated: (WebViewController webViewController) {
              _controller = webViewController;
            },
          ),
          ValueListenableBuilder(
              valueListenable: isLoading,
              builder: (ctx, bool status, child) {
                return isLoading.value
                    ? Center(child: CircularProgressIndicator())
                    : const SizedBox();
              }),
        ],
      ),
    );
  }
}
