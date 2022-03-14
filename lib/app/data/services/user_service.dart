import 'package:custom_common/app/data/models/user_model.dart';
import 'package:custom_common/app/utils/rest_api.dart';

class UserService {
  static Future<List<UserModel>?> fetchUsers(Map<String, dynamic> query) async {
    try {
      var data = await RestApiClient.restApiClient(
        url: 'https://agrichapp.herokuapp.com/members',
        queryParameters: query,
      );
      return (data as List).map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      return null;
    }
  }
}
