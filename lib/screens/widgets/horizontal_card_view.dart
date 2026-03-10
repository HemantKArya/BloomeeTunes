import 'dart:io';
import 'package:Bloomee/blocs/media_player/bloomee_player_cubit.dart';
import 'package:Bloomee/core/models/exported.dart';
import 'package:Bloomee/core/models/media_playlist_model.dart';
import 'package:Bloomee/core/events/global_event_bus.dart';
import 'package:Bloomee/plugins/blocs/plugin/plugin_bloc.dart';
import 'package:Bloomee/screens/screen/common_views/album_view.dart';
import 'package:Bloomee/screens/screen/common_views/artist_view.dart';
import 'package:Bloomee/screens/screen/common_views/playlist_view.dart';
import 'package:Bloomee/screens/widgets/square_card.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';

/// Displays a horizontal scrollable card view for a home [Section].
class HorizontalCardView extends StatefulWidget {
  final Section section;
  final String pluginId;
  final VoidCallback? onLoadMore;
  final bool canLoadMore;
  final bool isLoadingMore;

  HorizontalCardView({
    super.key,
    required this.section,
    required this.pluginId,
    this.onLoadMore,
    this.canLoadMore = false,
    this.isLoadingMore = false,
  });

  @override
  State<HorizontalCardView> createState() => _HorizontalCardViewState();
}

class _HorizontalCardViewState extends State<HorizontalCardView> {
  late final ScrollController _scrollController;
  bool _loadMoreRequested = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_maybeLoadMore);
  }

  @override
  void didUpdateWidget(covariant HorizontalCardView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isLoadingMore != widget.isLoadingMore ||
        oldWidget.canLoadMore != widget.canLoadMore ||
        oldWidget.section.items.length != widget.section.items.length) {
      _loadMoreRequested = false;
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_maybeLoadMore)
      ..dispose();
    super.dispose();
  }

  void _scrollToNext() {
    _scrollController.animateTo(
      _scrollController.offset + 200,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollToPrevious() {
    _scrollController.animateTo(
      _scrollController.offset - 200,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _maybeLoadMore() {
    if (!_scrollController.hasClients ||
        !widget.canLoadMore ||
        widget.isLoadingMore ||
        _loadMoreRequested) {
      return;
    }

    final remaining =
        _scrollController.position.maxScrollExtent - _scrollController.offset;
    if (remaining <= 240) {
      _loadMoreRequested = true;
      widget.onLoadMore?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 5),
            child: Text(
              widget.section.title,
              textAlign: TextAlign.start,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Default_Theme.accentColor2,
              ).merge(Default_Theme.secondoryTextStyle),
            ),
          ),
          SizedBox(
            height: 220,
            child: Row(
              children: [
                if (Platform.isWindows || Platform.isLinux)
                  IconButton(
                    icon: const Icon(MingCute.left_line),
                    onPressed: _scrollToPrevious,
                  ),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.section.items.length +
                        (widget.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, i) {
                      if (i >= widget.section.items.length) {
                        return const SizedBox(
                          width: 96,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Default_Theme.accentColor2,
                            ),
                          ),
                        );
                      }

                      final item = widget.section.items[i];
                      return _buildCard(
                        item,
                        onTap: () => _handleItemTap(context, item),
                      );
                    },
                  ),
                ),
                if (Platform.isWindows || Platform.isLinux)
                  IconButton(
                    icon: const Icon(MingCute.right_line),
                    onPressed: _scrollToNext,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleItemTap(BuildContext context, MediaItem item) {
    final loadedPluginIds = context.read<PluginBloc>().state.loadedPluginIds;
    if (!requirePlugin(widget.pluginId, loadedPluginIds)) {
      return;
    }

    item.when(
      track: (track) {
        // Collect all Track objects from the section for queue context.
        final tracks = <Track>[];
        for (final mediaItem in widget.section.items) {
          mediaItem.when(
            track: (t) => tracks.add(t),
            album: (_) {},
            artist: (_) {},
            playlist: (_) {},
          );
        }
        if (tracks.isEmpty) return;
        final idx = tracks.indexWhere((t) => t.id == track.id);
        context.read<BloomeePlayerCubit>().bloomeePlayer.loadPlaylist(
              Playlist(tracks: tracks, title: widget.section.title),
              idx: idx >= 0 ? idx : 0,
              doPlay: true,
            );
      },
      album: (album) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AlbumView(album: album, pluginId: widget.pluginId),
          ),
        );
      },
      artist: (artist) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                ArtistView(artist: artist, pluginId: widget.pluginId),
          ),
        );
      },
      playlist: (playlist) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                OnlPlaylistView(playlist: playlist, pluginId: widget.pluginId),
          ),
        );
      },
    );
  }

  Widget _buildCard(MediaItem item, {VoidCallback? onTap}) {
    return item.when(
      track: (track) => SquareImgCard(
        imgPath: track.thumbnail.url,
        fallbackImgPath: track.thumbnail.urlLow ?? track.thumbnail.url,
        title: track.title,
        subtitle: track.artists.map((a) => a.name).join(', '),
        isList: false,
        onTap: onTap,
      ),
      album: (album) => SquareImgCard(
        imgPath: album.thumbnail?.url ?? '',
        fallbackImgPath: album.thumbnail?.url,
        title: album.title,
        subtitle: album.artists.map((a) => a.name).join(', '),
        isList: true,
        onTap: onTap,
      ),
      artist: (artist) => SquareImgCard(
        imgPath: artist.thumbnail?.url ?? '',
        fallbackImgPath: artist.thumbnail?.url,
        title: artist.name,
        subtitle: artist.subtitle ?? '',
        isList: false,
        onTap: onTap,
      ),
      playlist: (playlist) => SquareImgCard(
        imgPath: playlist.thumbnail.url,
        fallbackImgPath: playlist.thumbnail.url,
        title: playlist.title,
        subtitle: playlist.owner ?? '',
        isList: true,
        onTap: onTap,
      ),
    );
  }
}
