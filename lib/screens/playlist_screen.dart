import 'package:flutter/material.dart';
import 'package:skyfy_app/helpers/content_helper.dart';
import '../models/Content.dart';
import '../widgets/song_cover.dart';

class PlaylistScreen extends StatefulWidget {
  final int playlistId;
  final String playlistName;
  final Function(Content song) onSongSelected;
  final Function(List<Content> songs) onPlayAll;
  final ValueNotifier<Content?> songNotifier;

  const PlaylistScreen({
    super.key,
    required this.playlistId,
    required this.playlistName,
    required this.onSongSelected,
    required this.onPlayAll,
    required this.songNotifier,
  });

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  final contentHelper = ContentHelper();
  bool loading = true;
  List<Content> playlistSongs = [];

  @override
  void initState() {
    super.initState();
    loadSongs();
  }

  Future<void> loadSongs() async {
    if (widget.playlistId == -1) {
      final data = await contentHelper.getLikedSongs();
      playlistSongs = (data as List).map((e) => Content.fromJson(e)).toList();
    } else {
      final data = await contentHelper.getPlaylistSongs(widget.playlistId);
      playlistSongs = (data as List).map((e) => Content.fromJson(e)).toList();
    }
    setState(() => loading = false);
  }

  Future<void> removeSong(Content song) async {
    if (widget.playlistId == -1) {
      await contentHelper.unlikeSong(song.id);
    } else {
      await contentHelper.PlaylistRemove(song.id,widget.playlistId);
    }
    loadSongs();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: Colors.blueAccent, content: Text(widget.playlistId == -1 ? "Removed from Liked Songs" : "Removed '${song.name}'")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Center(child: CircularProgressIndicator(color: Colors.white))
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Text(widget.playlistName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.play_circle_fill, color: Colors.white, size: 32),
                      onPressed: () => widget.onPlayAll(playlistSongs),
                    )
                  ],
                ),
              ),
              Expanded(
                child: ValueListenableBuilder<Content?>(
                  valueListenable: widget.songNotifier,
                  builder: (_, current, __) {
                    return ListView.separated(
                      itemCount: playlistSongs.length,
                      separatorBuilder: (_, __) => const Divider(color: Colors.white12),
                      itemBuilder: (_, i) {
                        final song = playlistSongs[i];
                        final playing = current?.id == song.id;
                        return GestureDetector(
                          onLongPress: () => removeSong(song),
                          child: ListTile(
                            onTap: () => widget.onSongSelected(song),
                            leading: SongCover(imageUrl: song.imageUrl, size: 48),
                            title: Text(song.name, style: TextStyle(color: playing ? Colors.blueAccent : Colors.white, fontWeight: FontWeight.w600)),
                            trailing: Icon(playing ? Icons.graphic_eq : Icons.play_arrow, color: playing ? Colors.blueAccent : Colors.white),
                          ),
                        );
                      },
                    );
                  },
                ),
              )
            ],
          );
  }
}
