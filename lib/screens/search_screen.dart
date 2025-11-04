import 'package:flutter/material.dart';
import 'package:skyfy_app/helpers/content_helper.dart';
import 'package:skyfy_app/models/Content.dart';

class SearchScreen extends StatefulWidget {
  final Function(Content song) onSongSelected;
  final String? initialQuery;

  const SearchScreen({
    super.key,
    required this.onSongSelected,
    this.initialQuery,
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
      setState(() {
        results = (data as List).map((json) => Content.fromJson(json)).toList();
      });
    } finally {
      setState(() => loading = false);
    }
  }

  Widget songTile(Content song) {
    return GestureDetector(
      onTap: () => widget.onSongSelected(song),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Container(
              width: 50,
              height: 50,
              child: AspectRatio(
                aspectRatio: 1,
                child: (song.imageUrl == null || song.imageUrl!.isEmpty)
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
                            color: Colors.white, size: 35),
                      )
                    : Image.network(
                        song.imageUrl!,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Text(
              song.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          IconButton(
            icon: const Icon(Icons.play_arrow_rounded,
                color: Colors.white, size: 32),
            onPressed: () => widget.onSongSelected(song),
          ),
        ],
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

            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                  : results.isEmpty
                      ? const Center(
                          child: Text(
                            "No results",
                            style: TextStyle(color: Colors.white54, fontSize: 16),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          itemCount: results.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 14),
                          itemBuilder: (_, i) => songTile(results[i]),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
