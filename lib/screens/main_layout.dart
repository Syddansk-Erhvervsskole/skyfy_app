import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:just_audio/just_audio.dart';
import 'package:skyfy_app/helpers/mini_player.dart';
import 'package:skyfy_app/helpers/weather_helper.dart';
import 'package:skyfy_app/models/Content.dart';
import 'package:skyfy_app/screens/upload_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int currentIndex = 0;

  final AudioPlayer player = AudioPlayer();
  Content? currentSong;
  late StreamSubscription<PlayerState> _playerSub;
  final storage = const FlutterSecureStorage();

  final pages = [];

  @override
  void initState() {
    super.initState();

    pages.addAll([
      HomeScreen(onSongSelected: playSong),
      const UploadScreen(),
      const ProfileScreen(),
    ]);

    _playerSub = player.playerStateStream.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _playerSub.cancel();
    player.dispose();
    super.dispose();
  }

  String formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  Future<void> playSong(Content song) async {
    setState(() => currentSong = song);
    var weatherCode = (await WeatherHelper.getCurrentWeatherCode(55.39, 10.38)).toString();
    try {
      var auth_token = await storage.read(key: "auth_token");
      await player.setAudioSource(AudioSource.uri(Uri.parse(song.streamUrl), headers: {
        "Authorization": "Bearer ${auth_token}",
        "Weather_Code": weatherCode,
      }));
      await player.play();
    } catch (_) {
      setState(() => currentSong = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        title: Image.asset('lib/assets/SmallWithNoSubtitle.png', width: 100),
        backgroundColor: Colors.black,
      ),

      body: pages[currentIndex],

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
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              hoverColor: Colors.transparent,
            ),
            child: BottomNavigationBar(
              backgroundColor: const Color.fromARGB(255, 17, 17, 17),
              selectedItemColor: Colors.blueAccent,
              unselectedItemColor: Colors.white54,
              currentIndex: currentIndex,
              onTap: (i) => setState(() => currentIndex = i),
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
                BottomNavigationBarItem(icon: Icon(Icons.add), label: ""),
                BottomNavigationBarItem(icon: Icon(Icons.list_sharp), label: ""),
              ],
            ),
          )
        ],
      ),
    );
  }
}
