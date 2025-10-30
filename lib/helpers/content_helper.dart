import 'api_helper.dart';

class ContentHelper extends ApiHelper {
  Future<dynamic> getContent(int id) async {
    return await get('Content/$id/stream');
    // return await post('Authorization/Login', data);
  }
} 