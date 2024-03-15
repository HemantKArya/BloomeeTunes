import 'package:Bloomee/utils/load_Image.dart';
import 'package:flutter/material.dart';

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
    return ListTile(
      leading: loadImageCached(imgUrl),
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
    );
  }
}
