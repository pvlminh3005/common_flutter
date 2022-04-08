import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    GetMaterialApp(
      title: "Application",
      debugShowCheckedModeBanner: false,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      theme: ThemeData(
        primaryColor: Colors.black,
        backgroundColor: Colors.black,
        // colorScheme: const ColorScheme.dark(
        //   primary: Colors.green,
        //   secondary: Colors.greenAccent,
        //   surface: Color(0xff121212),
        //   background: Colors.black,
        //   error: Colors.red,
        // ),
        appBarTheme: AppBarTheme(backgroundColor: Colors.black),
      ),
    ),
  );
}
