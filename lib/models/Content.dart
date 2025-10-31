import 'package:skyfy_app/helpers/api_helper.dart';


class Content {
  final int id;
  final String name;
  final String? imageUrl;
  final String? artist;

  Content({
    required this.id,
    required this.name,
    this.imageUrl,
    this.artist,
  });


  factory Content.fromJson(Map<String, dynamic> json) {
    return Content(
      id: json["id"],
      name: json["name"],
      imageUrl: json["imageUrl"],
      artist: json["artist"],
    );
  }


  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "imageUrl": imageUrl,
      "artist": artist,
    };
  }

  String get streamUrl => "${ApiHelper.baseUrl}/Content/$id/playlist.m3u8";
}
