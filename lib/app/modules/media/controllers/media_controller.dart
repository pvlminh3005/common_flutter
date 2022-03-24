import 'package:get/get.dart';

import '../../../packages/media_picker/gallery_media_picker.dart';

class MediaController extends GetxController with StateMixin<List<MediaModel>> {
  List<MediaModel> mediaList = [];

  @override
  void onInit() {
    1.delay(initialize);
    super.onInit();
  }

  void initialize() {
    change([], status: RxStatus.empty());
  }

  void pickGallery(List<MediaModel> selectList) {
    change([...state!, ...selectList], status: RxStatus.success());
    Get.back();
  }

  Future<void> refreshPage() async {
    await 2.delay(initialize);
  }

  @override
  void onClose() {}
}
