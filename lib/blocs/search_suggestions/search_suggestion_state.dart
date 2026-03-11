// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'search_suggestion_bloc.dart';

class SearchSuggestionState extends Equatable {
  final List<String> suggestionList;
  final List<Map<String, String>> dbSuggestionList;
  final List<plugin_models.EntitySuggestion> entitySuggestionList;

  const SearchSuggestionState(
    this.suggestionList,
    this.dbSuggestionList, {
    this.entitySuggestionList = const [],
  });

  @override
  List<Object> get props => [
        suggestionList,
        dbSuggestionList,
        entitySuggestionList,
        dbSuggestionList.length,
        suggestionList.length,
        entitySuggestionList.length,
      ];

  SearchSuggestionState copyWith({
    List<String>? suggestionList,
    List<Map<String, String>>? dbSuggestionList,
    List<plugin_models.EntitySuggestion>? entitySuggestionList,
  }) {
    return SearchSuggestionState(
      suggestionList ?? this.suggestionList,
      dbSuggestionList ?? this.dbSuggestionList,
      entitySuggestionList: entitySuggestionList ?? this.entitySuggestionList,
    );
  }
}

final class SearchSuggestionLoading extends SearchSuggestionState {
  const SearchSuggestionLoading() : super(const [], const []);
}

final class SearchSuggestionLoaded extends SearchSuggestionState {
  const SearchSuggestionLoaded(
    List<String> suggestionList,
    List<Map<String, String>> dbSuggestionList, {
    List<plugin_models.EntitySuggestion> entitySuggestionList = const [],
  }) : super(suggestionList, dbSuggestionList,
            entitySuggestionList: entitySuggestionList);
}
