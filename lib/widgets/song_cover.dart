import 'package:flutter/material.dart';

class SongCover extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final double borderRadius;

  const SongCover({
    super.key,
    this.imageUrl,
    this.size = 48,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    final fallbackWidget = Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4F98FF), Color(0xFF1E3A8A)],
        ),
      ),
      child: const Center(
        child: Icon(Icons.music_note, size: 22, color: Colors.white),
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        width: size,
        height: size,
        color: Colors.black12,
        child: (imageUrl == null || imageUrl!.isEmpty)
            ? fallbackWidget
            : Image.network(
                imageUrl!,
                fit: BoxFit.cover,
              ),
      ),
    );
  }
}
