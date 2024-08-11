// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:Bloomee/routes_and_consts/global_str_consts.dart';
import 'package:Bloomee/utils/load_Image.dart';

import '../../theme_data/default.dart';

class ChartListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imgUrl;
  final bool rectangularImage;
  final VoidCallback? onTap;

  const ChartListTile({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.imgUrl,
    this.onTap,
    this.rectangularImage = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (onTap != null) {
          onTap!();
        } else {
          context.push(
              "/${GlobalStrConsts.searchScreen}?query=$title by $subtitle");
        }
      },
      child: SizedBox(
        // width: 320,
        child: ListTile(
          leading: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: rectangularImage
                  ? SizedBox(
                      height: 60,
                      width: 80,
                      child:
                          LoadImageCached(imageUrl: imgUrl, fit: BoxFit.cover),
                    )
                  : SizedBox(
                      height: 60,
                      width: 60,
                      child: LoadImageCached(imageUrl: imgUrl))),
          title: Text(
            title,
            textAlign: TextAlign.start,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: Default_Theme.tertiaryTextStyle.merge(const TextStyle(
                fontWeight: FontWeight.w600,
                color: Default_Theme.primaryColor1,
                fontSize: 14)),
          ),
          subtitle: Text(subtitle,
              textAlign: TextAlign.start,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: Default_Theme.tertiaryTextStyle.merge(TextStyle(
                  color: Default_Theme.primaryColor1.withOpacity(0.8),
                  fontSize: 13))),
        ),
      ),
    );
  }
}
