import 'package:Bloomee/utils/country_info.dart';

class RemotePluginModel {
  final String assetName;
  final String description;
  final String id;
  final String name;
  final String manifestVersion;
  final String type;
  final String version;
  final String downloadUrl;
  final String? thumbnailUrl;
  final String? publisherName;
  final List<String> countryAllowlist;
  final DateTime? lastUpdated;

  RemotePluginModel({
    required this.assetName,
    required this.description,
    required this.id,
    required this.name,
    required this.manifestVersion,
    required this.type,
    required this.version,
    required this.downloadUrl,
    this.thumbnailUrl,
    this.publisherName,
    this.countryAllowlist = const [],
    this.lastUpdated,
  });

  factory RemotePluginModel.fromJson(Map<String, dynamic> json) {
    return RemotePluginModel(
      assetName: json['asset_name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      manifestVersion: json['manifest_version']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      version: json['version']?.toString() ?? '',
      downloadUrl: json['download_url']?.toString() ?? '',
      thumbnailUrl: json['thumbnail_url']?.toString(),
      publisherName: json['publisher'] != null
          ? json['publisher']['name']?.toString()
          : null,
      countryAllowlist:
          (json['country_allowlist'] as List<dynamic>? ?? const [])
              .map((value) =>
                  CountryInfoService.normalizeCountryCode(value?.toString()))
              .where((value) => value.isNotEmpty)
              .toSet()
              .toList()
            ..sort(),
      lastUpdated: json['last_updated'] != null
          ? DateTime.tryParse(json['last_updated'].toString())
          : null,
    );
  }

  bool isAllowedInCountry(String countryCode) {
    if (countryAllowlist.isEmpty) {
      return true;
    }
    final normalized = CountryInfoService.normalizeCountryCode(countryCode);
    return normalized.isNotEmpty && countryAllowlist.contains(normalized);
  }
}

class PluginRepositoryModel {
  final String url;
  final String schemaVersion;
  final String name;
  final String description;
  final String? thumbnailUrl;
  final List<RemotePluginModel> plugins;
  final DateTime? generatedAt;

  PluginRepositoryModel({
    required this.url,
    required this.schemaVersion,
    required this.name,
    required this.description,
    this.thumbnailUrl,
    required this.plugins,
    this.generatedAt,
  });

  factory PluginRepositoryModel.fromJson(
      String url, Map<String, dynamic> json) {
    return PluginRepositoryModel(
      url: url,
      schemaVersion: json['schema_version']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown Repository',
      description: json['description']?.toString() ?? '',
      thumbnailUrl: json['thumbnail_url']?.toString(),
      plugins: (json['plugins'] as List?)
              ?.map((p) =>
                  RemotePluginModel.fromJson(Map<String, dynamic>.from(p)))
              .toList() ??
          [],
      generatedAt: json['generated_at'] != null
          ? DateTime.tryParse(json['generated_at'].toString())
          : null,
    );
  }
}
