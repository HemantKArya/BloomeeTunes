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
import 'package:Bloomee/screens/widgets/album_card.dart';
import 'package:Bloomee/screens/widgets/more_bottom_sheet.dart';
import 'package:Bloomee/screens/widgets/sign_board_widget.dart';
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

/// Displays artist details loaded via the plugin system.
class ArtistView extends StatefulWidget {
  final ArtistSummary artist;
  final String pluginId;

  const ArtistView({super.key, required this.artist, required this.pluginId});

  @override
  State<ArtistView> createState() => _ArtistViewState();
}

class _ArtistViewState extends State<ArtistView> {
  late final ContentBloc _contentBloc;
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
      _contentBloc.add(LoadArtistDetails(
        pluginId: widget.pluginId,
        artistId: widget.artist.id,
      ));
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkSavedState());
  }

  Future<void> _checkSavedState() async {
    final saved = await context
        .read<LibraryItemsCubit>()
        .isRemoteSaved(widget.artist.id, PlaylistType.artist);
    if (mounted) setState(() => _isSaved = saved);
  }

  @override
  void dispose() {
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
            final details = state.artistDetails;
            final topTracks = details?.topTracks ?? [];
            final albums = details?.albums.items ?? [];
            final artistMeta = <String>[
              if (topTracks.isNotEmpty)
                '${topTracks.length} ${topTracks.length == 1 ? 'top track' : 'top tracks'}',
              if (albums.isNotEmpty)
                '${albums.length} ${albums.length == 1 ? 'album' : 'albums'}',
              if (widget.artist.subtitle != null &&
                  widget.artist.subtitle!.trim().isNotEmpty)
                widget.artist.subtitle!.trim(),
            ];

            return DefaultTabController(
              length: 2,
              child: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  SliverAppBar(
                    expandedHeight:
                        ResponsiveBreakpoints.of(context).isMobile ? 220 : 250,
                    flexibleSpace:
                        LayoutBuilder(builder: (context, constraints) {
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
                                          '${widget.pluginId}_artist_${widget.artist.id}',
                                      child: ClipOval(
                                        child: LoadImageCached(
                                          imageUrl: formatImgURL(
                                            widget.artist.thumbnail?.url ?? '',
                                            ImageQuality.medium,
                                          ),
                                          fallbackUrl:
                                              widget.artist.thumbnail?.url,
                                          fit: BoxFit.fitWidth,
                                        ),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          widget.artist.name,
                                          maxLines: 3,
                                          style: Default_Theme
                                              .secondoryTextStyleMedium
                                              .merge(TextStyle(
                                            overflow: TextOverflow.ellipsis,
                                            fontSize: 18,
                                            color: Default_Theme.primaryColor1
                                                .withValues(alpha: 0.8),
                                          )),
                                        ),
                                        if (artistMeta.isNotEmpty)
                                          Text(
                                            artistMeta.join(' • '),
                                            maxLines: 1,
                                            style: Default_Theme
                                                .secondoryTextStyle
                                                .merge(TextStyle(
                                              overflow: TextOverflow.ellipsis,
                                              fontSize: 12.5,
                                              color: Default_Theme.accentColor2
                                                  .withValues(alpha: 0.9),
                                            )),
                                          ),
                                        if (details?.description != null &&
                                            details!.description!.isNotEmpty)
                                          Text(
                                            details.description!,
                                            maxLines: 3,
                                            style: Default_Theme
                                                .secondoryTextStyle
                                                .merge(TextStyle(
                                              overflow: TextOverflow.ellipsis,
                                              fontSize: 13,
                                              color: Default_Theme.primaryColor1
                                                  .withValues(alpha: 0.5),
                                            )),
                                          ),
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 5),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                OutlinedButton.icon(
                                                  style:
                                                      OutlinedButton.styleFrom(
                                                    side: const BorderSide(
                                                      width: 2,
                                                      color: Default_Theme
                                                          .accentColor2,
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    if (topTracks.isNotEmpty) {
                                                      context
                                                          .read<
                                                              BloomeePlayerCubit>()
                                                          .bloomeePlayer
                                                          .loadPlaylist(
                                                            Playlist(
                                                              tracks: topTracks,
                                                              title: widget
                                                                  .artist.name,
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
                                                                widget
                                                                    .artist.id,
                                                                PlaylistType
                                                                    .artist);
                                                      } else {
                                                        await cubit
                                                            .saveRemoteArtist(
                                                          artist: widget.artist,
                                                          sourceName:
                                                              _sourceName(
                                                                  context),
                                                        );
                                                      }
                                                      await _checkSavedState();
                                                    },
                                                    icon: Icon(
                                                      _isSaved
                                                          ? Icons.favorite
                                                          : Icons
                                                              .favorite_border,
                                                      size: 25,
                                                      color: Default_Theme
                                                          .accentColor2,
                                                    ),
                                                  ),
                                                ),
                                                if (widget.artist.url != null)
                                                  Tooltip(
                                                    message:
                                                        'Open Original Link',
                                                    child: IconButton(
                                                      onPressed: () {
                                                        SnackbarService.showMessage(
                                                            'Opening original artist page.');
                                                        launchUrl(
                                                          Uri.parse(widget
                                                              .artist.url!),
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
                    child: TabBar(
                      dividerColor: Colors.transparent,
                      indicatorColor: Default_Theme.accentColor2,
                      labelColor: Default_Theme.primaryColor1,
                      unselectedLabelColor:
                          Default_Theme.primaryColor1.withValues(alpha: 0.5),
                      tabs: const [
                        Tab(text: 'Top Songs'),
                        Tab(text: 'Albums'),
                      ],
                    ),
                  ),
                ],
                body: state.artistDetailStatus == DetailStatus.loaded
                    ? TabBarView(
                        children: [
                          // Top Songs tab
                          topTracks.isNotEmpty
                              ? ListView.builder(
                                  itemCount: topTracks.length,
                                  itemBuilder: (context, index) {
                                    return SongCardWidget(
                                      song: topTracks[index],
                                      onOptionsTap: () => showMoreBottomSheet(
                                        context,
                                        topTracks[index],
                                        showDelete: false,
                                        showSinglePlay: true,
                                      ),
                                      onTap: () {
                                        context
                                            .read<BloomeePlayerCubit>()
                                            .bloomeePlayer
                                            .loadPlaylist(
                                              Playlist(
                                                tracks: topTracks,
                                                title: widget.artist.name,
                                              ),
                                              doPlay: true,
                                              idx: index,
                                            );
                                      },
                                    );
                                  },
                                )
                              : const Center(
                                  child: SignBoardWidget(
                                    message: 'No top songs available',
                                    icon: MingCute.music_2_line,
                                  ),
                                ),
                          // Albums tab
                          albums.isNotEmpty
                              ? SingleChildScrollView(
                                  child: Wrap(
                                    alignment: WrapAlignment.center,
                                    runSpacing: 10,
                                    children: albums
                                        .map((album) => AlbumCard(
                                              album: album,
                                              pluginId: widget.pluginId,
                                            ))
                                        .toList(),
                                  ),
                                )
                              : const Center(
                                  child: SignBoardWidget(
                                    message: 'No albums available',
                                    icon: MingCute.album_line,
                                  ),
                                ),
                        ],
                      )
                    : state.artistDetailStatus == DetailStatus.error
                        ? Center(
                            child: Text(
                              state.error ?? 'Failed to load artist',
                              style: const TextStyle(
                                  color: Default_Theme.primaryColor1),
                            ),
                          )
                        : const Center(child: CircularProgressIndicator()),
              ),
            );
          },
        ),
      ),
    );
  }
}
