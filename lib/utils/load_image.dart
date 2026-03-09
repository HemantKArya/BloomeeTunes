// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:http/http.dart' as http;

bool _isValidNetworkUrl(String? url) {
  if (url == null || url.trim().isEmpty) return false;
  final parsed = Uri.tryParse(url.trim());
  return parsed != null &&
      (parsed.scheme == 'http' || parsed.scheme == 'https') &&
      parsed.host.isNotEmpty;
}

File? _resolveLocalImageFile(String? url) {
  if (url == null || url.trim().isEmpty) return null;

  final trimmed = url.trim();
  final parsed = Uri.tryParse(trimmed);

  String? path;
  if (parsed != null && parsed.scheme == 'file') {
    try {
      path = parsed.toFilePath(windows: Platform.isWindows);
    } catch (_) {
      path = null;
    }
  }

  if (path == null && trimmed.startsWith('file://')) {
    final rawPath = trimmed.substring('file://'.length);
    if (rawPath.startsWith('/') ||
        rawPath.startsWith(r'\\') ||
        RegExp(r'^[a-zA-Z]:[\\/]').hasMatch(rawPath)) {
      path = rawPath;
    }
  } else if (trimmed.startsWith('/') ||
      trimmed.startsWith(r'\\') ||
      RegExp(r'^[a-zA-Z]:[\\/]').hasMatch(trimmed)) {
    path = trimmed;
  }

  if (path == null || path.isEmpty) return null;

  final file = File(path);
  return file.existsSync() ? file : null;
}

Image _placeholderImage(String placeholderPath, BoxFit fit) {
  return Image(
    image: AssetImage(placeholderPath),
    fit: fit,
  );
}

ImageProvider<Object> getImageProviderSync(
  String? imageUrl, {
  String? fallbackUrl,
  String placeholderUrl = "assets/icons/bloomee_new_logo_c.png",
}) {
  final primaryFile = _resolveLocalImageFile(imageUrl);
  if (primaryFile != null) {
    return FileImage(primaryFile);
  }

  final fallbackFile = _resolveLocalImageFile(fallbackUrl);
  if (fallbackFile != null && !_isValidNetworkUrl(imageUrl)) {
    return FileImage(fallbackFile);
  }

  if (_isValidNetworkUrl(imageUrl)) {
    return CachedNetworkImageProvider(imageUrl!.trim());
  }
  if (_isValidNetworkUrl(fallbackUrl)) {
    return CachedNetworkImageProvider(fallbackUrl!.trim());
  }

  return AssetImage(placeholderUrl);
}

Widget _buildLocalFileImage({
  required File file,
  required String placeholderPath,
  required BoxFit fit,
}) {
  return Image.file(
    file,
    fit: fit,
    errorBuilder: (context, error, stackTrace) =>
        _placeholderImage(placeholderPath, fit),
  );
}

Image loadImage(coverImageUrl,
    {placeholderPath = "assets/icons/bloomee_new_logo_c.png"}) {
  final localFile = _resolveLocalImageFile(coverImageUrl?.toString());
  if (localFile != null) {
    return Image.file(
      localFile,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          _placeholderImage(placeholderPath, BoxFit.cover),
    );
  }

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
                      color: AppTheme.accentColor2),
                );
              } else {
                return SizedBox(
                  height: constraints.maxHeight,
                  width: constraints.maxHeight,
                  child: const CircularProgressIndicator(
                      color: AppTheme.accentColor2),
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

Widget loadImageCached(coverImageURL,
    {placeholderPath = "assets/icons/bloomee_new_logo_c.png",
    fit = BoxFit.cover}) {
  final localFile = _resolveLocalImageFile(coverImageURL?.toString());
  if (localFile != null) {
    return _buildLocalFileImage(
      file: localFile,
      placeholderPath: placeholderPath,
      fit: fit,
    );
  }

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

class LoadImageCached extends StatefulWidget {
  final String imageUrl;
  final String? fallbackUrl;
  final String placeholderUrl;
  final BoxFit fit;

  const LoadImageCached({
    Key? key,
    required this.imageUrl,
    this.placeholderUrl = "assets/icons/bloomee_new_logo_c.png",
    this.fit = BoxFit.cover,
    this.fallbackUrl,
  }) : super(key: key);

  @override
  State<LoadImageCached> createState() => _LoadImageCachedState();
}

class _LoadImageCachedState extends State<LoadImageCached> {
  static final Set<String> _failedImageUrls = <String>{};

  @override
  Widget build(BuildContext context) {
    final primaryFile = _resolveLocalImageFile(widget.imageUrl);
    if (primaryFile != null) {
      return _buildLocalFileImage(
        file: primaryFile,
        placeholderPath: widget.placeholderUrl,
        fit: widget.fit,
      );
    }

    final fallbackFile = _resolveLocalImageFile(widget.fallbackUrl);
    if (!_isValidNetworkUrl(widget.imageUrl) && fallbackFile != null) {
      return _buildLocalFileImage(
        file: fallbackFile,
        placeholderPath: widget.placeholderUrl,
        fit: widget.fit,
      );
    }

    final hasPrimary = _isValidNetworkUrl(widget.imageUrl);
    final hasFallback = _isValidNetworkUrl(widget.fallbackUrl);

    if (!hasPrimary && !hasFallback) {
      return _placeholderImage(widget.placeholderUrl, widget.fit);
    }

    final primaryUrl = hasPrimary ? widget.imageUrl : widget.fallbackUrl!;
    final fallbackUrl = hasPrimary && hasFallback ? widget.fallbackUrl : null;

    if (_failedImageUrls.contains(primaryUrl) &&
        (fallbackUrl == null || _failedImageUrls.contains(fallbackUrl))) {
      return _placeholderImage(widget.placeholderUrl, widget.fit);
    }

    return CachedNetworkImage(
      imageUrl: primaryUrl,
      placeholder: (context, url) => Image(
        image: const AssetImage("assets/icons/lazy_loading.png"),
        fit: widget.fit,
      ),
      errorWidget: (context, url, error) {
        _failedImageUrls.add(url);
        if (fallbackFile != null) {
          return _buildLocalFileImage(
            file: fallbackFile,
            placeholderPath: widget.placeholderUrl,
            fit: widget.fit,
          );
        }
        if (fallbackUrl == null || _failedImageUrls.contains(fallbackUrl)) {
          return _placeholderImage(widget.placeholderUrl, widget.fit);
        }

        return CachedNetworkImage(
          imageUrl: fallbackUrl,
          memCacheWidth: 500,
          placeholder: (context, url) => Image(
            image: const AssetImage("assets/icons/lazy_loading.png"),
            fit: widget.fit,
          ),
          errorWidget: (context, url, error) {
            _failedImageUrls.add(url);
            return _placeholderImage(widget.placeholderUrl, widget.fit);
          },
          fadeInDuration: const Duration(milliseconds: 300),
          fit: widget.fit,
        );
      },
      fadeInDuration: const Duration(milliseconds: 300),
      fit: widget.fit,
    );
  }
}

Future<ImageProvider> getImageProvider(String imageUrl,
    {String placeholderUrl = "assets/icons/bloomee_new_logo_c.png"}) async {
  final localFile = _resolveLocalImageFile(imageUrl);
  if (localFile != null) {
    return FileImage(localFile);
  }

  final parsed = Uri.tryParse(imageUrl);
  if (parsed != null &&
      (parsed.scheme == 'http' || parsed.scheme == 'https') &&
      parsed.host.isNotEmpty) {
    final response = await http.head(parsed);
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
