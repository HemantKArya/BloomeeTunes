import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:Bloomee/services/feed/feed_item.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// Downloads `feed.json` from the project site and keeps the last good copy
/// on disk.
///
/// - The cached copy is shown instantly and when offline.
/// - The network is asked at most every [ttl] (unless forced), and only
///   "has it changed?" (ETag / Last-Modified), so usually nothing downloads.
/// - Concurrent refreshes share one request.
/// - A response that is not a feed never replaces the cached copy.
class FeedService {
  static const defaultUrl =
      'https://hemantkarya.github.io/BloomeeTunes/feed.json';

  /// `--dart-define=BLOOMEE_FEED=<url or file path>` previews another feed,
  /// e.g. `ghpage/feed.json` while editing it. Drafts are shown then.
  static const _override = String.fromEnvironment('BLOOMEE_FEED');

  static const ttl = Duration(hours: 6);
  static const timeout = Duration(seconds: 8);
  static const _cacheName = 'feed_cache.json';

  final String source;
  final http.Client _client;
  final Future<Directory> Function() _cacheDir;
  final DateTime Function() _now;

  FeedService({
    String? source,
    http.Client? client,
    Future<Directory> Function()? cacheDir,
    DateTime Function()? now,
  })  : source = source ?? (_override.isEmpty ? defaultUrl : _override),
        _client = client ?? http.Client(),
        _cacheDir = cacheDir ?? getApplicationSupportDirectory,
        _now = now ?? DateTime.now;

  /// Reading a feed other than the published one, to preview it.
  bool get isPreviewSource => source != defaultUrl;

  bool get _isFile => !source.startsWith('http');

  _CacheEntry? _memory;
  Future<List<FeedItem>?>? _inflight;

  /// The last good feed, or an empty list. A previewed file is read as is.
  Future<List<FeedItem>> cached() async {
    if (_isFile) return await _refresh(true) ?? const [];
    final entry = await _readCache();
    if (entry == null) return const [];
    try {
      return FeedItem.parseFeed(jsonDecode(entry.body));
    } catch (_) {
      return const [];
    }
  }

  /// The current feed from the network, or null when it was not asked
  /// (still fresh) or could not be reached. Callers keep what they have.
  Future<List<FeedItem>?> refresh({bool force = false}) =>
      _inflight ??= _refresh(force).whenComplete(() => _inflight = null);

  Future<List<FeedItem>?> _refresh(bool force) async {
    try {
      if (_isFile) {
        return FeedItem.parseFeed(jsonDecode(await File(source).readAsString()));
      }
      final cache = await _readCache();
      final now = _now();
      if (!force &&
          cache != null &&
          now.difference(cache.fetchedAt).abs() < ttl) {
        return null;
      }

      final response = await _client.get(Uri.parse(source), headers: {
        if (cache?.etag case final etag?) 'If-None-Match': etag,
        if (cache?.lastModified case final modified?)
          'If-Modified-Since': modified,
      }).timeout(timeout);

      if (response.statusCode == 304 && cache != null) {
        await _writeCache(cache.copyWith(fetchedAt: now));
        return FeedItem.parseFeed(jsonDecode(cache.body));
      }
      if (response.statusCode != 200) {
        throw HttpException('Feed returned ${response.statusCode}');
      }
      final body = utf8.decode(response.bodyBytes);
      final items = FeedItem.parseFeed(jsonDecode(body));
      await _writeCache(_CacheEntry(
        body: body,
        fetchedAt: now,
        etag: response.headers['etag'],
        lastModified: response.headers['last-modified'],
      ));
      return items;
    } catch (e) {
      log('Feed refresh failed: $e', name: 'FeedService');
      return null;
    }
  }

  Future<File> _file() async => File('${(await _cacheDir()).path}/$_cacheName');

  Future<_CacheEntry?> _readCache() async {
    if (_memory != null || _isFile) return _memory;
    try {
      final file = await _file();
      if (!await file.exists()) return null;
      return _memory = _CacheEntry.fromJson(
          jsonDecode(await file.readAsString()) as Map<String, dynamic>);
    } catch (e) {
      log('Feed cache unreadable: $e', name: 'FeedService');
      return null;
    }
  }

  Future<void> _writeCache(_CacheEntry entry) async {
    _memory = entry;
    try {
      final file = await _file();
      await file.parent.create(recursive: true);
      // Write then rename, so a crash never leaves half a file.
      final temp = File('${file.path}.tmp');
      await temp.writeAsString(jsonEncode(entry.toJson()), flush: true);
      await temp.rename(file.path);
    } catch (e) {
      log('Feed cache not saved: $e', name: 'FeedService');
    }
  }
}

class _CacheEntry {
  final String body;
  final DateTime fetchedAt;
  final String? etag;
  final String? lastModified;

  const _CacheEntry({
    required this.body,
    required this.fetchedAt,
    this.etag,
    this.lastModified,
  });

  factory _CacheEntry.fromJson(Map<String, dynamic> json) => _CacheEntry(
        body: json['body'] as String,
        fetchedAt: DateTime.parse(json['fetchedAt'] as String),
        etag: json['etag'] as String?,
        lastModified: json['lastModified'] as String?,
      );

  Map<String, Object?> toJson() => {
        'body': body,
        'fetchedAt': fetchedAt.toUtc().toIso8601String(),
        'etag': etag,
        'lastModified': lastModified,
      };

  _CacheEntry copyWith({required DateTime fetchedAt}) => _CacheEntry(
        body: body,
        fetchedAt: fetchedAt,
        etag: etag,
        lastModified: lastModified,
      );
}
