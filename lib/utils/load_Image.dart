// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:Bloomee/theme_data/default.dart';
import 'package:http/http.dart' as http;

Image loadImage(coverImageUrl,
    {placeholderPath = "assets/icons/bloomee_new_logo_c.png"}) {
  ImageProvider<Object> placeHolder = AssetImage(placeholderPath);
  return Image.network(
    coverImageUrl,
    fit: BoxFit.cover,
    loadingBuilder: (context, child, loadingProgress) {
      if (loadingProgress == null) {
        return child;
      } else {
        return Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxHeight > constraints.maxWidth) {
                return SizedBox(
                  height: constraints.maxWidth,
                  width: constraints.maxWidth,
                  child: const CircularProgressIndicator(
                      color: Default_Theme.accentColor2),
                );
              } else {
                return SizedBox(
                  height: constraints.maxHeight,
                  width: constraints.maxHeight,
                  child: const CircularProgressIndicator(
                      color: Default_Theme.accentColor2),
                );
              }
            },
          ),
        );
      }
    },
    errorBuilder: (context, error, stackTrace) {
      return Image(
        image: placeHolder,
        fit: BoxFit.cover,
      );
    },
  );
}

CachedNetworkImage loadImageCached(coverImageURL,
    {placeholderPath = "assets/icons/bloomee_new_logo_c.png",
    fit = BoxFit.cover}) {
  ImageProvider<Object> placeHolder = AssetImage(placeholderPath);
  return CachedNetworkImage(
    imageUrl: coverImageURL,
    memCacheWidth: 500,
    // memCacheHeight: 500,
    placeholder: (context, url) => Image(
      image: const AssetImage("assets/icons/lazy_loading.png"),
      fit: fit,
    ),
    errorWidget: (context, url, error) => Image(
      image: placeHolder,
      fit: fit,
    ),
    fadeInDuration: const Duration(milliseconds: 700),
    fit: fit,
  );
}

class LoadImageCached extends StatelessWidget {
  final String imageUrl;
  final String placeholderUrl;
  final BoxFit fit;
  final double height;

  const LoadImageCached({
    Key? key,
    required this.imageUrl,
    this.placeholderUrl = "assets/icons/bloomee_new_logo_c.png",
    this.fit = BoxFit.cover,
    this.height = 500,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      height: height,
      // memCacheHeight: 500,
      placeholder: (context, url) => Image(
        image: const AssetImage("assets/icons/lazy_loading.png"),
        fit: fit,
      ),
      errorWidget: (context, url, error) => Image(
        image: AssetImage(placeholderUrl),
        fit: fit,
      ),
      fadeInDuration: const Duration(milliseconds: 700),
      fit: fit,
    );
  }
}

Future<ImageProvider> getImageProvider(String imageUrl,
    {String placeholderUrl = "assets/icons/bloomee_new_logo_c.png"}) async {
  if (imageUrl != "") {
    final response = await http.head(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      CachedNetworkImageProvider cachedImageProvider =
          CachedNetworkImageProvider(imageUrl);
      return cachedImageProvider;
    } else {
      return AssetImage(placeholderUrl);
    }
  }
  return AssetImage(placeholderUrl);
}
