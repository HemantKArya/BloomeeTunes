// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math';
import 'dart:developer' as dev;
import 'package:Bloomee/core/di/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:Bloomee/core/models/exported.dart';
import 'package:Bloomee/plugins/utils/media_id.dart';
import 'package:Bloomee/src/rust/api/plugin/commands.dart';
import 'package:Bloomee/utils/load_image.dart';
import 'package:responsive_framework/responsive_framework.dart';

class ChartWidget extends StatefulWidget {
  final ChartSummary chart;
  final String pluginId;

  const ChartWidget({
    super.key,
    required this.chart,
    required this.pluginId,
  });

  @override
  State<ChartWidget> createState() => _ChartWidgetState();
}

class TextColorPair {
  final Color color1;
  final Color color2;
  TextColorPair({required this.color1, required this.color2});
}

final List<TextColorPair> colorPair = [
  TextColorPair(
    color1: const Color.fromARGB(255, 223, 63, 0).withValues(alpha: 0.9),
    color2: const Color.fromARGB(255, 205, 135, 23).withValues(alpha: 0.7),
  ),
  TextColorPair(
    color1: const Color.fromARGB(255, 255, 173, 50).withValues(alpha: 0.9),
    color2: const Color.fromARGB(255, 205, 132, 23).withValues(alpha: 0.7),
  ),
  TextColorPair(
    color1: const Color.fromARGB(255, 6, 85, 159).withValues(alpha: 0.9),
    color2: const Color.fromARGB(255, 28, 105, 220).withValues(alpha: 0.7),
  ),
  TextColorPair(
    color1: const Color.fromARGB(255, 222, 8, 125).withValues(alpha: 0.9),
    color2: const Color.fromARGB(255, 223, 38, 72).withValues(alpha: 0.7),
  ),
];

class _ChartWidgetState extends State<ChartWidget> {
  late final Widget cachedClipPath;
  late final Future<String?> _resolvedThumbnailFuture;
  final _random = Random();
  TextColorPair _color = colorPair[0];

  @override
  void initState() {
    _color = colorPair[_random.nextInt(colorPair.length)];
    cachedClipPath = ClipPath(
      clipper: ChartCardClipper(),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomRight,
            end: Alignment.topLeft,
            colors: [_color.color1, _color.color2],
          ),
        ),
      ),
    );
    _resolvedThumbnailFuture = _resolveThumbnailUrl();
    super.initState();
  }

  Future<String?> _resolveThumbnailUrl() async {
    final direct = widget.chart.thumbnail?.url;
    if (direct != null && direct.trim().isNotEmpty) {
      return direct;
    }

    if (widget.pluginId.trim().isEmpty) {
      return null;
    }

    try {
      final localChartId = localIdOf(widget.chart.id) ?? widget.chart.id;
      final response = await ServiceLocator.pluginService.execute(
        pluginId: widget.pluginId,
        request: PluginRequest.chartProvider(
          ChartProviderCommand.getChartDetails(id: localChartId),
        ),
      );

      String? resolved;
      response.when(
        chartDetails: (items) {
          if (items.isNotEmpty) {
            resolved = items.first.item.when(
              track: (track) => track.thumbnail.url,
              album: (album) => album.thumbnail?.url ?? '',
              artist: (artist) => artist.thumbnail?.url ?? '',
              playlist: (playlist) => playlist.thumbnail.url,
            );
          }
        },
        search: (_) {},
        albumDetails: (_) {},
        artistDetails: (_) {},
        playlistDetails: (_) {},
        streams: (_) {},
        moreTracks: (_) {},
        moreAlbums: (_) {},
        homeSections: (_) {},
        loadMoreItems: (_) {},
        charts: (_) {},
        ack: () {},
      );

      return (resolved != null && resolved!.trim().isNotEmpty)
          ? resolved
          : null;
    } catch (e, stackTrace) {
      dev.log(
        'Failed to resolve chart cover for ${widget.chart.id}',
        name: 'ChartWidget',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: SizedBox(
        height: ResponsiveBreakpoints.of(context).isMobile ||
                ResponsiveBreakpoints.of(context).isTablet
            ? MediaQuery.of(context).size.height * 0.35
            : MediaQuery.of(context).size.height * 0.25,
        width: ResponsiveBreakpoints.of(context).isMobile
            ? MediaQuery.of(context).size.height * 0.3
            : ResponsiveBreakpoints.of(context).isTablet
                ? MediaQuery.of(context).size.width * 0.3
                : MediaQuery.of(context).size.width * 0.25,
        child: LayoutBuilder(builder: (context, constraints) {
          return FutureBuilder<String?>(
            future: _resolvedThumbnailFuture,
            builder: (context, snapshot) {
              final thumbnailUrl = snapshot.data;
              return Stack(children: [
                if (thumbnailUrl != null && thumbnailUrl.isNotEmpty)
                  SizedBox(
                    height: constraints.maxHeight,
                    width: constraints.maxWidth,
                    child: LoadImageCached(
                      imageUrl: thumbnailUrl,
                      fallbackUrl: thumbnailUrl,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  const PlaceholderWidget(),
                Positioned(child: cachedClipPath),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: SizedBox(
                    width: constraints.maxWidth * 0.9,
                    height: MediaQuery.of(context).size.height * 0.09,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding:
                            const EdgeInsets.only(right: 10, bottom: 4, top: 4),
                        child: Text(
                          widget.chart.title,
                          maxLines: 2,
                          softWrap: true,
                          textAlign: TextAlign.right,
                          overflow: TextOverflow.ellipsis,
                          textWidthBasis: TextWidthBasis.parent,
                          style: const TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255),
                            fontSize: 28,
                            fontFamily: "Unageo",
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ]);
            },
          );
        }),
      ),
    );
  }
}

class PlaceholderWidget extends StatelessWidget {
  const PlaceholderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
        color: const Color.fromARGB(255, 52, 0, 147).withValues(alpha: 0.5),
      ),
      const Center(
        child: Icon(MingCute.music_2_fill, size: 80, color: Colors.white),
      ),
    ]);
  }
}

class ChartCardClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height * 0.75);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, size.height * 0.65);
    path.quadraticBezierTo(
        size.width * 0.6, size.height * 0.75, 0, size.height * 0.76);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
