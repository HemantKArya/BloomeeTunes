import 'dart:async';
import 'dart:math' as math;
import 'package:Bloomee/blocs/media_player/bloomee_player_cubit.dart';
import 'package:Bloomee/utils/artwork_glow_color.dart';
import 'package:Bloomee/core/adapters/track_adapter.dart';
import 'package:Bloomee/l10n/app_localizations.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:Bloomee/core/models/exported.dart' hide MediaItem;
import 'package:Bloomee/screens/widgets/media_metadata_links.dart';
import 'package:Bloomee/utils/load_image.dart';

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
    this.onDesktopCollapse,
  });

  final double peekHeight;
  final double parentHeight;
  final bool isDesktopMode;
  final bool startExpanded;
  final bool canBeHidden;
  final UpNextPanelController? controller;
  final VoidCallback? onDesktopCollapse;

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
    if (!_sheetController.isAttached) return;
    if (_sheetController.size < _minSheetSize + 0.1) {
      _sheetController.animateTo(_maxSheetSize,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutExpo);
    } else {
      _collapseSheet();
    }
  }

  void _collapseSheet() {
    if (!_sheetController.isAttached) return;
    _sheetController.animateTo(_minSheetSize,
        duration: const Duration(milliseconds: 300), curve: Curves.easeOutExpo);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isDesktopMode) {
      return _DesktopLayout(
        playerCubit: _playerCubit,
        onCollapse: widget.onDesktopCollapse,
      );
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
          child: Container(
            decoration: BoxDecoration(
              // A tinted gradient keeps depth without filtering the moving
              // player behind the sheet on every drag and scroll frame.
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF20202A), Color(0xFF0E1018)],
              ),
              borderRadius: _UpNextStyles.panelBorderRadius,
              border: Border(
                  top: BorderSide(
                      color: Colors.white.withValues(alpha: 0.1), width: 0.5)),
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
                  child: RepaintBoundary(
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
                                    MediaQuery.paddingOf(context).bottom + 20)),
                      ],
                    ),
                  ),
                ),
              ],
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
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.queue_music_rounded,
              color: Default_Theme.primaryColor2.withValues(alpha: 0.8),
              size: 18),
          const SizedBox(width: 8),
          Text(l10n.upNextTitle, style: _UpNextStyles.headerTextStyle),
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
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: StreamBuilder<List<MediaItem>>(
              stream: playerCubit.bloomeePlayer.queue,
              initialData: playerCubit.bloomeePlayer.queue.valueOrNull,
              builder: (context, snapshot) {
                return Text(l10n.upNextItemsInQueue(snapshot.data?.length ?? 0),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _UpNextStyles.queueCountStyle);
              },
            ),
          ),
          const SizedBox(width: 8),
          _ClearQueueButton(playerCubit: playerCubit),
        ],
      ),
    );
  }
}

