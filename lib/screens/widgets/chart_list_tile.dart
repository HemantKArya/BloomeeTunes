// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:Bloomee/core/constants/route_paths.dart';
import 'package:Bloomee/utils/load_image.dart';
import 'package:Bloomee/core/theme/app_theme.dart';

/// A list tile for chart items.
///
/// When tapped, navigates to the search screen with a pre-filled query
/// so the plugin-based search can find the track.
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
        log("imgUrl: $imgUrl", name: "ChartListTile");
        if (onTap != null) {
          onTap!();
        } else {
          // Navigate to search screen with query
          final query = "$title $subtitle".trim();
          context.push("/${RoutePaths.searchScreen}?query=$query");
        }
      },
      child: SizedBox(
        child: ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: rectangularImage
                ? SizedBox(
                    height: 60,
                    width: 80,
                    child: LoadImageCached(
                      imageUrl: imgUrl,
                      fallbackUrl: imgUrl,
                      fit: BoxFit.cover,
                    ),
                  )
                : SizedBox(
                    height: 60,
                    width: 60,
                    child: LoadImageCached(
                      imageUrl: imgUrl,
                      fallbackUrl: imgUrl,
                    ),
                  ),
          ),
          title: Text(
            title,
            textAlign: TextAlign.start,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: Default_Theme.tertiaryTextStyle.merge(
              const TextStyle(
                fontWeight: FontWeight.w600,
                color: Default_Theme.primaryColor1,
                fontSize: 14,
              ),
            ),
          ),
          subtitle: Text(
            subtitle,
            textAlign: TextAlign.start,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: Default_Theme.tertiaryTextStyle.merge(
              TextStyle(
                color: Default_Theme.primaryColor1.withValues(alpha: 0.8),
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
