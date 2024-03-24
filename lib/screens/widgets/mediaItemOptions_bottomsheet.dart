// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:Bloomee/blocs/add_to_playlist/cubit/add_to_playlist_cubit.dart';

import 'package:Bloomee/model/songModel.dart';
import 'package:Bloomee/routes_and_consts/global_str_consts.dart';
import 'package:Bloomee/theme_data/default.dart';
import 'package:Bloomee/utils/load_Image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

void showMediaItemOptions(BuildContext context, MediaItemModel mediaItemModel) {
  showMaterialModalBottomSheet(
    context: context,
    expand: false,
    animationCurve: Curves.easeIn,
    duration: const Duration(milliseconds: 300),
    elevation: 20,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return ClipRRect(
        // borderRadius: const BorderRadius.only(
        //     topLeft: Radius.circular(40), topRight: Radius.circular(40)),
        child: Container(
          height: (MediaQuery.of(context).size.height * 0.45) + 15,
          color: Default_Theme.accentColor2,
          child: Column(children: [
            const Spacer(),
            ClipRRect(
                // borderRadius: const BorderRadius.only(
                //     topLeft: Radius.circular(42),
                //     topRight: Radius.circular(42)),
                child: Container(
              height: MediaQuery.of(context).size.height * 0.46,
              width: MediaQuery.of(context).size.width,
              color: Default_Theme.themeColor,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 15),
                          child: SizedBox(
                            height: 80,
                            width: 80,
                            child: loadImageCached(
                                mediaItemModel.artUri.toString()),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: SelectableText(
                                  mediaItemModel.title,
                                  maxLines: 2,
                                  // overflow: TextOverflow.ellipsis,
                                  style: Default_Theme.secondoryTextStyle.merge(
                                      const TextStyle(
                                          color: Default_Theme.primaryColor2,
                                          fontWeight: FontWeight.bold,
                                          overflow: TextOverflow.ellipsis,
                                          fontSize: 20)),
                                ),
                              ),
                              SelectableText(
                                mediaItemModel.artist ?? "Unknown",
                                maxLines: 2,
                                textAlign: TextAlign.start,
                                // overflow: TextOverflow.ellipsis,
                                style: Default_Theme.secondoryTextStyle.merge(
                                    TextStyle(
                                        color: Default_Theme.primaryColor2
                                            .withOpacity(0.5),
                                        overflow: TextOverflow.ellipsis,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18)),
                              ),
                              // Spacer()
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(
                    color: Default_Theme.accentColor2,
                    thickness: 3,
                    height: 20,
                  ),
                  InkWell(
                    onTap: () {
                      context
                          .read<AddToPlaylistCubit>()
                          .setMediaItemModel(mediaItemModel);
                      context.pushNamed(GlobalStrConsts.addToPlaylistScreen);
                      context.pop(context);
                    },
                    child: const OptionIconBtn(
                      btnName: "Add to Playlist",
                      btnIconData: MingCute.album_2_fill,
                    ),
                  ),
                  const OptionIconBtn(
                      btnName: "Save Offline",
                      btnIconData: MingCute.download_2_fill),
                  InkWell(
                    child: const OptionIconBtn(
                      btnName: "Share with others",
                      btnIconData: MingCute.share_2_line,
                    ),
                    onTap: () {
                      Share.share(
                        "Check out this song on Bloomee\n${mediaItemModel.title} by ${mediaItemModel.artist}\n${mediaItemModel.extras?['perma_url']}",
                      );
                    },
                  ),
                  InkWell(
                    child: const OptionIconBtn(
                      btnName: "Open in Browser",
                      btnIconData: MingCute.chrome_fill,
                    ),
                    onTap: () {
                      launchUrl(Uri.parse(mediaItemModel.extras?['perma_url']));
                    },
                  )
                ],
              ),
            ))
          ]),
        ),
      );
    },
  );
}

class OptionIconBtn extends StatelessWidget {
  final String btnName;
  final IconData btnIconData;
  const OptionIconBtn({
    Key? key,
    required this.btnName,
    required this.btnIconData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, right: 15, bottom: 5, left: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            btnIconData,
            size: 30,
            color: Default_Theme.primaryColor1,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, top: 5),
            child: Text(
              btnName,
              textAlign: TextAlign.center,
              style: Default_Theme.secondoryTextStyleMedium.merge(
                  const TextStyle(
                      color: Default_Theme.primaryColor2, fontSize: 18)),
            ),
          )
        ],
      ),
    );
  }
}
