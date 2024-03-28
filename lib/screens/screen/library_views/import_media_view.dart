// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';
import 'package:Bloomee/utils/external_list_importer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:Bloomee/repository/Saavn/cubit/saavn_repository_cubit.dart';
import 'package:Bloomee/screens/screen/library_views/cubit/import_playlist_cubit.dart';
import 'package:Bloomee/screens/widgets/import_playlist.dart';
import 'package:Bloomee/services/db/cubit/bloomee_db_cubit.dart';
import 'package:Bloomee/theme_data/default.dart';

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
            btnIcon: FontAwesome.spotify_brand,
            onClickFunc: () {
              getIdAndShowBottomSheet(context);
            },
          ),
          ImportFromBtn(
              btnName: "Music from Spotify",
              btnIcon: FontAwesome.spotify_brand,
              onClickFunc: () {
                log("music from spotify");
              }),
          ImportFromBtn(
              btnName: "Playlist from Youtube",
              btnIcon: FontAwesome.youtube_brand,
              onClickFunc: () {
                getIdAndShowBottomSheet(context,
                    hintText: "Youtube Playlist ID", isSpotify: false);
              }),
          ImportFromBtn(
              btnName: "Music from Youtube",
              btnIcon: FontAwesome.youtube_brand,
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
  final IconData btnIcon;
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
        icon: Padding(
          padding: const EdgeInsets.only(left: 8, right: 8),
          child: Icon(btnIcon, color: Default_Theme.primaryColor1, size: 30),
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
                                } else {
                                  context.pop(context);
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) => ImporterDialogWidget(
                                        strm: ExternalMediaImporter
                                            .ytPlaylistImporter(value)),
                                  );
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
