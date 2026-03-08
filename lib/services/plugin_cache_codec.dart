// ignore_for_file: public_member_api_docs
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart'; // compute()
import 'package:Bloomee/src/rust/api/plugin/models.dart';

// ═════════════════════════════════════════════════════════════════════════════
// Internal encode / decode helpers (private, sync, zero-allocation-friendly)
// ═════════════════════════════════════════════════════════════════════════════

// ── Artwork ──────────────────────────────────────────────────────────────────

Map<String, dynamic> _artworkToJson(Artwork a) => {
      'url': a.url,
      'url_low': a.urlLow,
      'url_high': a.urlHigh,
      'layout': a.layout.name,
    };

Artwork _artworkFromJson(Map<String, dynamic> m) => Artwork(
      url: m['url'] as String,
      urlLow: m['url_low'] as String?,
      urlHigh: m['url_high'] as String?,
      layout: ImageLayout.values.byName(m['layout'] as String),
    );

Artwork? _optArtworkFromJson(Object? raw) =>
    raw == null ? null : _artworkFromJson(raw as Map<String, dynamic>);

// ── ArtistSummary ─────────────────────────────────────────────────────────────

Map<String, dynamic> _artistSummaryToJson(ArtistSummary a) => {
      'id': a.id,
      'name': a.name,
      'thumbnail': a.thumbnail == null ? null : _artworkToJson(a.thumbnail!),
      'subtitle': a.subtitle,
      'url': a.url,
    };

ArtistSummary _artistSummaryFromJson(Map<String, dynamic> m) => ArtistSummary(
      id: m['id'] as String,
      name: m['name'] as String,
      thumbnail: _optArtworkFromJson(m['thumbnail']),
      subtitle: m['subtitle'] as String?,
      url: m['url'] as String?,
    );

// ── AlbumSummary ──────────────────────────────────────────────────────────────

Map<String, dynamic> _albumSummaryToJson(AlbumSummary a) => {
      'id': a.id,
      'title': a.title,
      'artists': a.artists.map(_artistSummaryToJson).toList(),
      'thumbnail': a.thumbnail == null ? null : _artworkToJson(a.thumbnail!),
      'subtitle': a.subtitle,
      'year': a.year,
      'url': a.url,
    };

AlbumSummary _albumSummaryFromJson(Map<String, dynamic> m) => AlbumSummary(
      id: m['id'] as String,
      title: m['title'] as String,
      artists: (m['artists'] as List<dynamic>)
          .map((e) => _artistSummaryFromJson(e as Map<String, dynamic>))
          .toList(),
      thumbnail: _optArtworkFromJson(m['thumbnail']),
      subtitle: m['subtitle'] as String?,
      year: m['year'] as int?,
      url: m['url'] as String?,
    );

// ── PlaylistSummary ───────────────────────────────────────────────────────────

Map<String, dynamic> _playlistSummaryToJson(PlaylistSummary p) => {
      'id': p.id,
      'title': p.title,
      'owner': p.owner,
      'thumbnail': _artworkToJson(p.thumbnail),
      'url': p.url,
    };

PlaylistSummary _playlistSummaryFromJson(Map<String, dynamic> m) =>
    PlaylistSummary(
      id: m['id'] as String,
      title: m['title'] as String,
      owner: m['owner'] as String?,
      thumbnail: _artworkFromJson(m['thumbnail'] as Map<String, dynamic>),
      url: m['url'] as String?,
    );

// ── Lyrics ────────────────────────────────────────────────────────────────────

Map<String, dynamic> _lyricsToJson(Lyrics l) => {
      'plain': l.plain,
      'synced': l.synced,
      'copyright': l.copyright,
    };

Lyrics _lyricsFromJson(Map<String, dynamic> m) => Lyrics(
      plain: m['plain'] as String?,
      synced: m['synced'] as String?,
      copyright: m['copyright'] as String?,
    );

// ── Track ─────────────────────────────────────────────────────────────────────

Map<String, dynamic> _trackToJson(Track t) => {
      'id': t.id,
      'title': t.title,
      'artists': t.artists.map(_artistSummaryToJson).toList(),
      'album': t.album == null ? null : _albumSummaryToJson(t.album!),
      // BigInt serialised as decimal string to avoid JSON precision loss.
      'duration_ms': t.durationMs?.toString(),
      'thumbnail': _artworkToJson(t.thumbnail),
      'url': t.url,
      'is_explicit': t.isExplicit,
      'lyrics': t.lyrics == null ? null : _lyricsToJson(t.lyrics!),
    };

