import 'dart:math' as math;

import 'package:Bloomee/blocs/media_player/bloomee_player_cubit.dart';
import 'package:Bloomee/core/models/exported.dart';
import 'package:Bloomee/core/models/media_playlist_model.dart';
import 'package:Bloomee/screens/screen/home/home_layout.dart';
import 'package:Bloomee/screens/widgets/more_bottom_sheet.dart';
import 'package:Bloomee/screens/widgets/song_tile.dart';
import 'package:audio_service/audio_service.dart' as audio;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';

/// Songs in columns of rows beside a vertical label (Recently, Last.fm
/// picks), in the original design. Only visible columns are built, and the
/// playing song is looked up once for the whole shelf.
class HomeTrackShelf extends StatefulWidget {
  final String label;
  final List<Track> tracks;
  final HomeMetrics metrics;

  /// Queue title when a song is played from here.
  final String queueTitle;

  /// Tapping the label, e.g. to open the full history.
  final VoidCallback? onLabelTap;
  final int rows;

  const HomeTrackShelf({
    super.key,
    required this.label,
    required this.tracks,
    required this.metrics,
    required this.queueTitle,
    this.onLabelTap,
    this.rows = 3,
  });

  static const rowHeight = 70.0;

  @override
  State<HomeTrackShelf> createState() => _HomeTrackShelfState();
}

class _HomeTrackShelfState extends State<HomeTrackShelf> {
  final _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tracks = widget.tracks;
    final columns = (tracks.length / widget.rows).ceil();
    final columnWidth = widget.metrics.trackColumnWidth;
    final player = context.read<BloomeePlayerCubit>().bloomeePlayer;

    return Column(
      children: [
        if (HomeMetrics.showsScrollButtons)
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(MingCute.left_line),
                  onPressed: () =>
                      scrollShelf(_controller, -1, step: columnWidth),
                ),
                IconButton(
                  icon: const Icon(MingCute.right_line),
                  onPressed: () =>
                      scrollShelf(_controller, 1, step: columnWidth),
                ),
              ],
            ),
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomeCategoryLabel(widget.label, onTap: widget.onLabelTap),
            Expanded(
              child: SizedBox(
                height: HomeTrackShelf.rowHeight * widget.rows + 10,
                child: StreamBuilder<audio.MediaItem?>(
                  stream: player.mediaItem,
                  initialData: player.mediaItem.valueOrNull,
                  builder: (context, snapshot) {
                    final playingId = snapshot.data?.id;
                    return ListView.builder(
                      controller: _controller,
                      scrollDirection: Axis.horizontal,
                      physics: _ColumnSnapPhysics(extent: columnWidth),
                      itemExtent: columnWidth,
                      itemCount: columns,
                      itemBuilder: (context, column) {
                        final start = column * widget.rows;
                        final end =
                            math.min(start + widget.rows, tracks.length);
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (var i = start; i < end; i++)
                              SongCardWidget(
                                key: ValueKey('${tracks[i].id}#$i'),
                                song: tracks[i],
                                isCurrentTrack: tracks[i].id == playingId,
                                onTap: () => _play(context, i),
                                onOptionsTap: () => showMoreBottomSheet(
                                    context, tracks[i],
                                    showSinglePlay: true),
                              ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _play(BuildContext context, int index) {
    context.read<BloomeePlayerCubit>().bloomeePlayer.loadPlaylist(
          Playlist(tracks: widget.tracks, title: widget.queueTitle),
          idx: index,
          doPlay: true,
        );
  }
}

/// Settles on whole columns after a swipe, so a column never rests half
/// cut at the left edge.
class _ColumnSnapPhysics extends ScrollPhysics {
  final double extent;
  const _ColumnSnapPhysics({required this.extent, super.parent});

  @override
  _ColumnSnapPhysics applyTo(ScrollPhysics? ancestor) =>
      _ColumnSnapPhysics(extent: extent, parent: buildParent(ancestor));

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    if ((velocity <= 0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0 && position.pixels >= position.maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }
    final tolerance = toleranceFor(position);
    var page = position.pixels / extent;
    if (velocity < -tolerance.velocity) {
      page -= 0.5;
    } else if (velocity > tolerance.velocity) {
      page += 0.5;
    }
    final target = (page.round() * extent)
        .clamp(position.minScrollExtent, position.maxScrollExtent);
    if (target == position.pixels) return null;
    return ScrollSpringSimulation(spring, position.pixels, target, velocity,
        tolerance: tolerance);
  }

  @override
  bool get allowImplicitScrolling => false;
}
