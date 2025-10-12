// lib/utils/color_palette.dart
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Public API:
/// await analyzeImageColors(url) -> returns a map { 'overlay': Color, 'text': Color, 'palette': List<Color> }
Future<Map<String, dynamic>> analyzeImageColors(
  String imageUrl, {
  int numColors = 12,
  int sampleSize = 150, // resize to sampleSize x sampleSize
  int kMeansIters = 12,
}) async {
  final bytes = await _downloadImageBytes(imageUrl);
  final ui.Image image = await _decodeImage(bytes);
  final Uint8List pixels =
      await _getResizedRGBABytes(image, sampleSize, sampleSize);
  final List<List<int>> pixelList = _rgbaToRgbList(pixels);

  // Run KMeans on pixelList
  final paletteWithProportions =
      _kMeansPalette(pixelList, numColors, maxIters: kMeansIters, seed: 42);
  final palette =
      paletteWithProportions.map((e) => e['color'] as List<int>).toList();

  final overlayRgb = _findBestOverlayColor(paletteWithProportions);
  final textRgb = _findReactiveTextColor(overlayRgb, palette);

  return {
    'overlay': Color.fromARGB(
        220, overlayRgb[0], overlayRgb[1], overlayRgb[2]), // semi-opaque
    'text': Color.fromARGB(255, textRgb[0], textRgb[1], textRgb[2]),
    'palette':
        palette.map((c) => Color.fromARGB(255, c[0], c[1], c[2])).toList(),
  };
}

/// -------------------- Helper: download + decode --------------------
Future<Uint8List> _downloadImageBytes(String url) async {
  final uri = Uri.parse(url);
  final client = HttpClient();
  final request = await client.getUrl(uri);
  final response = await request.close();
  if (response.statusCode != 200) {
    throw HttpException('Failed to download image: ${response.statusCode}');
  }
  // consolidateHttpClientResponseBytes is provided by flutter/foundation.dart
  final bytes = await consolidateHttpClientResponseBytes(response);
  client.close();
  return bytes;
}

Future<ui.Image> _decodeImage(Uint8List data) async {
  final codec = await ui.instantiateImageCodec(data);
  final frame = await codec.getNextFrame();
  return frame.image;
}

/// Resize to targetWidth x targetHeight and return RGBA8888 bytes
Future<Uint8List> _getResizedRGBABytes(
    ui.Image src, int targetW, int targetH) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final paint = Paint();
  final srcRect =
      Rect.fromLTWH(0, 0, src.width.toDouble(), src.height.toDouble());
  final dstRect = Rect.fromLTWH(0, 0, targetW.toDouble(), targetH.toDouble());
  canvas.drawImageRect(src, srcRect, dstRect, paint);
  final picture = recorder.endRecording();
  final img = await picture.toImage(targetW, targetH);
  final byteData = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
  if (byteData == null) throw Exception('Failed to get image bytes');
  return byteData.buffer.asUint8List();
}

/// Convert raw RGBA bytes to List<[r,g,b]> (drop alpha)
List<List<int>> _rgbaToRgbList(Uint8List rgba) {
  final out = <List<int>>[];
  for (int i = 0; i + 3 < rgba.length; i += 4) {
    final r = rgba[i];
    final g = rgba[i + 1];
    final b = rgba[i + 2];
    out.add([r, g, b]);
  }
  return out;
}

