import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';
import 'package:Bloomee/blocs/mediaPlayer/bloomee_player_cubit.dart';
import 'package:Bloomee/blocs/settings_cubit/cubit/settings_cubit.dart';
import 'package:Bloomee/model/songModel.dart';
import 'package:Bloomee/screens/widgets/toogle_btn.dart';
import 'package:Bloomee/theme_data/default.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'song_tile.dart';
import 'more_bottom_sheet.dart';

// Cached styles to avoid repeated merges
class _UpNextStyles {
  static final headerTextStyle = Default_Theme.secondoryTextStyleMedium.merge(
    TextStyle(
      color: Default_Theme.primaryColor2.withValues(alpha: 0.9),
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
  );

  static final queueCountStyle = Default_Theme.secondoryTextStyleMedium.merge(
    TextStyle(
      color: Colors.white.withValues(alpha: 0.7),
      fontSize: 13,
      fontWeight: FontWeight.w500,
    ),
  );

  static final legacyHeaderStyle = Default_Theme.secondoryTextStyleMedium.merge(
    const TextStyle(
      color: Default_Theme.primaryColor2,
      fontSize: 17,
      fontWeight: FontWeight.bold,
    ),
  );

  static final legacyQueueStyle = Default_Theme.secondoryTextStyleMedium.merge(
    TextStyle(
      color: Default_Theme.primaryColor2.withValues(alpha: 0.5),
      fontSize: 14,
      fontWeight: FontWeight.bold,
    ),
  );

  static const panelBorderRadius =
      BorderRadius.vertical(top: Radius.circular(16));
  static const desktopBorderRadius = BorderRadius.all(Radius.circular(20));
}

class UpNextPanelController {
  VoidCallback? _toggleListener;

  void toggle() {
    _toggleListener?.call();
  }

  void _attach(VoidCallback toggle) {
    _toggleListener = toggle;
  }

  void _detach() {
    _toggleListener = null;
  }
}

/// A modern up-next panel similar to YouTube Music / Spotify
/// Uses DraggableScrollableSheet for smooth snap animations
/// Click on header to toggle open/close instantly
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

  /// The height of the collapsed panel (header only)
  final double peekHeight;

  /// The total height of the parent container
  final double parentHeight;

  /// Whether this is being used in desktop/expanded mode (side panel)
  final bool isDesktopMode;

  /// Whether to start with the panel expanded (for modal use)
  final bool startExpanded;

  /// Whether the panel can be fully hidden (min size 0)
  final bool canBeHidden;

  /// Controller to toggle the panel programmatically
  final UpNextPanelController? controller;

  @override
  State<UpNextPanel> createState() => _UpNextPanelState();
}

class _UpNextPanelState extends State<UpNextPanel> {
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  late bool _isExpanded;

  // Cache expensive calculations
  double _minSheetSize = 0.1;
  double _maxSheetSize = 0.9;
  late final BloomeePlayerCubit _playerCubit;

  @override
  void initState() {
    super.initState();
    _playerCubit = context.read<BloomeePlayerCubit>();
    widget.controller?._attach(_toggleSheet);
    _isExpanded = widget.startExpanded;

    // Listen to sheet position changes to update expanded state
    _sheetController.addListener(_onSheetPositionChanged);
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
    final minSize = _calculateMinSize();
    final maxSize = _calculateMaxSize();

    if (minSize != _minSheetSize || maxSize != _maxSheetSize) {
      setState(() {
        _minSheetSize = minSize;
        _maxSheetSize = maxSize;
      });
    }
  }

  double _calculateMinSize() {
    if (widget.canBeHidden) return 0.0;
    if (widget.parentHeight == 0) return 0.1;
    return (widget.peekHeight / widget.parentHeight).clamp(0.05, 0.85);
  }

  double _calculateMaxSize() {
    if (widget.parentHeight == 0) return 0.9;

    // Calculate safe top padding (StatusBar + AppBar)
    final topPadding = MediaQuery.of(context).padding.top;
    final safeTopOffset = topPadding + kToolbarHeight + 10.0;

    final minSize = _calculateMinSize();
    final calculatedMax =
        (widget.parentHeight - safeTopOffset) / widget.parentHeight;

    // Ensure the upper bound is valid
    final upperBound = math.max(0.95, minSize + 0.15);

    return calculatedMax.clamp(minSize + 0.1, upperBound);
  }

  void _onSheetPositionChanged() {
    final bool nowExpanded = _sheetController.size > _minSheetSize + 0.1;
    if (nowExpanded != _isExpanded) {
      setState(() {
        _isExpanded = nowExpanded;
      });
    }
  }

