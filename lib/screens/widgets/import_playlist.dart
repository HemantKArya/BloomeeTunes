// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:Bloomee/repository/Saavn/cubit/saavn_repository_cubit.dart';
import 'package:Bloomee/screens/screen/library_views/cubit/import_playlist_cubit.dart';

import 'package:Bloomee/theme_data/default.dart';

class ImportPlaylist extends StatefulWidget {
  final String playlistID;
  final bool isSpotify;
  const ImportPlaylist({
    Key? key,
    required this.playlistID,
    this.isSpotify = true,
  }) : super(key: key);

  @override
  State<ImportPlaylist> createState() => _ImportPlaylistState();
}

class _ImportPlaylistState extends State<ImportPlaylist> {
  bool isCompleted = false;
  @override
  void initState() {
    super.initState();

    if (widget.isSpotify) {
      context
          .read<SaavnSearchRepositoryCubit>()
          .importFromSpotifyState
          .stream
          .listen((event) {
        if (event is ImportPlaylistStateComplete ||
            event.currentItem == event.totalLength) {
          setState(() {
            isCompleted = true;
          });
          Future.delayed(const Duration(milliseconds: 2000))
              .then((value) => context.pop(context));
        }
      });
    } else {
      context
          .read<ImportPlaylistCubit>()
          .importYtPlaylistBS
          .stream
          .listen((event) {
        if (event is ImportPlaylistStateComplete ||
            event.currentItem == event.totalLength) {
          setState(() {
            isCompleted = true;
          });
          Future.delayed(const Duration(milliseconds: 2000))
              .then((value) => context.pop(context));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 160,
          color: Default_Theme.accentColor2,
          child: Column(
            children: [
              Spacer(),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  color: Default_Theme.themeColor,
                  width: MediaQuery.of(context).size.width * 0.95,
                  height: 150,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      widget.isSpotify
                          ? StreamBuilder<ImportPlaylistState>(
                              stream: context
                                  .watch<SaavnSearchRepositoryCubit>()
                                  .importFromSpotifyState
                                  .stream,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "${snapshot.data!.itemName}  ${snapshot.data!.currentItem}/${snapshot.data!.totalLength}",
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                              color:
                                                  Default_Theme.primaryColor1,
                                              fontSize: 15)
                                          .merge(
                                              Default_Theme.secondoryTextStyle),
                                    ),
                                  );
                                } else {
                                  return Text(
                                    "Searching for playlist",
                                    style: const TextStyle(
                                            color: Default_Theme.primaryColor1)
                                        .merge(
                                            Default_Theme.secondoryTextStyle),
                                  );
                                }
                              })
                          : StreamBuilder<ImportPlaylistState>(
                              stream: context
                                  .watch<ImportPlaylistCubit>()
                                  .importYtPlaylistBS
                                  .stream,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "${snapshot.data!.itemName}  ${snapshot.data!.currentItem}/${snapshot.data!.totalLength}",
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                              color:
                                                  Default_Theme.primaryColor1,
                                              fontSize: 15)
                                          .merge(
                                              Default_Theme.secondoryTextStyle),
                                    ),
                                  );
                                } else {
                                  return Text(
                                    "Searching for playlist",
                                    style: const TextStyle(
                                            color: Default_Theme.primaryColor1)
                                        .merge(
                                            Default_Theme.secondoryTextStyle),
                                  );
                                }
                              }),
                      isCompleted
                          ? const Text(
                              "Successfully Imported!!",
                              style: TextStyle(
                                  color: Default_Theme.primaryColor1,
                                  fontSize: 18),
                            )
                          : const SizedBox(
                              width: 55,
                              height: 55,
                              child: CircularProgressIndicator(
                                color: Default_Theme.accentColor2,
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
