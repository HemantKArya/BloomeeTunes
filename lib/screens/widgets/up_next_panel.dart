import 'dart:math' as math;
import 'dart:ui';
import 'package:Bloomee/blocs/media_player/bloomee_player_cubit.dart';
import 'package:Bloomee/blocs/settings_cubit/cubit/settings_cubit.dart';
import 'package:Bloomee/core/adapters/track_adapter.dart';
import 'package:Bloomee/screens/widgets/toogle_btn.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'song_tile.dart';
import 'more_bottom_sheet.dart';

class _UpNextStyles {
  static final headerTextStyle = Default_Theme.secondoryTextStyleMedium.merge(
    TextStyle(
        color: Default_Theme.primaryColor2.withValues(alpha: 0.9),
        fontSize: 14,
        fontWeight: FontWeight.w600),
  );
  static final queueCountStyle = Default_Theme.secondoryTextStyleMedium.merge(
    TextStyle(
        color: Colors.white.withValues(alpha: 0.7),
        fontSize: 13,
        fontWeight: FontWeight.w500),
  );
  static const panelBorderRadius =
      BorderRadius.vertical(top: Radius.circular(25));
  static const desktopBorderRadius = BorderRadius.all(Radius.circular(25));
}

class UpNextPanelController {
  VoidCallback? _toggleListener;
  VoidCallback? _collapseListener;
  bool Function()? _isExpandedGetter;

  bool get isExpanded => _isExpandedGetter?.call() ?? false;

  void toggle() => _toggleListener?.call();

  bool collapse() {
    if (isExpanded) {
      _collapseListener?.call();
      return true;
    }
    return false;
  }

  void _attach(
      {required VoidCallback toggle,
      required VoidCallback collapse,
      required bool Function() isExpanded}) {
    _toggleListener = toggle;
    _collapseListener = collapse;
    _isExpandedGetter = isExpanded;
  }

  void _detach() {
    _toggleListener = null;
    _collapseListener = null;
    _isExpandedGetter = null;
  }
}

class UpNextPanel extends StatefulWidget {
  const UpNextPanel({
    super.key,
    required this.peekHeight,
    required this.parentHeight,
    this.isDesktopMode = false,
    this.startExpanded = false,
    this.canBeHidden = false,
    this.controller,
  });

  final double peekHeight;
  final double parentHeight;
  final bool isDesktopMode;
  final bool startExpanded;
  final bool canBeHidden;
  final UpNextPanelController? controller;

  @override
  State<UpNextPanel> createState() => _UpNextPanelState();
}

class _UpNextPanelState extends State<UpNextPanel> {
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  late bool _isExpanded;
  double _minSheetSize = 0.1;
  double _maxSheetSize = 0.9;
  late final BloomeePlayerCubit _playerCubit;

  @override
  void initState() {
    super.initState();
    _playerCubit = context.read<BloomeePlayerCubit>();
    _isExpanded = widget.startExpanded;

    widget.controller?._attach(
      toggle: _toggleSheet,
      collapse: _collapseSheet,
      isExpanded: () => _isExpanded,
    );

    _sheetController.addListener(_updateExpandedState);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateSheetSizes();
  }

