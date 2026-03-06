import 'package:Bloomee/core/models/exported.dart';
import 'package:Bloomee/screens/screen/common_views/playlist_view.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/utils/load_image.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

class PlaylistCard extends StatefulWidget {
  final PlaylistSummary playlist;
  final String pluginId;
  final double cardWidth;

  const PlaylistCard({
    super.key,
    required this.playlist,
    required this.pluginId,
    this.cardWidth = 180,
  });

  @override
  State<PlaylistCard> createState() => _PlaylistCardState();
}

class _PlaylistCardState extends State<PlaylistCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.cardWidth,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OnlPlaylistView(
                playlist: widget.playlist,
                pluginId: widget.pluginId,
              ),
            ),
          );
        },
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovering = true),
          onExit: (_) => setState(() => _isHovering = false),
          cursor: SystemMouseCursors.click,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildThumbnail(),
              const SizedBox(height: 8),
              _buildTitle(),
              if (widget.playlist.owner != null &&
                  widget.playlist.owner!.isNotEmpty)
                _buildOwner(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    return Hero(
      tag: '${widget.pluginId}_playlist_${widget.playlist.id}',
      child: AspectRatio(
        aspectRatio: 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                color: Default_Theme.primaryColor2.withValues(alpha: 0.04),
              ),
              LoadImageCached(
                imageUrl: widget.playlist.thumbnail.url,
                fallbackUrl: widget.playlist.thumbnail.url,
                fit: BoxFit.fitWidth,
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                color: _isHovering
                    ? Colors.black.withValues(alpha: 0.45)
                    : Colors.transparent,
                child: Center(
                  child: AnimatedOpacity(
                    opacity: _isHovering ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      MingCute.play_circle_line,
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
    );
  }

  Widget _buildTitle() {
    return Text(
      widget.playlist.title,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: Default_Theme.secondoryTextStyleMedium.merge(
        TextStyle(
          fontSize: 13,
          color: Default_Theme.primaryColor1.withValues(alpha: 0.9),
        ),
      ),
    );
  }

  Widget _buildOwner() {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Text(
        widget.playlist.owner!,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: Default_Theme.secondoryTextStyleMedium.merge(
          TextStyle(
            fontSize: 11,
            color: Default_Theme.primaryColor1.withValues(alpha: 0.55),
          ),
        ),
      ),
    );
  }
}
