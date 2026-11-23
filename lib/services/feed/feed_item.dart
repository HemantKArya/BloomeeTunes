import 'dart:ui' show Locale;

/// What an announcement is about. It picks the icon and the small label.
enum FeedKind {
  announcement,

  /// One of our other apps.
  app,

  /// A sign-up, pre-registration or survey link.
  form,

  /// Something users should know about (a broken source, a security fix).
  notice;

  static FeedKind parse(Object? value) =>
      values.where((k) => k.name == value).firstOrNull ?? announcement;
}

/// Text in several languages: `"Hello"` or `{"en": "Hello", "hi": "नमस्ते"}`.
class FeedText {
  final Map<String, String> byLanguage;
  const FeedText(this.byLanguage);

  static FeedText? parse(Object? value) {
    if (value is String) {
      return value.trim().isEmpty ? null : FeedText({'en': value.trim()});
    }
    if (value is! Map) return null;
    final map = <String, String>{
      for (final e in value.entries)
        if (e.value is String && (e.value as String).trim().isNotEmpty)
          e.key.toString().toLowerCase().replaceAll('_', '-'):
              (e.value as String).trim(),
    };
    return map.isEmpty ? null : FeedText(map);
  }

  /// Exact locale ("pt-br"), then its language ("pt"), then English, then
  /// whatever the author wrote first.
  String resolve(Locale locale) {
    final language = locale.languageCode.toLowerCase();
    final country = locale.countryCode?.toLowerCase();
    return (country == null ? null : byLanguage['$language-$country']) ??
        byLanguage[language] ??
        byLanguage['en'] ??
        byLanguage.values.first;
  }
}

/// Facts about this install that announcements can target.
class FeedAudience {
  /// `Platform.operatingSystem`: android, windows, linux, macos, ios.
  final String platform;

  /// Installed through a store (the Microsoft Store MSIX today).
  final bool storeBuild;

  /// e.g. "3.1.1".
  final String appVersion;

  const FeedAudience({
    required this.platform,
    required this.storeBuild,
    required this.appVersion,
  });
}

/// One entry of `feed.json`. See docs/announcements.md for the format.
class FeedItem {
  final String id;
  final FeedKind kind;
  final FeedText title;
  final FeedText? body;
  final String? image;

  /// A small logo shown beside the entry, in place of the kind icon.
  final String? icon;
  final FeedText? actionLabel;

  /// A link, or links per audience: platform names, "store" and "default".
  final Map<String, String> actionUrls;
  final DateTime? start;
  final DateTime? end;
  final Set<String>? platforms;

  /// true: store installs only; false: everyone else; null: both.
  final bool? store;
  final String? minVersion;
  final String? maxVersion;

  /// Also offered as a card on Home, not only in the inbox.
  final bool home;

  /// Shown first, highlighted, and on Home until dismissed.
  final bool urgent;

  /// Visible only in preview, so it can be checked before going live.
  final bool draft;

  const FeedItem({
    required this.id,
    required this.title,
    this.kind = FeedKind.announcement,
    this.body,
    this.image,
    this.icon,
    this.actionLabel,
    this.actionUrls = const {},
    this.start,
    this.end,
    this.platforms,
    this.store,
    this.minVersion,
    this.maxVersion,
    this.home = false,
    this.urgent = false,
    this.draft = false,
  });

  /// Null when the entry is unusable (no id or title). Bad optional fields
  /// are dropped rather than rejecting the whole entry.
  static FeedItem? tryParse(Object? json) {
    if (json is! Map) return null;
    final id = json['id'];
    final title = FeedText.parse(json['title']);
    if (id is! String || id.trim().isEmpty || title == null) return null;

    final action = json['action'];
    final urls = <String, String>{};
    FeedText? label;
    if (action is Map) {
      label = FeedText.parse(action['label']);
      final url = action['url'];
      if (url is String) {
        if (isSafeUrl(url)) urls['default'] = url;
      } else if (url is Map) {
        for (final e in url.entries) {
          if (e.value is String && isSafeUrl(e.value as String)) {
            urls[e.key.toString().toLowerCase()] = e.value as String;
          }
        }
      }
    }

    final image = json['image'];
    final icon = json['icon'];
    final platforms = json['platforms'];
    return FeedItem(
      id: id.trim(),
      kind: FeedKind.parse(json['kind']),
      title: title,
      body: FeedText.parse(json['body']),
      image: image is String && image.startsWith('https://') ? image : null,
      icon: icon is String && icon.startsWith('https://') ? icon : null,
      actionLabel: label,
      actionUrls: urls,
      start: _date(json['start']),
      end: _date(json['end'], endOfDay: true),
      platforms: platforms is List
          ? {for (final p in platforms) p.toString().toLowerCase()}
          : null,
      store: json['store'] is bool ? json['store'] as bool : null,
      minVersion: json['minVersion'] is String ? json['minVersion'] : null,
      maxVersion: json['maxVersion'] is String ? json['maxVersion'] : null,
      home: json['home'] == true,
      urgent: json['urgent'] == true,
      draft: json['draft'] == true,
    );
  }

