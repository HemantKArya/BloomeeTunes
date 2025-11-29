// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:Bloomee/theme_data/default.dart';
import 'package:Bloomee/utils/imgurl_formator.dart';
import 'package:flutter/material.dart';
import 'package:Bloomee/utils/load_Image.dart';

class YtSongTile extends StatefulWidget {
  final String title;
  final String subtitle;
  final String imgUrl;
  final bool rectangularImage;
  final VoidCallback? onTap;
  final VoidCallback? onOpts;
  final String permalink;
  final String id;

  const YtSongTile({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.imgUrl,
    this.onTap,
    this.onOpts,
    this.rectangularImage = false,
    required this.permalink,
    required this.id,
  }) : super(key: key);

  @override
  State<YtSongTile> createState() => _YtSongTileState();
}

class _YtSongTileState extends State<YtSongTile> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (widget.onTap != null) {
          widget.onTap!();
        } else {}
      },
      child: SizedBox(
        // width: 320,
        child: ListTile(
          leading: Padding(
            padding: const EdgeInsets.only(left: 16, right: 0),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: widget.rectangularImage
                    ? SizedBox(
                        height: 60,
                        width: 80,
                        child: LoadImageCached(
                            imageUrl:
                                formatImgURL(widget.imgUrl, ImageQuality.low),
                            fit: BoxFit.cover),
                      )
                    : SizedBox(
                        height: 60,
                        width: 60,
                        child: LoadImageCached(
                            imageUrl: formatImgURL(
                                widget.imgUrl, ImageQuality.low)))),
          ),
          title: Text(
            widget.title,
            textAlign: TextAlign.start,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: Default_Theme.tertiaryTextStyle.merge(const TextStyle(
                fontWeight: FontWeight.w600,
                color: Default_Theme.primaryColor1,
                fontSize: 14)),
          ),
          subtitle: Text(widget.subtitle,
              textAlign: TextAlign.start,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: Default_Theme.tertiaryTextStyle.merge(TextStyle(
                  color: Default_Theme.primaryColor1.withValues(alpha: 0.8),
                  fontSize: 13))),
          // dense: true,
          contentPadding: const EdgeInsets.all(0),
          trailing: IconButton(
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(8),
            onPressed: () {
              if (widget.onOpts != null) {
                widget.onOpts!();
              }
            },
            icon: const Icon(
              Icons.more_vert,
              color: Default_Theme.primaryColor1,
            ),
          ),
        ),
      ),
    );
  }
}
