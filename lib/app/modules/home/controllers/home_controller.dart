import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  late TextEditingController phoneController;
  late TextEditingController searchController;
  late TextEditingController emailController;

  final formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    phoneController = TextEditingController();
    searchController = TextEditingController();
    emailController = TextEditingController();
    super.onInit();
  }

  void checkEmail() {
    print('alo');
    if (formKey.currentState!.validate()) {}
  }

  @override
  void onClose() {
    phoneController.dispose();
    searchController.dispose();
    emailController.dispose();
  }
}
