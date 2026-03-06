import 'package:Bloomee/core/models/exported.dart';
import 'package:Bloomee/screens/screen/common_views/album_view.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/screens/widgets/media_metadata_links.dart';
import 'package:Bloomee/utils/imgurl_formator.dart';
import 'package:Bloomee/utils/load_image.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

class AlbumCard extends StatefulWidget {
  final AlbumSummary album;
  final String pluginId;

  const AlbumCard({super.key, required this.album, required this.pluginId});

  @override
  State<AlbumCard> createState() => _AlbumCardState();
}

class _AlbumCardState extends State<AlbumCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    // ─── THE FIX: CONSTRAINTS ───
    // This ensures the card has a reasonable size in Search/Horizontal lists
    // while still being able to fill a Grid cell if needed.
    return Container(
      constraints: const BoxConstraints(maxWidth: 180), // Absolute max width
      margin:
          const EdgeInsets.symmetric(horizontal: 4), // Breathing room for lists
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AlbumView(
                album: widget.album,
                pluginId: widget.pluginId,
              ),
            ),
          );
        },
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovering = true),
          onExit: (_) => setState(() => _isHovering = false),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── 1. SQUARE IMAGE CONTAINER ───
              AspectRatio(
                aspectRatio: 1, // Forces perfect square regardless of input
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors
                        .black, // Background for wide images (Letterboxing)
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color:
                          Default_Theme.primaryColor1.withValues(alpha: 0.08),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      )
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // The Image: 'contain' handles wide images without breaking layout
                        Hero(
                          tag: '${widget.pluginId}_album_${widget.album.id}',
                          child: LoadImageCached(
                            imageUrl: formatImgURL(
                              widget.album.thumbnail?.url ?? '',
                              ImageQuality.medium,
                            ),
                            fallbackUrl: widget.album.thumbnail?.url,
                            fit: BoxFit
                                .contain, // Shows full wide image centered
                          ),
                        ),

                        // Hover/Tap Overlay
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: _isHovering ? 1.0 : 0.0,
                          child: Container(
                            color: Colors.black.withValues(alpha: 0.4),
                            child: const Center(
                              child: Icon(
                                MingCute.play_circle_fill,
                                color: Colors.white,
                                size: 42,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // ─── 2. TEXT SECTION ───
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.album.title,
                      maxLines: 1, // Single line for perfect grid alignment
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color:
                            Default_Theme.primaryColor1.withValues(alpha: 0.9),
                        letterSpacing: -0.2,
                      ).merge(Default_Theme.secondoryTextStyleMedium),
                    ),
                    const SizedBox(height: 2),
                    // Logic to handle Artist text overflow gracefully
                    SizedBox(
                      height: 18,
                      child: ArtistListLinks(
                        artists: widget.album.artists,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Default_Theme.primaryColor1
                              .withValues(alpha: 0.5),
                          fontWeight: FontWeight.w500,
                        ).merge(Default_Theme.secondoryTextStyle),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
