import 'api_helper.dart';

class LoginHelper extends ApiHelper {
  Future<dynamic> login(String username, String password) async {
    final data = {'username': username, 'password': password};
    return await post('Authorization/Login', data);
  }

  Future<dynamic> refresh() async {
    return await post('Authorization/Refresh');
  }
} 