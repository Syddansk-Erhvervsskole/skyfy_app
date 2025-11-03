import 'dart:typed_data';
 import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'api_helper.dart';

class ContentHelper extends ApiHelper {

  Future<dynamic> getAllContent() async {
    return await get('Content/all');
    // return await post('Authorization/Login', data);
  }



Future<dynamic> uploadContent(String name, Uint8List? songBytes) async {

  final data = {'name': name};
  var result = await post('Content', data); 

  if (result == null || songBytes == null) return;

  String contentId = result['id'].toString(); 
  final url = Uri.parse("${ApiHelper.baseUrl}/Content/$contentId/upload"); 


  var request = http.MultipartRequest("PUT", url);

  request.files.add(
    http.MultipartFile.fromBytes(
      'file', 
      songBytes,
      filename: "$name.mp3",
      contentType: MediaType("audio", "mpeg"),
    ),
  );


  final token = await storage.read(key: 'token');
  if (token != null) {
    request.headers['Authorization'] = "Bearer $token";
  }


  var streamedResponse = await request.send();
  var response = await http.Response.fromStream(streamedResponse);

  if (response.statusCode != 200) {
    throw Exception("Upload failed: ${response.statusCode} - ${response.body}");
  }

  return response.body;
}

} 