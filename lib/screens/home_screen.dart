import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:skyfy_app/helpers/content_helper.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeScreen extends StatefulWidget {
  final Function(String title, String url) onSongSelected;

  const HomeScreen({super.key, required this.onSongSelected});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final storage = const FlutterSecureStorage();
  final contentHelper = ContentHelper();

  List<dynamic> songs = [];

  @override
  void initState() {
    super.initState();
    fetchSongs();
  }

  void fetchSongs() async {
    try {
      final data = await contentHelper.getAllContent();
      setState(() {
        songs = data; 
      });
    } catch (e) {
      print("Error fetching content: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body: Column( children: [ 
          GestureDetector(
            onTap: () {
              print("Rain banner clicked!");
            },
            child: Padding(
              padding: const EdgeInsets.all(6),

              child: Container(
              width: double.infinity,
              height: 150,
              padding: const EdgeInsets.all(15),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color.fromARGB(255, 0, 0, 0),
                    Color.fromRGBO(79, 152, 255, 0.23),
                  ],
                ),
              ),
              child: SvgPicture.asset('lib/assets/RainBanner.svg', fit: BoxFit.contain),
            ),
          ),),

          Expanded( child: songs.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: songs.length,
              itemBuilder: (context, index) {
                final song = songs[index];
                final id = song["id"];
                final name = song["name"];

                final streamUrl = "${contentHelper.baseUrl}/Content/$id/playlist.m3u8";

                return Card(
                  color: const Color.fromARGB(113, 33, 33, 33),
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  child: ListTile(
                    title: Text(
                      name,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    trailing: const Icon(Icons.play_arrow, color: Colors.white),
                    onTap: () => widget.onSongSelected(name, streamUrl),
                  ),
                );
              },
            ),)
    ]));
  }
}
