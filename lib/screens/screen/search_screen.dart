import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Bloomee/repository/Saavn/cubit/saavn_repository_cubit.dart';
import 'package:Bloomee/repository/cubits/fetch_search_results.dart';
import 'package:Bloomee/screens/screen/search_views/search_page.dart';
import 'package:Bloomee/screens/widgets/horizontalSongCard_widget.dart';
import 'package:Bloomee/theme_data/default.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      onVerticalDragEnd: (DragEndDetails details) =>
          FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: SizedBox(height: 50.0, child: SearchBoxWidget()),
          backgroundColor: Default_Theme.themeColor,
        ),
        backgroundColor: Default_Theme.themeColor,
        body: BlocBuilder<FetchSearchResultsCubit, FetchSearchResultsState>(
          buildWhen: (previous, current) {
            if (current != previous && current.albumName == "Search") {
              return true;
            } else {
              return false;
            }
          },
          builder: (context, state) {
            if (state is SaavnRepositoryInitial) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Icon(
                        Icons.error_outline,
                        color: Default_Theme.primaryColor2.withOpacity(0.4),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Text(
                        "Change the keyword and try to search again!",
                        softWrap: true,
                        textAlign: TextAlign.center,
                        style: Default_Theme.tertiaryTextStyle.merge(TextStyle(
                            color:
                                Default_Theme.primaryColor2.withOpacity(0.4))),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return ListView.builder(
                itemCount: state.mediaItems.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {},
                    child: Padding(
                      padding:
                          const EdgeInsets.only(left: 18, bottom: 5, right: 18),
                      child: HorizontalSongCardWidget(
                        index: index,
                        mediaPlaylist: state,
                        showLiked: true,
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}

class SearchBoxWidget extends StatelessWidget {
  SearchBoxWidget({
    super.key,
  });
  final TextEditingController _textEditingController = TextEditingController();
  // final _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showSearch(
                context: context,
                delegate: searchPageDelegate(),
                query: _textEditingController.text)
            .then((value) {
          if ((value as String) != 'null') {
            _textEditingController.text = value.toString();
          }
        });
      },
      child: TextField(
        controller: _textEditingController,
        // autofocus: false,
        // onTap: () {
        //   showSearch(
        //     context: context,
        //     delegate: searchPageDelegate(),
        //   );
        // },
        // focusNode: _focusNode,
        // onSubmitted: (value) {
        //   _searchSuggestions = [];
        //   context.read<FetchSearchResultsCubit>().search(value);
        // },
        // onChanged: (value) {
        //   YouTubeServices().getSearchSuggestions(query: value).then((value) {
        //     _searchSuggestions = value as List<String>;
        //   });
        // },
        // onTapOutside: (event) {
        //   _searchSuggestions = [];
        //   _focusNode.unfocus();
        // },
        enabled: false,

        textAlign: TextAlign.center,
        style: TextStyle(color: Default_Theme.primaryColor1.withOpacity(0.55)),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
            filled: true,
            suffixIcon: Icon(
              Icons.search,
              color: Default_Theme.primaryColor1.withOpacity(0.4),
            ),
            fillColor: Default_Theme.primaryColor2.withOpacity(0.07),
            contentPadding: const EdgeInsets.only(top: 20),
            hintText: "What you want to listen?",
            hintStyle: TextStyle(
                color: Default_Theme.primaryColor1.withOpacity(0.4),
                fontFamily: "Gilroy"),
            disabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(style: BorderStyle.none),
                borderRadius: BorderRadius.circular(50)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Default_Theme.primaryColor1.withOpacity(0.7)),
                borderRadius: BorderRadius.circular(50))),
      ),
    );
  }
}