Track _trackFromJson(Map<String, dynamic> m) => Track(
      id: m['id'] as String,
      title: m['title'] as String,
      artists: (m['artists'] as List<dynamic>)
          .map((e) => _artistSummaryFromJson(e as Map<String, dynamic>))
          .toList(),
      album: m['album'] == null
          ? null
          : _albumSummaryFromJson(m['album'] as Map<String, dynamic>),
      durationMs: m['duration_ms'] == null
          ? null
          : BigInt.parse(m['duration_ms'] as String),
      thumbnail: _artworkFromJson(m['thumbnail'] as Map<String, dynamic>),
      url: m['url'] as String?,
      isExplicit: m['is_explicit'] as bool,
      lyrics: m['lyrics'] == null
          ? null
          : _lyricsFromJson(m['lyrics'] as Map<String, dynamic>),
    );

// ── MediaItem (sealed variant) ────────────────────────────────────────────────

Map<String, dynamic> _mediaItemToJson(MediaItem item) => switch (item) {
      MediaItem_Track(:final field0) => {
          'type': 'track',
          'data': _trackToJson(field0),
        },
      MediaItem_Album(:final field0) => {
          'type': 'album',
          'data': _albumSummaryToJson(field0),
        },
      MediaItem_Artist(:final field0) => {
          'type': 'artist',
          'data': _artistSummaryToJson(field0),
        },
      MediaItem_Playlist(:final field0) => {
          'type': 'playlist',
          'data': _playlistSummaryToJson(field0),
        },
    };

MediaItem _mediaItemFromJson(Map<String, dynamic> m) {
  final data = m['data'] as Map<String, dynamic>;
  return switch (m['type'] as String) {
    'track' => MediaItem.track(_trackFromJson(data)),
    'album' => MediaItem.album(_albumSummaryFromJson(data)),
    'artist' => MediaItem.artist(_artistSummaryFromJson(data)),
    'playlist' => MediaItem.playlist(_playlistSummaryFromJson(data)),
    final t => throw FormatException('Unknown MediaItem type: $t'),
  };
}

// ── ChartSummary ──────────────────────────────────────────────────────────────

/// Encode a [ChartSummary] to a JSON-compatible map.
Map<String, dynamic> chartSummaryToJson(ChartSummary s) => {
      'id': s.id,
      'title': s.title,
      'description': s.description,
      'thumbnail': s.thumbnail == null ? null : _artworkToJson(s.thumbnail!),
    };

/// Decode a [ChartSummary] from a JSON-compatible map.
ChartSummary chartSummaryFromJson(Map<String, dynamic> m) => ChartSummary(
      id: m['id'] as String,
      title: m['title'] as String,
      description: m['description'] as String?,
      thumbnail: _optArtworkFromJson(m['thumbnail']),
    );

// ── ChartItem ─────────────────────────────────────────────────────────────────

/// Encode a [ChartItem] to a JSON-compatible map.
Map<String, dynamic> chartItemToJson(ChartItem c) => {
      'item': _mediaItemToJson(c.item),
      'rank': c.rank,
      'trend': c.trend.name,
      'change': c.change,
      'peak_rank': c.peakRank,
      'weeks_on_chart': c.weeksOnChart,
    };

/// Decode a [ChartItem] from a JSON-compatible map.
ChartItem chartItemFromJson(Map<String, dynamic> m) => ChartItem(
      item: _mediaItemFromJson(m['item'] as Map<String, dynamic>),
      rank: m['rank'] as int,
      trend: Trend.values.byName(m['trend'] as String),
      change: m['change'] as int?,
      peakRank: m['peak_rank'] as int?,
      weeksOnChart: m['weeks_on_chart'] as int?,
    );

// ── Section ───────────────────────────────────────────────────────────────────

/// Encode a [Section] to a JSON-compatible map.
Map<String, dynamic> sectionToJson(Section s) => {
      'id': s.id,
      'title': s.title,
      'subtitle': s.subtitle,
      'card_type': s.cardType.name,
      'items': s.items.map(_mediaItemToJson).toList(),
      'more_link': s.moreLink,
    };

/// Decode a [Section] from a JSON-compatible map.
Section sectionFromJson(Map<String, dynamic> m) => Section(
      id: m['id'] as String,
      title: m['title'] as String,
      subtitle: m['subtitle'] as String?,
      cardType: CardType.values.byName(m['card_type'] as String),
      items: (m['items'] as List<dynamic>)
          .map((e) => _mediaItemFromJson(e as Map<String, dynamic>))
          .toList(),
      moreLink: m['more_link'] as String?,
    );

// ═════════════════════════════════════════════════════════════════════════════
// Public API — chart cache encoding / decoding
// ═════════════════════════════════════════════════════════════════════════════

