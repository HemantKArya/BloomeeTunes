import 'package:Bloomee/screens/widgets/ambient_artwork_texture.dart';
import 'package:flutter/material.dart';

/// A single, non-interactive artwork layer behind player and lyrics views.
/// The blur is baked once per cover into a small, reusable image.
class ArtworkAmbientBackground extends StatelessWidget {
  final String imageUrl;
  final String? fallbackUrl;

  const ArtworkAmbientBackground({
    super.key,
    required this.imageUrl,
    this.fallbackUrl,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ExcludeSemantics(
        child: RepaintBoundary(
          child: ClipRect(
            child: Stack(
              fit: StackFit.expand,
              children: [
                const ColoredBox(color: Color(0xFF0C080E)),
                AmbientArtworkTexture(
                  imageUrl: imageUrl,
                  fallbackUrl: fallbackUrl,
                ),
                // Keep the sleeve's colour visible while protecting text and
                // transport contrast, especially in the middle of the stage.
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0x99080A10),
                        Color(0xC7080A10),
                        Color(0xE6080A10),
                      ],
                      stops: [0, 0.55, 1],
                    ),
                  ),
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(-0.5, -0.15),
                      radius: 1.2,
                      colors: [Colors.transparent, Color(0x9905080D)],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
