import 'dart:convert';

import 'package:Bloomee/core/utils/legacy_media_id_mapper.dart';
import 'backup_settings_policy.dart';

enum BackupImportMode { newCopy, merge, replace }

class BackupSelection {
  final bool library;
  final bool history;
  final bool settings;
  final BackupImportMode mode;

  const BackupSelection({
    this.library = true,
    this.history = true,
    this.settings = true,
    this.mode = BackupImportMode.merge,
  });
}

/// Versioned, storage-independent interchange document. No Isar row IDs or links.
class BackupDocument {
  static const format = 'bloomee';
  static const version = 1;
  static const maxBytes = 32 * 1024 * 1024;
  static const maxRecords = 100000;

  final Map<String, dynamic> data;
  final List<String> warnings;

  BackupDocument._(this.data, this.warnings);

  String get kind => data['kind'] as String;
  List<Map<String, dynamic>> rows(String section) =>
      (data[section] as List? ?? const []).cast<Map<String, dynamic>>();
  bool has(String section) => data.containsKey(section);
  bool get allowsReplacement => data['sourceFormat'] != 'legacy';
  int get trackCount => rows('tracks').length;
  int get playlistCount => rows('playlists').length;

  static BackupDocument decode(String text) {
    if (utf8.encode(text).length > maxBytes) {
      throw const FormatException('File exceeds the 32 MB import limit.');
    }
    return fromMap(
        jsonDecode(text.startsWith('\uFEFF') ? text.substring(1) : text));
  }

  static BackupDocument fromMap(dynamic input) {
    if (input is! Map<String, dynamic>) {
      throw const FormatException('Expected a JSON object.');
    }
    final warnings = <String>[];
    final map = input['format'] == format
        ? Map<String, dynamic>.from(input)
        : _legacy(input, warnings);
    if (map['format'] != format || map['schemaVersion'] != version) {
      throw const FormatException('Unsupported backup schema version.');
    }
    if (!['backup', 'playlist', 'track'].contains(map['kind'])) {
      throw const FormatException('Unsupported document kind.');
    }
    _checkTree(map, 0);
    final tracks = _rows(map, 'tracks');
    if (map['kind'] == 'track') {
      if (tracks.length != 1) {
        throw const FormatException(
            'A track document must contain exactly one track.');
      }
      if (!map.containsKey('playlists') || _rows(map, 'playlists').isEmpty) {
        map['playlists'] = <Map<String, dynamic>>[
          {
            'name': 'Imported',
            'type': 'userPlaylist',
            'entries': [_requiredString(tracks.single, 'mediaId')],
          }
        ];
      }
    }
    if (!map.containsKey('tracks') || !map.containsKey('playlists')) {
      throw const FormatException('Missing tracks or playlists section.');
    }
    final ids = <String>{};
    for (final t in tracks) {
      final id = _requiredString(t, 'mediaId');
      _requiredString(t, 'title');
      if (!ids.add(id)) throw FormatException('Duplicate track ID: $id');
      if (t['durationMs'] != null &&
          (t['durationMs'] is! int ||
              (t['durationMs'] as int) < 0 ||
              (t['durationMs'] as int) > 9007199254740991)) {
        throw const FormatException(
            'durationMs must be a non-negative integer.');
      }
    }
    final names = <String>{};
    if (map['kind'] == 'playlist' && _rows(map, 'playlists').length != 1) {
      throw const FormatException(
          'A playlist document must contain exactly one playlist.');
    }
    for (final p in _rows(map, 'playlists')) {
      final name = _requiredString(p, 'name');
      if (!names.add(name.toLowerCase())) {
        throw FormatException('Duplicate playlist name: $name');
      }
      if (p['type'] is! String ||
          !['userPlaylist', 'album', 'artist', 'remotePlaylist']
              .contains(p['type'])) {
        throw const FormatException('Invalid playlist type.');
      }
      if (name.toLowerCase() == 'liked' && p['type'] != 'userPlaylist') {
        throw const FormatException('Liked must be a user playlist.');
      }
      final entries = p['entries'];
      if (entries is! List || entries.length > maxRecords) {
        throw const FormatException('Invalid playlist entries.');
      }
      final seen = <String>{};
      for (final id in entries) {
        if (id is! String || !ids.contains(id) || !seen.add(id)) {
          throw const FormatException(
              'Missing or duplicate playlist track reference.');
        }
      }
    }
    for (final h in _rows(map, 'history')) {
      if (!ids.contains(h['mediaId']) ||
          DateTime.tryParse('${h['playedAt']}') == null) {
        throw const FormatException(
            'Invalid playback history reference or date.');
      }
    }
    for (final h in _rows(map, 'searchHistory')) {
      _requiredString(h, 'query');
      if (DateTime.tryParse('${h['lastSearched']}') == null) {
        throw const FormatException('Invalid search history date.');
      }
    }
    final settingKeys = <String>{};
    for (final s in _rows(map, 'settings')) {
      _requiredString(s, 'key');
      final key = s['key'] as String;
      if (!settingKeys.add(key)) {
        throw FormatException('Duplicate preference: $key');
      }
      if (s['value'] is! String && s['value'] is! bool) {
        throw const FormatException('Settings must be strings or booleans.');
      }
      if (BackupSettingsPolicy.supports(key) &&
          !BackupSettingsPolicy.valid(key, s['value'])) {
        throw FormatException('Invalid preference value: $key');
      }
    }
    // Freeze recursively so a preview and commit always use identical bytes.
    return BackupDocument._(
        _freeze(map) as Map<String, dynamic>, List.unmodifiable(warnings));
  }

