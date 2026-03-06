import 'package:Bloomee/core/models/exported.dart';
import 'package:Bloomee/screens/screen/common_views/album_view.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/screens/widgets/media_metadata_links.dart';
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
  late final String _heroTag;

  @override
  void initState() {
    super.initState();
    _heroTag =
        '${widget.pluginId}_album_${widget.album.id}_${identityHashCode(this)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 180),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AlbumView(
                album: widget.album,
                pluginId: widget.pluginId,
                heroTag: _heroTag,
              ),
            ),
          );
        },
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovering = true),
          onExit: (_) => setState(() => _isHovering = false),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            // ─── CHANGED: center children horizontally ───
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ─── 1. SQUARE IMAGE CONTAINER ───
              AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
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
                        Hero(
                          tag: _heroTag,
                          child: LoadImageCached(
                            imageUrl: widget.album.thumbnail!.urlHigh ??
                                widget.album.thumbnail!.url,
                            fallbackUrl: widget.album.thumbnail?.url,
                            fit: BoxFit.contain,
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
              // ─── CHANGED: removed Padding with horizontal symmetry,
              //     using a fixed-height container to prevent bleed,
              //     all text centered ───
              SizedBox(
                // Fixed height = 2-line title + gap + 1-line artist
                // 14px font * 1.3 lineHeight * 2 lines ≈ 36 + 2 gap + 18 = 56
                height: 56,
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  // ─── CHANGED: center text horizontally ───
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ─── CHANGED: maxLines 1 → 2, centered ───
                    Text(
                      widget.album.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color:
                            Default_Theme.primaryColor1.withValues(alpha: 0.9),
                        letterSpacing: -0.2,
                        // ─── ADDED: explicit line height so 2 lines
                        //     are predictable and don't overflow ───
                        height: 1.25,
                      ).merge(Default_Theme.secondoryTextStyleMedium),
                    ),
                    const SizedBox(height: 2),
                    // ─── Artist row — fixed height, centered ───
                    SizedBox(
                      height: 18,
                      child: ArtistListLinks(
                        artists: widget.album.artists,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        // ─── CHANGED: centered ───
                        textAlign: TextAlign.center,
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