/// Encode a chart summary + item list into a compact JSON blob for storage.
///
/// Runs synchronously on the calling thread — encoding is cheap and
/// does not need an isolate.
String encodeChartCache({
  required ChartSummary summary,
  required List<ChartItem> items,
}) {
  return jsonEncode({
    'summary': chartSummaryToJson(summary),
    'items': items.map(chartItemToJson).toList(),
  });
}

/// Decode a chart JSON blob back into typed components.
///
/// Parsing and object construction runs in a background isolate via
/// [compute], so the main thread stays free. Typically < 10 ms for a
/// 100-entry chart on mid-range hardware.
///
/// Throws [FormatException] if the blob is malformed.
Future<({ChartSummary summary, List<ChartItem> items})> decodeChartCacheAsync(
    String jsonBlob) {
  return compute(_parseChartCache, jsonBlob);
}

// Top-level — required by compute() for isolate spawning.
({ChartSummary summary, List<ChartItem> items}) _parseChartCache(
    String jsonBlob) {
  try {
    final m = jsonDecode(jsonBlob) as Map<String, dynamic>;
    return (
      summary: chartSummaryFromJson(m['summary'] as Map<String, dynamic>),
      items: (m['items'] as List<dynamic>)
          .map((e) => chartItemFromJson(e as Map<String, dynamic>))
          .toList(),
    );
  } catch (e, st) {
    log('Failed to decode chart cache: $e',
        stackTrace: st, name: 'PluginCacheCodec');
    rethrow;
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Public API — sections cache encoding / decoding
// ═════════════════════════════════════════════════════════════════════════════

/// Encode a list of home [Section]s into a compact JSON blob for storage.
///
/// Runs synchronously on the calling thread.
String encodeSectionsCache(List<Section> sections) {
  return jsonEncode(sections.map(sectionToJson).toList());
}

/// Decode a sections JSON blob back into a typed list.
///
/// Parsing and object construction runs in a background isolate via
/// [compute]. Typically < 10 ms for a typical home feed (10–20 sections,
/// 5–10 items each).
///
/// Throws [FormatException] if the blob is malformed.
Future<List<Section>> decodeSectionsCacheAsync(String jsonBlob) {
  return compute(_parseSectionsCache, jsonBlob);
}

// Top-level — required by compute() for isolate spawning.
List<Section> _parseSectionsCache(String jsonBlob) {
  try {
    final list = jsonDecode(jsonBlob) as List<dynamic>;
    return list.map((e) => sectionFromJson(e as Map<String, dynamic>)).toList();
  } catch (e, st) {
    log('Failed to decode sections cache: $e',
        stackTrace: st, name: 'PluginCacheCodec');
    rethrow;
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Public API — chart items-only cache (for chart detail view)
// ═════════════════════════════════════════════════════════════════════════════

/// Encode only the [ChartItem] list for a single chart — no summary needed.
///
/// Smaller blob (~40–120 KB) than the full [encodeChartCache] since the
/// chart summary is retained separately in the chart-list cache.
String encodeChartItemsCache(List<ChartItem> items) =>
    jsonEncode(items.map(chartItemToJson).toList());

/// Decode a chart-items blob back into a typed list.
///
/// Runs in a background isolate via [compute].
Future<List<ChartItem>> decodeChartItemsCacheAsync(String jsonBlob) =>
    compute(_parseChartItemsCache, jsonBlob);

List<ChartItem> _parseChartItemsCache(String jsonBlob) {
  try {
    return (jsonDecode(jsonBlob) as List<dynamic>)
        .map((e) => chartItemFromJson(e as Map<String, dynamic>))
        .toList();
  } catch (e, st) {
    log('Failed to decode chart items cache: $e',
        stackTrace: st, name: 'PluginCacheCodec');
    rethrow;
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Public API — chart list (summaries) cache
// ═════════════════════════════════════════════════════════════════════════════

/// Encode a list of [ChartSummary] objects for the chart-picker carousel.
String encodeChartListCache(List<ChartSummary> summaries) =>
    jsonEncode(summaries.map(chartSummaryToJson).toList());

/// Decode a chart-list blob back into a typed list.
///
/// Runs in a background isolate via [compute].
Future<List<ChartSummary>> decodeChartListCacheAsync(String jsonBlob) =>
    compute(_parseChartListCache, jsonBlob);

List<ChartSummary> _parseChartListCache(String jsonBlob) {
  try {
    return (jsonDecode(jsonBlob) as List<dynamic>)
        .map((e) => chartSummaryFromJson(e as Map<String, dynamic>))
        .toList();
  } catch (e, st) {
    log('Failed to decode chart list cache: $e',
        stackTrace: st, name: 'PluginCacheCodec');
    rethrow;
  }
}
