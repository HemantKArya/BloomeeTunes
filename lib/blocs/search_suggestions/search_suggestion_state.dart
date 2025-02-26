// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'search_suggestion_bloc.dart';

class SearchSuggestionState extends Equatable {
  final List<String> suggestionList;
  final List<Map<String, String>> dbSuggestionList;
  const SearchSuggestionState(this.suggestionList, this.dbSuggestionList);

  @override
  List<Object> get props => [
        suggestionList,
        dbSuggestionList,
        dbSuggestionList.length,
        suggestionList.length
      ];

  SearchSuggestionState copyWith({
    List<String>? suggestionList,
    List<Map<String, String>>? dbSuggestionList,
  }) {
    return SearchSuggestionState(
      suggestionList ?? this.suggestionList,
      dbSuggestionList ?? this.dbSuggestionList,
    );
  }
}

final class SearchSuggestionLoading extends SearchSuggestionState {
  const SearchSuggestionLoading() : super(const [], const []);
}

final class SearchSuggestionLoaded extends SearchSuggestionState {
  const SearchSuggestionLoaded(
      List<String> suggestionList, List<Map<String, String>> dbSuggestionList)
      : super(suggestionList, dbSuggestionList);
}
