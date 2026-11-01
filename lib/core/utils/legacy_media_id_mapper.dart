library legacy_media_id_mapper;

const pluginJisSaavnId = 'content-resolver.bloomfactory.jisaavn';
const pluginYtMusicId = 'content-resolver.bloomfactory.ytmusic';
const pluginYtVideoId = 'content-resolver.bloomfactory.ytvideo';

bool isPluginScopedMediaId(String value) =>
    value.trim().startsWith('content-resolver.');

String stripYoutubePrefix(String id) {
  final value = id.trim();
  if (value.toLowerCase().startsWith('youtube')) {
    return value.substring(7);
  }
  return value;
}

String? coercePluginScopedMediaId(String rawId) {
  final cleanedId = stripYoutubePrefix(rawId);
  if (cleanedId.isEmpty) return null;
  return isPluginScopedMediaId(cleanedId) ? cleanedId : null;
}

String? buildPluginScopedMediaId({
  required String rawId,
  required String source,
  String permaUrl = '',
}) {
  final cleanedId = stripYoutubePrefix(rawId);
  if (cleanedId.isEmpty) return null;
  if (isPluginScopedMediaId(cleanedId)) return cleanedId;

  final normalizedSource = source.trim().toLowerCase();
  if (normalizedSource == 'saavn') {
    return '$pluginJisSaavnId::$cleanedId';
  }

  if (normalizedSource.contains('youtube') ||
      normalizedSource == 'ytm' ||
      normalizedSource == 'ytv') {
    return permaUrl.contains('music.youtube.com')
        ? '$pluginYtMusicId::$cleanedId'
        : '$pluginYtVideoId::$cleanedId';
  }

  return null;
}

String? buildPluginScopedMediaIdFromLegacyMap(Map<String, dynamic> raw) {
  final mediaId =
      (raw['mediaID'] ?? raw['mediaId'] ?? raw['id'] ?? '').toString().trim();
  final source = (raw['source'] ?? '').toString();
  final permaUrl = (raw['permaURL'] ?? raw['permaUrl'] ?? '').toString();

  if (mediaId.isNotEmpty) {
    final scoped = buildPluginScopedMediaId(
      rawId: mediaId,
      source: source,
      permaUrl: permaUrl,
    );
    if (scoped != null) return scoped;
  }

  if (permaUrl.isNotEmpty) {
    final scoped = coercePluginScopedMediaId(permaUrl);
    if (scoped != null) return scoped;
  }

  return null;
}
