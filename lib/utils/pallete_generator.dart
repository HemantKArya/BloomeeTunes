import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

Future<PaletteGenerator> getPalleteFromImage(String url) async {
  ImageProvider<Object> placeHolder =
      const AssetImage("assets/icons/bloomee_new_logo_c.png");

  try {
    return (await PaletteGenerator.fromImageProvider(
        CachedNetworkImageProvider(url)));
  } catch (e) {
    return await PaletteGenerator.fromImageProvider(placeHolder);
  }
}
