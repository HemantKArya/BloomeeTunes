// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:Bloomee/blocs/media_player/bloomee_player_cubit.dart';
import 'package:Bloomee/core/di/service_locator.dart';
import 'package:Bloomee/core/models/exported.dart';
import 'package:Bloomee/core/models/media_playlist_model.dart';
import 'package:Bloomee/plugins/blocs/content/content_bloc.dart';
import 'package:Bloomee/plugins/blocs/content/content_event.dart';
import 'package:Bloomee/plugins/blocs/content/content_state.dart';
import 'package:Bloomee/plugins/blocs/plugin/plugin_bloc.dart';
import 'package:Bloomee/plugins/blocs/plugin/plugin_state.dart';
import 'package:Bloomee/screens/widgets/album_card.dart';
import 'package:Bloomee/screens/widgets/artist_card.dart';
import 'package:Bloomee/screens/widgets/more_bottom_sheet.dart';
import 'package:Bloomee/screens/widgets/playlist_card.dart';
import 'package:Bloomee/screens/widgets/sign_board_widget.dart';
import 'package:Bloomee/screens/widgets/song_tile.dart';
import 'package:Bloomee/src/rust/api/plugin/commands.dart';
import 'package:Bloomee/src/rust/api/plugin/plugin_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:Bloomee/blocs/internet_connectivity/cubit/connectivity_cubit.dart';
import 'package:Bloomee/screens/screen/search_views/search_page.dart';
import 'package:Bloomee/core/theme/app_theme.dart';

class SearchScreen extends StatefulWidget {
  final String searchQuery;
  const SearchScreen({
    Key? key,
    this.searchQuery = "",
  }) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final ContentBloc _contentBloc;
  final TextEditingController _textEditingController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<ContentSearchFilter> _filter =
      ValueNotifier(ContentSearchFilter.all);
  String? _activePluginId;

