import 'dart:typed_data';
 import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'api_helper.dart';

class ContentHelper extends ApiHelper {

Future<dynamic> getAllContent() async {
  return await get('Content/all');

}

Future<dynamic> getAllWeatherContent(int code) async {
    return await get('Content/weather/$code/10');

  }


Future<dynamic> searchContent(String text) async {
  var res = await get('Content/search/$text');
    return res;

  }

Future<dynamic> getPlaylistSongs(int id) async {
  var res = await get('Playlist/Content/$id');
    return res;

  }

Future<dynamic> getPlaylists() async {
  var res = await get('Playlist/all');
    return res;

  }
Future<dynamic> CreatePlaylist(String name) async {
  var res = await post('Playlist/Create/$name');
    return res;

  }

Future<dynamic> DeletePlaylist(int id) async {
  var res = await delete('Playlist/$id');
    return res;

  }

Future<dynamic> PlaylistAdd(int songid, int playlistID) async {
  print(songid);
    print(playlistID);
  var res = await post('Playlist/$playlistID/add/content/$songid');
    return res;

  }

Future<dynamic> PlaylistRemove(int songid, int playlistID) async {

  var res = await delete('Playlist/$playlistID/remove/content/$songid');
    return res;

  }

Future<dynamic> getLikedSongs() async {
  return get("Like");
}

Future<dynamic> likeSong(int id) async {
  return post("Like/$id", {});
}

Future<dynamic> unlikeSong(int id) async {
  return delete("Like/$id");
}

Future<void> uploadAllContent(String name, Uint8List song, Uint8List cover) async {
  final url = Uri.parse("${ApiHelper.baseUrl}/Content/upload/all");
  var req = http.MultipartRequest("POST", url);

  req.fields["name"] = name;

  req.files.add(http.MultipartFile.fromBytes("song", song, filename: "$name.mp3"));
  req.files.add(http.MultipartFile.fromBytes("cover", cover, filename: "cover.jpg"));

  final token = await storage.read(key: 'auth_token');
  req.headers["Authorization"] = "Bearer $token";

  var res = await req.send();
  if (res.statusCode != 200) {
    throw Exception("Upload failed");
  }
}

Future<dynamic> uploadContent(
  String name,
  Uint8List? songBytes, {
  Uint8List? coverBytes, // optional cover image
}) async {

  //Create content entry first
  final data = {'name': name};
  var result = await post('Content', data); 
  if (result == null || songBytes == null) return;

  String contentId = result['id'].toString(); 

  //Upload audio
  final uploadSongUrl = Uri.parse("${ApiHelper.baseUrl}/Content/$contentId/upload"); 
  var songReq = http.MultipartRequest("PUT", uploadSongUrl);

  songReq.files.add(
    http.MultipartFile.fromBytes(
      'file', 
      songBytes,
      filename: "$name.mp3",
      contentType: MediaType("audio", "mpeg"),
    ),
  );

  final token = await storage.read(key: 'token');
  if (token != null) {
    songReq.headers['Authorization'] = "Bearer $token";
  }

  var songStream = await songReq.send();
  var songRes = await http.Response.fromStream(songStream);

  if (songRes.statusCode != 200) {
    throw Exception("Song upload failed: ${songRes.statusCode} - ${songRes.body}");
  }

//Upload cover image
  if (coverBytes != null) {
    final uploadCoverUrl = Uri.parse("${ApiHelper.baseUrl}/Content/$contentId/upload/cover"); 
    var coverReq = http.MultipartRequest("POST", uploadCoverUrl);

    coverReq.files.add(
      http.MultipartFile.fromBytes(
        'file',
        coverBytes,
        filename: "cover.jpg",
        contentType: MediaType("image", "jpeg"),
      ),
    );

    if (token != null) {
      coverReq.headers['Authorization'] = "Bearer $token";
    }

    var coverStream = await coverReq.send();
    var coverRes = await http.Response.fromStream(coverStream);

    if (coverRes.statusCode != 200) {
      throw Exception("Cover upload failed: ${coverRes.statusCode} - ${coverRes.body}");
    }
  }

  return songRes.body;
}


} 