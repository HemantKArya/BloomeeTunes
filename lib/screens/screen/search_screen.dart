// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';

import 'package:Bloomee/blocs/media_player/bloomee_player_cubit.dart';
import 'package:Bloomee/blocs/search_suggestions/search_suggestion_bloc.dart';
import 'package:Bloomee/blocs/internet_connectivity/cubit/connectivity_cubit.dart';
import 'package:Bloomee/core/di/service_locator.dart';
import 'package:Bloomee/core/models/exported.dart';
import 'package:Bloomee/core/models/media_playlist_model.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
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
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  final ValueNotifier<ContentSearchFilter> _filter =
      ValueNotifier(ContentSearchFilter.all);
  String? _activePluginId;

  bool _isSearching = false;
  int _highlightedSuggestionIndex = -1;
  List<String> _currentCombinedSuggestions = [];

  @override
  void initState() {
    super.initState();
    _contentBloc = ContentBloc(pluginService: ServiceLocator.pluginService);
    _scrollController.addListener(_onSearchScroll);

    _searchFocusNode.addListener(() {
      setState(() {
        _isSearching = _searchFocusNode.hasFocus;
        if (_isSearching) {
          context
              .read<SearchSuggestionBloc>()
              .add(SearchSuggestionFetch(_textEditingController.text));
        }
      });
    });

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
    _searchFocusNode.dispose();
    _filter.dispose();
    _contentBloc.close();
    super.dispose();
  }

  void _onSearchScroll() {
    if (!_scrollController.hasClients) return;
    if (_searchFocusNode.hasFocus) _searchFocusNode.unfocus();

    final state = _contentBloc.state;
    final nextPageToken = state.searchResults?.nextPageToken;
    if (nextPageToken == null ||
        state.searchStatus == SearchStatus.loading ||
        state.searchStatus == SearchStatus.loadingMore) {
      return;
    }

    final remaining =
        _scrollController.position.maxScrollExtent - _scrollController.offset;
    if (remaining <= 400) {
      _contentBloc.add(LoadMoreSearchContent(pageToken: nextPageToken));
    }
  }

  void _doSearch(String query) {
    if (query.trim().isEmpty || _activePluginId == null) return;

    // Save search history
    context
        .read<SearchSuggestionBloc>()
        .add(SearchSuggestionSave(query.trim()));

    _searchFocusNode.unfocus();

    _contentBloc.add(SearchContent(
      query: query.trim(),
      filter: _filter.value,
    ));
  }

  void _triggerSearch() {
    if (_textEditingController.text.trim().isNotEmpty) {
      _doSearch(_textEditingController.text);
    }
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (!_isSearching || _currentCombinedSuggestions.isEmpty) {
      return KeyEventResult.ignored;
    }

    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        setState(() {
          _highlightedSuggestionIndex = (_highlightedSuggestionIndex + 1)
              .clamp(-1, _currentCombinedSuggestions.length - 1);
        });
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        setState(() {
          _highlightedSuggestionIndex = (_highlightedSuggestionIndex - 1)
              .clamp(-1, _currentCombinedSuggestions.length - 1);
        });
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Default_Theme.themeColor,
        body: SafeArea(
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildModernSearchBar(),
              _buildAestheticFilterChips(),
              if (!_isSearching) _buildPluginsGlassyBox(),
              if (_isSearching)
                _buildSuggestionsArea()
              else
                _buildContentArea(),
            ],
          ),
        ),
      ),
    );
  }

  // --- BEAUTIFUL MODERN SEARCH BAR ---
  SliverAppBar _buildModernSearchBar() {
    return SliverAppBar(
      floating: true,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      backgroundColor: Default_Theme.themeColor,
      titleSpacing: 16,
      toolbarHeight: 70,
      title: Focus(
        onKeyEvent: _handleKeyEvent,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFF161616), // Deep premium dark
            borderRadius: BorderRadius.circular(16), // Apple-like squircle
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.06),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Icon(
                MingCute.search_2_line,
                color: Default_Theme.primaryColor1.withValues(alpha: 0.5),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _textEditingController,
                  focusNode: _searchFocusNode,
                  style: TextStyle(
                    color: Default_Theme.primaryColor1.withValues(alpha: 0.95),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  onChanged: (val) {
                    setState(() => _highlightedSuggestionIndex = -1);
                    context
                        .read<SearchSuggestionBloc>()
                        .add(SearchSuggestionFetch(val));
                  },
                  onSubmitted: (val) {
                    if (_highlightedSuggestionIndex >= 0 &&
                        _highlightedSuggestionIndex <
                            _currentCombinedSuggestions.length) {
                      final selected = _currentCombinedSuggestions[
                          _highlightedSuggestionIndex];
                      _textEditingController.text = selected;
                      _doSearch(selected);
                    } else {
                      _doSearch(val);
                    }
                  },
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    hintText: "What do you want to listen to?",
                    hintStyle: TextStyle(
                      color:
                          Default_Theme.primaryColor1.withValues(alpha: 0.35),
                      fontFamily: "Unageo",
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _textEditingController,
                builder: (context, value, child) {
                  if (value.text.isNotEmpty) {
                    return IconButton(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      icon: Icon(MingCute.close_fill,
                          color: Default_Theme.primaryColor1
                              .withValues(alpha: 0.5),
                          size: 18),
                      onPressed: () {
                        _textEditingController.clear();
                        context
                            .read<SearchSuggestionBloc>()
                            .add(const SearchSuggestionFetch(''));
                        _searchFocusNode.requestFocus();
                      },
                    );
                  }
                  return const SizedBox(width: 16);
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  // --- SEPARATED, AESTHETIC FILTER CHIPS (Compact & Sleek) ---
  Widget _buildAestheticFilterChips() {
    return SliverToBoxAdapter(
      child: ValueListenableBuilder<ContentSearchFilter>(
        valueListenable: _filter,
        builder: (context, filterValue, child) {
          return SizedBox(
            height: 38, // REDUCED: Was 48. Makes the chip height much sleeker.
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 2), // REDUCED vertical padding
              physics: const BouncingScrollPhysics(),
              itemCount: ContentSearchFilter.values.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final e = ContentSearchFilter.values[index];
                final isSelected = filterValue == e;
                final displayName =
                    e.name[0].toUpperCase() + e.name.substring(1);

                return InkWell(
                  borderRadius: BorderRadius.circular(20),
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    _filter.value = e;
                    if (_textEditingController.text.isNotEmpty)
                      _triggerSearch();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16), // Slightly tighter horizontally too
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Default_Theme.accentColor2
                          : Default_Theme.primaryColor2.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? Default_Theme.accentColor2
                            : Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                    child: Text(
                      displayName,
                      style: Default_Theme.secondoryTextStyleMedium.copyWith(
                        color: isSelected
                            ? Default_Theme.primaryColor2
                            : Default_Theme.primaryColor1
                                .withValues(alpha: 0.8),
                        fontSize:
                            13, // Adjusted slightly to match compact height
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  // --- REDESIGNED PLUGINS PANEL ---
  Widget _buildPluginsGlassyBox() {
    return SliverToBoxAdapter(
      child: BlocBuilder<PluginBloc, PluginState>(
        builder: (context, pluginState) {
          final resolvers = pluginState.loadedContentResolvers;

          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Default_Theme.primaryColor2.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.05),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(MingCute.plugin_2_line,
                                size: 18, color: Default_Theme.accentColor2),
                            const SizedBox(width: 8),
                            Text(
                              "SOURCES",
                              style: Default_Theme.secondoryTextStyleMedium
                                  .copyWith(
                                fontSize: 12,
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.w800,
                                color: Default_Theme.primaryColor1
                                    .withValues(alpha: 0.7),
                              ),
                            ),
                            const Spacer(),
                            // The + icon requested for plugin manager
                            InkWell(
                              borderRadius: BorderRadius.circular(50),
                              onTap: () {
                                // TODO: Route to Plugin Manager later
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Icon(
                                  MingCute.add_line,
                                  size: 20,
                                  color: Default_Theme.primaryColor1
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Horizontal Scrollable Plugins List
                      if (resolvers.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Text(
                            "No plugins installed",
                            style: TextStyle(
                              color: Default_Theme.primaryColor1
                                  .withValues(alpha: 0.4),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        )
                      else
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: resolvers.map((plugin) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: _pluginChip(plugin),
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // The perfectly smooth, splash-less Plugin Chip
  Widget _pluginChip(PluginInfo plugin) {
    final id = plugin.manifest.id;
    final isSelected = _activePluginId == id;

    return InkWell(
      borderRadius: BorderRadius.circular(50),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      onTap: () {
        if (_activePluginId == id) return;
        setState(() {
          _activePluginId = id;
          _contentBloc.add(SetActiveContentPlugin(pluginId: id));
        });
        if (_textEditingController.text.isNotEmpty) _triggerSearch();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        // REDUCED: vertical padding from 8 to 5.5 for a tighter, compact look
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5.5),
        decoration: BoxDecoration(
          color: isSelected
              ? Default_Theme.accentColor2.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: isSelected
                ? Default_Theme.accentColor2
                : Default_Theme.primaryColor1.withValues(alpha: 0.15),
            width: 1.5,
          ),
        ),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSelected) ...[
                const Icon(
                  MingCute.check_line,
                  size: 13, // Scaled down slightly to match compact box
                  color: Default_Theme.accentColor2,
                ),
                const SizedBox(width: 4),
              ],
              Text(
                plugin.name,
                style: Default_Theme.secondoryTextStyleMedium.merge(
                  TextStyle(
                    color: isSelected
                        ? Default_Theme.accentColor2
                        : Default_Theme.primaryColor1.withValues(alpha: 0.8),
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- SUGGESTIONS VIEW WITH CLICK BUG FIX ---
  Widget _buildSuggestionsArea() {
    return BlocBuilder<SearchSuggestionBloc, SearchSuggestionState>(
      builder: (context, state) {
        if (state is SearchSuggestionLoading) {
          return const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
                child: CircularProgressIndicator(
                    color: Default_Theme.accentColor2)),
          );
        }

        if (state is SearchSuggestionLoaded) {
          final dbList =
              state.dbSuggestionList.map((e) => e.values.first).toList();
          final apiList = state.suggestionList;
          _currentCombinedSuggestions = [...dbList, ...apiList];

          if (_currentCombinedSuggestions.isEmpty &&
              _textEditingController.text.isEmpty) {
            return const SliverFillRemaining(
              hasScrollBody: false,
              child: SignBoardWidget(
                message: "Start typing to search...",
                icon: MingCute.keyboard_line,
              ),
            );
          }

          if (_currentCombinedSuggestions.isEmpty) {
            return const SliverFillRemaining(
              hasScrollBody: false,
              child: SignBoardWidget(
                message: "No Suggestions found!",
                icon: MingCute.ghost_line,
              ),
            );
          }

          return SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 8),
              ...dbList.asMap().entries.map((entry) {
                return _buildSuggestionTile(
                  suggestion: entry.value,
                  icon: MingCute.history_line,
                  isHistory: true,
                  isHighlighted: entry.key == _highlightedSuggestionIndex,
                );
              }),
              ...apiList.asMap().entries.map((entry) {
                return _buildSuggestionTile(
                  suggestion: entry.value,
                  icon: MingCute.search_line,
                  isHistory: false,
                  isHighlighted: (entry.key + dbList.length) ==
                      _highlightedSuggestionIndex,
                );
              }),
              const SizedBox(height: 100),
            ]),
          );
        }

        return const SliverFillRemaining(
          hasScrollBody: false,
          child: SignBoardWidget(
            message: "No Suggestions found!",
            icon: MingCute.ghost_line,
          ),
        );
      },
    );
  }

  Widget _buildSuggestionTile({
    required String suggestion,
    required IconData icon,
    required bool isHistory,
    required bool isHighlighted,
  }) {
    // FIX: Using Listener with onPointerDown intercepts the click instantly,
    // before the focus is lost and the widget tree is unmounted.
    return Listener(
      onPointerDown: (event) {
        _textEditingController.text = suggestion;
        _doSearch(suggestion);
      },
      // Using a plain container here. We don't use InkWell because its tap is
      // delayed by Flutter's gesture arena, which loses the race to the focus node blur.
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          color: isHighlighted
              ? Default_Theme.primaryColor1.withValues(alpha: 0.08)
              : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          child: Row(
            children: [
              Icon(icon,
                  size: 20,
                  color: Default_Theme.primaryColor1.withValues(alpha: 0.5)),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  suggestion,
                  style: TextStyle(
                          color: Default_Theme.primaryColor1
                              .withValues(alpha: 0.9),
                          fontSize: 15.5)
                      .merge(Default_Theme.secondoryTextStyle),
                ),
              ),
              if (isHistory)
                GestureDetector(
                  onTap: () => context
                      .read<SearchSuggestionBloc>()
                      .add(SearchSuggestionClear(suggestion)),
                  child: Icon(MingCute.close_fill,
                      color: Default_Theme.primaryColor1.withValues(alpha: 0.4),
                      size: 18),
                )
              else
                GestureDetector(
                  onTap: () {
                    _textEditingController.text = suggestion;
                    _searchFocusNode.requestFocus();
                    _textEditingController.selection =
                        TextSelection.fromPosition(TextPosition(
                            offset: _textEditingController.text.length));
                  },
                  child: Icon(MingCute.arrow_left_up_line,
                      color: Default_Theme.primaryColor1.withValues(alpha: 0.4),
                      size: 18),
                )
            ],
          ),
        ),
      ),
    );
  }

  // --- CONTENT RESULTS VIEW ---
  Widget _buildContentArea() {
    return BlocBuilder<ConnectivityCubit, ConnectivityState>(
      builder: (context, connState) {
        if (connState == ConnectivityState.disconnected) {
          return const SliverFillRemaining(
            hasScrollBody: false,
            child: SignBoardWidget(
              icon: MingCute.wifi_off_line,
              message: "No internet connection!",
            ),
          );
        }

        return BlocBuilder<ContentBloc, ContentState>(
          bloc: _contentBloc,
          builder: (context, state) {
            final hasResults = state.searchResults != null;

            if (state.searchStatus == SearchStatus.loading && !hasResults) {
              return const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                    child: CircularProgressIndicator(
                        color: Default_Theme.accentColor2)),
              );
            }

            if ((state.searchStatus == SearchStatus.loaded ||
                    state.searchStatus == SearchStatus.loadingMore) &&
                hasResults) {
              return _buildSliverSearchResults(state);
            }

            if (state.searchStatus == SearchStatus.error) {
              return SliverFillRemaining(
                hasScrollBody: false,
                child: SignBoardWidget(
                  message: state.error ?? "Search failed!",
                  icon: MingCute.sweats_line,
                ),
              );
            }

            return const SliverFillRemaining(
              hasScrollBody: false,
              child: SignBoardWidget(
                message: "Discover amazing music...",
                icon: MingCute.planet_line,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSliverSearchResults(ContentState state) {
    final items = state.searchResults!.items;
    if (items.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: SignBoardWidget(
          message: "No results found!\nTry another keyword or source.",
          icon: MingCute.ghost_line,
        ),
      );
    }

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
    final isLoadingMore = state.searchStatus == SearchStatus.loadingMore;

    return SliverMainAxisGroup(
      slivers: [
        if (tracks.isNotEmpty) ...[
          _sliverSectionHeader('Tracks'),
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 12),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final track = tracks[index];
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    child: SongCardWidget(
                      song: track,
                      onTap: () {
                        context
                            .read<BloomeePlayerCubit>()
                            .bloomeePlayer
                            .loadPlaylist(
                              Playlist(
                                  tracks: tracks, title: state.searchQuery),
                              idx: index,
                              doPlay: true,
                            );
                      },
                      onOptionsTap: () => showMoreBottomSheet(context, track),
                    ),
                  );
                },
                childCount: tracks.length,
              ),
            ),
          ),
        ],
        if (albums.isNotEmpty) ...[
          _sliverSectionHeader('Albums'),
          _buildResponsiveGrid(albums
              .map((a) => AlbumCard(album: a, pluginId: pluginId))
              .toList()),
        ],
        if (artists.isNotEmpty) ...[
          _sliverSectionHeader('Artists'),
          _buildResponsiveGrid(artists
              .map((a) => ArtistCard(artist: a, pluginId: pluginId))
              .toList()),
        ],
        if (playlists.isNotEmpty) ...[
          _sliverSectionHeader('Playlists'),
          _buildResponsiveGrid(playlists
              .map((p) => PlaylistCard(playlist: p, pluginId: pluginId))
              .toList()),
        ],
        if (isLoadingMore)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                  child: CircularProgressIndicator(
                      color: Default_Theme.accentColor2)),
            ),
          )
        else
          const SliverPadding(padding: EdgeInsets.only(bottom: 30)),
      ],
    );
  }

  Widget _sliverSectionHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(left: 20, top: 20, bottom: 12),
        child: Text(
          title,
          style: Default_Theme.secondoryTextStyleMedium.merge(
            TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Default_Theme.primaryColor1.withValues(alpha: 0.9),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveGrid(List<Widget> children) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverToBoxAdapter(
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.start,
          children: children,
        ),
      ),
    );
  }
}
