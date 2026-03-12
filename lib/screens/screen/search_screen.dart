// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:Bloomee/blocs/settings_cubit/cubit/settings_cubit.dart';
import 'package:Bloomee/blocs/media_player/bloomee_player_cubit.dart';
import 'package:Bloomee/blocs/search_suggestions/search_suggestion_bloc.dart';
import 'package:Bloomee/blocs/internet_connectivity/cubit/connectivity_cubit.dart';
import 'package:Bloomee/core/di/service_locator.dart';
import 'package:Bloomee/core/models/exported.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/l10n/app_localizations.dart';
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
import 'package:Bloomee/src/rust/api/plugin/models.dart' as plugin_models;

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

  // Highly optimized State Management using Notifiers (Eliminates Root setState)
  final ValueNotifier<ContentSearchFilter> _filterNotifier =
      ValueNotifier(ContentSearchFilter.all);
  final ValueNotifier<String?> _activePluginIdNotifier = ValueNotifier(null);
  final ValueNotifier<bool> _isSuggestionPanelOpenNotifier =
      ValueNotifier(false);
  final ValueNotifier<int> _highlightedSuggestionIndexNotifier =
      ValueNotifier(-1);

  List<({String query, ContentSearchFilter filter})>
      _currentCombinedSuggestions = [];

  @override
  void initState() {
    super.initState();
    _contentBloc = ContentBloc(pluginService: ServiceLocator.pluginService);
    _scrollController.addListener(_onSearchScroll);

    _searchFocusNode.addListener(() {
      if (_searchFocusNode.hasFocus) {
        _isSuggestionPanelOpenNotifier.value = true;
        context
            .read<SearchSuggestionBloc>()
            .add(SearchSuggestionFetch(_textEditingController.text));
      }
    });

    final pluginState = context.read<PluginBloc>().state;
    final resolvers = pluginState.loadedContentResolvers;
    if (resolvers.isNotEmpty) {
      final persistedId = context.read<SettingsCubit>().state.searchPluginId;
      final hasPersistedPlugin = persistedId.isNotEmpty &&
          resolvers.any((p) => p.manifest.id == persistedId);
      final activeId =
          hasPersistedPlugin ? persistedId : resolvers.first.manifest.id;

      _activePluginIdNotifier.value = activeId;
      _contentBloc.add(SetActiveContentPlugin(pluginId: activeId));
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
    _filterNotifier.dispose();
    _activePluginIdNotifier.dispose();
    _isSuggestionPanelOpenNotifier.dispose();
    _highlightedSuggestionIndexNotifier.dispose();
    _contentBloc.close();
    super.dispose();
  }

  void _onSearchScroll() {
    if (!_scrollController.hasClients) return;
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

  String _normalizeSearchQuery(String query) =>
      query.trim().replaceAll(RegExp(r'\s+'), ' ');

  void _setSearchFieldText(String query) {
    _textEditingController.value = TextEditingValue(
      text: query,
      selection: TextSelection.collapsed(offset: query.length),
    );
  }

  void _closeSuggestionPanel() {
    _isSuggestionPanelOpenNotifier.value = false;
    _highlightedSuggestionIndexNotifier.value = -1;
    _searchFocusNode.unfocus();
  }

  void _openSuggestionPanel() {
    _isSuggestionPanelOpenNotifier.value = true;
    _highlightedSuggestionIndexNotifier.value = -1;
  }

  void _performSearch(
      {required String query, required ContentSearchFilter filter}) {
    final normalizedQuery = _normalizeSearchQuery(query);
    if (normalizedQuery.isEmpty || _activePluginIdNotifier.value == null)
      return;

    context
        .read<SearchSuggestionBloc>()
        .add(SearchSuggestionSave(normalizedQuery));
    _setSearchFieldText(normalizedQuery);
    _filterNotifier.value = filter;
    _closeSuggestionPanel();
    _contentBloc.add(SearchContent(query: normalizedQuery, filter: filter));
  }

  void _doSearch(String query) =>
      _performSearch(query: query, filter: _filterNotifier.value);
  void _doSearchInAllCategories(String query) =>
      _performSearch(query: query, filter: ContentSearchFilter.all);
  void _doSearchWithFilter(String query, ContentSearchFilter filter) =>
      _performSearch(query: query, filter: filter);

  void _triggerSearch() {
    if (_textEditingController.text.trim().isNotEmpty) {
      _doSearch(_textEditingController.text);
    }
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (!_isSuggestionPanelOpenNotifier.value ||
        _currentCombinedSuggestions.isEmpty) {
      return KeyEventResult.ignored;
    }

    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        _highlightedSuggestionIndexNotifier.value =
            (_highlightedSuggestionIndexNotifier.value + 1)
                .clamp(-1, _currentCombinedSuggestions.length - 1);
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        _highlightedSuggestionIndexNotifier.value =
            (_highlightedSuggestionIndexNotifier.value - 1)
                .clamp(-1, _currentCombinedSuggestions.length - 1);
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PluginBloc, PluginState>(
      listenWhen: (prev, curr) =>
          prev.loadedContentResolvers.isEmpty &&
          curr.loadedContentResolvers.isNotEmpty &&
          _activePluginIdNotifier.value == null,
      listener: (context, pluginState) {
        final resolvers = pluginState.loadedContentResolvers;
        final persistedId = context.read<SettingsCubit>().state.searchPluginId;
        final hasPersistedPlugin = persistedId.isNotEmpty &&
            resolvers.any((p) => p.manifest.id == persistedId);
        final activeId =
            hasPersistedPlugin ? persistedId : resolvers.first.manifest.id;

        _activePluginIdNotifier.value = activeId;
        _contentBloc.add(SetActiveContentPlugin(pluginId: activeId));
      },
      child: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
          _closeSuggestionPanel();
        },
        child: Scaffold(
          backgroundColor: Default_Theme.themeColor,
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              // Extracted Background Painter
              _NebulaBackground(contentBloc: _contentBloc),

              SafeArea(
                child: ValueListenableBuilder<bool>(
                  valueListenable: _isSuggestionPanelOpenNotifier,
                  builder: (context, isSuggestionPanelOpen, _) {
                    return CustomScrollView(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        _FloatingSearchBarSliver(
                          textEditingController: _textEditingController,
                          searchFocusNode: _searchFocusNode,
                          handleKeyEvent: _handleKeyEvent,
                          contentBloc: _contentBloc,
                          currentCombinedSuggestions:
                              _currentCombinedSuggestions,
                          highlightedIndexNotifier:
                              _highlightedSuggestionIndexNotifier,
                          onSearchRequested: _performSearch,
                          onClearRequested: () {
                            _textEditingController.clear();
                            _openSuggestionPanel();
                            context
                                .read<SearchSuggestionBloc>()
                                .add(const SearchSuggestionFetch(''));
                            _searchFocusNode.requestFocus();
                          },
                          onQueryChanged: (val) {
                            _openSuggestionPanel();
                            context
                                .read<SearchSuggestionBloc>()
                                .add(SearchSuggestionFetch(val));
                          },
                        ),
                        _AestheticFilterChipsSliver(
                          filterNotifier: _filterNotifier,
                          textEditingController: _textEditingController,
                          onFilterTapped: _triggerSearch,
                        ),
                        if (!isSuggestionPanelOpen)
                          _PluginsGlassyBoxSliver(
                            activePluginNotifier: _activePluginIdNotifier,
                            contentBloc: _contentBloc,
                            onPluginChanged: _triggerSearch,
                            textEditingController: _textEditingController,
                          ),
                        if (isSuggestionPanelOpen)
                          _SuggestionsSliver(
                            textEditingController: _textEditingController,
                            highlightedIndexNotifier:
                                _highlightedSuggestionIndexNotifier,
                            onSearchInAllCategories: _doSearchInAllCategories,
                            onSearchWithFilter: _doSearchWithFilter,
                            onSetSearchFieldText: (query) {
                              _setSearchFieldText(query);
                              _openSuggestionPanel();
                              _searchFocusNode.requestFocus();
                              context
                                  .read<SearchSuggestionBloc>()
                                  .add(SearchSuggestionFetch(query));
                            },
                            onSuggestionsGenerated: (suggestions) {
                              // We update this silently without triggering rebuilds for the KeyHandler
                              _currentCombinedSuggestions = suggestions;
                            },
                          )
                        else
                          _ContentSliver(
                            contentBloc: _contentBloc,
                            activePluginNotifier: _activePluginIdNotifier,
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── OPTIMIZED MODULAR SLIVERS ──────────────────────────────────────────────────

class _FloatingSearchBarSliver extends StatelessWidget {
  final TextEditingController textEditingController;
  final FocusNode searchFocusNode;
  final ContentBloc contentBloc;
  final FocusOnKeyEventCallback handleKeyEvent;
  final List<({String query, ContentSearchFilter filter})>
      currentCombinedSuggestions;
  final ValueNotifier<int> highlightedIndexNotifier;
  final Function({required String query, required ContentSearchFilter filter})
      onSearchRequested;
  final VoidCallback onClearRequested;
  final ValueChanged<String> onQueryChanged;

  const _FloatingSearchBarSliver({
    required this.textEditingController,
    required this.searchFocusNode,
    required this.contentBloc,
    required this.handleKeyEvent,
    required this.currentCombinedSuggestions,
    required this.highlightedIndexNotifier,
    required this.onSearchRequested,
    required this.onClearRequested,
    required this.onQueryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      titleSpacing: 16,
      toolbarHeight: 70,
      title: Focus(
        onKeyEvent: handleKeyEvent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08), width: 1),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  _buildAnimatedSearchLeadingIcon(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: textEditingController,
                      focusNode: searchFocusNode,
                      style: TextStyle(
                        color:
                            Default_Theme.primaryColor1.withValues(alpha: 0.95),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      onChanged: onQueryChanged,
                      onSubmitted: (val) {
                        final hIndex = highlightedIndexNotifier.value;
                        if (hIndex >= 0 &&
                            hIndex < currentCombinedSuggestions.length) {
                          final selected = currentCombinedSuggestions[hIndex];
                          onSearchRequested(
                              query: selected.query, filter: selected.filter);
                        } else {
                          onSearchRequested(
                              query: val, filter: ContentSearchFilter.all);
                        }
                      },
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 14),
                        hintText:
                            AppLocalizations.of(context)!.searchHintExplore,
                        hintStyle: TextStyle(
                          color: Default_Theme.primaryColor1
                              .withValues(alpha: 0.35),
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: textEditingController,
                    builder: (context, value, child) {
                      if (value.text.isNotEmpty) {
                        return IconButton(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          icon: Icon(MingCute.close_fill,
                              color: Default_Theme.primaryColor1
                                  .withValues(alpha: 0.5),
                              size: 18),
                          onPressed: onClearRequested,
                        );
                      }
                      return const SizedBox(width: 16);
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedSearchLeadingIcon() {
    return BlocBuilder<ContentBloc, ContentState>(
      bloc: contentBloc,
      buildWhen: (previous, current) =>
          previous.searchStatus != current.searchStatus,
      builder: (context, state) {
        final isLoading = state.searchStatus == SearchStatus.loading ||
            state.searchStatus == SearchStatus.loadingMore;
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 240),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            final rotation = Tween<double>(begin: 0.82, end: 1).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutBack));
            return FadeTransition(
                opacity: animation,
                child: RotationTransition(turns: rotation, child: child));
          },
          child: isLoading
              ? SizedBox(
                  key: const ValueKey('search-loading'),
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color:
                          Default_Theme.primaryColor1.withValues(alpha: 0.5)),
                )
              : Icon(MingCute.search_2_line,
                  key: const ValueKey('search-idle'),
                  color: Default_Theme.primaryColor1.withValues(alpha: 0.5),
                  size: 20),
        );
      },
    );
  }
}

class _AestheticFilterChipsSliver extends StatelessWidget {
  final ValueNotifier<ContentSearchFilter> filterNotifier;
  final TextEditingController textEditingController;
  final VoidCallback onFilterTapped;

  const _AestheticFilterChipsSliver(
      {required this.filterNotifier,
      required this.textEditingController,
      required this.onFilterTapped});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: ValueListenableBuilder<ContentSearchFilter>(
        valueListenable: filterNotifier,
        builder: (context, filterValue, child) {
          return SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
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
                    filterNotifier.value = e;
                    if (textEditingController.text.isNotEmpty) onFilterTapped();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Default_Theme.accentColor2
                          : Default_Theme.primaryColor2.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: isSelected
                              ? Default_Theme.accentColor2
                              : Colors.white.withValues(alpha: 0.05)),
                    ),
                    child: Text(
                      displayName,
                      style: Default_Theme.secondoryTextStyleMedium.copyWith(
                        color: isSelected
                            ? Default_Theme.primaryColor2
                            : Default_Theme.primaryColor1
                                .withValues(alpha: 0.8),
                        fontSize: 13,
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
}

class _PluginsGlassyBoxSliver extends StatelessWidget {
  final ValueNotifier<String?> activePluginNotifier;
  final ContentBloc contentBloc;
  final TextEditingController textEditingController;
  final VoidCallback onPluginChanged;

  const _PluginsGlassyBoxSliver({
    required this.activePluginNotifier,
    required this.contentBloc,
    required this.textEditingController,
    required this.onPluginChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: BlocBuilder<PluginBloc, PluginState>(
        buildWhen: (prev, curr) =>
            prev.loadedContentResolvers != curr.loadedContentResolvers,
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
                        color: Colors.white.withValues(alpha: 0.05), width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(MingCute.plugin_2_line,
                                size: 18, color: Default_Theme.accentColor2),
                            const SizedBox(width: 8),
                            Text(
                              AppLocalizations.of(context)!.searchSources,
                              style: Default_Theme.secondoryTextStyleMedium
                                  .copyWith(
                                fontSize: 12,
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.w800,
                                color: Default_Theme.primaryColor1
                                    .withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (resolvers.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Text(
                            AppLocalizations.of(context)!.searchNoPlugins,
                            style: TextStyle(
                                color: Default_Theme.primaryColor1
                                    .withValues(alpha: 0.4),
                                fontStyle: FontStyle.italic),
                          ),
                        )
                      else
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: resolvers
                                .map((plugin) => Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: _PluginChip(
                                        plugin: plugin,
                                        activePluginNotifier:
                                            activePluginNotifier,
                                        onTap: () {
                                          final id = plugin.manifest.id;
                                          if (activePluginNotifier.value == id)
                                            return;
                                          activePluginNotifier.value = id;
                                          contentBloc.add(
                                              SetActiveContentPlugin(
                                                  pluginId: id));
                                          context
                                              .read<SettingsCubit>()
                                              .setSearchPluginId(id);
                                          if (textEditingController.text
                                              .isNotEmpty) onPluginChanged();
                                        },
                                      ),
                                    ))
                                .toList(),
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
}

class _PluginChip extends StatelessWidget {
  final PluginInfo plugin;
  final ValueNotifier<String?> activePluginNotifier;
  final VoidCallback onTap;

  const _PluginChip(
      {required this.plugin,
      required this.activePluginNotifier,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: activePluginNotifier,
      builder: (context, activeId, child) {
        final isSelected = activeId == plugin.manifest.id;

        return InkWell(
          borderRadius: BorderRadius.circular(50),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
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
                    const Icon(MingCute.check_line,
                        size: 13, color: Default_Theme.accentColor2),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    plugin.name,
                    style: Default_Theme.secondoryTextStyleMedium.merge(
                      TextStyle(
                        color: isSelected
                            ? Default_Theme.accentColor2
                            : Default_Theme.primaryColor1
                                .withValues(alpha: 0.8),
                        fontSize: 12.5,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        letterSpacing: 0.3,
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
  }
}

class _SuggestionsSliver extends StatelessWidget {
  final TextEditingController textEditingController;
  final ValueNotifier<int> highlightedIndexNotifier;
  final void Function(String) onSearchInAllCategories;
  final void Function(String, ContentSearchFilter) onSearchWithFilter;
  final void Function(String) onSetSearchFieldText;
  final void Function(List<({String query, ContentSearchFilter filter})>)
      onSuggestionsGenerated;

  const _SuggestionsSliver({
    required this.textEditingController,
    required this.highlightedIndexNotifier,
    required this.onSearchInAllCategories,
    required this.onSearchWithFilter,
    required this.onSetSearchFieldText,
    required this.onSuggestionsGenerated,
  });

  String _normalize(String q) => q.trim().replaceAll(RegExp(r'\s+'), ' ');
  ContentSearchFilter _filterForEntity(plugin_models.EntityType type) =>
      switch (type) {
        plugin_models.EntityType.track => ContentSearchFilter.track,
        plugin_models.EntityType.album => ContentSearchFilter.album,
        plugin_models.EntityType.artist => ContentSearchFilter.artist,
        plugin_models.EntityType.playlist => ContentSearchFilter.playlist,
        _ => ContentSearchFilter.all,
      };

  String _buildEntitySearchQuery(plugin_models.EntitySuggestion entity) {
    final parts = <String>[entity.title.trim()];
    if (entity.subtitle != null && entity.subtitle!.isNotEmpty) {
      parts.add(entity.subtitle!
          .toLowerCase()
          .replaceAll(RegExp(r'\s+'), " ")
          .replaceAll(RegExp(r'[^\w\s]+', unicode: true), "")
          .replaceAll(entity.title.toLowerCase().trim(), ""));
    }
    return _normalize(parts.where((p) => p.isNotEmpty).join(' '));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchSuggestionBloc, SearchSuggestionState>(
      builder: (context, state) {
        if (state is SearchSuggestionLoading) {
          return const SliverToBoxAdapter(
            child: Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(
                    child: CircularProgressIndicator(
                        color: Default_Theme.accentColor2))),
          );
        }

        if (state is SearchSuggestionLoaded) {
          final dbList =
              state.dbSuggestionList.map((e) => e.values.first).toList();
          final apiList = state.suggestionList;
          final entityList = state.entitySuggestionList;

          final combined = <({String query, ContentSearchFilter filter})>[
            ...dbList.map(
                (q) => (query: _normalize(q), filter: ContentSearchFilter.all)),
            ...apiList.map(
                (q) => (query: _normalize(q), filter: ContentSearchFilter.all)),
            ...entityList.map((e) => (
                  query: _buildEntitySearchQuery(e),
                  filter: _filterForEntity(e.kind)
                )),
          ];

          WidgetsBinding.instance
              .addPostFrameCallback((_) => onSuggestionsGenerated(combined));

          if (combined.isEmpty && textEditingController.text.isEmpty) {
            return SliverFillRemaining(
                hasScrollBody: false,
                child: SignBoardWidget(
                    message: AppLocalizations.of(context)!.searchStartTyping,
                    icon: MingCute.keyboard_line));
          }
          if (combined.isEmpty) {
            return SliverFillRemaining(
                hasScrollBody: false,
                child: SignBoardWidget(
                    message: AppLocalizations.of(context)!.searchNoSuggestions,
                    icon: MingCute.ghost_line));
          }

          final children = <Widget>[
            const SizedBox(height: 12),
            if (dbList.isNotEmpty) ...[
              _buildSuggestionSectionHeader('Recent', MingCute.history_line),
              ...dbList.asMap().entries.map((e) => _SuggestionTile(
                    suggestion: e.value,
                    icon: MingCute.history_line,
                    isHistory: true,
                    globalIndex: e.key,
                    highlightedIndexNotifier: highlightedIndexNotifier,
                    onSearch: onSearchInAllCategories,
                    onPopulate: onSetSearchFieldText,
                  )),
              const SizedBox(height: 12),
            ],
            if (apiList.isNotEmpty) ...[
              _buildSuggestionSectionHeader(
                  'Suggestions', MingCute.search_2_line),
              ...apiList.asMap().entries.map((e) => _SuggestionTile(
                    suggestion: e.value,
                    icon: MingCute.search_line,
                    isHistory: false,
                    globalIndex: e.key + dbList.length,
                    highlightedIndexNotifier: highlightedIndexNotifier,
                    onSearch: onSearchInAllCategories,
                    onPopulate: onSetSearchFieldText,
                  )),
              const SizedBox(height: 12),
            ],
            if (entityList.isNotEmpty) ...[
              _buildSuggestionSectionHeader(
                  'Top Results', MingCute.sparkles_2_line),
              ...entityList.asMap().entries.map((e) => _EntitySuggestionTile(
                    entity: e.value,
                    globalIndex: e.key + dbList.length + apiList.length,
                    filter: _filterForEntity(e.value.kind),
                    query: _buildEntitySearchQuery(e.value),
                    highlightedIndexNotifier: highlightedIndexNotifier,
                    onSearch: onSearchWithFilter,
                  )),
            ],
            const SizedBox(height: 120),
          ];

          return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              sliver: SliverList(delegate: SliverChildListDelegate(children)));
        }
        return SliverFillRemaining(
            hasScrollBody: false,
            child: SignBoardWidget(
                message: AppLocalizations.of(context)!.searchNoSuggestions,
                icon: MingCute.ghost_line));
      },
    );
  }

  Widget _buildSuggestionSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 4, 10, 8),
      child: Row(
        children: [
          Icon(icon,
              size: 14,
              color: Default_Theme.primaryColor1.withValues(alpha: 0.5)),
          const SizedBox(width: 8),
          Text(title,
              style: Default_Theme.secondoryTextStyleMedium.copyWith(
                  color: Default_Theme.primaryColor1.withValues(alpha: 0.55),
                  fontSize: 11.5,
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  final String suggestion;
  final IconData icon;
  final bool isHistory;
  final int globalIndex;
  final ValueNotifier<int> highlightedIndexNotifier;
  final void Function(String) onSearch;
  final void Function(String) onPopulate;

  const _SuggestionTile(
      {required this.suggestion,
      required this.icon,
      required this.isHistory,
      required this.globalIndex,
      required this.highlightedIndexNotifier,
      required this.onSearch,
      required this.onPopulate});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => onSearch(suggestion),
        splashColor: Colors.transparent,
        highlightColor: Default_Theme.primaryColor1.withValues(alpha: 0.05),
        child: ValueListenableBuilder<int>(
          valueListenable: highlightedIndexNotifier,
          builder: (context, highlightedIndex, child) {
            final isHighlighted = highlightedIndex == globalIndex;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
              decoration: BoxDecoration(
                color: isHighlighted
                    ? Default_Theme.primaryColor1.withValues(alpha: 0.065)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: child,
            );
          },
          child: Row(
            children: [
              Icon(icon,
                  size: 18,
                  color: Default_Theme.primaryColor1.withValues(alpha: 0.48)),
              const SizedBox(width: 14),
              Expanded(
                  child: Text(suggestion,
                      style: TextStyle(
                              color: Default_Theme.primaryColor1
                                  .withValues(alpha: 0.9),
                              fontSize: 15)
                          .merge(Default_Theme.secondoryTextStyle))),
              if (isHistory)
                GestureDetector(
                    onTap: () => context
                        .read<SearchSuggestionBloc>()
                        .add(SearchSuggestionClear(suggestion)),
                    child: Icon(MingCute.close_fill,
                        color:
                            Default_Theme.primaryColor1.withValues(alpha: 0.4),
                        size: 18))
              else
                GestureDetector(
                    onTap: () => onPopulate(
                        suggestion.trim().replaceAll(RegExp(r'\s+'), ' ')),
                    child: Icon(MingCute.arrow_left_up_line,
                        color:
                            Default_Theme.primaryColor1.withValues(alpha: 0.4),
                        size: 18))
            ],
          ),
        ),
      ),
    );
  }
}

class _EntitySuggestionTile extends StatelessWidget {
  final plugin_models.EntitySuggestion entity;
  final int globalIndex;
  final ContentSearchFilter filter;
  final String query;
  final ValueNotifier<int> highlightedIndexNotifier;
  final void Function(String, ContentSearchFilter) onSearch;

  const _EntitySuggestionTile(
      {required this.entity,
      required this.globalIndex,
      required this.filter,
      required this.query,
      required this.highlightedIndexNotifier,
      required this.onSearch});

  @override
  Widget build(BuildContext context) {
    final thumbnailUrl = entity.thumbnail?.urlLow ?? entity.thumbnail?.url;
    final isArtist = entity.kind == plugin_models.EntityType.artist;
    final typeLabel = switch (entity.kind) {
      plugin_models.EntityType.track =>
        AppLocalizations.of(context)!.searchTracks,
      plugin_models.EntityType.album =>
        AppLocalizations.of(context)!.searchAlbums,
      plugin_models.EntityType.artist =>
        AppLocalizations.of(context)!.searchArtists,
      plugin_models.EntityType.playlist =>
        AppLocalizations.of(context)!.searchPlaylists,
      plugin_models.EntityType.genre => 'Genre',
      plugin_models.EntityType.unknown => 'Result',
    };

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => onSearch(query, filter),
        splashColor: Colors.transparent,
        highlightColor: Default_Theme.primaryColor1.withValues(alpha: 0.05),
        child: ValueListenableBuilder<int>(
          valueListenable: highlightedIndexNotifier,
          builder: (context, highlightedIndex, child) {
            final isHighlighted = highlightedIndex == globalIndex;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isHighlighted
                    ? Default_Theme.primaryColor1.withValues(alpha: 0.07)
                    : Default_Theme.primaryColor2.withValues(alpha: 0.02),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: isHighlighted
                        ? Default_Theme.primaryColor1.withValues(alpha: 0.12)
                        : Colors.white.withValues(alpha: 0.04)),
              ),
              child: child,
            );
          },
          child: Row(
            children: [
              isArtist
                  ? ClipOval(child: _buildThumb(thumbnailUrl))
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: _buildThumb(thumbnailUrl)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(entity.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                                color: Default_Theme.primaryColor1
                                    .withValues(alpha: 0.9),
                                fontSize: 14.5)
                            .merge(Default_Theme.secondoryTextStyleMedium)),
                    if (entity.subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(entity.subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                                  color: Default_Theme.primaryColor1
                                      .withValues(alpha: 0.5),
                                  fontSize: 12)
                              .merge(Default_Theme.secondoryTextStyle)),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                    color: Default_Theme.primaryColor1.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                        color: Default_Theme.primaryColor1
                            .withValues(alpha: 0.08))),
                child: Text(typeLabel,
                    style: Default_Theme.secondoryTextStyleMedium.copyWith(
                        color:
                            Default_Theme.primaryColor1.withValues(alpha: 0.52),
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumb(String? url) {
    if (url != null) {
      return CachedNetworkImage(
          imageUrl: url,
          width: 42,
          height: 42,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => _placeholder());
    }
    return _placeholder();
  }

  Widget _placeholder() => Container(
      width: 42,
      height: 42,
      color: Default_Theme.primaryColor2.withValues(alpha: 0.15),
      child: Icon(MingCute.search_line,
          size: 18, color: Default_Theme.primaryColor1.withValues(alpha: 0.4)));
}

class _ContentSliver extends StatelessWidget {
  final ContentBloc contentBloc;
  final ValueNotifier<String?> activePluginNotifier;

  const _ContentSliver(
      {required this.contentBloc, required this.activePluginNotifier});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityCubit, ConnectivityState>(
      builder: (context, connState) {
        if (connState == ConnectivityState.disconnected) {
          return SliverFillRemaining(
              hasScrollBody: false,
              child: SignBoardWidget(
                  icon: MingCute.wifi_off_line,
                  message: AppLocalizations.of(context)!.emptyNoInternet));
        }

        return BlocBuilder<ContentBloc, ContentState>(
          bloc: contentBloc,
          builder: (context, state) {
            final hasResults = state.searchResults != null &&
                state.searchResults!.items.isNotEmpty;

            if (state.searchStatus == SearchStatus.loading && !hasResults) {
              return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                      child: CircularProgressIndicator(
                          color: Default_Theme.accentColor2)));
            }
            if ((state.searchStatus == SearchStatus.loading ||
                    state.searchStatus == SearchStatus.loaded ||
                    state.searchStatus == SearchStatus.loadingMore) &&
                hasResults) {
              return _SliverSearchResults(
                  state: state, activePluginNotifier: activePluginNotifier);
            }
            if (state.searchStatus == SearchStatus.loaded &&
                state.searchResults != null &&
                state.searchResults!.items.isEmpty) {
              return SliverFillRemaining(
                  hasScrollBody: false,
                  child: SignBoardWidget(
                      message: AppLocalizations.of(context)!.searchNoResults,
                      icon: MingCute.ghost_line));
            }
            if (state.searchStatus == SearchStatus.error) {
              return SliverFillRemaining(
                  hasScrollBody: false,
                  child: SignBoardWidget(
                      message: state.error ??
                          AppLocalizations.of(context)!.searchFailed,
                      icon: MingCute.sweats_line));
            }
            return SliverFillRemaining(
                hasScrollBody: false,
                child: SignBoardWidget(
                    message: AppLocalizations.of(context)!.searchDiscover,
                    icon: MingCute.planet_line));
          },
        );
      },
    );
  }
}

class _SliverSearchResults extends StatelessWidget {
  final ContentState state;
  final ValueNotifier<String?> activePluginNotifier;

  const _SliverSearchResults(
      {required this.state, required this.activePluginNotifier});

  @override
  Widget build(BuildContext context) {
    final items = state.searchResults!.items;
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

    final pluginId = activePluginNotifier.value ?? '';
    final isLoadingMore = state.searchStatus == SearchStatus.loadingMore;
    final isRefreshing = state.searchStatus == SearchStatus.loading;

    return SliverMainAxisGroup(
      slivers: [
        if (isRefreshing)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                    color: Default_Theme.primaryColor2.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.05))),
                child: Row(
                  children: [
                    const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Default_Theme.accentColor2)),
                    const SizedBox(width: 10),
                    Text('Searching...',
                        style: Default_Theme.secondoryTextStyleMedium.copyWith(
                            color: Default_Theme.primaryColor1
                                .withValues(alpha: 0.78),
                            fontSize: 12.5)),
                  ],
                ),
              ),
            ),
          ),
        if (tracks.isNotEmpty) ...[
          _sliverSectionHeader(AppLocalizations.of(context)!.searchTracks),
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
                      onTap: () => context
                          .read<BloomeePlayerCubit>()
                          .bloomeePlayer
                          .updateQueueTracks([track], doPlay: true),
                      onOptionsTap: () => showMoreBottomSheet(context, track,
                          showSinglePlay: true),
                    ),
                  );
                },
                childCount: tracks.length,
              ),
            ),
          ),
        ],
        if (albums.isNotEmpty) ...[
          _sliverSectionHeader(AppLocalizations.of(context)!.searchAlbums),
          _buildResponsiveGrid(albums
              .map((a) => AlbumCard(album: a, pluginId: pluginId))
              .toList()),
        ],
        if (artists.isNotEmpty) ...[
          _sliverSectionHeader(AppLocalizations.of(context)!.searchArtists),
          _buildResponsiveGrid(artists
              .map((a) => ArtistCard(artist: a, pluginId: pluginId))
              .toList()),
        ],
        if (playlists.isNotEmpty) ...[
          _sliverSectionHeader(AppLocalizations.of(context)!.searchPlaylists),
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
                          color: Default_Theme.accentColor2))))
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
          style: Default_Theme.secondoryTextStyleMedium.merge(TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Default_Theme.primaryColor1.withValues(alpha: 0.9))),
        ),
      ),
    );
  }

  Widget _buildResponsiveGrid(List<Widget> children) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverToBoxAdapter(
        child: Wrap(
            spacing: 20,
            runSpacing: 28,
            alignment: WrapAlignment.start,
            children: children),
      ),
    );
  }
}

