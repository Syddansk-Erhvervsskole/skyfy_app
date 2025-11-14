import 'package:flutter/material.dart';
import 'package:skyfy_app/models/Playlist.dart';
import 'package:skyfy_app/helpers/content_helper.dart';
import 'playlist_screen.dart';
import '../models/Content.dart';

class PlaylistsScreen extends StatefulWidget {
  final Function(Content song) onSongSelected;
  final Function(List<Content> songs) onPlayAll;
  final ValueNotifier<Content?> songNotifier;

  const PlaylistsScreen({
    super.key,
    required this.onSongSelected,
    required this.onPlayAll,
    required this.songNotifier,
  });

  @override
  State<PlaylistsScreen> createState() => _PlaylistsScreenState();
}

class _PlaylistsScreenState extends State<PlaylistsScreen> {
  final contentHelper = ContentHelper();
  bool isLoading = true;
  List<Playlist> playlists = [];
  Playlist? selectedPlaylist;

  @override
  void initState() {
    super.initState();
    fetchPlaylists();
  }

  Future<void> fetchPlaylists() async {
    final data = await contentHelper.getPlaylists();
    playlists = (data as List).map((json) => Playlist.fromJson(json)).toList();
    playlists.insert(0, Playlist(id: -1, name: "Liked Songs"));
    setState(() => isLoading = false);
  }

  Future<void> deletePlaylist(Playlist playlist) async {
    if (playlist.id == -1) return;
    final confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.black87,
        title: const Text("Delete Playlist", style: TextStyle(color: Colors.white)),
        content: Text("Delete '${playlist.name}'?", style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel", style: TextStyle(color: Colors.white60))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Delete", style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
    if (confirm == true) {
      await contentHelper.DeletePlaylist(playlist.id);
      fetchPlaylists();
      setState(() => selectedPlaylist = null);
    }
  }

  Widget playlistTile(Playlist playlist) {
    return Dismissible(
      key: ValueKey(playlist.id),
      direction: playlist.id == -1 ? DismissDirection.none : DismissDirection.endToStart,
      confirmDismiss: (_) async {
        await deletePlaylist(playlist);
        return false;
      },
      background: Container(
        decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.8), borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: playlist.id == -1
            ? const Icon(Icons.favorite, color: Colors.pinkAccent, size: 35)
            : Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(colors: [Color(0xFF0A0A0A), Color.fromRGBO(79, 152, 255, 0.4)]),
                ),
                child: const Icon(Icons.queue_music, color: Colors.white70),
              ),
        title: Text(playlist.name, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right, color: Colors.white54),
        onTap: () => setState(() => selectedPlaylist = playlist),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(selectedPlaylist == null ? "Playlists" : selectedPlaylist!.name, style: const TextStyle(color: Colors.white)),
        leading: selectedPlaylist != null
            ? IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => setState(() => selectedPlaylist = null))
            : null,
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: selectedPlaylist == null
              ? (isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                  : ListView.separated(
                      padding: const EdgeInsets.all(14),
                      itemCount: playlists.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) => playlistTile(playlists[i]),
                    ))
              : PlaylistScreen(
                  playlistId: selectedPlaylist!.id,
                  playlistName: selectedPlaylist!.name,
                  onSongSelected: widget.onSongSelected,
                  onPlayAll: widget.onPlayAll,
                  songNotifier: widget.songNotifier,
                ),
        ),
      ),
    );
  }
}
