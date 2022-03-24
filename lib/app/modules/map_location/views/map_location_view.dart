import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/map_location_controller.dart';

class MapLocationView extends GetView<MapLocationController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MapLocationView'),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          'MapLocationView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
