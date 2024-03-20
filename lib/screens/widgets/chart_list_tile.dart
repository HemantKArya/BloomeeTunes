import 'package:Bloomee/routes_and_consts/global_str_consts.dart';
import 'package:Bloomee/utils/load_Image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme_data/default.dart';

class ChartListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imgUrl;

  const ChartListTile({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.imgUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push(
          "/${GlobalStrConsts.searchScreen}?query=${title} by ${subtitle}"),
      child: SizedBox(
        width: 300,
        child: ListTile(
          leading: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(height: 60, child: loadImageCached(imgUrl))),
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