  @override
  void didUpdateWidget(UpNextPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.parentHeight != widget.parentHeight ||
        oldWidget.peekHeight != widget.peekHeight) {
      _updateSheetSizes();
    }
  }

  void _updateSheetSizes() {
    final minSize = widget.canBeHidden
        ? 0.0
        : (widget.parentHeight > 0
            ? (widget.peekHeight / widget.parentHeight)
            : 0.1);

    final safeTopOffset = MediaQuery.of(context).padding.top + 8.0;
    final maxSize = widget.parentHeight > 0
        ? ((widget.parentHeight - safeTopOffset) / widget.parentHeight)
            .clamp(minSize + 0.1, math.max<double>(0.98, minSize + 0.15))
        : 0.95;

    if (minSize != _minSheetSize || maxSize != _maxSheetSize) {
      setState(() {
        _minSheetSize = minSize;
        _maxSheetSize = maxSize;
      });
    }
  }

  void _updateExpandedState() {
    final nowExpanded = _sheetController.size > _minSheetSize + 0.1;
    if (nowExpanded != _isExpanded) {
      setState(() => _isExpanded = nowExpanded);
    }
  }

  @override
  void dispose() {
    widget.controller?._detach();
    _sheetController.removeListener(_updateExpandedState);
    _sheetController.dispose();
    super.dispose();
  }

  void _toggleSheet() {
    if (_sheetController.size < _minSheetSize + 0.1) {
      _sheetController.animateTo(_maxSheetSize,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutExpo);
    } else {
      _collapseSheet();
    }
  }

  void _collapseSheet() {
    _sheetController.animateTo(_minSheetSize,
        duration: const Duration(milliseconds: 300), curve: Curves.easeOutExpo);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isDesktopMode) {
      return _DesktopLayout(playerCubit: _playerCubit);
    }

    return MediaQuery.removeViewInsets(
      context: context,
      removeBottom: true,
      child: DraggableScrollableSheet(
        controller: _sheetController,
        initialChildSize: widget.startExpanded ? _maxSheetSize : _minSheetSize,
        minChildSize: _minSheetSize,
        maxChildSize: _maxSheetSize,
        snap: true,
        snapAnimationDuration: const Duration(milliseconds: 250),
        builder: (context, scrollController) {
          return _PanelContent(
            peekHeight: widget.peekHeight,
            isExpanded: _isExpanded,
            onHeaderTap: _toggleSheet,
            scrollController: scrollController,
            playerCubit: _playerCubit,
            sheetController: _sheetController,
            minSize: _minSheetSize,
            maxSize: _maxSheetSize,
          );
        },
      ),
    );
  }
}

class _PanelContent extends StatelessWidget {
  final double peekHeight;
  final bool isExpanded;
  final VoidCallback onHeaderTap;
  final ScrollController scrollController;
  final BloomeePlayerCubit playerCubit;
  final DraggableScrollableController sheetController;
  final double minSize;
  final double maxSize;

  const _PanelContent({
    required this.peekHeight,
    required this.isExpanded,
    required this.onHeaderTap,
    required this.scrollController,
    required this.playerCubit,
    required this.sheetController,
    required this.minSize,
    required this.maxSize,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Material(
        color: Colors.transparent,
        child: ClipRRect(
          borderRadius: _UpNextStyles.panelBorderRadius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.85),
                borderRadius: _UpNextStyles.panelBorderRadius,
                border: Border(
                    top: BorderSide(
                        color: Colors.white.withValues(alpha: 0.1),
                        width: 0.5)),
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: onHeaderTap,
                    behavior: HitTestBehavior.opaque,
                    child: SizedBox(
                      height: peekHeight - 0.5,
                      child: _CompactHeader(isExpanded: isExpanded),
                    ),
                  ),
                  Expanded(
                    child: AnimatedBuilder(
                      animation: sheetController,
                      builder: (context, child) {
                        final currentSize = sheetController.isAttached
                            ? sheetController.size
                            : minSize;
                        final progress =
                            ((currentSize - minSize) / (maxSize - minSize))
                                .clamp(0.0, 1.0);
                        final opacity = progress < 0.15
                            ? 0.0
                            : ((progress - 0.15) / 0.35).clamp(0.0, 1.0);

                        return IgnorePointer(
                          ignoring: opacity == 0.0,
                          child: Opacity(opacity: opacity, child: child),
                        );
                      },
                      child: CustomScrollView(
                        controller: scrollController,
                        physics: const ClampingScrollPhysics(),
                        slivers: [
                          SliverToBoxAdapter(
                              child: _QueueInfoRow(playerCubit: playerCubit)),
                          _SongListSliver(
                              playerCubit: playerCubit,
                              scrollController: scrollController),
                          SliverToBoxAdapter(
                              child: SizedBox(
                                  height:
                                      MediaQuery.of(context).padding.bottom +
                                          20)),
                        ],
                      ),
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

class _CompactHeader extends StatelessWidget {
  final bool isExpanded;
  const _CompactHeader({required this.isExpanded});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.queue_music_rounded,
              color: Default_Theme.primaryColor2.withValues(alpha: 0.8),
              size: 18),
          const SizedBox(width: 8),
          Text("Up Next", style: _UpNextStyles.headerTextStyle),
          const SizedBox(width: 6),
          AnimatedRotation(
            turns: isExpanded ? 0.5 : 0,
            duration: const Duration(milliseconds: 200),
            child: Icon(Icons.keyboard_arrow_up_rounded,
                color: Default_Theme.primaryColor2.withValues(alpha: 0.5),
                size: 20),
          ),
        ],
      ),
    );
  }
}

