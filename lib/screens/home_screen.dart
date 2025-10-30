import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:skyfy_app/helpers/content_helper.dart';
import 'package:skyfy_app/helpers/api_helper.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final storage = const FlutterSecureStorage();
  String? currentSong;

  final contentHelper = ContentHelper();
  final player = AudioPlayer();

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

  void showAddToPlaylistDialog(String songTitle) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF121212),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add "$songTitle" to Playlist',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...playlists.map((p) {
                return ListTile(
                  title: Text(p, style: const TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('"$songTitle" added to "$p"'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                );
              }),
              const Divider(color: Colors.white24),
              ListTile(
                leading: const Icon(Icons.add, color: Colors.white),
                title: const Text('Create New Playlist',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (context) {
                      final controller = TextEditingController();
                      return AlertDialog(
                        backgroundColor: const Color(0xFF1E1E1E),
                        title: const Text('New Playlist',
                            style: TextStyle(color: Colors.white)),
                        content: TextField(
                          controller: controller,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'Enter playlist name',
                            hintStyle: TextStyle(color: Colors.white38),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white24),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel',
                                style: TextStyle(color: Colors.white70)),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Created playlist "${controller.text}" and added "$songTitle"'),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                            child: const Text('Create',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void handlePlayPause(Map<String, dynamic> song, bool isPlaying) async {
    if (isPlaying) {
      setState(() {
        currentSong = null;
      });
      await player.pause();
    } else {
      setState(() {
        currentSong = song['title'];
      });

      final url = Uri.parse('${contentHelper.baseUrl}/Content/8/playlist.m3u8');
      try {
        await player.stop();

        player.playbackEventStream.listen(
          (event) {
            print("🎵 Playback event: $event");
          },
          onError: (Object e, StackTrace stackTrace) {
            print("❌ Playback error: $e");
          },
        );

        await player.setAudioSource(
          AudioSource.uri(url),
        );
        
        await player.play();
      } catch (e) {
        print('Audio Load/Play Failed: $e');
      }
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
          ListView.builder(
            padding: const EdgeInsets.all(0),
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
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Like button
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: IconButton(
                          icon: const Icon(Icons.thumb_up_outlined,
                              color: Colors.white),
                          onPressed: () =>
                              showAddToPlaylistDialog(song['title']!),
                        ),
                      ),
                      // Add to playlist button
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: IconButton(
                          icon: const Icon(Icons.playlist_add,
                              color: Colors.white),
                          onPressed: () =>
                              showAddToPlaylistDialog(song['title']!),
                        ),
                      ),
                      // Play / Pause toggle button
                      Container(
                        child: IconButton(
                          icon: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            handlePlayPause(song, isPlaying);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Bottom now playing bar
          if (currentSong != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: const Color(0xFF181818),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
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
                      icon: const Icon(Icons.pause_circle_filled,
                          color: Color.fromRGBO(79, 152, 255, 1), size: 32),
                      onPressed: () {
                        setState(() {
                          currentSong = null;
                        });
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
