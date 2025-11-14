import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:just_audio/just_audio.dart';
import 'package:skyfy_app/helpers/mini_player.dart';
import 'package:skyfy_app/helpers/weather_helper.dart';
import 'package:skyfy_app/models/Content.dart';
import 'package:skyfy_app/screens/playlists_screen.dart';
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
  ValueNotifier<Content?> currentSongNotifier = ValueNotifier(null);

  final storage = const FlutterSecureStorage();
  late StreamSubscription<PlayerState> _playerSub;
  late StreamSubscription<int?> _indexSub;

  final GlobalKey<SearchScreenState> searchKey = GlobalKey<SearchScreenState>();

  final pages = <Widget>[];

  @override
  void initState() {
    super.initState();

    pages.addAll([
      HomeScreen(
        onSongSelected: playSong,
        onPlayAll: playAllSongs,
        songNotifier: currentSongNotifier, 
      ),
      const UploadScreen(),
      PlaylistsScreen(
        onSongSelected: playSong,
        onPlayAll: playAllSongs,
        songNotifier: currentSongNotifier, 
      ),
      SearchScreen(
        key: searchKey,
        onSongSelected: playSong,
        initialQuery: query,
        songNotifier: currentSongNotifier, 
      ),
      const ProfileScreen(),
    ]);

    _playerSub = player.playerStateStream.listen((_) {
      if (mounted) setState(() {});
    });

    _indexSub = player.currentIndexStream.listen((index) {
      if (index != null && index < songQueue.length && mounted) {
        currentSong = songQueue[index];
        currentSongNotifier.value = currentSong; 
        setState(() {});
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

Future<void> playSong(Content song) async {
  try {
    if (!songQueue.contains(song)) {
      songQueue.add(song);

      var token = await storage.read(key: "auth_token");
      int weatherCode = await WeatherHelper.getCurrentWeatherCode();
      var uri =   Uri.parse(song.streamUrl(weatherCode.toString()));

      await playlist.add(
        AudioSource.uri(
          uri,
          headers: {
              "Authorization": "Bearer $token",
          },
          tag: song,
        ),
      );
    }

    final index = songQueue.indexOf(song);

    await player.setAudioSource(playlist, initialIndex: index, preload: true);

    currentSong = song;
    currentSongNotifier.value = song;

    await player.play();
    setState(() {});
  } catch (e) {


  currentSong = null;
  currentSongNotifier.value = null;
}

}


  Future<void> playAllSongs(List<Content> songs) async {
    try { 
      playlist.clear();
      songQueue.clear();

      var token = await storage.read(key: "auth_token");

      for (var s in songs) {
        songQueue.add(s);
        await playlist.add(
          AudioSource.uri(
            Uri.parse(s.streamUrl((await WeatherHelper.getCurrentWeatherCode()).toString())),
            headers: {
              "Authorization": "Bearer $token",
            },
            tag: s,
          ),
        );
      }

      currentSong = songs.first;
      currentSongNotifier.value = currentSong;

      await player.setAudioSource(playlist, preload: true);
      await player.play();
      setState(() {});
    } catch (_) {}
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
      songNotifier: currentSongNotifier, 
    );

    setState(() => navIndex = 3);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      searchKey.currentState?.runSearch(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.asset('lib/assets/SmallWithNoSubtitle.png', width: 100),
      ),
      body: pages[navIndex],
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MiniPlayer(
            player: player,
            currentSong: currentSong,
            formatDuration: (d) =>
                "${d.inMinutes.remainder(60).toString().padLeft(2, '0')}:${d.inSeconds.remainder(60).toString().padLeft(2, '0')}",
          ),
          BottomNavigationBar(
            currentIndex: navIndex,
            onTap: (i) => setState(() => navIndex = i),
            backgroundColor: const Color.fromARGB(255, 17, 17, 17),
            selectedItemColor: Colors.blueAccent,
            unselectedItemColor: Colors.white54,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
              BottomNavigationBarItem(icon: Icon(Icons.add), label: ""),
              BottomNavigationBarItem(icon: Icon(Icons.list), label: ""),
              BottomNavigationBarItem(icon: Icon(Icons.search), label: ""),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: ""),
            ],
          ),
        ],
      ),
    );
  }
}
