import 'api_helper.dart';
import 'token_helper.dart';

class UserHelper extends ApiHelper {
  Future<dynamic> register(String email, String username, String password) async {
    final data = {'email': email, 'username': username, 'password': password};
    return await post('User', data);
  }

  Future<dynamic> deleteUser() async {
    var id = await TokenHelper.getUserId();
    // print(id);
    return await delete('User/$id');
  }
} 