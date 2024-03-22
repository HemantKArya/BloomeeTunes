// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:Bloomee/screens/widgets/like_widget.dart';
import 'package:Bloomee/theme_data/default.dart';
import 'package:Bloomee/utils/load_Image.dart';
import 'package:icons_plus/icons_plus.dart';

class SingleSongCardWidget extends StatelessWidget {
  final String titleText;
  final String subText;
  final String artUri;
  final bool showLiked;
  final VoidCallback? onLiked;
  final VoidCallback? onDisliked;
  final VoidCallback? onClicked;
  final boxWidth;
  bool isLiked;
  final bool showOptions;
  SingleSongCardWidget({
    Key? key,
    required this.titleText,
    required this.subText,
    this.artUri = "",
    this.onLiked,
    this.onDisliked,
    this.onClicked,
    this.showLiked = false,
    this.isLiked = false,
    this.showOptions = false,
    this.boxWidth = 0.86,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // color: Colors.white.withOpacity(0.3),
      // width: MediaQuery.of(context).size.width * boxWidth,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        focusColor: null,
        highlightColor: null,
        onTap: () {
          if (onClicked != null) {
            onClicked!();
          }
        },
        child: Container(
          padding: const EdgeInsets.only(left: 7, right: 7, top: 3, bottom: 3),
          child: Row(
            // mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: SizedBox(
                    width: 55,
                    height: 55,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: loadImageCached(artUri),
                    )),
              ),
              Expanded(
                flex: 15,
                // width: MediaQuery.of(context).size.width * boxWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      titleText,
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: Default_Theme.tertiaryTextStyle.merge(
                          const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Default_Theme.primaryColor1,
                              fontSize: 15)),
                    ),
                    const SizedBox(height: 4),
                    Text(subText,
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: Default_Theme.tertiaryTextStyle.merge(TextStyle(
                            color:
                                Default_Theme.primaryColor1.withOpacity(0.75),
                            fontSize: 13)))
                  ],
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Visibility(
                    visible: showLiked,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0, bottom: 3),
                      child: LikeBtnWidget(
                        isLiked: isLiked,
                        iconSize: 29,
                        onLiked: onLiked,
                        onDisliked: onDisliked,
                      ),
                    ),
                  ),
                  Visibility(
                      visible: showOptions,
                      child: const Icon(MingCute.more_2_fill)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
