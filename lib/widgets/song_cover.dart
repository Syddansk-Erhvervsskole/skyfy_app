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

  Widget get _fallbackWidget {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4F98FF), Color(0xFF1E3A8A)],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.music_note,
          size: 22,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: _fallbackWidget,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: size,
        height: size,
        child: Image.network(
          imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallbackWidget,
          frameBuilder: (ctx, child, frame, _) {
            // ✅ Start with fallback, then fade to real image ONLY when ready
            if (frame == null) {
              return Stack(
                children: [
                  _fallbackWidget,
                  AnimatedOpacity(
                    opacity: 0,
                    duration: Duration.zero,
                    child: child,
                  ),
                ],
              );
            }

            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: child,
            );
          },
        ),
      ),
    );
  }
}