/// Pill-styled "Clear Queue" button that keeps only the currently
/// playing track and removes everything else from the queue.
class _ClearQueueButton extends StatelessWidget {
  final BloomeePlayerCubit playerCubit;
  const _ClearQueueButton({required this.playerCubit});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => playerCubit.bloomeePlayer.clearQueue(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.18),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.playlist_remove_rounded,
              size: 15,
              color: Default_Theme.primaryColor2.withValues(alpha: 0.75),
            ),
            const SizedBox(width: 6),
            Text(
              'Clear',
              style: Default_Theme.secondoryTextStyleMedium.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Default_Theme.primaryColor2.withValues(alpha: 0.75),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DesktopLayout extends StatelessWidget {
  final BloomeePlayerCubit playerCubit;
  final VoidCallback? onCollapse;
  const _DesktopLayout({required this.playerCubit, this.onCollapse});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: _GlassQueueSurface(
        playerCubit: playerCubit,
        child: Material(
          type: MaterialType.transparency,
          child: Column(
            children: [
              _DesktopHeader(playerCubit: playerCubit, onCollapse: onCollapse),
              const _HairlineDivider(),
              Expanded(child: _DesktopSongList(playerCubit: playerCubit)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dark, see-through glass with a rim light tinted by the current cover.
///
/// The ambient artwork behind the panel is already a pre-blurred texture, so
/// a translucent tint reads as frosted glass without a BackdropFilter (which
/// would re-blur the window on every scroll and transition frame). The light
/// is painted on its own layer and only repaints when the cover changes.
class _GlassQueueSurface extends StatefulWidget {
  final BloomeePlayerCubit playerCubit;
  final Widget child;
  const _GlassQueueSurface({required this.playerCubit, required this.child});

  static const radius = 22.0;

  @override
  State<_GlassQueueSurface> createState() => _GlassQueueSurfaceState();
}

class _GlassQueueSurfaceState extends State<_GlassQueueSurface> {
  static const _neutralLight = Color(0xFFDDE4F0);
  StreamSubscription<String>? _artSub;
  Color _light = _neutralLight;
  String _artUrl = '';

  @override
  void initState() {
    super.initState();
    _artSub = widget.playerCubit.bloomeePlayer.mediaItem
        .map((item) {
          if (item == null) return '';
          final thumb = mediaItemToTrack(item).thumbnail;
          return thumb.urlLow ?? thumb.url;
        })
        .distinct()
        .listen(_onArtwork);
  }

  void _onArtwork(String url) {
    _artUrl = url;
    final cached = ArtworkGlowColor.cached(url);
    if (cached != null) {
      _setLight(cached);
      return;
    }
    ArtworkGlowColor.resolve(url).then((color) {
      if (mounted && url == _artUrl) _setLight(color ?? _neutralLight);
    });
  }

  void _setLight(Color color) {
    if (color != _light) setState(() => _light = color);
  }

  @override
  void dispose() {
    _artSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(_GlassQueueSurface.radius),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: Color(0x6107090E)),
          RepaintBoundary(
            child: TweenAnimationBuilder<Color?>(
              tween: ColorTween(end: _light),
              duration: reduceMotion
                  ? Duration.zero
                  : const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (context, color, _) => CustomPaint(
                painter: _GlassLightPainter(color ?? _neutralLight),
              ),
            ),
          ),
          widget.child,
        ],
      ),
    );
  }
}

class _GlassLightPainter extends CustomPainter {
  final Color light;
  const _GlassLightPainter(this.light);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final rect = Offset.zero & size;
    final shortest = size.shortestSide;

    // Light spilling in from the top-left corner.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          colors: [
            light.withValues(alpha: 0.20),
            light.withValues(alpha: 0.06),
            light.withValues(alpha: 0),
          ],
          stops: const [0, 0.45, 1],
        ).createShader(
            Rect.fromCircle(center: Offset.zero, radius: shortest * 0.95)),
    );

    // A faint counter-reflection in the opposite corner.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          colors: [light.withValues(alpha: 0.07), light.withValues(alpha: 0)],
        ).createShader(
            Rect.fromCircle(center: rect.bottomRight, radius: shortest * 0.7)),
    );

    // Soft top sheen, like the upper face of a glass pane.
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, 140),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.05),
            Colors.white.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, 140)),
    );

    final rim = RRect.fromRectAndRadius(
      rect.deflate(0.5),
      const Radius.circular(_GlassQueueSurface.radius - 0.5),
    );

    // Edge: lit at the top-left, fading to a hairline, catching a little
    // light again at the bottom-right.
    canvas.drawRRect(
      rim,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            light.withValues(alpha: 0.75),
            light.withValues(alpha: 0.22),
            Colors.white.withValues(alpha: 0.07),
            Colors.white.withValues(alpha: 0.05),
            light.withValues(alpha: 0.25),
          ],
          stops: const [0, 0.16, 0.38, 0.82, 1],
        ).createShader(rect),
    );

    // Specular hot spot on the corner itself.
    canvas.drawRRect(
      rim,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.85),
            light.withValues(alpha: 0.55),
            light.withValues(alpha: 0),
          ],
          stops: const [0, 0.3, 1],
        ).createShader(Rect.fromCircle(
            center: const Offset(_GlassQueueSurface.radius * 0.6,
                _GlassQueueSurface.radius * 0.6),
            radius: 120)),
    );
  }

  @override
  bool shouldRepaint(_GlassLightPainter oldDelegate) =>
      oldDelegate.light != light;
}

