import 'dart:ui' as ui;

import 'package:Bloomee/utils/load_image.dart';
import 'package:flutter/material.dart';

/// Blur once when artwork changes, into a small texture. Drawing and moving
/// the player subsequently composites an image, rather than a viewport blur.
class AmbientArtworkTexture extends StatefulWidget {
  final String imageUrl;
  final String? fallbackUrl;

  const AmbientArtworkTexture({
    super.key,
    required this.imageUrl,
    this.fallbackUrl,
  });

  @override
  State<AmbientArtworkTexture> createState() => _AmbientArtworkTextureState();
}

class _AmbientArtworkTextureState extends State<AmbientArtworkTexture> {
  static const _textureSize = 256;
  ui.Image? _texture;
  int _generation = 0;
  ImageStream? _stream;
  ImageStreamListener? _listener;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(AmbientArtworkTexture oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl ||
        oldWidget.fallbackUrl != widget.fallbackUrl) {
      _load();
    }
  }

  void _detach() {
    final listener = _listener;
    if (listener != null) _stream?.removeListener(listener);
    _listener = null;
    _stream = null;
  }

  void _load() {
    _detach();
    final generation = ++_generation;
    if (widget.imageUrl.isEmpty) {
      final previous = _texture;
      setState(() => _texture = null);
      previous?.dispose();
      return;
    }
    final providers = <ImageProvider>[
      getImageProviderSync(widget.imageUrl, fallbackUrl: widget.fallbackUrl),
      if (widget.fallbackUrl != null && widget.fallbackUrl != widget.imageUrl)
        getImageProviderSync(widget.fallbackUrl),
      const AssetImage('assets/icons/bloomee_new_logo_c.png'),
    ];
    _resolve(providers, 0, generation);
  }

  void _resolve(List<ImageProvider> providers, int index, int generation) {
    if (!mounted || generation != _generation) return;
    _detach();
    _stream = ResizeImage.resizeIfNeeded(
      _textureSize,
      _textureSize,
      providers[index],
    ).resolve(const ImageConfiguration());
    _listener = ImageStreamListener(
      (info, synchronousCall) {
        _detach();
        _makeTexture(info, generation);
      },
      onError: (Object error, StackTrace? stack) {
        _detach();
        if (index + 1 < providers.length) {
          _resolve(providers, index + 1, generation);
        }
      },
    );
    _stream!.addListener(_listener!);
  }

  Future<void> _makeTexture(ImageInfo info, int generation) async {
    ui.Picture? picture;
    ui.Image? result;
    try {
      if (!mounted || generation != _generation) return;
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final source = Rect.fromLTWH(
          0, 0, info.image.width.toDouble(), info.image.height.toDouble());
      // Overscan keeps filter edges outside the final texture.
      const target =
          Rect.fromLTWH(-24, -24, _textureSize + 48.0, _textureSize + 48.0);
      canvas.drawImageRect(
          info.image,
          source,
          target,
          Paint()
            ..imageFilter = ui.ImageFilter.blur(
              sigmaX: 10,
              sigmaY: 10,
              tileMode: ui.TileMode.clamp,
            ));
      picture = recorder.endRecording();
      result = await picture.toImage(_textureSize, _textureSize);
      if (!mounted || generation != _generation) return;
      final previous = _texture;
      setState(() => _texture = result);
      result = null; // Ownership transfers to this State.
      previous?.dispose();
    } catch (_) {
      // Keep the last good ambient image (or the dark base on first load).
    } finally {
      result?.dispose();
      picture?.dispose();
      info.dispose();
    }
  }

  @override
  void dispose() {
    _generation++;
    _detach();
    _texture?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final texture = _texture;
    return AnimatedSwitcher(
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 450),
      child: texture == null
          ? const SizedBox.expand()
          : _TextureImage(key: ObjectKey(texture), image: texture),
    );
  }
}

/// Each crossfade child owns a handle, so replacing a texture cannot dispose
/// the outgoing image while it is still being painted by AnimatedSwitcher.
class _TextureImage extends StatefulWidget {
  final ui.Image image;
  const _TextureImage({super.key, required this.image});

  @override
  State<_TextureImage> createState() => _TextureImageState();
}

class _TextureImageState extends State<_TextureImage> {
  late final ui.Image _image = widget.image.clone();

  @override
  Widget build(BuildContext context) => SizedBox.expand(
        child: RawImage(image: _image, fit: BoxFit.cover),
      );

  @override
  void dispose() {
    _image.dispose();
    super.dispose();
  }
}
