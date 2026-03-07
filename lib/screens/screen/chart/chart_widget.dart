// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer' as dev;
import 'package:Bloomee/core/di/service_locator.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
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

class _ChartWidgetState extends State<ChartWidget> {
  late final Future<String?> _resolvedThumbnailFuture;

  @override
  void initState() {
    super.initState();
    _resolvedThumbnailFuture = _resolveThumbnailUrl();
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
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: isMobile || isTablet
            ? MediaQuery.of(context).size.height * 0.35
            : MediaQuery.of(context).size.height * 0.25,
        width: isMobile
            ? MediaQuery.of(context).size.height * 0.3
            : isTablet
                ? MediaQuery.of(context).size.width * 0.3
                : MediaQuery.of(context).size.width * 0.25,
        child: FutureBuilder<String?>(
          future: _resolvedThumbnailFuture,
          builder: (context, snapshot) {
            final thumbnailUrl = snapshot.data;
            return Stack(
              fit: StackFit.expand,
              children: [
                // Cover image or placeholder
                if (thumbnailUrl != null && thumbnailUrl.isNotEmpty)
                  LoadImageCached(
                    imageUrl: thumbnailUrl,
                    fallbackUrl: thumbnailUrl,
                    fit: BoxFit.cover,
                  )
                else
                  const _ChartPlaceholder(),

                // Bottom gradient for text readability
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.25),
                          Colors.black.withValues(alpha: 0.8),
                        ],
                        stops: const [0.3, 0.6, 1.0],
                      ),
                    ),
                  ),
                ),

                // Chart title
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: 14,
                  child: Text(
                    widget.chart.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Default_Theme.secondoryTextStyleMedium.merge(
                      const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ChartPlaceholder extends StatelessWidget {
  const _ChartPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Default_Theme.primaryColor2.withValues(alpha: 0.08),
      child: Center(
        child: Icon(
          MingCute.music_2_fill,
          size: 48,
          color: Colors.white.withValues(alpha: 0.15),
        ),
      ),
    );
  }
}
