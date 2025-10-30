import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:skyfy_app/helpers/content_helper.dart';

class HomeScreen extends StatelessWidget {
  final Function(String title, String url) onSongSelected;
  HomeScreen({super.key, required this.onSongSelected});

  final storage = const FlutterSecureStorage();
  final contentHelper = ContentHelper();

  final List<Map<String, String>> songs = const [
    {'title': 'Morning Sun'},
    {'title': 'Rainy Nights'},
    {'title': 'Ocean Breeze'},
    {'title': 'City Lights'},
    {'title': 'Mountain Echo'},
    {'title': 'Desert Mirage'},
    {'title': 'Autumn Dreams'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: ListView.builder(
        itemCount: songs.length,
        itemBuilder: (context, index) {
          final song = songs[index];
          final url = "${contentHelper.baseUrl}/Content/6/playlist.m3u8";

          return Card(
            color: const Color.fromARGB(113, 33, 33, 33),
            margin: const EdgeInsets.symmetric(vertical: 2),
            child: ListTile(
              title: Text(
                song['title']!,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              trailing: const Icon(Icons.play_arrow, color: Colors.white),
              onTap: () => onSongSelected(song['title']!, url),
            ),
          );
        },
      ),
    );
  }
}
