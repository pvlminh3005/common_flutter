import 'package:custom_common/app/packages/media_picker/media_picker.dart';
import 'package:get/get.dart';

import '../../../packages/media_picker_test/gallery_media_picker.dart';

class MediaController extends GetxController
    with StateMixin<List<AssetEntity>> {
  List<MediaModel> mediaList = [];

  @override
  void onInit() {
    1.delay(initialize);
    super.onInit();
  }

  void initialize() {
    change([], status: RxStatus.empty());
  }

  void pickGallery(List<AssetEntity> selectList) {
    change([...state!, ...selectList], status: RxStatus.success());
    Get.back();
  }

  Future<void> refreshPage() async {
    await 2.delay(initialize);
  }

  @override
  void onClose() {}
}
