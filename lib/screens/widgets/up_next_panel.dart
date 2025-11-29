import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';
import 'package:Bloomee/blocs/mediaPlayer/bloomee_player_cubit.dart';
import 'package:Bloomee/blocs/settings_cubit/cubit/settings_cubit.dart';
import 'package:Bloomee/model/songModel.dart';
import 'package:Bloomee/screens/widgets/toogle_btn.dart';
import 'package:Bloomee/theme_data/default.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'song_tile.dart';
import 'more_bottom_sheet.dart';

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
  StreamSubscription? _mediaItemSub;
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  late bool _isExpanded;

  double get _minSheetSize {
    if (widget.canBeHidden) return 0.0;
    return (widget.peekHeight / widget.parentHeight).clamp(0.05, 0.85);
  }

  @override
  void initState() {
    super.initState();
    widget.controller?._attach(_toggleSheet);
    _isExpanded = widget.startExpanded;
    // Listen to sheet position changes to update expanded state
    _sheetController.addListener(_onSheetPositionChanged);
    _mediaItemSub = context
        .read<BloomeePlayerCubit>()
        .bloomeePlayer
        .mediaItem
        .listen((value) {
      if (value != null && mounted) {}
    });
  }

  void _onSheetPositionChanged() {
    final double minSize = _minSheetSize;
    final bool nowExpanded = _sheetController.size > minSize + 0.1;
    if (nowExpanded != _isExpanded) {
      setState(() {
        _isExpanded = nowExpanded;
      });
    }
  }

  @override
  void dispose() {
    widget.controller?._detach();
    _mediaItemSub?.cancel();
    _sheetController.removeListener(_onSheetPositionChanged);
    _sheetController.dispose();
    super.dispose();
  }

  /// Toggle the sheet between collapsed and expanded states
  void _toggleSheet() {
    final double currentSize = _sheetController.size;
    final double minSize = _minSheetSize;
    final double maxSize = ((widget.parentHeight - 80) / widget.parentHeight)
        .clamp(minSize + 0.1, 0.92);

    // If panel is mostly collapsed, expand it; otherwise collapse it
    if (currentSize < minSize + 0.1) {
      _sheetController.animateTo(
        maxSize,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutExpo,
      );
    } else {
      _sheetController.animateTo(
        minSize,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutExpo,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // For desktop mode, use a simple scrollable layout without DraggableScrollableSheet
    if (widget.isDesktopMode) {
      return _buildDesktopLayout();
    }

    // Ensure minSize is valid (between 0 and maxChildSize)
    final double minSize = _minSheetSize;

    // Max size leaves space for app bar (approximately 100px from top)
    final double maxSize = ((widget.parentHeight - 80) / widget.parentHeight)
        .clamp(minSize + 0.1, 0.92);

    // Start expanded if requested (for modal use)
    final double initialSize = widget.startExpanded ? maxSize : minSize;

    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: initialSize,
      minChildSize: minSize,
      maxChildSize: maxSize,
      snap: true,
      snapSizes: [minSize, maxSize],
      snapAnimationDuration: const Duration(milliseconds: 250),
      builder: (context, scrollController) {
        return Material(
          color: Colors.transparent,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.75),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
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
                          onTap: _toggleSheet,
                          behavior: HitTestBehavior.opaque,
                          child: SizedBox(
                            height: math.min(
                                widget.peekHeight, constraints.maxHeight),
                            child: _buildCompactHeader(),
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
                                child: _buildQueueInfoRow(),
                              ),
                              // Song list
                              _buildSongList(),
                              // Bottom padding
                              SliverToBoxAdapter(
                                child: SizedBox(
                                    height:
                                        MediaQuery.of(context).padding.bottom +
                                            20),
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
        );
      },
    );
  }

  /// Compact header for collapsed state - minimal space usage
  Widget _buildCompactHeader() {
    return Container(
      // Use constraints from parent instead of fixed height
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
              style: Default_Theme.secondoryTextStyleMedium.merge(
                TextStyle(
                  color: Default_Theme.primaryColor2.withValues(alpha: 0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 4),
            AnimatedRotation(
              turns: _isExpanded ? 0.5 : 0,
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

  /// Desktop layout - always expanded, no draggable behavior
  Widget _buildDesktopLayout() {
    return Material(
      color: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 0.5,
              ),
            ),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {}, // Desktop doesn't need toggle
                  child: _buildCompactHeader(),
                ),
                _buildQueueInfoRow(),
                Expanded(
                  child: _buildDesktopSongList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Desktop song list using ReorderableListView
  Widget _buildDesktopSongList() {
    return StreamBuilder(
      stream: context.read<BloomeePlayerCubit>().bloomeePlayer.queue,
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
            context
                .read<BloomeePlayerCubit>()
                .bloomeePlayer
                .moveQueueItem(oldIndex, newIndex);
          },
          buildDefaultDragHandles: false,
          itemBuilder: (context, index) {
            final songModel = mediaItem2MediaItemModel(queue[index]);
            return Dismissible(
              key: ValueKey(queue[index].id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                color: Colors.red.withValues(alpha: 0.8),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (direction) {
                context
                    .read<BloomeePlayerCubit>()
                    .bloomeePlayer
                    .removeQueueItemAt(index);
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
                            context
                                .read<BloomeePlayerCubit>()
                                .bloomeePlayer
                                .skipToQueueItem(index);
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 8),
                          child: Icon(
                            Icons.drag_handle_rounded,
                            color: Default_Theme.primaryColor2
                                .withValues(alpha: 0.4),
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildQueueInfoRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          StreamBuilder<List>(
            stream: context.read<BloomeePlayerCubit>().bloomeePlayer.queue,
            builder: (context, snapshot) {
              return Text(
                "${snapshot.data?.length ?? 0} Items in Queue",
                style: Default_Theme.secondoryTextStyleMedium.merge(
                  TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
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
                    context
                        .read<BloomeePlayerCubit>()
                        .bloomeePlayer
                        .check4RelatedSongs();
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSongList() {
    return StreamBuilder(
      stream: context.read<BloomeePlayerCubit>().bloomeePlayer.queue,
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
            context
                .read<BloomeePlayerCubit>()
                .bloomeePlayer
                .moveQueueItem(oldIndex, newIndex);
          },
          itemBuilder: (context, index) {
            final songModel = mediaItem2MediaItemModel(queue[index]);
            // Mobile view: Use long press to reorder (no visible drag handle)
            return ReorderableDelayedDragStartListener(
              key: ValueKey(queue[index].id),
              index: index,
              child: Dismissible(
                key: ValueKey('dismissible_${queue[index].id}'),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: Colors.red.withValues(alpha: 0.8),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) {
                  context
                      .read<BloomeePlayerCubit>()
                      .bloomeePlayer
                      .removeQueueItemAt(index);
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
                        context
                            .read<BloomeePlayerCubit>()
                            .bloomeePlayer
                            .skipToQueueItem(index);
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
          },
        );
      },
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
  StreamSubscription? _mediaItemSub;

  @override
  void initState() {
    _mediaItemSub = context
        .read<BloomeePlayerCubit>()
        .bloomeePlayer
        .mediaItem
        .listen((value) {
      if (value != null && mounted) {}
    });
    super.initState();
  }

  @override
  void dispose() {
    _mediaItemSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 28, 17, 24)
                    .withValues(alpha: 0.60),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
            ),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
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
                      if (widget.panelController.isPanelOpen) {
                        widget.panelController.close();
                      } else {
                        widget.panelController.open();
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
                            color: Default_Theme.primaryColor2
                                .withValues(alpha: 0.8),
                            thickness: 4,
                          ),
                        ),
                      ),
                      Text("Up Next",
                          style: Default_Theme.secondoryTextStyleMedium.merge(
                              const TextStyle(
                                  color: Default_Theme.primaryColor2,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold))),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 8,
                right: 8,
              ),
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
                        child: StreamBuilder<List>(
                            stream: context
                                .read<BloomeePlayerCubit>()
                                .bloomeePlayer
                                .queue,
                            builder: (context, snapshot) {
                              return Text(
                                  "${snapshot.data?.length ?? 0} Items in Queue",
                                  style: Default_Theme.secondoryTextStyleMedium
                                      .merge(TextStyle(
                                          color: Default_Theme.primaryColor2
                                              .withValues(alpha: 0.5),
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold)));
                            }),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8, bottom: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: BlocBuilder<SettingsCubit, SettingsState>(
                                builder: (context, state) {
                                  return ToggleButton(
                                    label: "Auto Play",
                                    initialState: state.autoPlay,
                                    onChanged: (val) async {
                                      await context
                                          .read<SettingsCubit>()
                                          .setAutoPlay(val);
                                      if (val) {
                                        context
                                            .read<BloomeePlayerCubit>()
                                            .bloomeePlayer
                                            .check4RelatedSongs();
                                      }
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder(
                stream: context.read<BloomeePlayerCubit>().bloomeePlayer.queue,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ReorderableListView.builder(
                      padding: const EdgeInsets.only(top: 5),
                      physics: const BouncingScrollPhysics(),
                      itemCount: snapshot.data?.length ?? 0,
                      itemBuilder: (context, index) {
                        final songModel =
                            mediaItem2MediaItemModel(snapshot.data![index]);
                        return Dismissible(
                          key: ValueKey(snapshot.data?[index].id),
                          onDismissed: (direction) {
                            context
                                .read<BloomeePlayerCubit>()
                                .bloomeePlayer
                                .removeQueueItemAt(index);
                          },
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: Platform.isAndroid ? 8 : 32,
                            ),
                            child: SongCardWidget(
                              showOptions: true,
                              onTap: () {
                                context
                                    .read<BloomeePlayerCubit>()
                                    .bloomeePlayer
                                    .skipToQueueItem(index);
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
                      },
                      onReorder: (int oldIndex, int newIndex) {
                        context
                            .read<BloomeePlayerCubit>()
                            .bloomeePlayer
                            .moveQueueItem(oldIndex, newIndex);
                      },
                    );
                  }
                  return const CircularProgressIndicator();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
