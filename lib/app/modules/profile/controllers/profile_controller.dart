import 'package:custom_common/app/data/services/user_service.dart';
import 'package:get/get.dart';

import '../../../data/models/user_model.dart';

class ProfileController extends GetxController
    with StateMixin<List<UserModel>?>, ScrollMixin {
  int limit = 10;
  int pages = 1;
  late Map<String, dynamic> query;
  @override
  void onInit() {
    initialize();

    super.onInit();
  }

  void initialize() async {
    query = {'_limit': limit, '_pages': pages};
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    var data = await UserService.fetchUsers(query);
    if (data == null) {
      change(state, status: RxStatus.error());
    } else {
      change(data, status: RxStatus.success());
    }
  }

  Future<void> loadingMore() async {
    change(state, status: RxStatus.loadingMore());
    query['_pages']++;
    var data = await UserService.fetchUsers(query);
    change([...state!, ...data ?? []], status: RxStatus.success());
  }

  @override
  void onClose() {}

  @override
  Future<void> onEndScroll() async {
    await loadingMore();
  }

  @override
  Future<void> onTopScroll() {
    throw UnimplementedError();
  }
}