  @override
  void dispose() {
    widget.controller?._detach();
    _sheetController.removeListener(_onSheetPositionChanged);
    _sheetController.dispose();
    super.dispose();
  }

  /// Toggle the sheet between collapsed and expanded states
  void _toggleSheet() {
    final double currentSize = _sheetController.size;

    // If panel is mostly collapsed, expand it; otherwise collapse it
    if (currentSize < _minSheetSize + 0.1) {
      _sheetController.animateTo(
        _maxSheetSize,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutExpo,
      );
    } else {
      _sheetController.animateTo(
        _minSheetSize,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutExpo,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // For desktop mode, use a simple scrollable layout without DraggableScrollableSheet
    if (widget.isDesktopMode) {
      return _DesktopLayout(playerCubit: _playerCubit);
    }

    // Start expanded if requested (for modal use)
    final double initialSize =
        widget.startExpanded ? _maxSheetSize : _minSheetSize;

    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: initialSize,
      minChildSize: _minSheetSize,
      maxChildSize: _maxSheetSize,
      snap: true,
      snapSizes: [_minSheetSize, _maxSheetSize],
      snapAnimationDuration: const Duration(milliseconds: 250),
      builder: (context, scrollController) {
        return _PanelContent(
          peekHeight: widget.peekHeight,
          isExpanded: _isExpanded,
          onHeaderTap: _toggleSheet,
          scrollController: scrollController,
          playerCubit: _playerCubit,
        );
      },
    );
  }
}

/// Extracted panel content widget - reduces rebuilds in main state
class _PanelContent extends StatelessWidget {
  final double peekHeight;
  final bool isExpanded;
  final VoidCallback onHeaderTap;
  final ScrollController scrollController;
  final BloomeePlayerCubit playerCubit;

