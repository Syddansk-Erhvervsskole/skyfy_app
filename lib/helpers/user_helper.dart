import 'api_helper.dart';

class UserHelper extends ApiHelper {
  Future<dynamic> register(String email, String username, String password) async {
    final data = {'email': email, 'username': username, 'password': password};
    return await post('User', data);
  }
} 