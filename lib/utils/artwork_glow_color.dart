import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:Bloomee/utils/load_image.dart';
import 'package:flutter/material.dart';

/// A bright "light" colour taken from a cover, for rim/corner glows.
///
/// The cover is decoded at 24x24 (576 pixels), so this is far cheaper than a
/// full palette pass and safe to run on the UI isolate. Results are cached
/// per URL and concurrent requests for the same URL share one decode.
class ArtworkGlowColor {
  ArtworkGlowColor._();

  static const _sampleSize = 24;
  static const _maxCache = 64;
  static final _cache = <String, Color>{};
  static final _pending = <String, Future<Color?>>{};

  static Color? cached(String url) => _cache[url];

  static Future<Color?> resolve(String url) {
    if (url.isEmpty) return Future.value(null);
    final hit = _cache[url];
    if (hit != null) return Future.value(hit);
    return _pending[url] ??= _decode(url).whenComplete(() {
      _pending.remove(url);
    });
  }

  static Future<Color?> _decode(String url) async {
    final completer = Completer<ImageInfo?>();
    final stream = ResizeImage.resizeIfNeeded(
      _sampleSize,
      _sampleSize,
      getImageProviderSync(url),
    ).resolve(ImageConfiguration.empty);
    late final ImageStreamListener listener;
    listener = ImageStreamListener(
      (info, _) {
        stream.removeListener(listener);
        if (!completer.isCompleted) completer.complete(info);
      },
      onError: (_, __) {
        stream.removeListener(listener);
        if (!completer.isCompleted) completer.complete(null);
      },
    );
    stream.addListener(listener);

    final info = await completer.future;
    if (info == null) return null;
    try {
      final data =
          await info.image.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (data == null) return null;
      final color = _pick(data);
      _cache[url] = color;
      if (_cache.length > _maxCache) _cache.remove(_cache.keys.first);
      return color;
    } catch (_) {
      return null;
    } finally {
      info.dispose();
    }
  }

  /// Weighted towards vivid, reasonably lit pixels, then lifted to a bright
  /// tone so it reads as light hitting a glass edge rather than a fill.
  static Color _pick(ByteData data) {
    double r = 0, g = 0, b = 0, weight = 0;
    double ar = 0, ag = 0, ab = 0;
    var count = 0;
    for (var i = 0; i + 3 < data.lengthInBytes; i += 4) {
      final pr = data.getUint8(i) / 255.0;
      final pg = data.getUint8(i + 1) / 255.0;
      final pb = data.getUint8(i + 2) / 255.0;
      if (data.getUint8(i + 3) < 128) continue;
      ar += pr;
      ag += pg;
      ab += pb;
      count++;

      final max = math.max(pr, math.max(pg, pb));
      final min = math.min(pr, math.min(pg, pb));
      final sat = max == 0 ? 0.0 : (max - min) / max;
      if (max < 0.15 || sat < 0.12) continue;
      final w = sat * sat * max;
      r += pr * w;
      g += pg * w;
      b += pb * w;
      weight += w;
    }

    final Color base;
    if (weight > 0.5) {
      base = Color.from(
          alpha: 1, red: r / weight, green: g / weight, blue: b / weight);
    } else if (count > 0) {
      base = Color.from(
          alpha: 1, red: ar / count, green: ag / count, blue: ab / count);
    } else {
      return Colors.white;
    }

    final hsv = HSVColor.fromColor(base);
    // Greyscale sleeves keep a neutral, slightly cool light.
    if (hsv.saturation < 0.12) {
      return const Color(0xFFDDE4F0);
    }
    return hsv
        .withSaturation(hsv.saturation.clamp(0.45, 0.85))
        .withValue(0.95)
        .toColor();
  }
}