  @override
  void initState() {
    super.initState();
    _contentBloc = ContentBloc(pluginService: ServiceLocator.pluginService);

    // Pick first loaded content resolver as default
    final pluginState = context.read<PluginBloc>().state;
    final resolvers = pluginState.loadedContentResolvers;
    if (resolvers.isNotEmpty) {
      _activePluginId = resolvers.first.manifest.id;
      _contentBloc.add(SetActiveContentPlugin(pluginId: _activePluginId!));
    }

    if (widget.searchQuery.isNotEmpty) {
      _textEditingController.text = widget.searchQuery;
      _doSearch(widget.searchQuery);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textEditingController.dispose();
    _filter.dispose();
    _contentBloc.close();
    super.dispose();
  }

  void _doSearch(String query) {
    if (query.trim().isEmpty || _activePluginId == null) return;
    _contentBloc.add(SearchContent(
      query: query.trim(),
      filter: _filter.value,
    ));
  }

  Widget _pluginRadioButton(PluginInfo plugin) {
    final id = plugin.manifest.id;
    final isSelected = _activePluginId == id;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: SizedBox(
        height: 27,
        child: OutlinedButton(
          onPressed: () {
            setState(() {
              _activePluginId = id;
              _contentBloc.add(SetActiveContentPlugin(pluginId: id));
              if (_textEditingController.text.trim().isNotEmpty) {
                _doSearch(_textEditingController.text);
              }
            });
          },
          style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.only(left: 10, right: 10),
              backgroundColor:
                  isSelected ? Default_Theme.accentColor2 : Colors.transparent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              side: const BorderSide(
                  color: Default_Theme.accentColor2,
                  style: BorderStyle.solid,
                  width: 2)),
          child: Text(
            plugin.name,
            style: TextStyle(
                    color: isSelected
                        ? Default_Theme.primaryColor2
                        : Default_Theme.accentColor2,
                    fontSize: 13)
                .merge(Default_Theme.secondoryTextStyleMedium),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        onVerticalDragEnd: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          appBar: AppBar(
            shadowColor: Colors.black,
            surfaceTintColor: Default_Theme.themeColor,
            title: SizedBox(
              height: 50.0,
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    showSearch(
                      context: context,
                      delegate: SearchPageDelegate(_filter.value),
                      query: _textEditingController.text,
                    ).then((value) {
                      if (value != null) {
                        _textEditingController.text = value.toString();
                        _doSearch(value.toString());
                      }
                    });
                  },
                  child: TextField(
                    controller: _textEditingController,
                    enabled: false,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Default_Theme.primaryColor1
                            .withValues(alpha: 0.55)),
                    decoration: InputDecoration(
                      filled: true,
                      suffixIcon: Icon(MingCute.search_2_fill,
                          color: Default_Theme.primaryColor1
                              .withValues(alpha: 0.4)),
                      fillColor:
                          Default_Theme.primaryColor2.withValues(alpha: 0.07),
                      contentPadding:
                          const EdgeInsets.only(top: 20, left: 15, right: 5),
                      hintText: "Find your next song obsession...",
                      hintStyle: TextStyle(
                        color:
                            Default_Theme.primaryColor1.withValues(alpha: 0.3),
                        fontFamily: "Unageo",
                        fontWeight: FontWeight.normal,
                      ),
                      disabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(style: BorderStyle.none),
                          borderRadius: BorderRadius.circular(50)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Default_Theme.primaryColor1
                                  .withValues(alpha: 0.7)),
                          borderRadius: BorderRadius.circular(50)),
                    ),
                  ),
                ),
              ),
            ),
            backgroundColor: Default_Theme.themeColor,
          ),
          backgroundColor: Default_Theme.themeColor,
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 18, right: 18, top: 5, bottom: 5),
                  child: BlocBuilder<PluginBloc, PluginState>(
                    builder: (context, pluginState) {
                      final resolvers = pluginState.loadedContentResolvers;
                      if (resolvers.isEmpty) return const SizedBox();

                      return Wrap(
                        direction: Axis.horizontal,
                        runSpacing: 8,
                        alignment: WrapAlignment.start,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          SizedBox(
                            height: 30,
                            width: 110,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ValueListenableBuilder(
                                valueListenable: _filter,
                                builder: (context, value, child) {
                                  return DropdownButtonFormField(
                                    key: UniqueKey(),
                                    isExpanded: true,
                                    isDense: true,
                                    alignment: Alignment.center,
                                    borderRadius: BorderRadius.circular(20),
                                    padding: const EdgeInsets.all(0),
                                    focusColor: Colors.transparent,
                                    dropdownColor:
                                        const Color.fromARGB(255, 15, 15, 15),
                                    decoration: InputDecoration(
                                      filled: false,
                                      contentPadding: const EdgeInsets.all(0),
                                      focusColor: Default_Theme.accentColor2,
                                      border: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              style: BorderStyle.none),
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              style: BorderStyle.none),
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              style: BorderStyle.none),
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      disabledBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              style: BorderStyle.none),
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      isDense: true,
                                    ),
                                    value: _filter.value.index,
                                    items: ContentSearchFilter.values
                                        .map((e) => DropdownMenuItem(
                                              value: e.index,
                                              child: SizedBox(
                                                height: 32,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                    left: 8,
                                                    top: 2,
                                                    bottom: 4,
                                                  ),
                                                  child: Text(
                                                    e.name[0].toUpperCase() +
                                                        e.name.substring(1),
                                                    style: Default_Theme
                                                        .secondoryTextStyleMedium
                                                        .merge(const TextStyle(
                                                      color: Default_Theme
                                                          .primaryColor1,
                                                      fontSize: 13.5,
                                                    )),
                                                  ),
                                                ),
                                              ),
                                            ))
                                        .toList(),
                                    onChanged: (value) {
                                      _filter.value =
                                          ContentSearchFilter.values[value!];
                                      if (_textEditingController.text
                                          .trim()
                                          .isNotEmpty) {
                                        _doSearch(_textEditingController.text);
                                      }
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                          for (var plugin in resolvers)
                            _pluginRadioButton(plugin),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
            body: BlocBuilder<ConnectivityCubit, ConnectivityState>(
              builder: (context, connState) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 600),
                  child: connState == ConnectivityState.disconnected
                      ? const SignBoardWidget(
                          icon: MingCute.wifi_off_line,
                          message: "No internet connection!",
                        )
                      : BlocBuilder<ContentBloc, ContentState>(
                          bloc: _contentBloc,
                          builder: (context, state) {
                            if (state.searchStatus == SearchStatus.loading) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Default_Theme.accentColor2,
                                ),
                              );
                            }
                            if (state.searchStatus == SearchStatus.loaded &&
                                state.searchResults != null) {
                              return _buildSearchResults(state);
                            }
                            if (state.searchStatus == SearchStatus.error) {
                              return SignBoardWidget(
                                message: state.error ?? "Search failed!",
                                icon: MingCute.sweats_line,
                              );
                            }
                            return const SignBoardWidget(
                              message:
                                  "Search for your favorite songs\nand discover new ones!",
                              icon: MingCute.search_2_line,
                            );
                          },
                        ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults(ContentState state) {
    final items = state.searchResults!.items;
    if (items.isEmpty) {
      return const SignBoardWidget(
        message: "No results found!\nTry another keyword or source!",
        icon: MingCute.sweats_line,
      );
    }

    // Separate items by type
    final tracks = <Track>[];
    final albums = <AlbumSummary>[];
    final artists = <ArtistSummary>[];
    final playlists = <PlaylistSummary>[];

    for (final item in items) {
      switch (item) {
        case MediaItem_Track(:final field0):
          tracks.add(field0);
        case MediaItem_Album(:final field0):
          albums.add(field0);
        case MediaItem_Artist(:final field0):
          artists.add(field0);
        case MediaItem_Playlist(:final field0):
          playlists.add(field0);
      }
    }

    final pluginId = _activePluginId ?? '';

    return ListView(
      controller: _scrollController,
      children: [
        if (tracks.isNotEmpty)
          ...tracks.map((track) => Padding(
                padding: const EdgeInsets.only(left: 4),
                child: SongCardWidget(
                  song: track,
                  onTap: () {
                    context
                        .read<BloomeePlayerCubit>()
                        .bloomeePlayer
                        .loadPlaylist(
                          Playlist(tracks: tracks, title: state.searchQuery),
                          idx: tracks.indexOf(track),
                          doPlay: true,
                        );
                  },
                  onOptionsTap: () => showMoreBottomSheet(context, track),
                ),
              )),
        if (albums.isNotEmpty) ...[
          _sectionHeader('Albums'),
          Wrap(
            alignment: WrapAlignment.center,
            runSpacing: 10,
            children: albums
                .map((a) => AlbumCard(album: a, pluginId: pluginId))
                .toList(),
          ),
        ],
        if (artists.isNotEmpty) ...[
          _sectionHeader('Artists'),
          Wrap(
            alignment: WrapAlignment.center,
            runSpacing: 10,
            children: artists
                .map((a) => ArtistCard(artist: a, pluginId: pluginId))
                .toList(),
          ),
        ],
        if (playlists.isNotEmpty) ...[
          _sectionHeader('Playlists'),
          Wrap(
            alignment: WrapAlignment.center,
            runSpacing: 10,
            children: playlists
                .map((p) => PlaylistCard(playlist: p, pluginId: pluginId))
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
      child: Text(
        title,
        style: Default_Theme.secondoryTextStyleMedium.merge(TextStyle(
          fontSize: 16,
          color: Default_Theme.primaryColor1.withValues(alpha: 0.7),
        )),
      ),
    );
  }
}
