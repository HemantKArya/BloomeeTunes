// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:Bloomee/repository/Youtube/youtube_api.dart';
import 'package:Bloomee/repository/cubits/fetch_search_results.dart';
import 'package:Bloomee/theme_data/default.dart';

class searchPageDelegate extends SearchDelegate {
  List<String> searchList = [];
  SourceEngine _sourceEngine = SourceEngine.eng_YTM;
  searchPageDelegate(
    this._sourceEngine,
  );
  @override
  String? get searchFieldLabel => "What you want to listen?";

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      primaryColor: Default_Theme.accentColor2,
      indicatorColor: Colors.white,
      highlightColor: Colors.white24,
      textTheme: const TextTheme(
          titleSmall: TextStyle(color: Colors.white),
          titleLarge: TextStyle(color: Colors.white),
          titleMedium: TextStyle(color: Colors.white)),
      inputDecorationTheme: const InputDecorationTheme(
          // fillColor: Colors.white,
          // focusColor: Colors.white,
          // hoverColor: Colors.white,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none),
      appBarTheme: AppBarTheme(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          color: Default_Theme.accentColor2),
      canvasColor: Default_Theme.themeColor,
      hintColor: Colors.white,
      splashColor: Colors.white54,
    );
  }

  @override
  void showResults(BuildContext context) {
    if (query.isNotEmpty) {
      context
          .read<FetchSearchResultsCubit>()
          .search(query, sourceEngine: _sourceEngine);
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
          icon: const Icon(Icons.clear))
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
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

    return FutureBuilder(
      future: YouTubeServices().getSearchSuggestions(query: query),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        List<String> suggestionList = snapshot.data! as List<String>;
        return ListView.builder(
          itemCount: suggestionList.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(suggestionList[index]),
              onTap: () {
                query = suggestionList[index];
                // Show the search results based on the selected suggestion.
              },
            );
          },
        );
      },
    );
  }
}
