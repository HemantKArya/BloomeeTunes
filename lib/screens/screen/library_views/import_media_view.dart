// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:Bloomee/repository/Saavn/cubit/saavn_repository_cubit.dart';
import 'package:Bloomee/screens/screen/library_views/cubit/import_playlist_cubit.dart';
import 'package:Bloomee/screens/widgets/import_playlist.dart';
import 'package:Bloomee/services/db/cubit/mediadb_cubit.dart';
import 'package:Bloomee/theme_data/default.dart';
import '../../widgets/unicode_icons.dart';

class ImportMediaFromPlatformsView extends StatelessWidget {
  const ImportMediaFromPlatformsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Default_Theme.themeColor,
      appBar: AppBar(
        backgroundColor: Default_Theme.themeColor,
        foregroundColor: Default_Theme.primaryColor1,
        title: Text(
          'Import Media From Platforms',
          style: const TextStyle(
                  color: Default_Theme.primaryColor1,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)
              .merge(Default_Theme.secondoryTextStyle),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ImportFromBtn(
            btnName: "Playlist from Spotify",
            btnIcon: "\uf1bc",
            onClickFunc: () {
              getIdAndShowBottomSheet(context);
            },
          ),
          ImportFromBtn(
              btnName: "Music from Spotify",
              btnIcon: "\uf1bc",
              onClickFunc: () {
                log("music from spotify");
              }),
          ImportFromBtn(
              btnName: "Playlist from Youtube",
              btnIcon: "\uf167",
              onClickFunc: () {
                getIdAndShowBottomSheet(context,
                    hintText: "Youtube Playlist ID", isSpotify: false);
              }),
          ImportFromBtn(
              btnName: "Music from Youtube",
              btnIcon: "\uf167",
              onClickFunc: () {
                log("music from youtube");
              }),
        ],
      ),
    );
  }
}

class ImportFromBtn extends StatelessWidget {
  final String btnName;
  final String btnIcon;
  final VoidCallback onClickFunc;
  const ImportFromBtn({
    Key? key,
    required this.btnName,
    required this.btnIcon,
    required this.onClickFunc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
        onPressed: () {
          onClickFunc();
        },
        icon: UnicodeIcon(
          strCode: btnIcon,
          font: const TextStyle(fontFamily: "FontAwesome-Brands"),
          fontSize: 25.0,
          padding: const EdgeInsets.only(left: 7, right: 5),
        ),
        label: Text(
          btnName,
          style: Default_Theme.secondoryTextStyle.merge(const TextStyle(
              fontSize: 20, color: Default_Theme.primaryColor1)),
        ));
  }
}

Future getIdAndShowBottomSheet(BuildContext context,
    {String hintText = "Playlist ID", bool isSpotify = true}) {
  return showMaterialModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 190,
          color: Default_Theme.accentColor2,
          child: Column(
            children: [
              const Spacer(),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  color: Default_Theme.themeColor,
                  height: 180,
                  child: Center(
                    child: Wrap(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            TextField(
                              textInputAction: TextInputAction.done,
                              maxLines: 3,
                              textAlignVertical: TextAlignVertical.center,
                              textAlign: TextAlign.center,
                              // focusNode: _focusNode,
                              cursorHeight: 30,
                              showCursor: true,
                              cursorWidth: 3,
                              cursorRadius: const Radius.circular(5),
                              cursorColor: Default_Theme.accentColor2,
                              autofocus: true,

                              style: const TextStyle(
                                      fontSize: 30,
                                      color: Default_Theme.accentColor2)
                                  .merge(
                                      Default_Theme.secondoryTextStyleMedium),
                              decoration: InputDecoration(
                                  hintText: hintText,
                                  hintStyle: TextStyle(
                                      color: Default_Theme.primaryColor2
                                          .withOpacity(0.3)),
                                  enabledBorder: const OutlineInputBorder(
                                    borderSide:
                                        BorderSide(style: BorderStyle.none),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                  )),
                              onSubmitted: (value) {
                                if (isSpotify) {
                                  context
                                      .read<SaavnSearchRepositoryCubit>()
                                      .initializeAccessTokenWithDebounce()
                                      .then((_value) {
                                    context
                                        .read<SaavnSearchRepositoryCubit>()
                                        .fetchPlaylistFromSpotify(
                                            context.read<MediaDBCubit>(),
                                            value);

                                    context
                                        .read<SaavnSearchRepositoryCubit>()
                                        .fetchPlaylistFromSpotify(
                                            context.read<MediaDBCubit>(),
                                            value.toString());
                                    showDialog(
                                      barrierDismissible: false,
                                      context: context,
                                      builder: (context) => ImportPlaylist(
                                          isSpotify: true,
                                          playlistID: value.toString()),
                                    ).then((value) => context.pop(context));
                                  });
                                } else {
                                  context
                                      .read<ImportPlaylistCubit>()
                                      .fetchYtPlaylistByID(
                                          "PLDIoUOhQQPlXr63I_vwF9GD8sAKh77dWU",
                                          context.read<MediaDBCubit>());
                                  showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (context) => ImportPlaylist(
                                        isSpotify: false,
                                        playlistID: value.toString()),
                                  ).then((value) => context.pop(context));
                                }

                                // context.pop(context);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