  const _PanelContent({
    required this.peekHeight,
    required this.isExpanded,
    required this.onHeaderTap,
    required this.scrollController,
    required this.playerCubit,
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
                color: Colors.black.withValues(alpha: 0.75),
                borderRadius: _UpNextStyles.panelBorderRadius,
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 0.5,
                  ),
                ),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Column(
                    children: [
                      // Header - always visible, tappable to toggle
                      GestureDetector(
                        onTap: onHeaderTap,
                        behavior: HitTestBehavior.opaque,
                        child: SizedBox(
                          height: math.min(peekHeight, constraints.maxHeight),
                          child: _CompactHeader(isExpanded: isExpanded),
                        ),
                      ),
                      // Scrollable content
                      Expanded(
                        child: CustomScrollView(
                          controller: scrollController,
                          physics: const ClampingScrollPhysics(),
                          slivers: [
                            // Queue info row
                            SliverToBoxAdapter(
                              child: _QueueInfoRow(playerCubit: playerCubit),
                            ),
                            // Song list
                            _SongListSliver(playerCubit: playerCubit),
                            // Bottom padding
                            SliverToBoxAdapter(
                              child: SizedBox(
                                height:
                                    MediaQuery.of(context).padding.bottom + 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact header for collapsed state
class _CompactHeader extends StatelessWidget {
  final bool isExpanded;

  const _CompactHeader({required this.isExpanded});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.queue_music_rounded,
              color: Default_Theme.primaryColor2.withValues(alpha: 0.8),
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              "Up Next",
              style: _UpNextStyles.headerTextStyle,
            ),
            const SizedBox(width: 4),
            AnimatedRotation(
              turns: isExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.keyboard_arrow_up_rounded,
                color: Default_Theme.primaryColor2.withValues(alpha: 0.5),
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Desktop layout - always expanded, no draggable behavior
class _DesktopLayout extends StatelessWidget {
  final BloomeePlayerCubit playerCubit;

  const _DesktopLayout({required this.playerCubit});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Material(
        color: Colors.transparent,
        child: ClipRRect(
          borderRadius: _UpNextStyles.desktopBorderRadius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: _UpNextStyles.desktopBorderRadius,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 0.5,
                ),
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {}, // Desktop doesn't need toggle
                    child: const _CompactHeader(isExpanded: true),
                  ),
                  _QueueInfoRow(playerCubit: playerCubit),
                  Expanded(
                    child: _DesktopSongList(playerCubit: playerCubit),
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

/// Queue info row with item count and auto-play toggle
class _QueueInfoRow extends StatelessWidget {
  final BloomeePlayerCubit playerCubit;

  const _QueueInfoRow({required this.playerCubit});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          StreamBuilder<List<MediaItem>>(
            stream: playerCubit.bloomeePlayer.queue,
            builder: (context, snapshot) {
              return Text(
                "${snapshot.data?.length ?? 0} Items in Queue",
                style: _UpNextStyles.queueCountStyle,
              );
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

/// Desktop song list using ReorderableListView
class _DesktopSongList extends StatelessWidget {
  final BloomeePlayerCubit playerCubit;

  const _DesktopSongList({required this.playerCubit});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MediaItem>>(
      stream: playerCubit.bloomeePlayer.queue,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(
                color: Default_Theme.primaryColor2,
              ),
            ),
          );
        }

        final queue = snapshot.data!;
        return ReorderableListView.builder(
          padding: const EdgeInsets.only(top: 5),
          physics: const BouncingScrollPhysics(),
          itemCount: queue.length,
          onReorder: (int oldIndex, int newIndex) {
            playerCubit.bloomeePlayer.moveQueueItem(oldIndex, newIndex);
          },
          buildDefaultDragHandles: false,
          itemBuilder: (context, index) {
            final mediaItem = queue[index];
            return _DesktopQueueItem(
              key: ValueKey(mediaItem.id),
              mediaItem: mediaItem,
              index: index,
              playerCubit: playerCubit,
            );
          },
        );
      },
    );
  }
}

/// Individual desktop queue item - extracted for better performance
class _DesktopQueueItem extends StatelessWidget {
  final MediaItem mediaItem;
  final int index;
  final BloomeePlayerCubit playerCubit;

  const _DesktopQueueItem({
    super.key,
    required this.mediaItem,
    required this.index,
    required this.playerCubit,
  });

  @override
  Widget build(BuildContext context) {
    final songModel = mediaItem2MediaItemModel(mediaItem);
    return Dismissible(
      key: ValueKey('dismiss_${mediaItem.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red.withValues(alpha: 0.8),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        playerCubit.bloomeePlayer.removeQueueItemAt(index);
      },
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.only(
            right: Platform.isAndroid ? 0 : 24,
          ),
          child: Row(
            children: [
              Expanded(
                child: SongCardWidget(
                  showOptions: true,
                  onTap: () {
                    playerCubit.bloomeePlayer.skipToQueueItem(index);
                  },
                  onOptionsTap: () {
                    showMoreBottomSheet(
                      context,
                      songModel,
                      showAddToQueue: false,
                      showPlayNext: false,
                    );
                  },
                  song: songModel,
                ),
              ),
              // Drag handle - clearly separated from song card
              ReorderableDragStartListener(
                index: index,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  child: Icon(
                    Icons.drag_handle_rounded,
                    color: Default_Theme.primaryColor2.withValues(alpha: 0.4),
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Mobile song list as a sliver
class _SongListSliver extends StatelessWidget {
  final BloomeePlayerCubit playerCubit;

  const _SongListSliver({required this.playerCubit});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MediaItem>>(
      stream: playerCubit.bloomeePlayer.queue,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(
                  color: Default_Theme.primaryColor2,
                ),
              ),
            ),
          );
        }

        final queue = snapshot.data!;
        return SliverReorderableList(
          itemCount: queue.length,
          onReorder: (int oldIndex, int newIndex) {
            playerCubit.bloomeePlayer.moveQueueItem(oldIndex, newIndex);
          },
          itemBuilder: (context, index) {
            final mediaItem = queue[index];
            return _MobileQueueItem(
              key: ValueKey(mediaItem.id),
              mediaItem: mediaItem,
              index: index,
              playerCubit: playerCubit,
            );
          },
        );
      },
    );
  }
}

/// Individual mobile queue item - extracted for better performance
class _MobileQueueItem extends StatelessWidget {
  final MediaItem mediaItem;
  final int index;
  final BloomeePlayerCubit playerCubit;

  const _MobileQueueItem({
    super.key,
    required this.mediaItem,
    required this.index,
    required this.playerCubit,
  });

  @override
  Widget build(BuildContext context) {
    final songModel = mediaItem2MediaItemModel(mediaItem);
    // Mobile view: Use long press to reorder (no visible drag handle)
    return ReorderableDelayedDragStartListener(
      index: index,
      child: Dismissible(
        key: ValueKey('dismissible_${mediaItem.id}'),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          color: Colors.red.withValues(alpha: 0.8),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        onDismissed: (direction) {
          playerCubit.bloomeePlayer.removeQueueItemAt(index);
        },
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: EdgeInsets.only(
              right: Platform.isAndroid ? 0 : 24,
            ),
            child: SongCardWidget(
              showOptions: true,
              onTap: () {
                playerCubit.bloomeePlayer.skipToQueueItem(index);
              },
              onOptionsTap: () {
                showMoreBottomSheet(
                  context,
                  songModel,
                  showAddToQueue: false,
                  showPlayNext: false,
                );
              },
              song: songModel,
            ),
          ),
        ),
      ),
    );
  }
}

/// Legacy wrapper for compatibility with existing SlidingUpPanel usage
/// This allows gradual migration from the old panel to the new one
class UpNextPanelLegacy extends StatefulWidget {
  const UpNextPanelLegacy({
    super.key,
    required this.panelController,
  });

  final dynamic panelController;

  @override
  State<UpNextPanelLegacy> createState() => _UpNextPanelLegacyState();
}

class _UpNextPanelLegacyState extends State<UpNextPanelLegacy> {
  late final BloomeePlayerCubit _playerCubit;

  @override
  void initState() {
    super.initState();
    _playerCubit = context.read<BloomeePlayerCubit>();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(25)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 28, 17, 24)
                      .withValues(alpha: 0.60),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(25),
                  ),
                ),
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _LegacyHeader(panelController: widget.panelController),
              _LegacyQueueInfo(playerCubit: _playerCubit),
              Expanded(
                child: _LegacySongList(playerCubit: _playerCubit),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Legacy header widget
class _LegacyHeader extends StatelessWidget {
  final dynamic panelController;

  const _LegacyHeader({required this.panelController});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 5,
        left: 10,
        right: 10,
        bottom: 5,
      ),
      child: Center(
        child: GestureDetector(
          onTap: () {
            try {
              if (panelController.isPanelOpen) {
                panelController.close();
              } else {
                panelController.open();
              }
            } catch (_) {}
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: SizedBox(
                  width: 40,
                  child: Divider(
                    color: Default_Theme.primaryColor2.withValues(alpha: 0.8),
                    thickness: 4,
                  ),
                ),
              ),
              Text(
                "Up Next",
                style: _UpNextStyles.legacyHeaderStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Legacy queue info row
class _LegacyQueueInfo extends StatelessWidget {
  final BloomeePlayerCubit playerCubit;

  const _LegacyQueueInfo({required this.playerCubit});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Divider(
            color: Default_Theme.primaryColor2.withValues(alpha: 0.5),
            thickness: 1.5,
          ),
          const SizedBox(height: 5),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: StreamBuilder<List<MediaItem>>(
                  stream: playerCubit.bloomeePlayer.queue,
                  builder: (context, snapshot) {
                    return Text(
                      "${snapshot.data?.length ?? 0} Items in Queue",
                      style: _UpNextStyles.legacyQueueStyle,
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 8),
                child: BlocBuilder<SettingsCubit, SettingsState>(
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
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Legacy song list
class _LegacySongList extends StatelessWidget {
  final BloomeePlayerCubit playerCubit;

  const _LegacySongList({required this.playerCubit});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MediaItem>>(
      stream: playerCubit.bloomeePlayer.queue,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(
              color: Default_Theme.primaryColor2,
            ),
          );
        }

        final queue = snapshot.data!;
        return ReorderableListView.builder(
          padding: const EdgeInsets.only(top: 5),
          physics: const BouncingScrollPhysics(),
          itemCount: queue.length,
          onReorder: (int oldIndex, int newIndex) {
            playerCubit.bloomeePlayer.moveQueueItem(oldIndex, newIndex);
          },
          itemBuilder: (context, index) {
            final mediaItem = queue[index];
            return _LegacyQueueItem(
              key: ValueKey(mediaItem.id),
              mediaItem: mediaItem,
              index: index,
              playerCubit: playerCubit,
            );
          },
        );
      },
    );
  }
}

/// Legacy queue item
class _LegacyQueueItem extends StatelessWidget {
  final MediaItem mediaItem;
  final int index;
  final BloomeePlayerCubit playerCubit;

  const _LegacyQueueItem({
    super.key,
    required this.mediaItem,
    required this.index,
    required this.playerCubit,
  });

  @override
  Widget build(BuildContext context) {
    final songModel = mediaItem2MediaItemModel(mediaItem);
    return Dismissible(
      key: ValueKey('dismiss_legacy_${mediaItem.id}'),
      onDismissed: (direction) {
        playerCubit.bloomeePlayer.removeQueueItemAt(index);
      },
      child: Padding(
        padding: EdgeInsets.only(
          right: Platform.isAndroid ? 8 : 32,
        ),
        child: SongCardWidget(
          showOptions: true,
          onTap: () {
            playerCubit.bloomeePlayer.skipToQueueItem(index);
          },
          onOptionsTap: () {
            showMoreBottomSheet(
              context,
              songModel,
              showAddToQueue: false,
              showPlayNext: false,
            );
          },
          song: songModel,
        ),
      ),
    );
  }
}
