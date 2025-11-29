// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:Bloomee/blocs/search_suggestions/search_suggestion_bloc.dart';
import 'package:Bloomee/model/source_engines.dart';
import 'package:Bloomee/screens/widgets/sign_board_widget.dart';
import 'package:Bloomee/services/db/bloomee_db_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Bloomee/blocs/search/fetch_search_results.dart';
import 'package:Bloomee/theme_data/default.dart';
import 'package:icons_plus/icons_plus.dart';

class SearchPageDelegate extends SearchDelegate {
  List<String> searchList = [];
  SourceEngine sourceEngine = SourceEngine.eng_YTM;
  ResultTypes resultType = ResultTypes.songs;
  SearchPageDelegate(
    this.sourceEngine,
    this.resultType,
  );
  @override
  String? get searchFieldLabel => "Explore the world of music...";

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: const AppBarTheme(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20))),
        backgroundColor: Color.fromARGB(255, 19, 19, 19),
        iconTheme: IconThemeData(color: Default_Theme.primaryColor1),
      ),
      textTheme: TextTheme(
        titleLarge: const TextStyle(
          color: Default_Theme.primaryColor1,
        ).merge(Default_Theme.secondoryTextStyleMedium),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(
          color: Default_Theme.primaryColor2.withValues(alpha: 0.3),
        ).merge(Default_Theme.secondoryTextStyle),
      ),
    );
  }

  @override
  void showResults(BuildContext context) {
    if (query.replaceAll(' ', '').isNotEmpty) {
      context
          .read<FetchSearchResultsCubit>()
          .search(query, sourceEngine: sourceEngine, resultType: resultType);
      BloomeeDBService.putSearchHistory(query);
    }
    close(context, query);
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            query = '';
          },
          icon: const Icon(MingCute.close_fill))
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(MingCute.arrow_left_fill),
      onPressed: () => Navigator.of(context).pop(),
      // Exit from the search screen.
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final List<String> searchResults = searchList
        .where((item) => item.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(searchResults[index]),
          onTap: () {
            // Handle the selected search result.
            close(context, searchResults[index]);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // final List<String> suggestionList = [];
    context.read<SearchSuggestionBloc>().add(SearchSuggestionFetch(query));

    return BlocBuilder<SearchSuggestionBloc, SearchSuggestionState>(
      builder: (context, state) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: switch (state) {
              SearchSuggestionLoading() => const Center(
                  child: CircularProgressIndicator(
                    color: Default_Theme.accentColor2,
                  ),
                ),
              SearchSuggestionLoaded() => state.suggestionList.isEmpty &&
                      state.dbSuggestionList.isEmpty
                  ? const Center(
                      child: SignBoardWidget(
                        message: "No Suggestions found!",
                        icon: MingCute.look_up_line,
                      ),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListView(
                          shrinkWrap: true,
                          physics:
                              const NeverScrollableScrollPhysics(), // Disable inner scrolling
                          children: state.dbSuggestionList
                              .map(
                                (e) => ListTile(
                                  title: Text(
                                    e.values.first,
                                    style: const TextStyle(
                                      color: Default_Theme.primaryColor1,
                                    ).merge(Default_Theme.secondoryTextStyle),
                                  ),
                                  contentPadding:
                                      const EdgeInsets.only(left: 16, right: 8),
                                  leading: Icon(
                                    MingCute.history_line,
                                    size: 22,
                                    color: Default_Theme.primaryColor1
                                        .withValues(alpha: 0.5),
                                  ),
                                  trailing: IconButton(
                                    onPressed: () {
                                      context.read<SearchSuggestionBloc>().add(
                                          SearchSuggestionClear(
                                              e.values.first));
                                    },
                                    icon: Icon(
                                      MingCute.close_fill,
                                      color: Default_Theme.primaryColor1
                                          .withValues(alpha: 0.5),
                                      size: 22,
                                    ),
                                  ),
                                  onTap: () {
                                    query = e.values.first;
                                    showResults(context);
                                  },
                                ),
                              )
                              .toList(),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics:
                              const NeverScrollableScrollPhysics(), // Disable inner scrolling
                          itemBuilder: (BuildContext context, int index) {
                            return ListTile(
                              title: Text(
                                state.suggestionList[index],
                                style: const TextStyle(
                                  color: Default_Theme.primaryColor1,
                                ).merge(Default_Theme.secondoryTextStyle),
                              ),
                              contentPadding:
                                  const EdgeInsets.only(left: 16, right: 8),
                              leading: Icon(
                                MingCute.search_line,
                                size: 22,
                                color: Default_Theme.primaryColor1
                                    .withValues(alpha: 0.5),
                              ),
                              trailing: IconButton(
                                onPressed: () {
                                  query = state.suggestionList[index];
                                  // only update the query and not show the results
                                },
                                icon: Icon(
                                  MingCute.arrow_left_up_line,
                                  color: Default_Theme.primaryColor1
                                      .withValues(alpha: 0.5),
                                  size: 22,
                                ),
                              ),
                              onTap: () {
                                query = state.suggestionList[index];
                                showResults(context);
                              },
                            );
                          },
                          itemCount: state.suggestionList.length,
                        ),
                      ],
                    ),
              _ => const Center(
                  child: SignBoardWidget(
                    message: "No Suggestions found!",
                    icon: MingCute.look_up_line,
                  ),
                ),
            },
          ),
        );
      },
    );
  }
}
