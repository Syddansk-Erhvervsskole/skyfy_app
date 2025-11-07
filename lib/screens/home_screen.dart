import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:skyfy_app/helpers/content_helper.dart';
import 'package:skyfy_app/helpers/weather_helper.dart';
import 'package:skyfy_app/models/Content.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:skyfy_app/widgets/song_cover.dart';

class HomeScreen extends StatefulWidget {
  final Function(Content song) onSongSelected;
  final Function(List<Content> songs) onPlayAll;
  final ValueNotifier<Content?> songNotifier; 

  const HomeScreen({
    super.key,
    required this.onSongSelected,
    required this.onPlayAll,
    required this.songNotifier,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final storage = const FlutterSecureStorage();
  final contentHelper = ContentHelper();

  bool isLoading = true;
  List<Content> songsBasedOnWeather = [];
  String weatherName = "";

  @override
  void initState() {
    super.initState();
    fetchSongsWeather();
  }

  void fetchSongsWeather() async {
    try {
      final wc = await WeatherHelper.getCurrentWeatherCode();
      final data = await contentHelper.getAllWeatherContent(wc);
      final wn = await WeatherHelper.getWeatherDescription();

      songsBasedOnWeather =
          (data as List).map((json) => Content.fromJson(json)).toList();
      print(songsBasedOnWeather.map((e) => e.toJson()));
      setState(() {
        weatherName = wn;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("HomeScreen error: $e");
    }
  }

  Widget songTile(Content song, Content? current) {
    bool playing = current?.id == song.id;

    return GestureDetector(
      onTap: () => widget.onSongSelected(song),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: playing
            ? BoxDecoration(
                color: const Color.fromARGB(50, 79, 152, 255),

              )
            : null,
        child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Row(
          children: [
           ClipRRect(
  borderRadius: BorderRadius.circular(6),
  child: SizedBox(
    width: 50,
    height: 50,
    child: SongCover(
      imageUrl: song.imageUrl,
      size: 50,
    ),
  ),
),


            const SizedBox(width: 10),

            Expanded(
              child: Text(
                song.name,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: playing ? Colors.blueAccent : Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            IconButton(
              icon: playing
                  ? const Icon(Icons.graphic_eq,
                      color: Colors.blueAccent, size: 28)
                  : const Icon(Icons.play_arrow_rounded,
                      color: Colors.white, size: 32),
              onPressed: () => widget.onSongSelected(song),
            )
          ],
        ),
      ),)
    );
  }

  Widget sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          !isLoading ? IconButton(
            icon: const Icon(Icons.play_arrow_rounded,
                color: Colors.white, size: 32),
            onPressed: () => widget.onPlayAll(songsBasedOnWeather),
          ) : const SizedBox.shrink(),
        ],
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
                    child: SvgPicture.asset('lib/assets/RainBanner.svg'),
                  ),
                ),
              ),

              sectionTitle(weatherName),

              if (isLoading)
                const Center(
                    child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(color: Colors.white),
                ))
              else if (songsBasedOnWeather.isEmpty)
                const Center(
                    child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text("No songs for current weather",
                      style: TextStyle(color: Colors.white54)),
                ))
              else
                ValueListenableBuilder<Content?>(
                  valueListenable: widget.songNotifier,
                  builder: (_, current, __) {
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: songsBasedOnWeather.length,
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, i) =>
                          songTile(songsBasedOnWeather[i], current),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
