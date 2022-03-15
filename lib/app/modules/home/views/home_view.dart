import 'package:custom_common/app/widgets/common/input_custom.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../utilities/utilities.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: WidgetsBinding.instance?.focusManager.primaryFocus?.unfocus,
      child: Scaffold(
        appBar: AppBar(
          title: Text('HomeView'),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InputCustom(
                  controller: controller.phoneController,
                  prefixIcon: Icon(Icons.phone),
                  keyboardType: TextInputType.phone,
                  hintText: '0000 000 000',
                  inputFormatters: [
                    MaskTextInputFormatter(mask: '#### ### ###'),
                  ],
                ),
                InputCustom(
                  controller: controller.searchController,
                  prefixIcon: Icon(Icons.search),
                  showClear: true,
                  hintText: 'Search',
                ),
                InputCustom(
                  prefixIcon: Icon(CupertinoIcons.viewfinder),
                  suffixIcon: IconButton(
                    icon: Icon(CupertinoIcons.question_circle_fill,
                        color: Colors.yellow.shade700),
                    onPressed: () {},
                  ),
                  hintText: 'CCV / CVC',
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    MaskTextInputFormatter(mask: '### / ###'),
                  ],
                ),
                InputCustom(
                  prefixIcon: Icon(Icons.calendar_month_outlined),
                  hintText: 'dd / mm / yyyy',
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    MaskTextInputFormatter(mask: '## / ## / ####'),
                  ],
                ),
                Form(
                  key: controller.formKey,
                  child: InputCustom(
                    controller: controller.emailController,
                    prefixIcon: Icon(Icons.alternate_email),
                    hintText: 'Email',
                    validator: Validator.validatorEmail,
                    onChanged: (value) => controller.checkEmail(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
