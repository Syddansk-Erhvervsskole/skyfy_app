import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class MiniPlayer extends StatelessWidget {
  final AudioPlayer player;
  final String? currentSong;
  final String Function(Duration) formatDuration;

  const MiniPlayer({
    super.key,
    required this.player,
    required this.currentSong,
    required this.formatDuration,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPlaying = player.playing;
    if (currentSong == null) return const SizedBox.shrink();
    
    return Padding(padding: EdgeInsets.only(bottom: 10), child: ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),

          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 17, 17, 17),
     
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4F98FF), Color(0xFF1E3A8A)],
                      ),
                    ),
                    child: const Icon(Icons.music_note, size: 20, color: Colors.white),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      currentSong ?? "Nothing playing",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  GestureDetector(
                    onTap: () async {
                      isPlaying ? await player.pause() : await player.play();
                    },
                    child: AnimatedScale(
                      scale: isPlaying ? 1.05 : 1.0,
                      duration: const Duration(milliseconds: 150),
                      child: Icon(
                        isPlaying
                            ? Icons.pause_circle_filled_rounded
                            : Icons.play_circle_fill_rounded,
                        color: const Color(0xFF4F98FF),
                        size: 38,
                      ),
                    ),
                  )
                ],
              ),

              const SizedBox(height: 8),

              StreamBuilder<Duration>(
                stream: player.positionStream,
                builder: (context, snapshot) {
                  final pos = snapshot.data ?? Duration.zero;
                  final total = player.duration ?? Duration.zero;

                  return Column(
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 3,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4),
                          overlayShape: SliderComponentShape.noOverlay,
                        ),
                        child: Slider(
                          min: 0,
                          max: total.inMilliseconds.toDouble(),
                          value: pos.inMilliseconds.clamp(0, total.inMilliseconds).toDouble(),
                          onChanged: (value) {
                            player.seek(Duration(milliseconds: value.toInt()));
                          },
                          activeColor: const Color(0xFF4F98FF),
                          inactiveColor: Colors.white12,
                        ),
                      ),

                      // Time Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            formatDuration(pos),
                            style: const TextStyle(color: Colors.white54, fontSize: 11),
                          ),
                          Text(
                            formatDuration(total),
                            style: const TextStyle(color: Colors.white54, fontSize: 11),
                          )
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
    ));
  }
}
