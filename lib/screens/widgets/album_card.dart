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
      constraints: const BoxConstraints(maxWidth: 168),
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
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
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

              const SizedBox(height: 8),

              // ─── 2. TEXT SECTION ───
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: SizedBox(
                  height: 44,
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        widget.album.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Default_Theme.primaryColor1
                              .withValues(alpha: 0.9),
                          letterSpacing: -0.2,
                          height: 1.15,
                        ).merge(Default_Theme.secondoryTextStyleMedium),
                      ),
                      const SizedBox(height: 2),
                      SizedBox(
                        height: 12,
                        child: ArtistListLinks(
                          artists: widget.album.artists,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10.5,
                            color: Default_Theme.primaryColor1
                                .withValues(alpha: 0.5),
                            fontWeight: FontWeight.w500,
                          ).merge(Default_Theme.secondoryTextStyle),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
