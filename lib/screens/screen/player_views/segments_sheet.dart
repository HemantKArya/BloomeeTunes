import 'dart:developer';

import 'package:Bloomee/core/di/service_locator.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/l10n/app_localizations.dart';
import 'package:Bloomee/src/rust/api/plugin/commands.dart';
import 'package:Bloomee/src/rust/api/plugin/models.dart';
import 'package:Bloomee/src/rust/api/plugin/types.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

/// Shows a bottom sheet listing track segments/chapters.
///
/// Queries all loaded content resolver plugins for segments of the given track.
/// Each segment can be tapped to seek the player.
void showSegmentsSheet(
  BuildContext context, {
  required String trackId,
  required Duration trackDuration,
  required void Function(Duration position) onSeek,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF121212),
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => _SegmentsSheetBody(
      trackId: trackId,
      trackDuration: trackDuration,
      onSeek: onSeek,
    ),
  );
}

class _SegmentsSheetBody extends StatefulWidget {
  final String trackId;
  final Duration trackDuration;
  final void Function(Duration position) onSeek;

  const _SegmentsSheetBody({
    required this.trackId,
    required this.trackDuration,
    required this.onSeek,
  });

  @override
  State<_SegmentsSheetBody> createState() => _SegmentsSheetBodyState();
}

class _SegmentsSheetBodyState extends State<_SegmentsSheetBody> {
  List<TrackSegment>? _segments;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchSegments();
  }

  Future<void> _fetchSegments() async {
    final pluginService = ServiceLocator.pluginService;
    final loadedIds = pluginService.getLoadedPlugins().toSet();
    final availablePlugins = await pluginService.getAvailablePlugins();
    final resolvers = availablePlugins
        .where((plugin) =>
            plugin.pluginType == PluginType.contentResolver &&
            loadedIds.contains(plugin.manifest.id))
        .toList(growable: false);

    for (final plugin in resolvers) {
      try {
        final response = await pluginService.execute(
          pluginId: plugin.manifest.id,
          request: PluginRequest.contentResolver(
            ContentResolverCommand.getSegmentsForTrack(id: widget.trackId),
          ),
        );

        if (response is PluginResponse_Segments && response.field0.isNotEmpty) {
          if (mounted) {
            setState(() {
              _segments = response.field0;
              _loading = false;
            });
          }
          return;
        }
      } catch (e) {
        log("Segments fetch failed for ${plugin.manifest.id}: $e",
            name: "SegmentsSheet");
      }
    }

    if (mounted) {
      setState(() {
        _segments = [];
        _loading = false;
      });
    }
  }

  String _formatDuration(BigInt ms) {
    final d = Duration(milliseconds: ms.toInt());
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (d.inHours > 0) {
      return '${d.inHours}:$m:$s';
    }
    return '$m:$s';
  }

  IconData _segmentIcon(SegmentType type) {
    return switch (type) {
      SegmentType.intro => MingCute.play_circle_line,
      SegmentType.outro => MingCute.stop_circle_line,
      SegmentType.chapter => MingCute.book_2_line,
      SegmentType.sponsor => MingCute.announcement_line,
      SegmentType.selfPromo => MingCute.microphone_fill,
      SegmentType.interaction => MingCute.chat_1_line,
      SegmentType.musicOfftopic => MingCute.music_line,
      SegmentType.filler => MingCute.more_1_line,
      SegmentType.unknown => MingCute.hashtag_line,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Default_Theme.primaryColor1.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.segmentsSheetTitle,
                style: TextStyle(
                  color: Default_Theme.primaryColor1,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ).merge(Default_Theme.secondoryTextStyle),
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: Default_Theme.accentColor2))
                  : _segments == null || _segments!.isEmpty
                      ? Center(
                          child: Text(
                            l10n.segmentsSheetEmpty,
                            style: TextStyle(
                              color: Default_Theme.primaryColor1
                                  .withValues(alpha: 0.5),
                              fontSize: 14,
                            ).merge(Default_Theme.secondoryTextStyle),
                          ),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: _segments!.length,
                          itemBuilder: (context, index) {
                            final segment = _segments![index];
                            return ListTile(
                              leading: Icon(
                                _segmentIcon(segment.segmentType),
                                color: Default_Theme.primaryColor1,
                                size: 22,
                              ),
                              title: Text(
                                segment.title ?? l10n.segmentsSheetUntitled,
                                style: const TextStyle(
                                  color: Default_Theme.primaryColor1,
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: Text(
                                '${_formatDuration(segment.startMs)} – ${_formatDuration(segment.endMs)}',
                                style: TextStyle(
                                  color: Default_Theme.primaryColor1
                                      .withValues(alpha: 0.5),
                                  fontSize: 12,
                                ),
                              ),
                              onTap: () {
                                widget.onSeek(Duration(
                                    milliseconds: segment.startMs.toInt()));
                                Navigator.of(context).pop();
                              },
                            );
                          },
                        ),
            ),
          ],
        );
      },
    );
  }
}
