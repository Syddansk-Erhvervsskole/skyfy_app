import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:just_audio/just_audio.dart';
import 'package:skyfy_app/helpers/location_helper.dart';
import 'package:skyfy_app/helpers/mini_player.dart';
import 'package:skyfy_app/helpers/weather_helper.dart';
import 'package:skyfy_app/models/Content.dart';
import 'package:skyfy_app/screens/search_screen.dart';
import 'package:skyfy_app/screens/upload_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int navIndex = 0;
  String query = "";
  final AudioPlayer player = AudioPlayer();
  final ConcatenatingAudioSource playlist = ConcatenatingAudioSource(children: []);

  final List<Content> songQueue = [];
  Content? currentSong;
  final storage = const FlutterSecureStorage();

  late StreamSubscription<PlayerState> _playerSub;
  late StreamSubscription<int?> _indexSub;

  final GlobalKey<SearchScreenState> searchKey = GlobalKey<SearchScreenState>();

  final pages = <Widget>[];

  @override
  void initState() {
    super.initState();

    pages.addAll([
      HomeScreen(onSongSelected: playSong),
      const UploadScreen(),
      const ProfileScreen(),
      SearchScreen(
        key: searchKey,
        onSongSelected: playSong,
        initialQuery: query,
      ),
    ]);


    _playerSub = player.playerStateStream.listen((_) {
      if (mounted) setState(() {});
    });

    _indexSub = player.currentIndexStream.listen((index) {
      if (index != null && index < songQueue.length && mounted) {
        setState(() => currentSong = songQueue[index]);
      }
    });
  }

  @override
  void dispose() {
    _playerSub.cancel();
    _indexSub.cancel();
    player.dispose();
    super.dispose();
  }

  String formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  Future<void> playSong(Content song) async {
    try {
      // Add to queue if missing
      if (!songQueue.contains(song)) {
        songQueue.add(song);
        setState(() => currentSong = song);

        var token = await storage.read(key: "auth_token");
        Position? pos = await LocationsHelper.getUserLocation();

        String weatherCode = "0";
        if (pos != null) {
          weatherCode = (await WeatherHelper.getCurrentWeatherCode(pos.latitude, pos.longitude)).toString();
        }

        await playlist.add(
          AudioSource.uri(
            Uri.parse(song.streamUrl),
            headers: {
              "Authorization": "Bearer $token",
              "Weather_Code": weatherCode,
            },
          ),
        );
      }

      final index = songQueue.indexOf(song);

      await player.setAudioSource(
        playlist,
        initialIndex: index,
        preload: true,
      );

      await player.play();
    } catch (e) {
      setState(() => currentSong = null);
    }
  }

  void _submitSearch(String value) {
    query = value;

    if (navIndex == 3 && searchKey.currentState != null) {

      searchKey.currentState!.runSearch(value);
      setState(() {});
      return;
    }

    pages[3] = SearchScreen(
      key: searchKey,
      onSongSelected: playSong,
      initialQuery: value,
    );

    setState(() {
      navIndex = 3;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (searchKey.currentState != null) {
        searchKey.currentState!.runSearch(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          children: [
            Image.asset('lib/assets/SmallWithNoSubtitle.png', width: 100),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                height: 35,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: SearchBar(
                  hintText: 'Search songs, artists, albums...',
                  textStyle: MaterialStateProperty.all(
                    const TextStyle(color: Colors.white),
                  ),
                  controller: TextEditingController(text: query),
                  hintStyle: MaterialStateProperty.all(
                    const TextStyle(color: Colors.white54),
                  ),
                  backgroundColor: MaterialStateProperty.all(
                    const Color.fromARGB(221, 39, 39, 39),
                  ),
                  elevation: MaterialStateProperty.all(0),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(500),
                    ),
                  ),
                  leading: const Icon(Icons.search, color: Colors.white54, size: 20),
                  padding: MaterialStateProperty.all(
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                  ),
                  onSubmitted: _submitSearch,
                ),
              ),
            ),
          ],
        ),
      ),

      body: pages[navIndex],

      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MiniPlayer(
            player: player,
            currentSong: currentSong,
            formatDuration: formatDuration,
          ),
          Theme(
            data: Theme.of(context).copyWith(
              splashFactory: NoSplash.splashFactory,
              bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                backgroundColor: Color.fromARGB(255, 17, 17, 17),
                selectedItemColor: Colors.blueAccent,
                unselectedItemColor: Colors.white54,
                type: BottomNavigationBarType.fixed, // 4 tabs stable colors
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: navIndex,
              onTap: (i) => setState(() => navIndex = i),
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
                BottomNavigationBarItem(icon: Icon(Icons.add), label: ""),
                BottomNavigationBarItem(icon: Icon(Icons.list_sharp), label: ""),
                BottomNavigationBarItem(icon: Icon(Icons.search), label: ""),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
