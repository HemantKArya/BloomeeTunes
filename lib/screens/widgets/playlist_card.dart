import 'package:Bloomee/model/playlist_onl_model.dart';
import 'package:Bloomee/screens/screen/common_views/playlist_view.dart';
import 'package:Bloomee/theme_data/default.dart';
import 'package:Bloomee/utils/load_Image.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:responsive_framework/responsive_framework.dart';

class PlaylistCard extends StatelessWidget {
  final PlaylistOnlModel playlist;
  final ValueNotifier<bool> hovering = ValueNotifier(false);
  PlaylistCard({
    super.key,
    required this.playlist,
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
                        )),
              );
            },
            child: Card(
              shadowColor: Colors.transparent,
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Hero(
                    tag: playlist.sourceId,
                    child: MouseRegion(
                      onEnter: (event) {
                        setHovering(true);
                      },
                      onExit: (event) {
                        setHovering(false);
                      },
                      child: Stack(
                        children: [
                          LoadImageCached(imageUrl: playlist.imageURL),
                          ValueListenableBuilder(
                            valueListenable: hovering,
                            builder: (context, child, value) {
                              return Positioned.fill(
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  color: hovering.value
                                      ? Colors.black.withOpacity(0.5)
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
                    padding: const EdgeInsets.only(
                      top: 8,
                    ),
                    child: Text(
                      playlist.name,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      style: Default_Theme.secondoryTextStyleMedium
                          .merge(const TextStyle(
                        fontSize: 14,
                        color: Default_Theme.primaryColor1,
                      )),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
