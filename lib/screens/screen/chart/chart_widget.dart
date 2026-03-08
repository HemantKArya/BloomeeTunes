// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/src/rust/api/plugin/models.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:Bloomee/utils/load_image.dart';
import 'package:responsive_framework/responsive_framework.dart';

class ChartWidget extends StatelessWidget {
  final ChartSummary chart;
  final String pluginId;

  const ChartWidget({
    super.key,
    required this.chart,
    required this.pluginId,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;

    final artwork = chart.thumbnail;
    final thumbnailUrl = artwork?.urlHigh ?? artwork?.url ?? artwork?.urlLow;

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
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (thumbnailUrl != null && thumbnailUrl.isNotEmpty)
              LoadImageCached(
                imageUrl: thumbnailUrl,
                fallbackUrl: artwork?.url ?? thumbnailUrl,
                fit: BoxFit.cover,
              )
            else
              const _ChartPlaceholder(),
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
            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: Text(
                chart.title,
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
