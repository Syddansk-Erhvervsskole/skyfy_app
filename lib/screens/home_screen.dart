import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:skyfy_app/helpers/content_helper.dart';
import 'package:skyfy_app/models/Content.dart';
import 'package:skyfy_app/widgets/song_cover.dart';
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

  @override
  void initState() {
    super.initState();
    fetchSongs();
  }

  void fetchSongs() async {
    // Temporary demo
    // setState(() {
    //   songs = [
    //     Content(id: 101, name: "Fallen Leaves", imageUrl: "https://content.gucca.dk/covers/400/d/i/dire-straits-original-recording-remastered_107412.jpg"),
    //     Content(id: 102, name: "Starfall", imageUrl: "https://i.ebayimg.com/00/s/MTYwMFgxNjAw/z/tmkAAOSwwQdkdfh7/\$_57.JPG?set_id=880000500F"),
    //     Content(id: 103, name: "Deep Blue", imageUrl: "https://cdn.hmv.com/r/w-640/hmv/files/da/da430a77-070d-439e-8c9c-899644a137df.jpg"),
    //     Content(id: 104, name: "City Lights"),
    //   ];
    // });

    try {
      final data = await contentHelper.getAllContent();
      setState(() {
        songs = (data as List).map((json) => Content.fromJson(json)).toList();
      });
    } catch (e) {
      debugPrint("Error fetching content: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            GestureDetector(
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.fromARGB(255, 10, 10, 10),
                        Color.fromRGBO(79, 152, 255, 0.25),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4F98FF).withOpacity(0.25),
                        blurRadius: 18,
                        spreadRadius: 1,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: SvgPicture.asset(
                        'lib/assets/RainBanner.svg',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Recommended for you",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 8),


Expanded(
  child: songs.isEmpty
      ? const Center(child: CircularProgressIndicator(color: Colors.white))
      : GridView.builder(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 90),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,  
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 0.78,
          ),
          itemCount: songs.length,
          itemBuilder: (context, index) {
            final song = songs[index];

            return GestureDetector(
              onTap: () => widget.onSongSelected(song),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: AspectRatio(
                      aspectRatio: 1, // Square
                      child: song.imageUrl == null || song.imageUrl!.isEmpty
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
                                  color: Colors.white, size: 40),
                            )
                          : Image.network(
                              song.imageUrl!,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),

                  const SizedBox(height: 8),


                Text(
                      song.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,

                        fontWeight: FontWeight.w600,
                      ),
                    ),

                ],
              ),
            );
          },
        ),
)

  
          ],
        ),
      ),
    );
  }
}
