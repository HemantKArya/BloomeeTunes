import 'package:Bloomee/theme_data/default.dart';
import 'package:Bloomee/utils/load_Image.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

class SquareImgCard extends StatelessWidget {
  final String imgPath;
  final String title;
  final String subtitle;
  final Function? onTap;
  final String? tag;
  final bool isWide;
  final bool isList;

  const SquareImgCard({
    super.key,
    required this.imgPath,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.isWide = false,
    this.tag,
    this.isList = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: isWide ? 250 : 150,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Stack(children: [
                SizedBox(
                  height: 150,
                  width: isWide ? 250 : 150,
                  child: LoadImageCached(
                    imageUrl: imgPath,
                  ),
                ),
                Visibility(
                  visible: tag != null,
                  child: Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color:
                            Default_Theme.accentColor2.withValues(alpha: 0.95),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(15),
                        ),
                        // border: Border.all(
                        //   color: Default_Theme.primaryColor1,
                        //   width: 1.5,
                        // ),
                      ),
                      child: isList
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(right: 5),
                                  child: Icon(
                                    MingCute.playlist_2_line,
                                    size: 18,
                                    color: Default_Theme.primaryColor2,
                                  ),
                                ),
                                Text(
                                  "$tag",
                                  style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Default_Theme.primaryColor2)
                                      .merge(Default_Theme.secondoryTextStyle),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(right: 5),
                                  child: Icon(
                                    MingCute.eye_2_line,
                                    size: 18,
                                    color: Default_Theme.primaryColor2,
                                  ),
                                ),
                                Text(
                                  "$tag",
                                  style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Default_Theme.primaryColor2)
                                      .merge(Default_Theme.secondoryTextStyle),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ]),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Default_Theme.secondoryTextStyle.merge(const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Default_Theme.primaryColor1,
                  height: 1.0)),
            ),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Default_Theme.secondoryTextStyle.merge(TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Default_Theme.primaryColor2.withValues(alpha: 0.8),
                  height: 1.0)),
            ),
          ],
        ),
      ),
    );
  }
}
