import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

Future<PaletteGenerator> getPalleteFromImage(String url) async {
  ImageProvider<Object> placeHolder =
      AssetImage("assets/sample/album_cover_sam1.jpg");

  try {
    return (await PaletteGenerator.fromImageProvider(
        CachedNetworkImageProvider(url)));
  } catch (e) {
    return await PaletteGenerator.fromImageProvider(placeHolder);
  }
}
