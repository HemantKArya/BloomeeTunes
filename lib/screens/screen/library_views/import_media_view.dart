// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';
import 'package:Bloomee/model/songModel.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:Bloomee/services/db/GlobalDB.dart';
import 'package:Bloomee/services/db/bloomee_db_service.dart';
import 'package:Bloomee/utils/external_list_importer.dart';
import 'package:Bloomee/services/file_manager.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:Bloomee/screens/widgets/import_playlist.dart';
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
              getIdAndShowBottomSheet(context,
                  hintText: "https://open.spotify.com/playlist/XXXXX",
                  isSpotify: true);
            },
          ),
          ImportFromBtn(
              btnName: "Music from Spotify",
              btnIcon: FontAwesome.spotify_brand,
              onClickFunc: () {
                getIdAndShowBottomSheet(context,
                    hintText: "https://open.spotify.com/track/XXXXXX",
                    isSpotify: true,
                    isSingle: true);
              }),
          ImportFromBtn(
              btnName: "Playlist from Youtube",
              btnIcon: FontAwesome.youtube_brand,
              onClickFunc: () {
                getIdAndShowBottomSheet(context,
                    hintText: "https://www.youtube.com/playlist?list=XXXXXX",
                    isSpotify: false);
              }),
          ImportFromBtn(
              btnName: "Music from Youtube",
              btnIcon: FontAwesome.youtube_brand,
              onClickFunc: () {
                getIdAndShowBottomSheet(context,
                    hintText: "https://www.youtube.com/watch?v=XXXXXX",
                    isSpotify: false,
                    isSingle: true);
              }),
          ImportFromBtn(
              btnName: "Import Playlist from Storage",
              btnIcon: FontAwesome.file,
              onClickFunc: () {
                FilePicker.platform.pickFiles().then((value) {
                  if (value != null) {
                    log(value.files[0].path.toString(), name: "Import File");
                    if (value.files[0].path != null) {
                      if (value.files[0].path!.endsWith('.blm')) {
                        BloomeeFileManager.importPlaylist(value.files[0].path!);
                        SnackbarService.showMessage(
                            "Started Importing Playlist");
                      } else {
                        log("Invalid File Format", name: "Import File");
                        SnackbarService.showMessage("Invalid File Format");
                      }
                    }
                  }
                });
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
    {String hintText = "Playlist ID",
    bool isSpotify = true,
    isSingle = false}) {
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
                              cursorHeight: 45,
                              showCursor: true,
                              cursorWidth: 5,
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
                                if (isSingle) {
                                  if (isSpotify) {
                                    context.pop(context);
                                    ExternalMediaImporter.sfyMediaImporter(
                                            value)
                                        .then((value) {
                                      if (value != null) {
                                        BloomeeDBService.addMediaItem(
                                            MediaItem2MediaItemDB(value),
                                            MediaPlaylistDB(
                                                playlistName:
                                                    "Spotify Imports"));
                                        SnackbarService.showMessage(
                                            "Imported Media: ${value.title}");
                                      } else {
                                        log("Failed to import media",
                                            name: "Import Media");
                                      }
                                    });
                                  } else {
                                    context.pop();
                                    ExternalMediaImporter.ytMediaImporter(value)
                                        .then((value) {
                                      if (value != null) {
                                        BloomeeDBService.addMediaItem(
                                            MediaItem2MediaItemDB(value),
                                            MediaPlaylistDB(
                                                playlistName:
                                                    "Youtube Imports"));
                                        SnackbarService.showMessage(
                                            "Imported Media: ${value.title}");
                                      } else {
                                        log("Failed to import media from YT",
                                            name: "Import Media");
                                      }
                                    });
                                  }
                                } else {
                                  if (isSpotify) {
                                    context.pop(context);
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context) =>
                                          ImporterDialogWidget(
                                              strm: ExternalMediaImporter
                                                  .sfyPlaylistImporter(
                                                      url: value)),
                                    );
                                  } else {
                                    context.pop(context);
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context) =>
                                          ImporterDialogWidget(
                                              strm: ExternalMediaImporter
                                                  .ytPlaylistImporter(value)),
                                    );
                                  }
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
