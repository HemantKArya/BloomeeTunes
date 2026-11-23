import 'package:Bloomee/blocs/media_player/bloomee_player_cubit.dart';
import 'package:Bloomee/core/events/global_event_bus.dart';
import 'package:Bloomee/core/models/exported.dart';
import 'package:Bloomee/core/models/media_playlist_model.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/plugins/blocs/plugin/plugin_bloc.dart';
import 'package:Bloomee/screens/screen/common_views/album_view.dart';
import 'package:Bloomee/screens/screen/common_views/artist_view.dart';
import 'package:Bloomee/screens/screen/common_views/playlist_view.dart';
import 'package:Bloomee/screens/screen/home/home_layout.dart';
import 'package:Bloomee/utils/load_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';

/// A plugin home section: pink title and one row of cards (original
/// design). Only the cards on screen are built, and their covers are
/// decoded at the size shown.
class HomeMediaShelf extends StatefulWidget {
  final Section section;
  final String pluginId;
  final bool canLoadMore;
  final bool isLoadingMore;
  final VoidCallback? onLoadMore;

  const HomeMediaShelf({
    super.key,
    required this.section,
    required this.pluginId,
    this.canLoadMore = false,
    this.isLoadingMore = false,
    this.onLoadMore,
  });

  /// Height of the card row (original design).
  static const rowHeight = 220.0;

  @override
  State<HomeMediaShelf> createState() => _HomeMediaShelfState();
}

class _HomeMediaShelfState extends State<HomeMediaShelf> {
  final _controller = ScrollController();
  bool _loadMoreRequested = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_maybeLoadMore);
  }

  @override
  void didUpdateWidget(covariant HomeMediaShelf oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isLoadingMore != widget.isLoadingMore ||
        oldWidget.section.items.length != widget.section.items.length) {
      _loadMoreRequested = false;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _maybeLoadMore() {
    if (!widget.canLoadMore ||
        widget.isLoadingMore ||
        _loadMoreRequested ||
        !_controller.hasClients) {
      return;
    }
    final position = _controller.position;
    if (position.maxScrollExtent - position.pixels <= 240) {
      _loadMoreRequested = true;
      widget.onLoadMore?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.section.items;
    final count = items.length + (widget.isLoadingMore ? 1 : 0);
    final buttons = HomeMetrics.showsScrollButtons;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        HomeSectionTitle(widget.section.title),
        SizedBox(
          height: HomeMediaShelf.rowHeight,
          child: Row(
            children: [
              if (buttons)
                IconButton(
                  icon: const Icon(MingCute.left_line),
                  onPressed: () => scrollShelf(_controller, -1, step: 200),
                ),
              Expanded(
                child: ListView.builder(
                  controller: _controller,
                  scrollDirection: Axis.horizontal,
                  itemExtent: HomeMetrics.cardSize + 16,
                  itemCount: count,
                  itemBuilder: (context, i) {
                    if (i >= items.length) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Default_Theme.accentColor2,
                        ),
                      );
                    }
                    final item = items[i];
                    return HomeMediaCard(
                      key: ValueKey(_idOf(item)),
                      item: item,
                      onTap: () => _open(context, item),
                    );
                  },
                ),
              ),
              if (buttons)
                IconButton(
                  icon: const Icon(MingCute.right_line),
                  onPressed: () => scrollShelf(_controller, 1, step: 200),
                ),
            ],
          ),
        ),
      ],
    );
  }

  void _open(BuildContext context, MediaItem item) {
    final loaded = context.read<PluginBloc>().state.loadedPluginIds;
    if (!requirePlugin(widget.pluginId, loaded)) return;
    final pluginId = widget.pluginId;
    item.when(
      track: (track) {
        final tracks = [
          for (final i in widget.section.items)
            ...i.when(
              track: (t) => [t],
              album: (_) => const <Track>[],
              artist: (_) => const <Track>[],
              playlist: (_) => const <Track>[],
            ),
        ];
        final index = tracks.indexWhere((t) => t.id == track.id);
        context.read<BloomeePlayerCubit>().bloomeePlayer.loadPlaylist(
              Playlist(tracks: tracks, title: widget.section.title),
              idx: index < 0 ? 0 : index,
              doPlay: true,
            );
      },
      album: (album) =>
          _push(context, AlbumView(album: album, pluginId: pluginId)),
      artist: (artist) =>
          _push(context, ArtistView(artist: artist, pluginId: pluginId)),
      playlist: (playlist) => _push(
          context, OnlPlaylistView(playlist: playlist, pluginId: pluginId)),
    );
  }

  static void _push(BuildContext context, Widget page) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));

  static String _idOf(MediaItem item) => item.when(
        track: (t) => 't:${t.id}',
        album: (a) => 'a:${a.id}',
        artist: (a) => 'r:${a.id}',
        playlist: (p) => 'p:${p.id}',
      );
}

/// Cover with a centred title and subtitle below (original card design).
class HomeMediaCard extends StatefulWidget {
  final MediaItem item;
  final VoidCallback onTap;

  const HomeMediaCard({super.key, required this.item, required this.onTap});

  @override
  State<HomeMediaCard> createState() => _HomeMediaCardState();
}

class _HomeMediaCardState extends State<HomeMediaCard> {
  bool _pressed = false;

  void _press(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final card = _CardData.of(widget.item);
    const size = HomeMetrics.cardSize;
    return Padding(
      padding: const EdgeInsets.all(8),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          onTapDown: (_) => _press(true),
          onTapUp: (_) => _press(false),
          onTapCancel: () => _press(false),
          child: AnimatedScale(
            scale: _pressed ? 0.96 : 1,
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            child: AnimatedOpacity(
              opacity: _pressed ? 0.85 : 1,
              duration: const Duration(milliseconds: 120),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: ColoredBox(
                      // Tint behind the cover while it loads.
                      color:
                          Default_Theme.primaryColor1.withValues(alpha: 0.05),
                      child: LoadImageCached(
                        imageUrl: card.image,
                        fallbackUrl: card.fallback,
                        width: size,
                        height: size,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 32,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          card.title,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _titleStyle,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          card.subtitle,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _subtitleStyle,
                        ),
                      ],
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

  static const _titleStyle = TextStyle(
    fontFamily: 'Gilroy',
    fontSize: 13,
    fontWeight: FontWeight.bold,
    color: Default_Theme.primaryColor1,
    height: 1.1,
  );
  static final _subtitleStyle = TextStyle(
    fontFamily: 'Gilroy',
    fontSize: 11,
    fontWeight: FontWeight.bold,
    color: Default_Theme.primaryColor1.withValues(alpha: 0.62),
    height: 1.1,
  );
}

class _CardData {
  final String image;
  final String? fallback;
  final String title;
  final String subtitle;

  const _CardData(this.image, this.fallback, this.title, this.subtitle);

  factory _CardData.of(MediaItem item) => item.when(
        track: (t) => _CardData(
          t.thumbnail.url,
          t.thumbnail.urlLow,
          t.title,
          t.artists.map((a) => a.name).join(', '),
        ),
        album: (a) => _CardData(
          a.thumbnail?.url ?? '',
          a.thumbnail?.urlLow,
          a.title,
          a.artists.map((r) => r.name).join(', '),
        ),
        artist: (a) => _CardData(
          a.thumbnail?.url ?? '',
          a.thumbnail?.urlLow,
          a.name,
          a.subtitle ?? '',
        ),
        playlist: (p) => _CardData(
          p.thumbnail.url,
          p.thumbnail.urlLow,
          p.title,
          p.owner ?? '',
        ),
      );
}
