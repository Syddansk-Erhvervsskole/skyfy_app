import 'package:flutter/material.dart';
import 'package:skyfy_app/helpers/content_helper.dart';
import 'package:skyfy_app/models/Content.dart';

class SearchScreen extends StatefulWidget {
  final Function(Content song) onSongSelected;
  final String? initialQuery;
  final ValueNotifier<Content?> songNotifier; 

  const SearchScreen({
    super.key,
    required this.onSongSelected,
    this.initialQuery,
    required this.songNotifier,
  });

  @override
  State<SearchScreen> createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final contentHelper = ContentHelper();
  List<Content> results = [];
  bool loading = false;

  Future<void> runSearch(String query) => search(query);

  @override
  void initState() {
    super.initState();

    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _controller.text = widget.initialQuery!;
      search(widget.initialQuery!);
    }
  }

  Future<void> search(String query) async {
    if (query.isEmpty) return;

    setState(() => loading = true);
    try {
      final data = await contentHelper.searchContent(query);
      results = (data as List).map((json) => Content.fromJson(json)).toList();
    } finally {
      setState(() => loading = false);
    }
  }

  Widget songTile(Content song, Content? current) {
    bool isPlaying = current?.id == song.id;

    return GestureDetector(
      onTap: () => widget.onSongSelected(song),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: isPlaying
            ? BoxDecoration(
                color: const Color.fromARGB(50, 79, 152, 255),
                borderRadius: BorderRadius.circular(10),
              )
            : null,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                width: 50,
                height: 50,
                child: (song.imageUrl == null || song.imageUrl!.isEmpty)
                    ? Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF4F98FF), Color(0xFF1E3A8A)],
                          ),
                        ),
                        child: const Icon(Icons.music_note,
                            color: Colors.white, size: 35),
                      )
                    : Image.network(song.imageUrl!, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                song.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isPlaying ? Colors.blueAccent : Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            IconButton(
              icon: isPlaying
                  ? const Icon(Icons.graphic_eq,
                      color: Colors.blueAccent, size: 28)
                  : const Icon(Icons.play_arrow_rounded,
                      color: Colors.white, size: 32),
              onPressed: () => widget.onSongSelected(song),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: SearchBar(
                hintText: 'Search songs, artists, albums...',
                controller: _controller,
                onChanged: (v) {
                  if (v.isEmpty) {
                    setState(() => results = []);
                    return;
                  }
                },
                onSubmitted: (v) => runSearch(v),
                hintStyle: WidgetStateProperty.all(const TextStyle(color: Colors.white54)),
                textStyle: WidgetStateProperty.all(const TextStyle(color: Colors.white)),
                backgroundColor: WidgetStateProperty.all(
                  const Color.fromARGB(221, 39, 39, 39),
                ),
                elevation: WidgetStateProperty.all(0),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                ),
                leading: const Icon(Icons.search, color: Colors.white54, size: 20),
              ),
            ),
            Expanded(
              child: loading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : ValueListenableBuilder<Content?>(
                      valueListenable: widget.songNotifier,
                      builder: (_, current, __) {
                        if (results.isEmpty) {
                          return const Center(
                            child: Text("Search for music",
                                style: TextStyle(
                                    color: Colors.white54, fontSize: 16)),
                          );
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          itemCount: results.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 14),
                          itemBuilder: (_, i) =>
                              songTile(results[i], current),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