class _DesktopHeader extends StatelessWidget {
  final BloomeePlayerCubit playerCubit;
  final VoidCallback? onCollapse;
  const _DesktopHeader({required this.playerCubit, this.onCollapse});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 10, 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.upNextTitle,
                  maxLines: 1,
                  style: Default_Theme.secondoryTextStyleMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.95),
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                StreamBuilder<int>(
                  stream: playerCubit.bloomeePlayer.queue
                      .map((q) => q.length)
                      .distinct(),
                  initialData:
                      playerCubit.bloomeePlayer.queue.valueOrNull?.length ?? 0,
                  builder: (context, snapshot) => Text(
                    l10n.upNextItemsInQueue(snapshot.data ?? 0),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Default_Theme.secondoryTextStyleMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _GlassPillButton(
            icon: Icons.playlist_remove_rounded,
            label: 'Clear',
            onTap: playerCubit.bloomeePlayer.clearQueue,
          ),
          const SizedBox(width: 4),
          IconButton(
            tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
            onPressed: onCollapse,
            iconSize: 20,
            splashRadius: 18,
            color: Colors.white.withValues(alpha: 0.6),
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
  }
}

class _GlassPillButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _GlassPillButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final fg = Colors.white.withValues(alpha: 0.78);
    return Material(
      color: Colors.white.withValues(alpha: 0.06),
      shape: StadiumBorder(
          side: BorderSide(color: Colors.white.withValues(alpha: 0.10))),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        hoverColor: Colors.white.withValues(alpha: 0.06),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: fg),
              const SizedBox(width: 6),
              Text(
                label,
                style: Default_Theme.secondoryTextStyleMedium.copyWith(
                    fontSize: 12, fontWeight: FontWeight.w600, color: fg),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HairlineDivider extends StatelessWidget {
  const _HairlineDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          Colors.white.withValues(alpha: 0),
          Colors.white.withValues(alpha: 0.09),
          Colors.white.withValues(alpha: 0),
        ]),
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
  bool _hasPositionedCurrentSong = false;
  static const double _itemHeight = 70.0;

  /// Only the playing id matters to the list; metadata refreshes of the same
  /// song (duration, artwork) must not rebuild every visible row.
  late final Stream<String?> _currentId = widget
      .playerCubit.bloomeePlayer.mediaItem
      .map((item) => item?.id)
      .distinct();

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

    if (!_hasPositionedCurrentSong) {
      // Do not run a second animation (and decode every intermediate sleeve)
      // while the full player is opening at a song deep in a long queue.
      _hasPositionedCurrentSong = true;
      _scrollController.jumpTo(clampedOffset);
    } else {
      _scrollController.animateTo(clampedOffset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MediaItem>>(
      stream: widget.playerCubit.bloomeePlayer.queue,
      initialData: widget.playerCubit.bloomeePlayer.queue.valueOrNull,
      builder: (context, queueSnapshot) {
        if (!queueSnapshot.hasData) {
          return const Center(
              child: CircularProgressIndicator(
                  color: Default_Theme.primaryColor2));
        }
        final queue = queueSnapshot.data!;

        return StreamBuilder<String?>(
          stream: _currentId,
          initialData:
              widget.playerCubit.bloomeePlayer.mediaItem.valueOrNull?.id,
          builder: (context, idSnapshot) {
            final currentId = idSnapshot.data;
            if (currentId != null && currentId != _lastPlayingId) {
              _lastPlayingId = currentId;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_scrollController.hasClients) {
                  _scrollToCurrentSong(queue, currentId);
                }
              });
            }

            final keys = _queueKeys(queue);
            return ReorderableListView.builder(
              scrollController: _scrollController,
              padding: const EdgeInsets.fromLTRB(6, 6, 6, 12),
              itemCount: queue.length,
              itemExtent: _itemHeight,
              onReorder: widget.playerCubit.bloomeePlayer.moveQueueItem,
              buildDefaultDragHandles: false,
              proxyDecorator: _queueProxyDecorator,
              itemBuilder: (context, index) {
                return _QueueItem(
                  key: keys[index],
                  mediaItem: queue[index],
                  index: index,
                  playerCubit: widget.playerCubit,
                  isDesktop: true,
                  isPlaying: queue[index].id == currentId,
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
  bool _hasPositionedCurrentSong = false;
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

    if (!_hasPositionedCurrentSong) {
      // Opening a deep queue must not animate through (and decode) every
      // intervening thumbnail while the sheet is also moving.
      _hasPositionedCurrentSong = true;
      widget.scrollController.jumpTo(clampedOffset);
    } else {
      widget.scrollController.animateTo(clampedOffset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MediaItem>>(
      stream: widget.playerCubit.bloomeePlayer.queue,
      initialData: widget.playerCubit.bloomeePlayer.queue.valueOrNull,
      builder: (context, queueSnapshot) {
        if (!queueSnapshot.hasData) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }
        final queue = queueSnapshot.data!;

        return StreamBuilder<MediaItem?>(
          stream: widget.playerCubit.bloomeePlayer.mediaItem,
          initialData: widget.playerCubit.bloomeePlayer.mediaItem.valueOrNull,
          builder: (context, mediaSnapshot) {
            final currentId = mediaSnapshot.data?.id;
            if (currentId != null && currentId != _lastPlayingId) {
              _lastPlayingId = currentId;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) _scrollToCurrentSong(queue, currentId);
              });
            }

            final keys = _queueKeys(queue);
            return SliverReorderableList(
              itemCount: queue.length,
              itemExtent: _itemHeight,
              onReorder: widget.playerCubit.bloomeePlayer.moveQueueItem,
              proxyDecorator: _queueProxyDecorator,
              itemBuilder: (context, index) {
                return _QueueItem(
                  key: keys[index],
                  mediaItem: queue[index],
                  index: index,
                  playerCubit: widget.playerCubit,
                  isDesktop: false,
                  isPlaying: queue[index].id == currentId,
                );
              },
            );
          },
        );
      },
    );
  }
}

/// Keys that survive reorders and removals: the track id plus which copy of
/// it this is. Index-based keys remounted every row (and re-decoded every
/// thumbnail) on each move.
List<Key> _queueKeys(List<MediaItem> queue) {
  final seen = <String, int>{};
  return [
    for (final item in queue)
      ValueKey(
          '${item.id}#${seen.update(item.id, (n) => n + 1, ifAbsent: () => 0)}'),
  ];
}

// Same raised surface as the theme's surfaceContainerHighest.
const _liftedSurface = Color(0xFF1A111B);

/// The row being dragged: lifted onto a slightly lighter surface with a
/// soft neutral shadow, no accent outline.
Widget _queueProxyDecorator(
    Widget child, int index, Animation<double> animation) {
  return AnimatedBuilder(
    animation: animation,
    builder: (context, child) {
      final t = Curves.easeOutCubic.transform(animation.value);
      return Transform.scale(
        scale: 1 + 0.02 * t,
        child: Material(
          elevation: 10 * t,
          color: Color.lerp(Colors.transparent, _liftedSurface, t),
          shadowColor: Colors.black,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: child,
        ),
      );
    },
    child: child,
  );
}

/// One queue row.
///
/// Desktop: one soft hover fill for the whole row; remove / more / drag
/// handle fade in on hover only, and the row can be dragged from anywhere.
/// Touch: long-press anywhere to drag, swipe right to remove.
class _QueueItem extends StatefulWidget {
  final MediaItem mediaItem;
  final int index;
  final BloomeePlayerCubit playerCubit;
  final bool isDesktop;
  final bool isPlaying;

  const _QueueItem({
    super.key,
    required this.mediaItem,
    required this.index,
    required this.playerCubit,
    required this.isDesktop,
    required this.isPlaying,
  });

  @override
  State<_QueueItem> createState() => _QueueItemState();
}

class _QueueItemState extends State<_QueueItem> {
  bool _hovered = false;

  void _setHovered(bool value) {
    if (_hovered != value) setState(() => _hovered = value);
  }

  void _openOptions(Track track) => showMoreBottomSheet(
        context,
        track,
        showAddToQueue: false,
        showPlayNext: false,
        showSinglePlay: true,
      );

  void _remove() =>
      widget.playerCubit.bloomeePlayer.removeQueueItemAt(widget.index);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final track = mediaItemToTrack(widget.mediaItem);
    final playing = widget.isPlaying;
    final desktop = widget.isDesktop;
    final showActions = !desktop || _hovered;

    final fill = playing
        ? Default_Theme.accentColor2.withValues(alpha: _hovered ? 0.11 : 0.08)
        : _hovered
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.transparent;

    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(12),
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () =>
              widget.playerCubit.bloomeePlayer.skipToQueueItem(widget.index),
          onSecondaryTap: () => _openOptions(track),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 4, 0),
            child: Row(
              children: [
                _QueueArtwork(track: track, playing: playing),
                const SizedBox(width: 12),
                Expanded(child: _QueueText(track: track, playing: playing)),
                const SizedBox(width: 4),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 120),
                  opacity: showActions ? 1 : 0,
                  child: IgnorePointer(
                    ignoring: !showActions,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (desktop && !playing)
                          _QueueAction(
                            icon: Icons.close_rounded,
                            tooltip: l10n.tooltipRemoveFromQueue,
                            onTap: _remove,
                          ),
                        _QueueAction(
                          icon: Icons.more_horiz_rounded,
                          tooltip: l10n.tooltipMoreOptions,
                          onTap: () => _openOptions(track),
                        ),
                        // Visual cue only: the whole row is the drag
                        // source (nested drag listeners fight each other).
                        if (desktop)
                          MouseRegion(
                            cursor: SystemMouseCursors.grab,
                            child: SizedBox(
                              width: 32,
                              height: 40,
                              child: Icon(
                                Icons.drag_handle_rounded,
                                size: 20,
                                color: Default_Theme.primaryColor2
                                    .withValues(alpha: 0.45),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (desktop) {
      return MouseRegion(
        onEnter: (_) => _setHovered(true),
        onExit: (_) => _setHovered(false),
        child: ReorderableDragStartListener(index: widget.index, child: row),
      );
    }

    return ReorderableDelayedDragStartListener(
      index: widget.index,
      child: Dismissible(
        key: ValueKey('dismiss_${widget.key}'),
        // The playing track cannot be removed (skip it instead).
        direction:
            playing ? DismissDirection.none : DismissDirection.startToEnd,
        onDismissed: (_) => _remove(),
        background: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20),
            decoration: BoxDecoration(
              color: Default_Theme.accentColor2.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.remove_circle_outline_rounded,
              size: 20,
              color: Default_Theme.accentColor2.withValues(alpha: 0.9),
            ),
          ),
        ),
        child: row,
      ),
    );
  }
}

class _QueueArtwork extends StatelessWidget {
  final Track track;
  final bool playing;
  const _QueueArtwork({required this.track, required this.playing});

  @override
  Widget build(BuildContext context) {
    final url = track.thumbnail.urlLow ?? track.thumbnail.url;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox.square(
        dimension: 48,
        child: Stack(
          fit: StackFit.expand,
          children: [
            LoadImageCached(
              imageUrl: url,
              fallbackUrl: url,
              fit: BoxFit.cover,
              width: 48,
              height: 48,
            ),
            if (playing)
              ColoredBox(
                color: Colors.black.withValues(alpha: 0.45),
                child: const Icon(
                  FontAwesome.chart_simple_solid,
                  size: 14,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _QueueText extends StatelessWidget {
  final Track track;
  final bool playing;
  const _QueueText({required this.track, required this.playing});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          track.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Default_Theme.secondoryTextStyle.merge(TextStyle(
            color: playing
                ? Default_Theme.accentColor2
                : Default_Theme.primaryColor1.withValues(alpha: 0.9),
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.1,
          )),
        ),
        const SizedBox(height: 3),
        TrackMetadataLinks(
          track: track,
          style: Default_Theme.secondoryTextStyle.merge(TextStyle(
            color: Default_Theme.primaryColor2.withValues(alpha: 0.55),
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
          )),
        ),
      ],
    );
  }
}

/// Small icon button: the icon brightens on hover; no circular splash.
class _QueueAction extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  const _QueueAction(
      {required this.icon, required this.tooltip, required this.onTap});

  @override
  State<_QueueAction> createState() => _QueueActionState();
}

class _QueueActionState extends State<_QueueAction> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      waitDuration: const Duration(milliseconds: 500),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: SizedBox(
            width: 34,
            height: 40,
            child: Icon(
              widget.icon,
              size: 19,
              color: Default_Theme.primaryColor2
                  .withValues(alpha: _hovered ? 0.95 : 0.55),
            ),
          ),
        ),
      ),
    );
  }
}
