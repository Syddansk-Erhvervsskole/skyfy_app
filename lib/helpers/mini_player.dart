import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:skyfy_app/models/Content.dart';
import 'package:skyfy_app/widgets/song_cover.dart';
import '../screens/playback_screen.dart';

class MiniPlayer extends StatefulWidget {
  final AudioPlayer player;
  final Content? currentSong;
  final String Function(Duration) formatDuration;

  const MiniPlayer({
    super.key,
    required this.player,
    required this.currentSong,
    required this.formatDuration,
  });

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {
  Color c1 = const Color(0xFF1B1E26);
  Color c2 = const Color(0xFF101318);
  Color lastC1 = const Color(0xFF1B1E26);
  Color lastC2 = const Color(0xFF101318);
  final fallbackAccent = const Color(0xFF4F98FF);

  @override
  void didUpdateWidget(covariant MiniPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentSong?.imageUrl != widget.currentSong?.imageUrl) {
      _extractColors();
    }
  }

  Future<void> _extractColors() async {
    final img = widget.currentSong?.imageUrl;

    if (img == null || img.isEmpty) {
      setState(() => c1 = c2 = const Color(0xFF111111));
      return;
    }

    try {
      final pal = await PaletteGenerator.fromImageProvider(
        NetworkImage(img),
        maximumColorCount: 15,
      );

      final d = pal.dominantColor?.color ?? const Color(0xFF111111);
      final dv = pal.darkVibrantColor?.color ?? d;

      setState(() {
        c1 = lastC1 = d.withOpacity(.9);
        c2 = lastC2 = dv.withOpacity(.85);
      });
    } catch (_) {
      setState(() => c1 = c2 = const Color(0xFF111111));
    }
  }

  void _openFullPlayer() {
    if (widget.currentSong == null) return;
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (_, __, ___) => PlaybackScreen(
          player: widget.player,
          currentSong: widget.currentSong,
        ),
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween(begin: const Offset(0, 1), end: Offset.zero)
              .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.currentSong == null) return const SizedBox.shrink();

    final isPlaying = widget.player.playing;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [c1, c2],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),

            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: _openFullPlayer,
                        child: Row(
                          children: [
                            SongCover(
                              imageUrl: widget.currentSong?.imageUrl,
                              size: 42,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                widget.currentSong?.name ?? "",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    IconButton(
                      onPressed: () => widget.player.seekToPrevious(),
                      icon: const Icon(Icons.skip_previous_rounded,
                          size: 26, color: Colors.white),
                    ),

                    IconButton(
                      onPressed: () => isPlaying
                          ? widget.player.pause()
                          : widget.player.play(),
                      icon: AnimatedScale(
                        scale: isPlaying ? 1.05 : 1.0,
                        duration: const Duration(milliseconds: 150),
                        child: Icon(
                          isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),

                    IconButton(
                      onPressed: () => widget.player.seekToNext(),
                      icon: const Icon(Icons.skip_next_rounded,
                          size: 26, color: Colors.white),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                StreamBuilder<Duration>(
                  stream: widget.player.positionStream,
                  builder: (context, snapshot) {
                    final pos = snapshot.data ?? Duration.zero;
                    final total = widget.player.duration ?? Duration.zero;

                    return Column(
                      children: [
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 2.5,
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 6),
                            overlayShape: SliderComponentShape.noOverlay,
                          ),
                          child: Slider(
                            min: 0,
                            max: total.inMilliseconds.toDouble(),
                            value: pos.inMilliseconds
                                .clamp(0, total.inMilliseconds)
                                .toDouble(),
                            onChanged: (v) =>
                                widget.player.seek(Duration(milliseconds: v.toInt())),
                            activeColor: fallbackAccent,
                            inactiveColor: Colors.white24,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(widget.formatDuration(pos),
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 11)),
                            Text(widget.formatDuration(total),
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 11)),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
