import 'package:Bloomee/core/models/exported.dart';
import 'package:Bloomee/screens/screen/common_views/artist_view.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/utils/imgurl_formator.dart';
import 'package:Bloomee/utils/load_image.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

class ArtistCard extends StatelessWidget {
  final ArtistSummary artist;
  final String pluginId;
  final ValueNotifier<bool> hovering = ValueNotifier(false);

  ArtistCard({super.key, required this.artist, required this.pluginId});

  void setHovering(bool isHovering) {
    hovering.value = isHovering;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: SizedBox(
        width: 180,
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ArtistView(artist: artist, pluginId: pluginId),
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
                  ClipOval(
                    child: SizedBox.square(
                      dimension: 160,
                      child: Stack(
                        children: [
                          LoadImageCached(
                            imageUrl: formatImgURL(
                              artist.thumbnail?.url ?? '',
                              ImageQuality.medium,
                            ),
                            fallbackUrl: artist.thumbnail?.url,
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
                      artist.name,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: Default_Theme.secondoryTextStyleMedium
                          .merge(TextStyle(
                        fontSize: 14,
                        color:
                            Default_Theme.primaryColor1.withValues(alpha: 0.9),
                      )),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