class _NebulaBackground extends StatelessWidget {
  final ContentBloc contentBloc;
  const _NebulaBackground({required this.contentBloc});

  List<Color> _getReactiveGradientColors(ContentState state) {
    if (state.searchStatus != SearchStatus.loaded &&
        state.searchStatus != SearchStatus.loadingMore)
      return [Colors.transparent, Colors.transparent];
    final items = state.searchResults?.items;
    if (items == null || items.isEmpty)
      return [Colors.transparent, Colors.transparent];

    String seedString = "";
    final firstItem = items.first;
    switch (firstItem) {
      case MediaItem_Track(:final field0):
        seedString = field0.thumbnail.urlLow ?? field0.thumbnail.url;
      case MediaItem_Album(:final field0):
        seedString =
            field0.thumbnail?.urlLow ?? field0.thumbnail?.url ?? field0.title;
      case MediaItem_Artist(:final field0):
        seedString =
            field0.thumbnail?.urlLow ?? field0.thumbnail?.url ?? field0.name;
      case MediaItem_Playlist(:final field0):
        seedString = field0.thumbnail.urlLow ?? field0.thumbnail.url;
    }

    final int hash = seedString.hashCode;
    double hue = (hash % 360).abs().toDouble();
    if (hue > 60 && hue < 170) hue = (hash % 2 == 0) ? 180 : 40;

    final color1 = HSLColor.fromAHSL(1.0, hue, 0.65, 0.35).toColor();
    final color2 =
        HSLColor.fromAHSL(1.0, (hue + 40) % 360, 0.65, 0.30).toColor();
    return [color1, color2];
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContentBloc, ContentState>(
      bloc: contentBloc,
      builder: (context, state) {
        final colors = _getReactiveGradientColors(state);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 1500),
          curve: Curves.easeOutCubic,
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.75,
          child: CustomPaint(
              painter: NebulaPainter(
                  color1: colors[0].withValues(alpha: 0.18),
                  color2: colors[1].withValues(alpha: 0.18))),
        );
      },
    );
  }
}

class NebulaPainter extends CustomPainter {
  final Color color1;
  final Color color2;

  NebulaPainter({required this.color1, required this.color2});

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..shader = RadialGradient(
              center: const Alignment(-0.5, -0.6),
              radius: 1.6,
              colors: [color1, Colors.transparent],
              stops: const [0.0, 1.0])
          .createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    final paint2 = Paint()
      ..shader = RadialGradient(
              center: const Alignment(0.5, -0.6),
              radius: 1.6,
              colors: [color2, Colors.transparent],
              stops: const [0.0, 1.0])
          .createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint1);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint2);
  }

  @override
  bool shouldRepaint(covariant NebulaPainter oldDelegate) =>
      oldDelegate.color1 != color1 || oldDelegate.color2 != color2;
}
