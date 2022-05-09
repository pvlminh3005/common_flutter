library webview;

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebviewCustom extends StatefulWidget {
  final String? url;
  final bool showAppBar;

  const WebviewCustom({
    this.url,
    this.showAppBar = false,
    Key? key,
  }) : super(key: key);

  @override
  State<WebviewCustom> createState() => _WebviewCustomState();
}

class _WebviewCustomState extends State<WebviewCustom> {
  final _controller = Completer<WebViewController>();
  String get initialUrl {
    if (!widget.url!.contains('https://')) {
      return 'https://${widget.url}';
    }
    return widget.url!;
  }

  final isLoading = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
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

  void updateUrl() async => (await _controller.future).loadUrl(initialUrl);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: Text(initialUrl),
              centerTitle: true,
            )
          : null,
      body: Stack(
        children: [
          WebView(
            initialUrl: initialUrl,
            onPageStarted: (start) => isLoading.value = true,
            onPageFinished: (finished) => isLoading.value = false,
            onWebViewCreated: (WebViewController webViewController) {
              _controller.complete(webViewController);
            },
          ),
          ValueListenableBuilder(
            valueListenable: isLoading,
            builder: (ctx, bool status, child) {
              return isLoading.value
                  ? Center(child: CircularProgressIndicator())
                  : const SizedBox();
            },
          ),
        ],
      ),
    );
  }
}
