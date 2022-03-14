import 'package:custom_common/app/modules/profile/widgets/profile_item.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ProfileView'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: controller.obx(
          (state) {
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: controller.scroll,
                    itemCount: state!.length,
                    itemBuilder: (ctx, index) {
                      return ProfileItem(state[index]);
                    },
                  ),
                ),
                if (controller.status.isLoadingMore)
                  Center(child: CircularProgressIndicator()),
              ],
            );
          },
          onError: (error) => Center(child: Text('Something wrong ...')),
        ),
      ),
    );
  }
}
