// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:Bloomee/core/models/exported.dart';
import 'package:Bloomee/screens/screen/chart/chart_view.dart';
import 'package:Bloomee/utils/load_image.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:icons_plus/icons_plus.dart';

/// A rich list tile for chart items with rank, trend indicator, artwork,
/// metadata, stats, and action buttons.
class ChartListTile extends StatelessWidget {
  final ChartItem chartItem;
  final VoidCallback? onTap;
  final VoidCallback? onAddTap;
  final ChartResolveActionStatus playStatus;
  final ChartResolveActionStatus addStatus;

  const ChartListTile({
    super.key,
    required this.chartItem,
    this.onTap,
    this.onAddTap,
    this.playStatus = ChartResolveActionStatus.idle,
    this.addStatus = ChartResolveActionStatus.idle,
  });

  @override
  Widget build(BuildContext context) {
    final (title, subtitle, imgUrl) = extractItemInfo(chartItem);

    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = constraints.maxWidth < 600;

      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          hoverColor: Colors.white.withValues(alpha: 0.02),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 24.0,
              vertical: 12.0,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ── Rank number ──
                SizedBox(
                  width: isMobile ? 38 : 50,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      chartItem.rank.toString(),
                      style: TextStyle(
                        fontSize: isMobile ? 24 : 28,
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                        color: _rankColor(chartItem.rank),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // ── Trend tag ──
                SizedBox(
                  width: 26,
                  height: isMobile ? 54 : 64,
                  child: _buildTrendTag(chartItem.trend, chartItem.change),
                ),
                const SizedBox(width: 14),

                // ── Artwork ──
                Container(
                  height: isMobile ? 54 : 64,
                  width: isMobile ? 54 : 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFF111111),
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                      width: 1,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: imgUrl.isNotEmpty
                      ? LoadImageCached(
                          imageUrl: imgUrl,
                          fit: BoxFit.cover,
                        )
                      : const Center(
                          child: Icon(MingCute.music_2_line,
                              color: Colors.white24, size: 24)),
                ),
                const SizedBox(width: 16),

                // ── Title + Artist ──
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Default_Theme.secondoryTextStyleMedium.merge(
                          TextStyle(
                            fontSize: isMobile ? 15 : 17,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                            color: Colors.white.withValues(alpha: 0.95),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Default_Theme.secondoryTextStyle.merge(
                          TextStyle(
                            fontSize: isMobile ? 12 : 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Stats (desktop only) ──
                if (!isMobile) ...[
                  const SizedBox(width: 16),
                  _buildDataMatrix(),
                ],

                const SizedBox(width: 16),

                _ChartActionButton(
                  onPressed: onTap,
                  icon: MingCute.play_fill,
                  status: playStatus,
                  tooltip: 'Play',
                  backgroundColor: Colors.white.withValues(alpha: 0.04),
                  foregroundColor: Colors.white.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 10),
                _ChartActionButton(
                  onPressed: onAddTap,
                  icon: MingCute.add_line,
                  status: addStatus,
                  tooltip: 'Add to playlist',
                  backgroundColor: Colors.white.withValues(alpha: 0.04),
                  foregroundColor: Colors.white.withValues(alpha: 0.7),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Color _rankColor(int rank) {
    if (rank <= 3) return const Color(0xFFCD9A7B); // Bronze/gold
    if (rank <= 10) return const Color(0xFFB3B9C5); // Silver
    return const Color(0xFF555555);
  }

  Widget _buildTrendTag(Trend trend, int? change) {
    switch (trend) {
      case Trend.newEntry:
        return _buildRotatedBadge('NEW', Default_Theme.accentColor1light);
      case Trend.reEntry:
        return _buildRotatedBadge('RE', Default_Theme.accentColor1light);
      case Trend.same:
        return const Center(
          child: Text('—',
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.w300)),
        );
      case Trend.up:
        return _buildArrow('↑', change, Default_Theme.successColor);
      case Trend.down:
        return _buildArrow('↓', change, Default_Theme.accentColor2);
      case Trend.unknown:
        return const SizedBox();
    }
  }

  Widget _buildRotatedBadge(String text, Color color) {
    return RotatedBox(
      quarterTurns: -1,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            border: Border.all(color: color, width: 1),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 8,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildArrow(String glyph, int? change, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(glyph,
            style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w300,
                height: 1)),
        const SizedBox(height: 2),
        Text(change?.toString() ?? '-',
            style: TextStyle(
                color: color, fontSize: 10, fontWeight: FontWeight.w800)),
      ],
    );
  }

  Widget _buildDataMatrix() {
    return SizedBox(
      width: 75,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _statRow('PEAK', chartItem.peakRank?.toString() ?? '-'),
          const SizedBox(height: 4),
          _statRow('WKS', chartItem.weeksOnChart?.toString() ?? '-'),
        ],
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.3),
            )),
        Text(value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
              color: Colors.white.withValues(alpha: 0.85),
            )),
      ],
    );
  }
}

class _ChartActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final ChartResolveActionStatus status;
  final String tooltip;
  final Color backgroundColor;
  final Color foregroundColor;

  const _ChartActionButton({
    required this.onPressed,
    required this.icon,
    required this.status,
    required this.tooltip,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 240),
            switchInCurve: Curves.easeOutBack,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: RotationTransition(
                  turns: Tween<double>(begin: 0.9, end: 1.0).animate(animation),
                  child: child,
                ),
              );
            },
            child: _ChartActionVisual(
              key: ValueKey(status),
              status: status,
              icon: icon,
              foregroundColor: foregroundColor,
            ),
          ),
        ),
      ),
    );
  }
}

class _ChartActionVisual extends StatelessWidget {
  final ChartResolveActionStatus status;
  final IconData icon;
  final Color foregroundColor;

  const _ChartActionVisual({
    super.key,
    required this.status,
    required this.icon,
    required this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      ChartResolveActionStatus.resolving => SizedBox(
          width: 36,
          height: 36,
          child: Padding(
            padding: const EdgeInsets.all(9),
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              color: foregroundColor,
            ),
          ),
        ),
      ChartResolveActionStatus.success => Icon(
          Icons.check_rounded,
          key: const ValueKey('success'),
          size: 18,
          color: foregroundColor,
        ),
      ChartResolveActionStatus.idle => Icon(
          icon,
          key: const ValueKey('idle'),
          size: 18,
          color: foregroundColor,
        ),
    };
  }
}
