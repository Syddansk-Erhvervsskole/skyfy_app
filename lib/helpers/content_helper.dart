import 'api_helper.dart';

class ContentHelper extends ApiHelper {
  Future<dynamic> getAllContent() async {
    return await get('Content/all');
    // return await post('Authorization/Login', data);
  }
} 