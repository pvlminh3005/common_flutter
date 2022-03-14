import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WebviewController extends GetxController {
  final inputController = TextEditingController();

  var _url = Rxn<String>('https://www.google.com');
  String? get url => _url.value;
  set url(String? url) => _url(url);

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    inputController.dispose();
  }
}
