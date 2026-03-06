// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:Bloomee/core/models/exported.dart';
import 'package:Bloomee/screens/screen/common_views/artist_view.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/utils/load_image.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

class ArtistCard extends StatefulWidget {
  final ArtistSummary artist;
  final String pluginId;

  const ArtistCard({
    super.key,
    required this.artist,
    required this.pluginId,
  });

  @override
  State<ArtistCard> createState() => _ArtistCardState();
}

class _ArtistCardState extends State<ArtistCard> {
  bool _isHovering = false;

  void _setHovering(bool hovering) {
    if (mounted) {
      setState(() {
        _isHovering = hovering;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: SizedBox(
        // Set your desired max width here. The circle will scale perfectly to match it.
        width: 160,
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ArtistView(
                  artist: widget.artist,
                  pluginId: widget.pluginId,
                ),
              ),
            );
          },
          child: MouseRegion(
            onEnter: (_) => _setHovering(true),
            onExit: (_) => _setHovering(false),
            // Removed the Card widget to fix alignment/margin issues
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AspectRatio(
                  aspectRatio: 1.0, // Forces a perfect square footprint
                  child: ClipOval(
                    child: Stack(
                      fit:
                          StackFit.expand, // Forces children to fill the circle
                      children: [
                        LoadImageCached(
                          imageUrl: widget.artist.thumbnail?.url ?? '',
                          fit: BoxFit
                              .cover, // Ensures all resolutions scale correctly
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          color: _isHovering
                              ? Colors.black.withValues(alpha: 0.5)
                              : Colors.transparent,
                          child: Center(
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 200),
                              opacity: _isHovering ? 1.0 : 0.0,
                              child: const Icon(
                                MingCute.play_circle_line,
                                color: Colors.white,
                                size: 50,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ─── ARTIST NAME ───
                const SizedBox(height: 12),
                Text(
                  widget.artist.name,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: Default_Theme.secondoryTextStyleMedium.merge(
                    TextStyle(
                      fontSize: 14,
                      color: Default_Theme.primaryColor2.withValues(alpha: 0.9),
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
