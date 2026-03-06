import 'package:Bloomee/blocs/media_player/bloomee_player_cubit.dart';
import 'package:Bloomee/core/di/service_locator.dart';
import 'package:Bloomee/core/events/global_event_bus.dart';
import 'package:Bloomee/core/models/exported.dart';
import 'package:Bloomee/core/models/media_playlist_model.dart';
import 'package:Bloomee/plugins/blocs/content/content_bloc.dart';
import 'package:Bloomee/plugins/blocs/content/content_event.dart';
import 'package:Bloomee/plugins/blocs/content/content_state.dart';
import 'package:Bloomee/plugins/blocs/plugin/plugin_bloc.dart';
import 'package:Bloomee/blocs/library/cubit/library_items_cubit.dart';
import 'package:Bloomee/screens/widgets/more_bottom_sheet.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:Bloomee/screens/widgets/song_tile.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/utils/imgurl_formator.dart';
import 'package:Bloomee/utils/load_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:url_launcher/url_launcher.dart';

/// Displays album details loaded via the plugin system.
class AlbumView extends StatefulWidget {
  final AlbumSummary album;
  final String pluginId;

  const AlbumView({super.key, required this.album, required this.pluginId});

  @override
  State<AlbumView> createState() => _AlbumViewState();
}

class _AlbumViewState extends State<AlbumView> {
  late final ContentBloc _contentBloc;
  final ScrollController _scrollController = ScrollController();
  bool _isSaved = false;

  String _sourceName(BuildContext context) {
    final plugins = context.read<PluginBloc>().state.availablePlugins;
    for (final plugin in plugins) {
      if (plugin.manifest.id == widget.pluginId) {
        return plugin.manifest.name;
      }
    }
    return widget.pluginId;
  }