/// -------------------- Simple KMeans --------------------
/// Signature now accepts named parameters for clarity (maxIters, seed)
List<Map<String, dynamic>> _kMeansPalette(
  List<List<int>> pixels,
  int k, {
  int maxIters = 10,
  int seed = 0,
}) {
  final rnd = Random(seed);
  if (pixels.isEmpty) return <Map<String, dynamic>>[];

  // If there are fewer unique colors than k, reduce k
  final unique = <int>{};
  for (var p in pixels) {
    unique.add((p[0] << 16) | (p[1] << 8) | p[2]);
  }
  final effectiveK = min(k, unique.length);

  // initialize centers by random pixels
  final centers = <List<double>>[];
  final usedIdx = <int>{};
  while (centers.length < effectiveK) {
    final idx = rnd.nextInt(pixels.length);
    if (usedIdx.contains(idx)) continue;
    usedIdx.add(idx);
    final px = pixels[idx];
    centers.add([px[0].toDouble(), px[1].toDouble(), px[2].toDouble()]);
  }

  var labels = List<int>.filled(pixels.length, -1);

  for (int iter = 0; iter < maxIters; iter++) {
    bool changed = false;
    // assign
    for (int i = 0; i < pixels.length; i++) {
      final p = pixels[i];
      double bestDist = double.infinity;
      int best = 0;
      for (int c = 0; c < centers.length; c++) {
        final dx = centers[c][0] - p[0];
        final dy = centers[c][1] - p[1];
        final dz = centers[c][2] - p[2];
        final d = dx * dx + dy * dy + dz * dz;
        if (d < bestDist) {
          bestDist = d;
          best = c;
        }
      }
      if (labels[i] != best) {
        labels[i] = best;
        changed = true;
      }
    }

    // update
    final sums = List.generate(centers.length, (_) => <double>[0.0, 0.0, 0.0]);
    final counts = List<int>.filled(centers.length, 0);
    for (int i = 0; i < pixels.length; i++) {
      final l = labels[i];
      sums[l][0] += pixels[i][0];
      sums[l][1] += pixels[i][1];
      sums[l][2] += pixels[i][2];
      counts[l] += 1;
    }
    for (int c = 0; c < centers.length; c++) {
      if (counts[c] == 0) {
        // re-seed empty cluster
        final idx = rnd.nextInt(pixels.length);
        centers[c] = [
          pixels[idx][0].toDouble(),
          pixels[idx][1].toDouble(),
          pixels[idx][2].toDouble()
        ];
      } else {
        centers[c][0] = sums[c][0] / counts[c];
        centers[c][1] = sums[c][1] / counts[c];
        centers[c][2] = sums[c][2] / counts[c];
      }
    }

    if (!changed) break;
  }

  // compute proportions and return palette sorted by proportion
  final countsFinal = <int, int>{};
  for (final l in labels) {
    countsFinal[l] = (countsFinal[l] ?? 0) + 1;
  }
  final total = pixels.length;
  final list = <Map<String, dynamic>>[];
  for (int c = 0; c < centers.length; c++) {
    final center = centers[c];
    final color = [center[0].round(), center[1].round(), center[2].round()];
    final proportion = (countsFinal[c] ?? 0) / total;
    list.add({'color': color, 'proportion': proportion});
  }
  list.sort((a, b) =>
      (b['proportion'] as double).compareTo(a['proportion'] as double));
  return list;
}

/// -------------------- Color theory helpers --------------------
List<double> _rgbToHsv(List<int> rgb) {
  final r = rgb[0] / 255.0;
  final g = rgb[1] / 255.0;
  final b = rgb[2] / 255.0;
  final maxC = max(r, max(g, b));
  final minC = min(r, min(g, b));
  final delta = maxC - minC;
  double h = 0.0;
  if (delta != 0) {
    if (maxC == r) {
      h = 60 * (((g - b) / delta) % 6);
    } else if (maxC == g) {
      h = 60 * (((b - r) / delta) + 2);
    } else {
      h = 60 * (((r - g) / delta) + 4);
    }
  }
  final s = maxC == 0 ? 0.0 : (delta / maxC);
  final v = maxC;
  return [h, s, v];
}

