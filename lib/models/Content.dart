import 'package:skyfy_app/helpers/api_helper.dart';


class Content {
  final int id;
  final String name;
  final String? imageUrl;
  final String? artist;
  bool liked;

  Content({
    required this.id,
    required this.name,
    required this.liked,
    this.imageUrl,
    this.artist,
  
  });


  factory Content.fromJson(Map<String, dynamic> json) {
    return Content(
      id: json["id"],
      name: json["name"],
      imageUrl: json["cover_Art"],
      artist: json["artist"],
      liked: json["liked"]
    );
  }


  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "cover_Art": imageUrl,
      "artist": artist,
    };
  }

  String streamUrl(String weather) => "${ApiHelper.baseUrl}/Content/$id/$weather/playlist.m3u8";
}
