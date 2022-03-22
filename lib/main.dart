import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'app/packages/camera/camera.dart';
import 'app/routes/app_pages.dart';

void main() async {
  await initializeApp();
  runApp(
    GetMaterialApp(
      title: "Application",
      debugShowCheckedModeBanner: false,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      theme: ThemeData(
        primaryColor: Colors.black,
        appBarTheme: AppBarTheme(backgroundColor: Colors.black),
      ),
    ),
  );
}

Future<void> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CameraCommon.initialCamera();
}
