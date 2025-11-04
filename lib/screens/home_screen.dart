import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:skyfy_app/helpers/content_helper.dart';
import 'package:skyfy_app/models/Content.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeScreen extends StatefulWidget {
  final Function(Content song) onSongSelected;

  const HomeScreen({super.key, required this.onSongSelected});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final storage = const FlutterSecureStorage();
  final contentHelper = ContentHelper();
  List<Content> songs = [];
  List<Content> songsBasedOnWeather = [];

  @override
  void initState() {
    super.initState();
    fetchSongsWeather();
    // fetchSongs();
  }

  void fetchSongsWeather() async {
    try {
      final data = await contentHelper.getAllWeatherContent(3);
      setState(() {
        songsBasedOnWeather = (data as List)
            .map((json) => Content.fromJson(json))
            .toList();
      });
    } catch (e) {
      debugPrint("Error fetching weather songs: $e");
    }
  }

  // void fetchSongs() async {
  //   try {
  //     final data = await contentHelper.getAllContent();
  //     setState(() {
  //       songs = (data as List).map((json) => Content.fromJson(json)).toList();
  //     });
  //   } catch (e) {
  //     debugPrint("Error fetching content: $e");
  //   }
  // }

Widget songTile(Content song) {
  return GestureDetector(
    onTap: () => widget.onSongSelected(song),
    child: Row(
      children: [
        // Cover art
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
      
          child: Container(
            width: 50,
            height: 50,
            child: AspectRatio(
              aspectRatio: 1,
              child: (song.imageUrl == null || song.imageUrl!.isEmpty)
                  ? Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF4F98FF),
                            Color(0xFF1E3A8A),
                          ],
                        ),
                      ),
                      child: const Icon(Icons.music_note,
                          color: Colors.white, size: 35),
                    )
                  : Image.network(
                      song.imageUrl!,
                      fit: BoxFit.cover,
                    ),
            ),
          ),
        ),

        const SizedBox(width: 12),


        Expanded(
          child: Text(
            song.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        IconButton(
          icon: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 32),
          onPressed: () => widget.onSongSelected(song),
        ),
      ],
    ),
  );
}


  Widget sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Weather Banner
              Padding(
                padding: const EdgeInsets.all(14),
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 10, 10, 10),
                        Color.fromRGBO(79, 152, 255, 0.25),
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child:
                        SvgPicture.asset('lib/assets/RainBanner.svg'),
                  ),
                ),
              ),

              sectionTitle("Based on your weather"),

              songsBasedOnWeather.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: songsBasedOnWeather.length,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, i) =>
                          songTile(songsBasedOnWeather[i]),
                    ),

              // const SizedBox(height: 20),

              // sectionTitle("Recommended for you"),

              // songs.isEmpty
              //     ? const Center(
              //         child: Padding(
              //           padding: EdgeInsets.all(20),
              //           child: CircularProgressIndicator(color: Colors.white),
              //         ),
              //       )
              //     : ListView.separated(
              //         shrinkWrap: true,
              //         physics: const NeverScrollableScrollPhysics(),
              //         itemCount: songs.length,
              //         padding: const EdgeInsets.symmetric(horizontal: 14),
              //         separatorBuilder: (_, __) => const SizedBox(height: 14),
              //         itemBuilder: (context, i) => songTile(songs[i]),
              //       ),
            ],
          ),
        ),
      ),
    );
  }
}
