import 'package:custom_common/app/data/models/user_model.dart';

import '../../utilities/utilities.dart';

class UserService {
  static Future<List<UserModel>?> fetchUsers(Map<String, dynamic> query) async {
    try {
      var data = await ApiClient.restApiClient(
        url: 'https://agrichapp.herokuapp.com/members',
        queryParameters: query,
      );
      return (data as List).map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      return null;
    }
  }
}
