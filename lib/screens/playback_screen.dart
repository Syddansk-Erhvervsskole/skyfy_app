import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:skyfy_app/models/Content.dart';
import 'package:skyfy_app/widgets/song_cover.dart';

class PlaybackScreen extends StatefulWidget {
  final AudioPlayer player;
  final Content? currentSong;

  const PlaybackScreen({
    super.key,
    required this.player,
    required this.currentSong,
  });

  @override
  State<PlaybackScreen> createState() => _PlaybackScreenState();
}

class _PlaybackScreenState extends State<PlaybackScreen> {
  Color c1 = const Color(0xFF1B1E26);
  Color c2 = const Color(0xFF101318);
  Color lastC1 = const Color(0xFF1B1E26);
  Color lastC2 = const Color(0xFF101318);

  Content? _song;

  @override
  void initState() {
    super.initState();

    _song = widget.currentSong;
    _extractColors();

    widget.player.currentIndexStream.listen((index) {
      if (index == null ||
          widget.player.sequence.isEmpty ||
          index >= widget.player.sequence.length ||
          index < 0) {
        return;
      }

      final tag = widget.player.sequence[index].tag;
      if (tag is Content) {
        setState(() => _song = tag);
        _extractColors();
      }
    });
  }

  @override
  void didUpdateWidget(covariant PlaybackScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentSong?.imageUrl != widget.currentSong?.imageUrl) {
      _song = widget.currentSong;
      _extractColors();
    }
  }

  Future<void> _extractColors() async {
    final imageUrl = _song?.imageUrl;

    if (imageUrl == null || imageUrl.isEmpty) {
      setState(() => c1 = c2 = const Color(0xFF111111));
      return;
    }

    try {
      final palette = await PaletteGenerator.fromImageProvider(
        NetworkImage(imageUrl),
        maximumColorCount: 16,
      );

      final d = palette.dominantColor?.color ?? const Color(0xFF111111);
      final dv = palette.darkVibrantColor?.color ?? d;

      setState(() {
        lastC1 = d;
        lastC2 = dv;
        c1 = d.withOpacity(0.9);
        c2 = dv.withOpacity(0.85);
      });
    } catch (_) {
      setState(() => c1 = c2 = const Color(0xFF111111));
    }
  }

  String _format(Duration d) =>
      "${d.inMinutes}:${d.inSeconds.remainder(60).toString().padLeft(2, '0')}";

  Color _lerp(Color a, Color b, double t) => Color.lerp(a, b, t) ?? a;

  @override
  Widget build(BuildContext context) {
    final blue = const Color(0xFF4F98FF);
    final hasImage = _song?.imageUrl != null && _song!.imageUrl!.isNotEmpty;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: hasImage ? [c1, c2] : [Colors.black, Colors.black],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8, right: 8),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: SongCover(
                        imageUrl: _song?.imageUrl,
                        size: 300,
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _song?.name ?? "",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _song?.artist ?? "Unknown Artist",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 17,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.playlist_add_rounded,
                          size: 34,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: StreamBuilder<Duration>(
                    stream: widget.player.positionStream,
                    builder: (context, snap) {
                      final pos = snap.data ?? Duration.zero;
                      final total = widget.player.duration ?? Duration.zero;
                      final t = total.inMilliseconds == 0
                          ? 0.0
                          : pos.inMilliseconds / total.inMilliseconds;

                      final sliderColor = hasImage ? _lerp(c2, c1, t) : blue;

                      return Column(
                        children: [
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 4,
                              thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 7),
                              overlayShape: SliderComponentShape.noOverlay,
                              thumbColor: sliderColor,
                              overlayColor: sliderColor.withOpacity(.4),
                            ),
                            child: Slider(
                              min: 0,
                              max: total.inMilliseconds.toDouble(),
                              value: pos.inMilliseconds
                                  .clamp(0, total.inMilliseconds)
                                  .toDouble(),
                              onChanged: (v) => widget.player.seek(
                                Duration(milliseconds: v.toInt()),
                              ),
                              activeColor: sliderColor,
                              inactiveColor: Colors.white30,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(_format(pos),
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 12)),
                                Text(_format(total),
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                const SizedBox(height: 18),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () => widget.player.seekToPrevious(),
                      icon: const Icon(
                        Icons.skip_previous_rounded,
                        color: Colors.white,
                        size: 38,
                      ),
                    ),

                    const SizedBox(width: 12),

                    StreamBuilder<bool>(
                      stream: widget.player.playingStream,
                      builder: (context, snap) {
                        final playing = snap.data ?? false;
                        return GestureDetector(
                          onTap: () =>
                              playing ? widget.player.pause() : widget.player.play(),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: hasImage ? _lerp(c1, c2, .3) : blue,
                            ),
                            child: Icon(
                              playing
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              size: 34,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(width: 12),

                    IconButton(
                      onPressed: () => widget.player.seekToNext(),
                      icon: const Icon(
                        Icons.skip_next_rounded,
                        color: Colors.white,
                        size: 38,
                      ),
                    ),
                  ],
                ),

                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
