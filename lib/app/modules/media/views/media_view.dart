import 'package:flutter/material.dart';

import 'package:get/get.dart';

// import '../../../packages/media_picker_test/gallery_media_picker.dart';
import '../controllers/media_controller.dart';
import '/app/packages/media_picker/media_picker.dart';

class MediaView extends GetView<MediaController> {
  // List<MediaModel> get mediaList => controller.mediaList;

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
          // openImagePicker(context);
          picker(context, RequestType.common);
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
          (state) => GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
            ),
            itemCount: state!.length,
            itemBuilder: (_, int index) {
              return AssetEntityImage(
                state[index],
                height: 80.0,
                width: 80.0,
                fit: BoxFit.cover,
              );
            },
          ),
          onEmpty: Center(child: Text('Empty')),
        ),
      ),
    );
  }

  // void openImagePicker(BuildContext context) {
  //   return MediaPicker.picker(
  //     context,
  //     mediaList: mediaList,
  //     onPick: controller.pickGallery,
  //     onCancel: () => Navigator.pop(context),
  //     mediaCount: MediaCount.multiple,
  //     mediaType: MediaType.other,
  //     // decoration: PickerDecoration(
  //     //   actionBarPosition: ActionBarPosition.top,
  //     //   blurStrength: 2,
  //     //   completeText: 'Ti???p t???c',
  //     // ),
  //   );
  // }

  void picker(BuildContext context, RequestType type) {
    MediaPicker.picker(
      context,
      type: type,
      enableMultiple: true,
      enableReview: true,
      gridCount: 3,
      multiCallback: (List<AssetEntity> assets) {
        controller.pickGallery(assets);
      },
      singleCallback: (AssetEntity asset) {},
    );
  }
}