  @override
  void initState() {
    super.initState();
    _contentBloc = ContentBloc(pluginService: ServiceLocator.pluginService);
    _scrollController.addListener(_onScroll);
    // Guard: verify plugin is still loaded before requesting details.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final isLoaded =
          context.read<PluginBloc>().state.isPluginLoaded(widget.pluginId);
      if (!isLoaded) {
        GlobalEventBus.instance.emitError(
          AppError.pluginNotLoaded(pluginId: widget.pluginId),
        );
        return;
      }
      _contentBloc.add(LoadAlbumDetails(
        pluginId: widget.pluginId,
        albumId: widget.album.id,
      ));
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkSavedState());
  }

  Future<void> _checkSavedState() async {
    final saved = await context
        .read<LibraryItemsCubit>()
        .isRemoteSaved(widget.album.id, PlaylistType.album);
    if (mounted) setState(() => _isSaved = saved);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final details = _contentBloc.state.albumDetails;
    final nextPageToken = details?.tracks.nextPageToken;
    final status = _contentBloc.state.albumDetailStatus;
    if (nextPageToken == null ||
        status == DetailStatus.loading ||
        status == DetailStatus.loadingMore) {
      return;
    }

    final remaining =
        _scrollController.position.maxScrollExtent - _scrollController.offset;
    if (remaining <= 320) {
      _contentBloc.add(LoadMoreAlbumTracks(
        pluginId: widget.pluginId,
        albumId: widget.album.id,
        pageToken: nextPageToken,
      ));
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _contentBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: BlocBuilder<ContentBloc, ContentState>(
          bloc: _contentBloc,
          builder: (context, state) {
            final details = state.albumDetails;
            final tracks = details?.tracks.items ?? [];
            final detailArtists = details?.summary.artists
                    .map((a) => a.name.trim())
                    .where((name) => name.isNotEmpty)
                    .toList() ??
                const <String>[];
            final albumArtists = detailArtists.join(', ');

            return CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverAppBar(
                  expandedHeight:
                      ResponsiveBreakpoints.of(context).isMobile ? 220 : 250,
                  flexibleSpace: LayoutBuilder(builder: (context, constraints) {
                    final subtitle = <String>[
                      if (widget.album.year != null &&
                          widget.album.year.toString().trim().isNotEmpty)
                        widget.album.year.toString().trim(),
                      if (tracks.isNotEmpty)
                        '${tracks.length} ${tracks.length == 1 ? 'track' : 'tracks'}',
                      if (widget.album.subtitle != null &&
                          widget.album.subtitle!.trim().isNotEmpty)
                        widget.album.subtitle!.trim(),
                    ].join(' • ');

                    return FlexibleSpaceBar(
                      background: Padding(
                        padding: const EdgeInsets.only(
                            left: 8, right: 8, top: 34, bottom: 8),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: constraints.maxHeight,
                            minWidth: 350,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.4,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Hero(
                                    tag:
                                        '${widget.pluginId}_album_${widget.album.id}',
                                    child: LoadImageCached(
                                      imageUrl: formatImgURL(
                                        widget.album.thumbnail?.url ?? '',
                                        ImageQuality.medium,
                                      ),
                                      fallbackUrl: widget.album.thumbnail?.url,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        widget.album.title,
                                        maxLines: 2,
                                        style: Default_Theme
                                            .secondoryTextStyleMedium
                                            .merge(TextStyle(
                                          overflow: TextOverflow.ellipsis,
                                          fontSize: 18,
                                          color: Default_Theme.primaryColor1
                                              .withValues(alpha: 0.9),
                                        )),
                                      ),
                                      if (albumArtists.isNotEmpty)
                                        Text(
                                          albumArtists,
                                          maxLines: 2,
                                          style: Default_Theme
                                              .secondoryTextStyle
                                              .merge(TextStyle(
                                            overflow: TextOverflow.ellipsis,
                                            fontSize: 13,
                                            color: Default_Theme.primaryColor1
                                                .withValues(alpha: 0.62),
                                          )),
                                        ),
                                      if (subtitle.isNotEmpty)
                                        Text(
                                          subtitle,
                                          style: Default_Theme
                                              .secondoryTextStyle
                                              .merge(TextStyle(
                                            fontSize: 13,
                                            color: Default_Theme.primaryColor1
                                                .withValues(alpha: 0.5),
                                          )),
                                        ),
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              OutlinedButton.icon(
                                                style: OutlinedButton.styleFrom(
                                                  side: const BorderSide(
                                                    width: 2,
                                                    color: Default_Theme
                                                        .accentColor2,
                                                  ),
                                                ),
                                                onPressed: () {
                                                  if (tracks.isNotEmpty) {
                                                    context
                                                        .read<
                                                            BloomeePlayerCubit>()
                                                        .bloomeePlayer
                                                        .loadPlaylist(
                                                          Playlist(
                                                            tracks: tracks,
                                                            title: widget
                                                                .album.title,
                                                          ),
                                                          doPlay: true,
                                                          idx: 0,
                                                        );
                                                  }
                                                },
                                                label: const Text('Play',
                                                    style: Default_Theme
                                                        .secondoryTextStyleMedium),
                                                icon: const Icon(
                                                    MingCute.play_fill,
                                                    size: 20),
                                              ),
                                              Tooltip(
                                                message: _isSaved
                                                    ? 'Remove from Library'
                                                    : 'Save to Library',
                                                child: IconButton(
                                                  onPressed: () async {
                                                    final cubit = context.read<
                                                        LibraryItemsCubit>();
                                                    if (_isSaved) {
                                                      await cubit
                                                          .removeRemoteSaved(
                                                              widget.album.id,
                                                              PlaylistType
                                                                  .album);
                                                    } else {
                                                      await cubit
                                                          .saveRemoteAlbum(
                                                        album: widget.album,
                                                        sourceName: _sourceName(
                                                            context),
                                                      );
                                                    }
                                                    await _checkSavedState();
                                                  },
                                                  icon: Icon(
                                                    _isSaved
                                                        ? Icons.favorite
                                                        : Icons.favorite_border,
                                                    size: 25,
                                                    color: Default_Theme
                                                        .accentColor2,
                                                  ),
                                                ),
                                              ),
                                              if (widget.album.url != null)
                                                Tooltip(
                                                  message: 'Open Original Link',
                                                  child: IconButton(
                                                    onPressed: () {
                                                      SnackbarService.showMessage(
                                                          'Opening original album page.');
                                                      launchUrl(
                                                        Uri.parse(
                                                            widget.album.url!),
                                                        mode: LaunchMode
                                                            .externalApplication,
                                                      );
                                                    },
                                                    icon: const Icon(
                                                      MingCute
                                                          .external_link_line,
                                                      size: 25,
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
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                    child: Text(
                      widget.album.title,
                      maxLines: 3,
                      textAlign: TextAlign.center,
                      style: Default_Theme.secondoryTextStyleMedium
                          .merge(TextStyle(
                        fontSize: 20,
                        color:
                            Default_Theme.primaryColor1.withValues(alpha: 0.8),
                      )),
                    ),
                  ),
                ),
                if ((state.albumDetailStatus == DetailStatus.loaded ||
                        state.albumDetailStatus == DetailStatus.loadingMore) &&
                    tracks.isNotEmpty)
                  SliverList.builder(
                    itemCount: tracks.length,
                    itemBuilder: (context, index) {
                      return SongCardWidget(
                        song: tracks[index],
                        onOptionsTap: () => showMoreBottomSheet(
                          context,
                          tracks[index],
                          showDelete: false,
                          showSinglePlay: true,
                        ),
                        onTap: () {
                          context
                              .read<BloomeePlayerCubit>()
                              .bloomeePlayer
                              .loadPlaylist(
                                Playlist(
                                    tracks: tracks, title: widget.album.title),
                                doPlay: true,
                                idx: index,
                              );
                        },
                      );
                    },
                  )
                else if (state.albumDetailStatus == DetailStatus.loaded)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(
                        'No tracks available',
                        style: TextStyle(color: Default_Theme.primaryColor1),
                      ),
                    ),
                  )
                else if (state.albumDetailStatus == DetailStatus.error)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(
                        state.error ?? 'Failed to load album',
                        style:
                            const TextStyle(color: Default_Theme.primaryColor1),
                      ),
                    ),
                  )
                else
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                if (state.albumDetailStatus == DetailStatus.loadingMore)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