double _relativeLuminance(List<int> rgb) {
  double conv(double c) {
    final v = c / 255.0;
    return v <= 0.03928 ? v / 12.92 : pow((v + 0.055) / 1.055, 2.4).toDouble();
  }

  final r = conv(rgb[0].toDouble());
  final g = conv(rgb[1].toDouble());
  final b = conv(rgb[2].toDouble());
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

double _contrastRatio(List<int> rgb1, List<int> rgb2) {
  final l1 = _relativeLuminance(rgb1);
  final l2 = _relativeLuminance(rgb2);
  final top = max(l1, l2) + 0.05;
  final bottom = min(l1, l2) + 0.05;
  return top / bottom;
}

/// -------------------- Overlay & Text Selection Algorithms --------------------
List<int> _findBestOverlayColor(
    List<Map<String, dynamic>> paletteWithProportions) {
  List<int>? bestColor;
  double maxScore = -1.0;

  for (final item in paletteWithProportions) {
    final color = List<int>.from(item['color'] as List<int>);
    final proportion = item['proportion'] as double;
    final hsv = _rgbToHsv(color);
    final s = hsv[1];
    final v = hsv[2];

    if (v < 0.35 || s < 0.15) continue;

    final brightnessWeight = pow(v, 1.5).toDouble();
    final saturationWeight = pow(s, 1.2).toDouble();
    final score = proportion * brightnessWeight * saturationWeight * 10.0;

    if (score > maxScore) {
      maxScore = score;
      bestColor = color;
    }
  }

  // Fallback: pick the brightest*saturated
  if (bestColor == null) {
    final fallback = paletteWithProportions.reduce((a, b) {
      final av = _rgbToHsv(List<int>.from(a['color']));
      final bv = _rgbToHsv(List<int>.from(b['color']));
      final ascore = av[2] * av[1];
      final bscore = bv[2] * bv[1];
      return ascore >= bscore ? a : b;
    });
    bestColor = List<int>.from(fallback['color']);
  }
  return bestColor;
}

List<int> _findReactiveTextColor(
    List<int> backgroundRgb, List<List<int>> palette) {
  const double minContrast = 4.0;

  // 1. Pure white
  if (_contrastRatio(backgroundRgb, [255, 255, 255]) >= minContrast) {
    return [255, 255, 255];
  }

  // 2. Try bright palette colors
  final lightCandidates = <Map<String, dynamic>>[];
  for (final color in palette) {
    final hsv = _rgbToHsv(color);
    final v = hsv[2];
    final s = hsv[1];
    if (v < 0.6) continue;
    final contrast = _contrastRatio(backgroundRgb, color);
    if (contrast >= minContrast) {
      final brightnessBonus = pow(v, 2).toDouble() * 3.0;
      final saturationBonus = min(s, 0.5);
      final score = contrast * 2.0 + brightnessBonus + saturationBonus;
      lightCandidates
          .add({'color': color, 'contrast': contrast, 'score': score});
    }
  }
  if (lightCandidates.isNotEmpty) {
    lightCandidates
        .sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));
    return List<int>.from(lightCandidates.first['color'] as List<int>);
  }

  // 3. Try tinted (blend with white)
  final tinted = <Map<String, dynamic>>[];
  for (final color in palette) {
    final tint = [
      (color[0] * 0.3 + 255 * 0.7).round(),
      (color[1] * 0.3 + 255 * 0.7).round(),
      (color[2] * 0.3 + 255 * 0.7).round()
    ];
    final contrast = _contrastRatio(backgroundRgb, tint);
    if (contrast >= minContrast) {
      final hsv = _rgbToHsv(tint);
      final v = hsv[2];
      final score = contrast * 2.0 + v * 2.0;
      tinted.add({'color': tint, 'score': score, 'contrast': contrast});
    }
  }
  if (tinted.isNotEmpty) {
    tinted
        .sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));
    return List<int>.from(tinted.first['color'] as List<int>);
  }

  // 4. Any readable color from palette
  final anyReadable = <Map<String, dynamic>>[];
  for (final color in palette) {
    final contrast = _contrastRatio(backgroundRgb, color);
    if (contrast >= minContrast) {
      final hsv = _rgbToHsv(color);
      final v = hsv[2];
      final score = v < 0.4 ? contrast * 0.3 : contrast * 2.0 + v * 1.5;
      anyReadable.add({'color': color, 'score': score, 'v': v});
    }
  }
  if (anyReadable.isNotEmpty) {
    anyReadable.sort((a, b) {
      final preferredA = (a['v'] as double) > 0.5 ? 1 : 0;
      final preferredB = (b['v'] as double) > 0.5 ? 1 : 0;
      final cmp = preferredB.compareTo(preferredA);
      if (cmp != 0) return cmp;
      return (b['score'] as double).compareTo(a['score'] as double);
    });
    return List<int>.from(anyReadable.first['color'] as List<int>);
  }

  // Fallback: off-white
  return [245, 245, 245];
}