class _QueueInfoRow extends StatelessWidget {
  final BloomeePlayerCubit playerCubit;
  const _QueueInfoRow({required this.playerCubit});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          StreamBuilder<List<MediaItem>>(
            stream: playerCubit.bloomeePlayer.queue,
            builder: (context, snapshot) {
              return Text("${snapshot.data?.length ?? 0} Items in Queue",
                  style: _UpNextStyles.queueCountStyle);
            },
          ),
          BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, state) {
              return ToggleButton(
                label: "Auto Play",
                initialState: state.autoPlay,
                onChanged: (val) async {
                  await context.read<SettingsCubit>().setAutoPlay(val);
                  if (val) {
                    playerCubit.bloomeePlayer.check4RelatedSongs();
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DesktopLayout extends StatelessWidget {
  final BloomeePlayerCubit playerCubit;
  const _DesktopLayout({required this.playerCubit});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: _UpNextStyles.desktopBorderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1), width: 0.5),
            ),
            child: Column(
              children: [
                const SizedBox(height: 16),
                const _CompactHeader(isExpanded: true),
                _QueueInfoRow(playerCubit: playerCubit),
                Expanded(child: _DesktopSongList(playerCubit: playerCubit)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DesktopSongList extends StatefulWidget {
  final BloomeePlayerCubit playerCubit;
  const _DesktopSongList({required this.playerCubit});

  @override
  State<_DesktopSongList> createState() => _DesktopSongListState();
}

class _DesktopSongListState extends State<_DesktopSongList> {
  final ScrollController _scrollController = ScrollController();
  String? _lastPlayingId;
  static const double _itemHeight = 70.0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCurrentSong(List<MediaItem> queue, String currentId) {
    final index = queue.indexWhere((item) => item.id == currentId);
    if (index == -1) {
      return;
    }

    // FIX: Subtract 1.5 item heights so the current song sits cleanly
    // in view with the previous song above it, instead of jamming into the top header.
    final targetOffset =
        math.max(0.0, (index * _itemHeight) - (_itemHeight * 1.5));
    final clampedOffset =
        targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent);

    _scrollController.animateTo(clampedOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MediaItem>>(
      stream: widget.playerCubit.bloomeePlayer.queue,
      builder: (context, queueSnapshot) {
        if (!queueSnapshot.hasData) {
          return const Center(
              child: CircularProgressIndicator(
                  color: Default_Theme.primaryColor2));
        }
        final queue = queueSnapshot.data!;

        return StreamBuilder<MediaItem?>(
          stream: widget.playerCubit.bloomeePlayer.mediaItem,
          builder: (context, mediaSnapshot) {
            final currentId = mediaSnapshot.data?.id;
            if (currentId != null && currentId != _lastPlayingId) {
              _lastPlayingId = currentId;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_scrollController.hasClients) {
                  _scrollToCurrentSong(queue, currentId);
                }
              });
            }

            // Defensive deduplication: identical IDs would assign the same
            // GlobalKey to two ReorderableListView items, causing Flutter's
            // semantics traversal to recurse infinitely.
            final seenIds = <String>{};
            final uniqueQueue =
                queue.where((m) => seenIds.add(m.id)).toList(growable: false);

            return ReorderableListView.builder(
              scrollController: _scrollController,
              physics: const BouncingScrollPhysics(),
              itemCount: uniqueQueue.length,
              onReorder: widget.playerCubit.bloomeePlayer.moveQueueItem,
              buildDefaultDragHandles: false,
              itemBuilder: (context, index) {
                return _QueueItem(
                  key: ValueKey('desktop_${uniqueQueue[index].id}'),
                  mediaItem: uniqueQueue[index],
                  index: index,
                  playerCubit: widget.playerCubit,
                  isDesktop: true,
                );
              },
            );
          },
        );
      },
    );
  }
}

class _SongListSliver extends StatefulWidget {
  final BloomeePlayerCubit playerCubit;
  final ScrollController scrollController;
  const _SongListSliver(
      {required this.playerCubit, required this.scrollController});

  @override
  State<_SongListSliver> createState() => _SongListSliverState();
}

class _SongListSliverState extends State<_SongListSliver> {
  String? _lastPlayingId;
  static const double _itemHeight = 70.0;
  static const double _headerOffset = 60.0;

  void _scrollToCurrentSong(List<MediaItem> queue, String currentId) {
    if (!widget.scrollController.hasClients) {
      return;
    }
    final index = queue.indexWhere((item) => item.id == currentId);
    if (index == -1) {
      return;
    }

    // FIX: Subtract 1.5 item heights so the current song sits cleanly
    // in view with the previous song above it, instead of jamming into the top header.
    final targetOffset = math.max(
        0.0, _headerOffset + (index * _itemHeight) - (_itemHeight * 1.5));
    final clampedOffset = targetOffset.clamp(
        0.0, widget.scrollController.position.maxScrollExtent);

    widget.scrollController.animateTo(clampedOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MediaItem>>(
      stream: widget.playerCubit.bloomeePlayer.queue,
      builder: (context, queueSnapshot) {
        if (!queueSnapshot.hasData) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }
        final queue = queueSnapshot.data!;

        return StreamBuilder<MediaItem?>(
          stream: widget.playerCubit.bloomeePlayer.mediaItem,
          builder: (context, mediaSnapshot) {
            final currentId = mediaSnapshot.data?.id;
            if (currentId != null && currentId != _lastPlayingId) {
              _lastPlayingId = currentId;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollToCurrentSong(queue, currentId);
              });
            }

            // Defensive deduplication — same reason as the desktop list above.
            final seenIds = <String>{};
            final uniqueQueue =
                queue.where((m) => seenIds.add(m.id)).toList(growable: false);

            return SliverReorderableList(
              itemCount: uniqueQueue.length,
              onReorder: widget.playerCubit.bloomeePlayer.moveQueueItem,
              itemBuilder: (context, index) {
                return _QueueItem(
                  key: ValueKey('mobile_${uniqueQueue[index].id}'),
                  mediaItem: uniqueQueue[index],
                  index: index,
                  playerCubit: widget.playerCubit,
                  isDesktop: false,
                );
              },
            );
          },
        );
      },
    );
  }
}

