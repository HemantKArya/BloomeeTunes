// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';
import 'package:Bloomee/blocs/mediaPlayer/bloomee_player_cubit.dart';
import 'package:Bloomee/model/MediaPlaylistModel.dart';
import 'package:Bloomee/screens/widgets/more_bottom_sheet.dart';
import 'package:Bloomee/screens/widgets/sign_board_widget.dart';
import 'package:Bloomee/screens/widgets/song_tile.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:Bloomee/blocs/internet_connectivity/cubit/connectivity_cubit.dart';
import 'package:Bloomee/blocs/search/fetch_search_results.dart';
import 'package:Bloomee/screens/screen/search_views/search_page.dart';
import 'package:Bloomee/theme_data/default.dart';

class SearchScreen extends StatefulWidget {
  String searchQuery = "";
  SearchScreen({
    Key? key,
    this.searchQuery = "",
  }) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  int _selectedSearchEngine = 0;
  SourceEngine _sourceEngine = SourceEngine.eng_JIS;
  final TextEditingController _textEditingController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void loadMoreResults() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        _sourceEngine == SourceEngine.eng_JIS &&
        context.read<FetchSearchResultsCubit>().state.hasReachedMax == false) {
      context
          .read<FetchSearchResultsCubit>()
          .searchJIS(_textEditingController.text, loadMore: true);
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(loadMoreResults);
    if (widget.searchQuery != "") {
      _textEditingController.text = widget.searchQuery;
      context
          .read<FetchSearchResultsCubit>()
          .search(widget.searchQuery.toString(), sourceEngine: _sourceEngine);
    }
  }

  Widget sourceEngineRadioButton(
      String text, int index, SourceEngine sourceEngine) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: SizedBox(
        height: 30,
        child: AnimatedContainer(
          duration: const Duration(seconds: 1),
          curve: accelerateEasing,
          child: OutlinedButton(
            onPressed: () {
              setState(() {
                _selectedSearchEngine = index;
                _sourceEngine = sourceEngine;
                if (_textEditingController.text.toString().isNotEmpty) {
                  log("Search Engine ${sourceEngine.toString()}",
                      name: "SearchScreen");
                  context.read<FetchSearchResultsCubit>().search(
                      _textEditingController.text.toString(),
                      sourceEngine: sourceEngine);
                }
              });
            },
            style: OutlinedButton.styleFrom(
                backgroundColor: _selectedSearchEngine == index
                    ? Default_Theme.accentColor2
                    : Colors.transparent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                side: const BorderSide(
                    color: Default_Theme.accentColor2,
                    style: BorderStyle.solid,
                    width: 2)),
            child: Text(
              text,
              style: TextStyle(
                      color: _selectedSearchEngine == index
                          ? Default_Theme.primaryColor2
                          : Default_Theme.accentColor2,
                      fontSize: 15)
                  .merge(Default_Theme.secondoryTextStyleMedium),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      onVerticalDragEnd: (DragEndDetails details) =>
          FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          shadowColor: Colors.black,
          bottom: PreferredSize(
            preferredSize: const Size(100, 20),
            child: SizedBox(
              height: 35,
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 18, right: 18, top: 5, bottom: 5),
                child: Row(
                  children: [
                    sourceEngineRadioButton("JIS", 0, SourceEngine.eng_JIS),
                    sourceEngineRadioButton("YTM", 1, SourceEngine.eng_YTM),
                    sourceEngineRadioButton("YTV", 2, SourceEngine.eng_YTV),
                    // const Spacer()
                  ],
                ),
              ),
            ),
          ),
          title: SizedBox(
            height: 50.0,
            child: InkWell(
              onTap: () {
                showSearch(
                        context: context,
                        delegate: searchPageDelegate(_sourceEngine),
                        query: _textEditingController.text)
                    .then((value) {
                  if ((value as String) != 'null') {
                    _textEditingController.text = value.toString();
                  }
                });
              },
              child: TextField(
                controller: _textEditingController,
                enabled: false,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Default_Theme.primaryColor1.withOpacity(0.55)),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                    filled: true,
                    suffixIcon: Icon(
                      MingCute.search_2_fill,
                      color: Default_Theme.primaryColor1.withOpacity(0.4),
                    ),
                    fillColor: Default_Theme.primaryColor2.withOpacity(0.07),
                    contentPadding: const EdgeInsets.only(top: 20),
                    hintText: "Find your next song obsession...",
                    hintStyle: TextStyle(
                      color: Default_Theme.primaryColor1.withOpacity(0.3),
                      fontFamily: "Unageo",
                      fontWeight: FontWeight.normal,
                    ),
                    disabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(style: BorderStyle.none),
                        borderRadius: BorderRadius.circular(50)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color:
                                Default_Theme.primaryColor1.withOpacity(0.7)),
                        borderRadius: BorderRadius.circular(50))),
              ),
            ),
          ),
          backgroundColor: Default_Theme.themeColor,
        ),
        backgroundColor: Default_Theme.themeColor,
        body: BlocBuilder<ConnectivityCubit, ConnectivityState>(
          builder: (context, state) {
            return AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                child: state == ConnectivityState.disconnected
                    ? const SignBoardWidget(
                        icon: MingCute.wifi_off_line,
                        message: "No internet connection!",
                      )
                    : BlocBuilder<FetchSearchResultsCubit,
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
                            if (state.mediaItems.isNotEmpty) {
                              log("Search Results: ${state.mediaItems.length}",
                                  name: "SearchScreen");
                              return ListView.builder(
                                controller: _scrollController,
                                physics: const BouncingScrollPhysics(),
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
                                        if (!listEquals(
                                            context
                                                .read<BloomeePlayerCubit>()
                                                .bloomeePlayer
                                                .currentPlaylist,
                                            state.mediaItems)) {
                                          context
                                              .read<BloomeePlayerCubit>()
                                              .bloomeePlayer
                                              .loadPlaylist(
                                                  MediaPlaylist(
                                                      albumName:
                                                          state.albumName,
                                                      mediaItems:
                                                          state.mediaItems),
                                                  idx: index,
                                                  doPlay: true);
                                          // context.read<BloomeePlayerCubit>().bloomeePlayer.play();
                                        } else if (context
                                                .read<BloomeePlayerCubit>()
                                                .bloomeePlayer
                                                .currentMedia !=
                                            state.mediaItems[index]) {
                                          context
                                              .read<BloomeePlayerCubit>()
                                              .bloomeePlayer
                                              .prepare4play(
                                                  idx: index, doPlay: true);
                                        }

                                        context.push('/MusicPlayer');
                                      },
                                      onOptionsTap: () => showMoreBottomSheet(
                                          context, state.mediaItems[index]),
                                    ),
                                  );
                                },
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
                      ));
          },
        ),
      ),
    );
  }
}
