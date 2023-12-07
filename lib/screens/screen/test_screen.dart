import 'package:Bloomee/repository/Spotify/spotify_api.dart';
import 'package:Bloomee/services/bloomeeUpdaterTools.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Bloomee/repository/Saavn/cubit/saavn_repository_cubit.dart';
import 'package:Bloomee/screens/screen/library_views/cubit/import_playlist_cubit.dart';
import 'package:Bloomee/theme_data/default.dart';

class TestView extends StatelessWidget {
  const TestView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Default_Theme.themeColor,
      appBar: AppBar(
        backgroundColor: Default_Theme.themeColor,
        foregroundColor: Default_Theme.primaryColor1,
        title: Text(
          'Tests',
          style: const TextStyle(
                  color: Default_Theme.primaryColor1,
                  fontSize: 25,
                  fontWeight: FontWeight.bold)
              .merge(Default_Theme.secondoryTextStyle),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            StreamBuilder<ImportPlaylistState>(
                stream: context
                    .watch<SaavnSearchRepositoryCubit>()
                    .importFromSpotifyState,
                builder: (context, snapshot) {
                  print(snapshot.data?.itemName.toString());
                  if (snapshot.hasData) {
                    return SizedBox(
                      child: CircularProgressIndicator(
                        value: snapshot.data!.currentItem.toDouble() /
                            snapshot.data!.totalLength.toDouble(),
                      ),
                    );
                  } else {
                    return Text("NO", style: TextStyle(color: Colors.white));
                  }
                }),
            TextButton(
                onPressed: () {
                  getLatestVersion().then((value) => print(value));
                },
                child: Text("getSearchSuggestions"))
          ],
        ),
      ),
    );
  }
}