  /// Parses a whole feed document; unusable entries and repeated ids are
  /// skipped. Throws [FormatException] only when the document itself is
  /// not a feed, so a broken publish never replaces a good cached copy.
  static List<FeedItem> parseFeed(Object? json) {
    if (json is! Map || json['items'] is! List) {
      throw const FormatException('Not a feed: expected {"items": [...]}');
    }
    final seen = <String>{};
    return [
      for (final raw in json['items'] as List)
        if (tryParse(raw) case final item? when seen.add(item.id)) item,
    ];
  }

  /// The link for this install: the store link on store builds, then the
  /// platform's own, then the default.
  String? actionUrlFor(FeedAudience audience) =>
      (audience.storeBuild ? actionUrls['store'] : null) ??
      actionUrls[audience.platform] ??
      actionUrls['default'];

  /// Whether this install should see the entry at [now].
  bool targets(FeedAudience audience, DateTime now, {bool preview = false}) {
    if (preview) return _audienceMatches(audience);
    if (draft) return false;
    if (start != null && now.isBefore(start!)) return false;
    if (end != null && !now.isBefore(end!)) return false;
    return _audienceMatches(audience);
  }

  bool _audienceMatches(FeedAudience audience) {
    if (platforms != null && !platforms!.contains(audience.platform)) {
      return false;
    }
    if (store != null && store != audience.storeBuild) return false;
    if (minVersion != null &&
        compareVersions(audience.appVersion, minVersion!) < 0) {
      return false;
    }
    if (maxVersion != null &&
        compareVersions(audience.appVersion, maxVersion!) > 0) {
      return false;
    }
    return true;
  }

  /// Date-only values cover the whole day ("end": "2027-01-15" includes
  /// the 15th). Dates without a time zone are read as UTC.
  static DateTime? _date(Object? value, {bool endOfDay = false}) {
    if (value is! String) return null;
    final parsed = DateTime.tryParse(value.trim());
    if (parsed == null) return null;
    final dateOnly = value.trim().length <= 10;
    final utc = parsed.isUtc
        ? parsed
        : DateTime.utc(parsed.year, parsed.month, parsed.day, parsed.hour,
            parsed.minute, parsed.second);
    return dateOnly && endOfDay ? utc.add(const Duration(days: 1)) : utc;
  }
}

/// Links must be https, or open a store app or mail client.
bool isSafeUrl(String url) {
  final uri = Uri.tryParse(url.trim());
  if (uri == null) return false;
  return switch (uri.scheme) {
    'https' => uri.host.isNotEmpty,
    'ms-windows-store' || 'market' || 'mailto' => true,
    _ => false,
  };
}

/// Compares dotted versions ("3.1.10" > "3.1.9"); a "v" prefix and any
/// "+build" or "-suffix" are ignored.
int compareVersions(String a, String b) {
  List<int> parts(String v) => v
      .trim()
      .replaceFirst(RegExp('^v'), '')
      .split(RegExp('[+-]'))
      .first
      .split('.')
      .map((p) => int.tryParse(RegExp(r'^\d+').stringMatch(p) ?? '') ?? 0)
      .toList();
  final x = parts(a), y = parts(b);
  for (var i = 0; i < x.length || i < y.length; i++) {
    final d = (i < x.length ? x[i] : 0) - (i < y.length ? y[i] : 0);
    if (d != 0) return d.sign;
  }
  return 0;
}
