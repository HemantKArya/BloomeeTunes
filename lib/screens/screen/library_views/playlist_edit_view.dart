// Page for editing and reordering playlist items.
import 'dart:ui';
import 'package:Bloomee/core/models/exported.dart';
import 'package:Bloomee/screens/screen/library_views/cubit/current_playlist_cubit.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:Bloomee/screens/widgets/song_tile.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';

class PlaylistEditView extends StatefulWidget {
  const PlaylistEditView({super.key});

  @override
  State<PlaylistEditView> createState() => _PlaylistEditViewState();
}

class _PlaylistEditViewState extends State<PlaylistEditView> {
  // Working copy of the track list. Updated by the child on every drag.
  List<Track> _localTracks = [];
  // Seeded once from the cubit state on first loaded data.
  bool _initialized = false;

  void _onTracksReordered(List<Track> newOrder) {
    setState(() => _localTracks = newOrder);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CurrentPlaylistCubit, CurrentPlaylistState>(
      builder: (context, state) {
        // Seed local list once from cubit state.
        if (!_initialized && state.playlist.tracks.isNotEmpty) {
          _localTracks = List<Track>.from(state.playlist.tracks);
          _initialized = true;
        }

        final bool isLoading = !_initialized &&
            (state is CurrentPlaylistInitial ||
                state is CurrentPlaylistLoading);

        if (isLoading) {
          return const Scaffold(
            backgroundColor: Default_Theme.themeColor,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: Default_Theme.themeColor,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                centerTitle: true,
                surfaceTintColor: Default_Theme.themeColor,
                foregroundColor: Default_Theme.primaryColor1,
                backgroundColor: Default_Theme.themeColor,
                title: Text(
                  'Edit Playlist',
                  style: Default_Theme.secondoryTextStyleMedium.merge(
                    const TextStyle(
                        fontSize: 16, color: Default_Theme.primaryColor1),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: IconButton(
                      onPressed: () {
                        if (_localTracks.isNotEmpty) {
                          context
                              .read<CurrentPlaylistCubit>()
                              .updatePlaylist(_localTracks);
                          SnackbarService.showMessage('Playlist Updated!');
                        }
                        Navigator.of(context).pop();
                      },
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      icon: const Icon(
                        MingCute.check_fill,
                        color: Default_Theme.accentColor2,
                      ),
                    ),
                  ),
                ],
              ),
              // Hint bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.035),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color:
                            Default_Theme.accentColor2.withValues(alpha: 0.22),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Default_Theme.accentColor2
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.drag_indicator_rounded,
                            size: 16,
                            color: Default_Theme.accentColor2
                                .withValues(alpha: 0.95),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Hold the handle to reorder tracks',
                            style: Default_Theme.secondoryTextStyleMedium.merge(
                              TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Default_Theme.primaryColor1
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Reorderable list
              SliverPlaylistItems(
                initialTracks: _localTracks,
                onTracksReordered: _onTracksReordered,
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                    height: MediaQuery.of(context).padding.bottom + 24),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Internal stateful list widget that manages the drag order locally
/// and reports the new order to the parent via [onTracksReordered].
class SliverPlaylistItems extends StatefulWidget {
  const SliverPlaylistItems({
    super.key,
    required this.initialTracks,
    this.onTracksReordered,
  });

  final List<Track> initialTracks;
  final ValueChanged<List<Track>>? onTracksReordered;

  @override
  State<SliverPlaylistItems> createState() => _SliverPlaylistItemsState();
}

class _SliverPlaylistItemsState extends State<SliverPlaylistItems> {
  late List<Track> _tracks;

  @override
  void initState() {
    super.initState();
    _tracks = List<Track>.from(widget.initialTracks);
  }

  @override
  void didUpdateWidget(SliverPlaylistItems oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-sync when the parent's list length changes (external add/remove).
    if (widget.initialTracks.length != _tracks.length) {
      setState(() => _tracks = List<Track>.from(widget.initialTracks));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      sliver: SliverReorderableList(
        itemCount: _tracks.length,
        itemExtent: 70,
        proxyDecorator: _proxyDecorator,
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (oldIndex < newIndex) newIndex -= 1;
            final Track item = _tracks.removeAt(oldIndex);
            _tracks.insert(newIndex, item);
          });
          widget.onTracksReordered?.call(List<Track>.from(_tracks));
        },
        itemBuilder: (context, index) {
          final track = _tracks[index];
          return KeyedSubtree(
            key: ValueKey(track.id),
            child: Stack(
              children: [
                IgnorePointer(
                  ignoring: true,
                  child: SongCardWidget(
                    song: track,
                    showOptions: false,
                    trailing: const SizedBox(width: 44),
                  ),
                ),
                Positioned(
                  right: 10,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: ReorderableDragStartListener(
                      index: index,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Default_Theme.accentColor2
                              .withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Default_Theme.accentColor2
                                .withValues(alpha: 0.20),
                          ),
                        ),
                        child: Icon(
                          Icons.drag_handle_rounded,
                          color: Default_Theme.accentColor2
                              .withValues(alpha: 0.88),
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

Widget _proxyDecorator(Widget child, int index, Animation<double> animation) {
  return AnimatedBuilder(
    animation: animation,
    builder: (BuildContext context, Widget? child) {
      final double animValue = Curves.easeInOut.transform(animation.value);
      final double elevation = lerpDouble(0, 6, animValue)!;
      return Material(
        elevation: elevation,
        color: Default_Theme.themeColor,
        borderRadius: BorderRadius.circular(12),
        shadowColor: Default_Theme.accentColor2.withValues(alpha: 0.25),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Default_Theme.accentColor2.withValues(alpha: 0.20),
            ),
          ),
          child: child,
        ),
      );
    },
    child: child,
  );
}
