import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:skyfy_app/helpers/content_helper.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/material.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final storage = const FlutterSecureStorage();
  String? currentSong;

  final contentHelper = ContentHelper();
  final AudioPlayer player = AudioPlayer();

  final List<Map<String, String>> songs = [
    {'title': 'Morning Sun'},
    {'title': 'Rainy Nights'},
    {'title': 'Ocean Breeze'},
    {'title': 'City Lights'},
    {'title': 'Mountain Echo'},
    {'title': 'Desert Mirage'},
    {'title': 'Autumn Dreams'},
  ];

  final List<String> playlists = [
    'Playlist 1',
    'Playlist 2',
    'Playlist 3',
    'Playlist 4'
  ];

  @override
  void initState() {
    super.initState();

    player.playbackEventStream.listen(
      (event) => print("🎵 Playback event: $event"),
      onError: (Object e, StackTrace st) =>
          print("❌ Playback error: $e"),
    );
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  // ✅ Duration formatting for mm:ss
  String formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  // ✅ Play / Pause logic
  void handlePlayPause(Map<String, dynamic> song, bool isPlaying) async {
    final playlistUrl = "${contentHelper.baseUrl}/Content/8/playlist.m3u8";

    if (isPlaying && player.playing) {
      await player.pause();
      setState(() {});
      return;
    }

    if (currentSong == song['title']) {
      await player.play();
      setState(() {});
      return;
    }

    setState(() => currentSong = song['title']);

    try {
      await player.setAudioSource(AudioSource.uri(Uri.parse(playlistUrl)));
      await player.play();
    } catch (e) {
      print("❌ Audio Load/Play Failed: $e");
      setState(() => currentSong = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Align(
          alignment: Alignment.centerLeft,
          child: Image.asset(
            'lib/assets/SmallWithNoSubtitle.png',
            width: 100,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // ✅ Song list
          ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];
              final isPlaying = currentSong == song['title'];

              return Card(
                color: const Color.fromARGB(113, 33, 33, 33),
                margin: const EdgeInsets.symmetric(vertical: 2),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  title: Text(
                    song['title']!,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      handlePlayPause(song, isPlaying);
                    },
                  ),
                ),
              );
            },
          ),

          // ✅ Bottom player with timeline
          if (currentSong != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: const Color(0xFF181818),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Row with song title + play/pause
                    Row(
                      children: [
                        const Icon(Icons.music_note, color: Colors.white70),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            currentSong!,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            player.playing
                                ? Icons.pause_circle_filled
                                : Icons.play_circle_fill,
                            color: const Color.fromRGBO(79, 152, 255, 1),
                            size: 32,
                          ),
                          onPressed: () async {
                            if (player.playing) {
                              await player.pause();
                            } else {
                              await player.play();
                            }
                            setState(() {});
                          },
                        ),
                      ],
                    ),

                    // ✅ Timeline slider
                    StreamBuilder<Duration>(
                      stream: player.positionStream,
                      builder: (context, snapshot) {
                        final position = snapshot.data ?? Duration.zero;
                        final total = player.duration ?? Duration.zero;

                        return Column(
                          children: [
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 3,
                                thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 6),
                              ),
                              child: Slider(
                                min: 0,
                                max: total.inMilliseconds.toDouble(),
                                value: position.inMilliseconds
                                    .clamp(0, total.inMilliseconds)
                                    .toDouble(),
                                onChanged: (value) {
                                  player.seek(
                                      Duration(milliseconds: value.toInt()));
                                },
                                activeColor: Colors.white,
                                inactiveColor: Colors.white24,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(formatDuration(position),
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 12)),
                                Text(formatDuration(total),
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 12)),
                              ],
                            )
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
