import 'package:Bloomee/core/models/exported.dart';
import 'package:Bloomee/screens/screen/common_views/playlist_view.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/utils/imgurl_formator.dart';
import 'package:Bloomee/utils/load_image.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:responsive_framework/responsive_framework.dart';

class PlaylistCard extends StatelessWidget {
  final PlaylistSummary playlist;
  final String pluginId;
  final ValueNotifier<bool> hovering = ValueNotifier(false);

  PlaylistCard({
    super.key,
    required this.playlist,
    required this.pluginId,
  });

  void setHovering(bool isHovering) {
    hovering.value = isHovering;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Padding(
        padding: const EdgeInsets.only(top: 10, left: 4, right: 4),
        child: SizedBox(
          width: ResponsiveBreakpoints.of(context).isMobile
              ? constraints.maxWidth * 0.45
              : 220,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OnlPlaylistView(
                    playlist: playlist,
                    pluginId: pluginId,
                  ),
                ),
              );
            },
            child: MouseRegion(
              onEnter: (_) => setHovering(true),
              onExit: (_) => setHovering(false),
              child: Card(
                color: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Hero(
                      tag: '${pluginId}_playlist_${playlist.id}',
                      child: Stack(
                        children: [
                          LoadImageCached(
                            imageUrl: formatImgURL(
                              playlist.thumbnail.url,
                              ImageQuality.medium,
                            ),
                            fallbackUrl: playlist.thumbnail.url,
                          ),
                          ValueListenableBuilder(
                            valueListenable: hovering,
                            builder: (context, child, value) {
                              return Positioned.fill(
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  color: hovering.value
                                      ? Colors.black.withValues(alpha: 0.5)
                                      : Colors.transparent,
                                  child: Center(
                                    child: AnimatedOpacity(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      opacity: hovering.value ? 1 : 0,
                                      child: const Icon(
                                        MingCute.play_circle_line,
                                        color: Colors.white,
                                        size: 50,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        playlist.title,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: Default_Theme.secondoryTextStyleMedium
                            .merge(TextStyle(
                          fontSize: 14,
                          color: Default_Theme.primaryColor1
                              .withValues(alpha: 0.9),
                        )),
                      ),
                    ),
                    if (playlist.owner != null && playlist.owner!.isNotEmpty)
                      Text(
                        playlist.owner!,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: Default_Theme.secondoryTextStyleMedium
                            .merge(TextStyle(
                          fontSize: 12,
                          color: Default_Theme.primaryColor1
                              .withValues(alpha: 0.7),
                        )),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
