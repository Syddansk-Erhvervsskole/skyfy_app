import 'package:flutter/material.dart';
import 'package:skyfy_app/helpers/content_helper.dart';
import 'package:skyfy_app/models/Playlist.dart';
import 'package:skyfy_app/models/Content.dart';

class AddToPlaylistSheet extends StatefulWidget {
  final Content song;

  const AddToPlaylistSheet({super.key, required this.song});

  @override
  State<AddToPlaylistSheet> createState() => _AddToPlaylistSheetState();
}

class _AddToPlaylistSheetState extends State<AddToPlaylistSheet> {
  final contentHelper = ContentHelper();
  List<Playlist> playlists = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await contentHelper.getPlaylists();
    playlists = (data as List).map((e) => Playlist.fromJson(e)).toList();
    setState(() => loading = false);
  }

  Future<void> addToPlaylist(Playlist playlist) async {

    var content = ((await contentHelper.getPlaylistSongs(playlist.id)) as List).map((json) => Content.fromJson(json)).toList();
    if(content.any((element) => element.id == widget.song.id)){
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text("Playlist already contains song"),
        duration: const Duration(seconds: 2),
      ),);
       return;
    }


    await contentHelper.PlaylistAdd(widget.song.id, playlist.id);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.blueAccent,
        content: Text("Added to '${playlist.name}'"),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: loading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const Text("Add to Playlist",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 12),
                ...playlists.map((p) => ListTile(
                      onTap: () => addToPlaylist(p),
                      title: Text(p.name, style: const TextStyle(color: Colors.white)),
                      trailing: const Icon(Icons.chevron_right, color: Colors.white54),
                    )),
                const SizedBox(height: 14),
              ],
            ),
    );
  }
}