  static List<Map<String, dynamic>> _rows(
      Map<String, dynamic> map, String key) {
    if (!map.containsKey(key)) return const [];
    final value = map[key];
    if (value is! List ||
        value.length > maxRecords ||
        value.any((e) => e is! Map<String, dynamic>)) {
      throw FormatException('Invalid $key section.');
    }
    return value.cast<Map<String, dynamic>>();
  }

  static String _requiredString(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('Missing or empty $key.');
    }
    return value;
  }

  static void _checkTree(dynamic value, int depth) {
    if (depth > 16) throw const FormatException('JSON nesting is too deep.');
    if (value is String && value.length > 1024 * 1024) {
      throw const FormatException('JSON string is too large.');
    }
    if (value is List) {
      if (value.length > maxRecords) {
        throw const FormatException('Too many records.');
      }
      for (final item in value) {
        _checkTree(item, depth + 1);
      }
    } else if (value is Map) {
      if (value.length > 1000) {
        throw const FormatException('Too many object fields.');
      }
      for (final item in value.values) {
        _checkTree(item, depth + 1);
      }
    }
  }

  static dynamic _freeze(dynamic value) {
    if (value is Map<String, dynamic>) {
      return Map<String, dynamic>.unmodifiable(
          value.map((k, v) => MapEntry(k, _freeze(v))));
    }
    if (value is List) return List<dynamic>.unmodifiable(value.map(_freeze));
    return value;
  }

  static Map<String, dynamic> _legacy(
      Map<String, dynamic> input, List<String> warnings) {
    final tracks = <String, Map<String, dynamic>>{};
    final playlists = <String, Map<String, dynamic>>{};
    Map<String, dynamic> playlist(String name) => playlists.putIfAbsent(
        name,
        () => {
              'name': name,
              'type': 'userPlaylist',
              'entries': <String>[],
            });
    String track(Map<String, dynamic> raw) {
      final id = buildPluginScopedMediaIdFromLegacyMap(raw) ??
          raw['mediaId'] ??
          raw['mediaID'] ??
          raw['id'] ??
          raw['permaURL'];
      if (id is! String || id.trim().isEmpty) {
        throw const FormatException('Legacy track has no usable ID.');
      }
      final modern = raw['artists'] is List ||
          raw.containsKey('durationMs') ||
          raw['thumbnail'] is Map ||
          raw['album'] is Map;
      tracks.putIfAbsent(
          id,
          () => {
                'mediaId': id,
                'title': raw['title'],
                'artists': modern
                    ? raw['artists']
                    : [
                        for (final name
                            in (raw['artist'] as String? ?? '').split(','))
                          if (name.trim().isNotEmpty) {'name': name.trim()},
                      ],
                'album': modern
                    ? raw['album']
                    : (raw['album'] is String ? {'title': raw['album']} : null),
                'thumbnail':
                    modern ? raw['thumbnail'] : {'url': raw['artURL'] ?? ''},
                'durationMs': raw['durationMs'] ??
                    (raw['duration'] is num
                        ? ((raw['duration'] as num) * 1000).round()
                        : null),
                'isExplicit': raw['isExplicit'] ?? false,
                'genre': raw['genre'],
                'language': raw['language'],
              });
      return id;
    }

    List<Map<String, dynamic>> section(dynamic value) {
      if (value is! List) {
        throw const FormatException('Invalid legacy section.');
      }
      return value.map((e) {
        final decoded = e is String ? jsonDecode(e) : e;
        if (decoded is! Map<String, dynamic>) {
          throw const FormatException('Invalid legacy record.');
        }
        return decoded;
      }).toList();
    }

    String kind;
    if (input.containsKey('playlists') && input.containsKey('media_items')) {
      kind = 'backup';
      warnings.add(
          'Legacy backup: only playlists and their tracks can be recovered. Original per-playlist order may be unavailable.');
      for (final p in section(input['playlists'])) {
        playlist(_requiredString(p, 'playlistName'));
      }
      for (final t in section(input['media_items'])) {
        final id = track(t);
        for (final p in section(t['mediaInPlaylists'] ?? [])) {
          final entries =
              playlist(_requiredString(p, 'playlistName'))['entries'] as List;
          if (!entries.contains(id)) entries.add(id);
        }
      }
    } else if (input.containsKey('playlistName')) {
      kind = 'playlist';
      final entries =
          playlist(_requiredString(input, 'playlistName'))['entries'] as List;
      for (final t in section(input['tracks'] ?? input['mediaItems'])) {
        final id = track(t);
        if (!entries.contains(id)) entries.add(id);
      }
    } else if (input.containsKey('title')) {
      kind = 'track';
      playlist('Imported')['entries'] = [track(input)];
    } else {
      throw const FormatException(
          'This JSON is not a Bloomee backup, playlist, or track.');
    }
    // Device-managed collections are never recreated using foreign device paths.
    playlists.removeWhere((name, _) =>
        ['_DOWNLOADS', '_LOCAL_MUSIC', 'recently_played'].contains(name));
    return {
      'format': format,
      'schemaVersion': version,
      'kind': kind,
      'sourceFormat': 'legacy',
      'tracks': tracks.values.toList(),
      'playlists': playlists.values.toList()
    };
  }
}
