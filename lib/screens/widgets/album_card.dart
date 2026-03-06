import 'package:Bloomee/core/models/exported.dart';
import 'package:Bloomee/screens/screen/common_views/album_view.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/screens/widgets/media_metadata_links.dart';
import 'package:Bloomee/utils/imgurl_formator.dart';
import 'package:Bloomee/utils/load_image.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:responsive_framework/responsive_framework.dart';

class AlbumCard extends StatelessWidget {
  final AlbumSummary album;
  final String pluginId;
  final ValueNotifier<bool> hovering = ValueNotifier(false);

  AlbumCard({super.key, required this.album, required this.pluginId});

  void setHovering(bool isHovering) {
    hovering.value = isHovering;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: LayoutBuilder(builder: (context, constraints) {
        return SizedBox(
          width: ResponsiveBreakpoints.of(context).isMobile
              ? constraints.maxWidth * 0.9
              : 220,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AlbumView(album: album, pluginId: pluginId),
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
                    SizedBox.square(
                      child: Hero(
                        tag: '${pluginId}_album_${album.id}',
                        child: Stack(
                          children: [
                            LoadImageCached(
                              imageUrl: formatImgURL(
                                album.thumbnail?.url ?? '',
                                ImageQuality.medium,
                              ),
                              fallbackUrl: album.thumbnail?.url,
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
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        album.title,
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
                    ArtistListLinks(
                      artists: album.artists,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: Default_Theme.secondoryTextStyleMedium.merge(
                        TextStyle(
                          fontSize: 12,
                          color: Default_Theme.primaryColor1
                              .withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