class _QueueItem extends StatelessWidget {
  final MediaItem mediaItem;
  final int index;
  final BloomeePlayerCubit playerCubit;
  final bool isDesktop;

  const _QueueItem({
    super.key,
    required this.mediaItem,
    required this.index,
    required this.playerCubit,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    final songModel = mediaItemToTrack(mediaItem);

    Widget content = Dismissible(
      key: ValueKey('dismiss_${mediaItem.id}'),
      direction: DismissDirection.startToEnd,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        color: Colors.red.withValues(alpha: 0.8),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => playerCubit.bloomeePlayer.removeQueueItemAt(index),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          // FIX: Removed the massive 24px Android padding gap. Just a slim 8px edge.
          padding: EdgeInsets.only(right: isDesktop ? 8.0 : 0.0),
          child: Row(
            children: [
              Expanded(
                child: SongCardWidget(
                  showOptions: true,
                  onTap: () => playerCubit.bloomeePlayer.skipToQueueItem(index),
                  onOptionsTap: () => showMoreBottomSheet(
                    context,
                    songModel,
                    showAddToQueue: false,
                    showPlayNext: false,
                    showSinglePlay: true,
                  ),
                  song: songModel,
                ),
              ),
              if (isDesktop)
                ReorderableDragStartListener(
                  index: index,
                  child: Padding(
                    // FIX: Slimmer horizontal padding limits the width entirely while maintaining grabability
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    child: Icon(Icons.drag_handle_rounded,
                        color:
                            Default_Theme.primaryColor2.withValues(alpha: 0.4),
                        size: 20),
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    return isDesktop
        ? content
        : ReorderableDelayedDragStartListener(index: index, child: content);
  }
}
