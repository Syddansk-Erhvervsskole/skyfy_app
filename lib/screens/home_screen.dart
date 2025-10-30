import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final storage = const FlutterSecureStorage();
  String? currentSong;

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
        final controller = TextEditingController();
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add "$songTitle" to Playlist',
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              ...playlists.map((p) => ListTile(
                title: Text(p, style: const TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('"$songTitle" added to "$p"')),
                  );
                },
              )),

              const Divider(color: Colors.white24),

              ListTile(
                leading: const Icon(Icons.add, color: Colors.white),
                title: const Text('Create New Playlist', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Align(
          alignment: Alignment.centerLeft,
          child: SvgPicture.asset(
            'lib/assets/SmallLogoNoCaption.svg',
            width: 100,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
            },
          ),
        ],
      ),

      body: Column(
        children: [
          GestureDetector(
            onTap: () {
              print("Rain banner clicked!");
            },
            child: Container(
              width: double.infinity,
              height: 150,
              margin: const EdgeInsets.only(bottom: 8),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0A0A0A),
                    Color.fromRGBO(79, 152, 255, 0.23),
                  ],
                ),
              ),
              child: SvgPicture.asset('lib/assets/RainBanner.svg', fit: BoxFit.contain),
            ),
          ),
  // GestureDetector(
  //           onTap: () {
  //             print("Rain banner clicked!");
  //           },
  //           child: Container(
  //             width: double.infinity,
  //             height: 150,
  //             margin: const EdgeInsets.only(bottom: 8),
  //             decoration: const BoxDecoration(
  //               gradient: LinearGradient(
  //                 begin: Alignment.topCenter,
  //                 end: Alignment.bottomRight,
  //                 colors: [
  //                   Color(0xFF0A0A0A),
  //                   Color.fromRGBO(79, 152, 255, 0.23),
  //                 ],
  //               ),
  //             ),
  //             child: SvgPicture.asset('lib/assets/RainBanner.svg', fit: BoxFit.contain),
  //           ),
  //         ),
          Expanded(
            child: ListView.builder(
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
                    title: Text(song['title']!, style: const TextStyle(color: Colors.white)),
                    trailing: IconButton(
                      icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          currentSong = isPlaying ? null : song['title'];
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
