import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:skyfy_app/helpers/mini_player.dart';
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
  String? currentSong;
  late StreamSubscription<PlayerState> _playerSub;

  final pages = [];

  @override
  void initState() {
    super.initState();

    pages.addAll([
      HomeScreen(onSongSelected: playSong),
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

  Future<void> playSong(String title, String url) async {
    setState(() => currentSong = title);

    try {
      await player.setAudioSource(AudioSource.uri(Uri.parse(url)));
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


        Theme(  data: Theme.of(context).copyWith(
            splashFactory: NoSplash.splashFactory,  
            highlightColor: Colors.transparent,     
            splashColor: Colors.transparent,         
            hoverColor: Colors.transparent,         
          ), child: 
          BottomNavigationBar(
            
            backgroundColor: const Color.fromARGB(255, 17, 17, 17),
            selectedItemColor: Colors.blueAccent,
            unselectedItemColor: Colors.white54,
            currentIndex: currentIndex,
            onTap: (i) => setState(() => currentIndex = i),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
            ],
          ),)
        ],
      ),
    );
  }
}
