// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';
import 'package:Bloomee/blocs/mediaPlayer/bloomee_player_cubit.dart';
import 'package:Bloomee/model/source_engines.dart';
import 'package:Bloomee/screens/widgets/album_card.dart';
import 'package:Bloomee/screens/widgets/artist_card.dart';
import 'package:Bloomee/screens/widgets/more_bottom_sheet.dart';
import 'package:Bloomee/screens/widgets/playlist_card.dart';
import 'package:Bloomee/screens/widgets/sign_board_widget.dart';
import 'package:Bloomee/screens/widgets/song_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:Bloomee/blocs/internet_connectivity/cubit/connectivity_cubit.dart';
import 'package:Bloomee/blocs/search/fetch_search_results.dart';
import 'package:Bloomee/screens/screen/search_views/search_page.dart';
import 'package:Bloomee/theme_data/default.dart';

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
  late List<SourceEngine> availSourceEngines;
  late SourceEngine _sourceEngine;
  final TextEditingController _textEditingController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<ResultTypes> resultType =
      ValueNotifier(ResultTypes.songs);

  @override
  void dispose() {
    _scrollController.removeListener(loadMoreResults);
    _scrollController.dispose();
    _textEditingController.dispose();
    resultType.dispose();
    super.dispose();
  }

  void loadMoreResults() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        _sourceEngine == SourceEngine.eng_JIS &&
        context.read<FetchSearchResultsCubit>().state.hasReachedMax == false) {
      context
          .read<FetchSearchResultsCubit>()
          .searchJISTracks(_textEditingController.text, loadMore: true);
    }
  }

  @override
  void initState() {
    super.initState();
    availSourceEngines = SourceEngine.values;
    _sourceEngine = availSourceEngines[0];

    setState(() {
      availableSourceEngines().then((value) {
        availSourceEngines = value;
        _sourceEngine = availSourceEngines[0];
      });
    });
    _scrollController.addListener(loadMoreResults);
    if (widget.searchQuery != "") {
      _textEditingController.text = widget.searchQuery;
      context.read<FetchSearchResultsCubit>().search(
            widget.searchQuery.toString(),
            sourceEngine: _sourceEngine,
            resultType: resultType.value,
          );
    }
  }

  Widget sourceEngineRadioButton(SourceEngine sourceEngine) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: SizedBox(
        height: 27,
        child: AnimatedContainer(
          duration: const Duration(seconds: 1),
          curve: Easing.standardAccelerate,
          child: OutlinedButton(
            onPressed: () {
              setState(() {
                _sourceEngine = sourceEngine;
                context.read<FetchSearchResultsCubit>().checkAndRefreshSearch(
                      query: _textEditingController.text.toString(),
                      sE: sourceEngine,
                      rT: resultType.value,
                    );
              });
            },
            style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.only(left: 10, right: 10),
                backgroundColor: _sourceEngine == sourceEngine
                    ? Default_Theme.accentColor2
                    : Colors.transparent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                side: const BorderSide(
                    color: Default_Theme.accentColor2,
                    style: BorderStyle.solid,
                    width: 2)),
            child: Text(
              sourceEngine.value,
              style: TextStyle(
                      color: _sourceEngine == sourceEngine
                          ? Default_Theme.primaryColor2
                          : Default_Theme.accentColor2,
                      fontSize: 13)
                  .merge(Default_Theme.secondoryTextStyleMedium),
            ),
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
        onVerticalDragEnd: (DragEndDetails details) =>
            FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          appBar: AppBar(
            shadowColor: Colors.black,
            surfaceTintColor: Default_Theme.themeColor,
            title: SizedBox(
              height: 50.0,
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 10,
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    showSearch(
                            context: context,
                            delegate: SearchPageDelegate(
                                _sourceEngine, resultType.value),
                            query: _textEditingController.text)
                        .then((value) {
                      if (value != null) {
                        _textEditingController.text = value.toString();
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
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                        filled: true,
                        suffixIcon: Icon(
                          MingCute.search_2_fill,
                          color: Default_Theme.primaryColor1
                              .withValues(alpha: 0.4),
                        ),
                        fillColor:
                            Default_Theme.primaryColor2.withValues(alpha: 0.07),
                        contentPadding:
                            const EdgeInsets.only(top: 20, left: 15, right: 5),
                        hintText: "Find your next song obsession...",
                        hintStyle: TextStyle(
                          color: Default_Theme.primaryColor1
                              .withValues(alpha: 0.3),
                          fontFamily: "Unageo",
                          fontWeight: FontWeight.normal,
                        ),
                        disabledBorder: OutlineInputBorder(
                            borderSide:
                                const BorderSide(style: BorderStyle.none),
                            borderRadius: BorderRadius.circular(50)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Default_Theme.primaryColor1
                                    .withValues(alpha: 0.7)),
                            borderRadius: BorderRadius.circular(50))),
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
                  child: FutureBuilder(
                      future: availableSourceEngines(),
                      builder: (context, snapshot) {
                        return snapshot.hasData || snapshot.data != null
                            ? Wrap(
                                direction: Axis.horizontal,
                                runSpacing: 8,
                                alignment: WrapAlignment.start,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                    SizedBox(
                                      height: 30,
                                      width: 100,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8),
                                        child: ValueListenableBuilder(
                                            valueListenable: resultType,
                                            builder: (context, value, child) {
                                              return DropdownButtonFormField(
                                                key: UniqueKey(),
                                                isExpanded: false,
                                                isDense: true,
                                                alignment: Alignment.center,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                padding:
                                                    const EdgeInsets.all(0),
                                                focusColor: Colors.transparent,
                                                dropdownColor:
                                                    const Color.fromARGB(
                                                        255, 15, 15, 15),
                                                decoration: InputDecoration(
                                                  filled: false,
                                                  fillColor: Default_Theme
                                                      .primaryColor2
                                                      .withValues(alpha: 0.07),
                                                  contentPadding:
                                                      const EdgeInsets.all(0),
                                                  focusColor: Default_Theme
                                                      .accentColor2,
                                                  border: OutlineInputBorder(
                                                      borderSide:
                                                          const BorderSide(
                                                              style: BorderStyle
                                                                  .none),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20)),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                          borderSide:
                                                              const BorderSide(
                                                                  style:
                                                                      BorderStyle
                                                                          .none),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      20)),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                          borderSide:
                                                              const BorderSide(
                                                                  style:
                                                                      BorderStyle
                                                                          .none),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      20)),
                                                  disabledBorder:
                                                      OutlineInputBorder(
                                                          borderSide:
                                                              const BorderSide(
                                                                  style:
                                                                      BorderStyle
                                                                          .none),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      20)),
                                                  isDense: true,
                                                ),
                                                value: resultType.value.index,
                                                items: ResultTypes.values
                                                    .map(
                                                        (e) => DropdownMenuItem(
                                                              value: e.index,
                                                              child: SizedBox(
                                                                height: 32,
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                    left: 8,
                                                                    top: 2,
                                                                    bottom: 4,
                                                                  ),
                                                                  child: Text(
                                                                    e.val,
                                                                    style: Default_Theme
                                                                        .secondoryTextStyleMedium
                                                                        .merge(
                                                                            const TextStyle(
                                                                      color: Default_Theme
                                                                          .primaryColor1,
                                                                      fontSize:
                                                                          13.5,
                                                                    )),
                                                                  ),
                                                                ),
                                                              ),
                                                            ))
                                                    .toList(),
                                                onChanged: (value) {
                                                  resultType.value = ResultTypes
                                                      .values[value!];
                                                  context
                                                      .read<
                                                          FetchSearchResultsCubit>()
                                                      .checkAndRefreshSearch(
                                                        query:
                                                            _textEditingController
                                                                .text
                                                                .toString(),
                                                        sE: _sourceEngine,
                                                        rT: resultType.value,
                                                      );
                                                },
                                              );
                                            }),
                                      ),
                                    ),
                                    for (var sourceEngine in availSourceEngines)
                                      sourceEngineRadioButton(sourceEngine)
                                  ])
                            : const SizedBox();
                      }),
                ),
              ),
            ],
            body: BlocBuilder<ConnectivityCubit, ConnectivityState>(
              builder: (context, state) {
                return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 600),
                    child: state == ConnectivityState.disconnected
                        ? const SignBoardWidget(
                            icon: MingCute.wifi_off_line,
                            message: "No internet connection!",
                          )
                        : BlocConsumer<FetchSearchResultsCubit,
                            FetchSearchResultsState>(
                            builder: (context, state) {
                              if (state is FetchSearchResultsLoading) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: Default_Theme.accentColor2,
                                  ),
                                );
                              } else if (state.loadingState ==
                                  LoadingState.loaded) {
                                if (state.resultType == ResultTypes.songs &&
                                    state.mediaItems.isNotEmpty) {
                                  log("Search Results: ${state.mediaItems.length}",
                                      name: "SearchScreen");
                                  return ListView.builder(
                                    controller: _scrollController,
                                    itemCount: state.hasReachedMax
                                        ? state.mediaItems.length
                                        : state.mediaItems.length + 1,
                                    itemBuilder: (context, index) {
                                      if (index == state.mediaItems.length) {
                                        return const Center(
                                          child: SizedBox(
                                            height: 30,
                                            width: 30,
                                            child: CircularProgressIndicator(
                                              color: Default_Theme.accentColor2,
                                            ),
                                          ),
                                        );
                                      }
                                      return Padding(
                                        padding: const EdgeInsets.only(left: 4),
                                        child: SongCardWidget(
                                          song: state.mediaItems[index],
                                          onTap: () {
                                            context
                                                .read<BloomeePlayerCubit>()
                                                .bloomeePlayer
                                                .updateQueue(
                                              [state.mediaItems[index]],
                                              doPlay: true,
                                            );
                                          },
                                          onOptionsTap: () =>
                                              showMoreBottomSheet(context,
                                                  state.mediaItems[index]),
                                        ),
                                      );
                                    },
                                  );
                                } else if (state.resultType ==
                                        ResultTypes.albums &&
                                    state.albumItems.isNotEmpty) {
                                  return Align(
                                    alignment: Alignment.topCenter,
                                    child: SingleChildScrollView(
                                      physics: const BouncingScrollPhysics(),
                                      child: Wrap(
                                        alignment: WrapAlignment.center,
                                        runSpacing: 10,
                                        children: [
                                          for (var album in state.albumItems)
                                            AlbumCard(album: album)
                                        ],
                                      ),
                                    ),
                                  );
                                } else if (state.resultType ==
                                        ResultTypes.artists &&
                                    state.artistItems.isNotEmpty) {
                                  return Align(
                                    alignment: Alignment.topCenter,
                                    child: SingleChildScrollView(
                                      physics: const BouncingScrollPhysics(),
                                      child: Wrap(
                                        alignment: WrapAlignment.center,
                                        runSpacing: 10,
                                        children: [
                                          for (var artist in state.artistItems)
                                            ArtistCard(artist: artist)
                                        ],
                                      ),
                                    ),
                                  );
                                } else if (state.resultType ==
                                        ResultTypes.playlists &&
                                    state.playlistItems.isNotEmpty) {
                                  return Align(
                                    alignment: Alignment.topCenter,
                                    child: SingleChildScrollView(
                                      physics: const BouncingScrollPhysics(),
                                      child: Wrap(
                                        alignment: WrapAlignment.center,
                                        runSpacing: 10,
                                        children: [
                                          for (var playlist
                                              in state.playlistItems)
                                            PlaylistCard(
                                              playlist: playlist,
                                              sourceEngine: _sourceEngine,
                                            )
                                        ],
                                      ),
                                    ),
                                  );
                                } else {
                                  return const SignBoardWidget(
                                      message:
                                          "No results found!\nTry another keyword or source engine!",
                                      icon: MingCute.sweats_line);
                                }
                              } else {
                                return const SignBoardWidget(
                                    message:
                                        "Search for your favorite songs\nand discover new ones!",
                                    icon: MingCute.search_2_line);
                              }
                            },
                            listener: (BuildContext context,
                                FetchSearchResultsState state) {
                              resultType.value = state.resultType;
                              if (state is! FetchSearchResultsLoaded &&
                                  state is! FetchSearchResultsInitial) {
                                _sourceEngine =
                                    state.sourceEngine ?? _sourceEngine;
                              }
                            },
                          ));
              },
            ),
          ),
        ),
      ),
    );
  }
}
