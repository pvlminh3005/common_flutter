import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/media_controller.dart';

class MediaView extends GetView<MediaController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MediaView'),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          'MediaView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.add),
      ),
    );
  }
}
