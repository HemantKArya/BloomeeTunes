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
class HorizontalCardView extends StatelessWidget {
  final Section section;
  final String pluginId;
  final ScrollController _scrollController = ScrollController();

  HorizontalCardView({
    super.key,
    required this.section,
    required this.pluginId,
  });

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
              section.title,
              textAlign: TextAlign.start,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Default_Theme.accentColor2,
              ).merge(Default_Theme.secondoryTextStyle),
            ),
          ),
          Expanded(
            child: SizedBox(
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
                      itemCount: section.items.length,
                      itemBuilder: (context, i) {
                        final item = section.items[i];
                        return GestureDetector(
                          onTap: () => _handleItemTap(context, item),
                          child: _buildCard(item),
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
          ),
        ],
      ),
    );
  }

  void _handleItemTap(BuildContext context, MediaItem item) {
    final loadedPluginIds = context.read<PluginBloc>().state.loadedPluginIds;
    if (!requirePlugin(pluginId, loadedPluginIds)) {
      return;
    }

    item.when(
      track: (track) {
        // Collect all Track objects from the section for queue context.
        final tracks = <Track>[];
        for (final mediaItem in section.items) {
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
              Playlist(tracks: tracks, title: section.title),
              idx: idx >= 0 ? idx : 0,
              doPlay: true,
            );
      },
      album: (album) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AlbumView(album: album, pluginId: pluginId),
          ),
        );
      },
      artist: (artist) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ArtistView(artist: artist, pluginId: pluginId),
          ),
        );
      },
      playlist: (playlist) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                OnlPlaylistView(playlist: playlist, pluginId: pluginId),
          ),
        );
      },
    );
  }

  Widget _buildCard(MediaItem item) {
    return item.when(
      track: (track) => SquareImgCard(
        imgPath: track.thumbnail.url,
        fallbackImgPath: track.thumbnail.urlLow ?? track.thumbnail.url,
        title: track.title,
        subtitle: track.artists.map((a) => a.name).join(', '),
        isList: false,
      ),
      album: (album) => SquareImgCard(
        imgPath: album.thumbnail?.url ?? '',
        fallbackImgPath: album.thumbnail?.url,
        title: album.title,
        subtitle: album.artists.map((a) => a.name).join(', '),
        isList: true,
      ),
      artist: (artist) => SquareImgCard(
        imgPath: artist.thumbnail?.url ?? '',
        fallbackImgPath: artist.thumbnail?.url,
        title: artist.name,
        subtitle: artist.subtitle ?? '',
        isList: false,
      ),
      playlist: (playlist) => SquareImgCard(
        imgPath: playlist.thumbnail.url,
        fallbackImgPath: playlist.thumbnail.url,
        title: playlist.title,
        subtitle: playlist.owner ?? '',
        isList: true,
      ),
    );
  }
}
