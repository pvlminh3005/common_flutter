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
  final Function(int)? onProcess;

  const WebviewCustom({
    this.controller,
    this.url,
    this.onSubmitted,
    this.onProcess,
    Key? key,
  }) : super(key: key);

  @override
  State<WebviewCustom> createState() => _WebviewCustomState();
}

class _WebviewCustomState extends State<WebviewCustom> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  late String? initialURL;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initialURL = widget.url;
    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FutureBuilder<WebViewController>(
          future: _controller.future,
          builder: (BuildContext context,
              AsyncSnapshot<WebViewController> controller) {
            if (controller.hasData) {
              return InputCustom(
                controller: widget.controller,
                margin: const EdgeInsets.all(12.0),
                prefixIcon: Icon(CupertinoIcons.search),
                showClear: true,
                hintText: 'Input URL',
                onSubmitted: (value) {
                  if (value != null) {
                    widget.onSubmitted;
                    String defaultUrl = 'https://www.';
                    controller.data!.loadUrl('${defaultUrl + value}/');
                  }
                },
              );
            }
            return SizedBox.shrink();
          },
        ),
        Expanded(
          child: Stack(
            children: [
              WebView(
                initialUrl: initialURL,
                javascriptMode: JavascriptMode.unrestricted,
                onPageFinished: (finish) {
                  setState(() => isLoading = false);
                },
                onPageStarted: (start) => setState(() => isLoading = true),
                onWebViewCreated: (WebViewController webViewController) {
                  _controller.complete(webViewController);
                },
                onProgress: widget.onProcess,
                onWebResourceError: (WebResourceError error) async {
                  isLoading = false;
                  setState(() {});
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
