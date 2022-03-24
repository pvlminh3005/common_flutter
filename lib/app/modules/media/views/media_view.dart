import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../packages/media_picker/gallery_media_picker.dart';
import '../controllers/media_controller.dart';

class MediaView extends GetView<MediaController> {
  List<MediaModel> get mediaList => controller.mediaList;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MediaView'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshPage,
        child: previewList(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Get.theme.primaryColor,
        onPressed: () {
          openImagePicker(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget previewList() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Align(
        alignment: Alignment.topCenter,
        child: controller.obx(
          (state) => SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Wrap(
              spacing: 5.0,
              runSpacing: 5.0,
              children: List.generate(
                state!.length,
                (index) => Image.memory(
                  state[index].thumbnail!,
                  fit: BoxFit.cover,
                  width: 80.0,
                  height: 80.0,
                ),
              ),
            ),
          ),
          onEmpty: Center(child: Text('Empty')),
        ),
      ),
    );
  }

  void openImagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return MediaPicker(
          mediaList: mediaList,
          onPick: controller.pickGallery,
          onCancel: () => Navigator.pop(context),
          mediaCount: MediaCount.multiple,
          mediaType: MediaType.image,
          // decoration: PickerDecoration(
          //   actionBarPosition: ActionBarPosition.top,
          //   blurStrength: 2,
          //   completeText: 'Tiếp tục',
          // ),
        );
      },
    );
  }
}
