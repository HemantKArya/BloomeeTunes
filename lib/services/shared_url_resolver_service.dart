import 'dart:convert';
import 'dart:developer';

import 'package:Bloomee/core/constants/setting_keys.dart';
import 'package:Bloomee/core/di/service_locator.dart';
import 'package:Bloomee/core/models/exported.dart';
import 'package:Bloomee/services/db/dao/settings_dao.dart';
import 'package:Bloomee/services/db/db_provider.dart';
import 'package:Bloomee/src/rust/api/plugin/commands.dart';
import 'package:Bloomee/src/rust/api/plugin/plugin_info.dart';
import 'package:Bloomee/src/rust/api/plugin/types.dart';
import 'package:Bloomee/utils/url_checker.dart';

enum SharedUrlResolveStatus {
  success,
  invalidUrl,
  noResolver,
  failed,
}

class SharedUrlResolveResult {
  final SharedUrlResolveStatus status;
  final Track? track;

  const SharedUrlResolveResult({
    required this.status,
    this.track,
  });
}

class SharedUrlResolverService {
  SharedUrlResolverService._();

  static Future<SharedUrlResolveResult> resolveYoutubeVideo(String url) async {
    final videoId = extractVideoId(url);
    if (videoId == null) {
      return const SharedUrlResolveResult(
        status: SharedUrlResolveStatus.invalidUrl,
      );
    }

    final List<PluginInfo> resolverPlugins;
    try {
      resolverPlugins = await _rankContentResolversForUrl(url);
    } catch (e) {
      log('Failed to discover shared URL resolvers: $e',
          name: 'SharedUrlResolverService');
      return const SharedUrlResolveResult(
        status: SharedUrlResolveStatus.failed,
      );
    }

    if (resolverPlugins.isEmpty) {
      return const SharedUrlResolveResult(
        status: SharedUrlResolveStatus.noResolver,
      );
    }

    for (final plugin in resolverPlugins) {
      try {
        final response = await ServiceLocator.pluginService
            .execute(
              pluginId: plugin.manifest.id,
              request: PluginRequest.contentResolver(
                ContentResolverCommand.getTrackDetails(id: videoId),
              ),
            )
            .timeout(const Duration(seconds: 10));

        if (response is PluginResponse_TrackDetails) {
          return SharedUrlResolveResult(
            status: SharedUrlResolveStatus.success,
            track: response.field0,
          );
        }
      } catch (e) {
        log(
          'Shared URL resolver failed for ${plugin.manifest.id}: $e',
          name: 'SharedUrlResolverService',
        );
      }
    }

    return const SharedUrlResolveResult(status: SharedUrlResolveStatus.failed);
  }

  static Future<List<PluginInfo>> _rankContentResolversForUrl(String url) async {
    final pluginService = ServiceLocator.pluginService;
    final available = await pluginService.getAvailablePlugins();
    final loadedIds = pluginService.getLoadedPlugins().toSet();
    final priority = await _getResolverPriority();

    final resolvers = available
        .where((p) =>
            p.pluginType == PluginType.contentResolver &&
            loadedIds.contains(p.manifest.id))
        .toList(growable: false);

    final claimed = <PluginInfo>[];
    final fallback = <PluginInfo>[];
    for (final plugin in resolvers) {
      if (_resolverClaimsUrl(plugin, url)) {
        claimed.add(plugin);
      } else {
        fallback.add(plugin);
      }
    }

    claimed.sort((a, b) => _resolverPriorityIndex(a, priority)
        .compareTo(_resolverPriorityIndex(b, priority)));
    fallback.sort((a, b) => _resolverPriorityIndex(a, priority)
        .compareTo(_resolverPriorityIndex(b, priority)));

    // Claimed host matches are authoritative. Fallback preserves compatibility
    // with older/community plugins that have not filled host_site yet.
    return [...claimed, ...fallback];
  }

  static Future<List<String>> _getResolverPriority() async {
    final raw = await SettingsDAO(DBProvider.db).getSettingStr(
      SettingKeys.resolverPriority,
      defaultValue: '[]',
    );
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.whereType<String>().toList(growable: false);
      }
    } catch (_) {}
    return const [];
  }

  static int _resolverPriorityIndex(
    PluginInfo plugin,
    List<String> priority,
  ) {
    final index = priority.indexOf(plugin.manifest.id);
    return index == -1 ? 1 << 20 : index;
  }

  static bool _resolverClaimsUrl(PluginInfo plugin, String url) {
    final uri = Uri.tryParse(url);
    final host = uri?.host.toLowerCase() ?? '';
    if (host.isEmpty) return false;

    return plugin.manifest.hostSite.any((site) {
      final candidate = _hostSiteCandidate(site);
      if (candidate.isEmpty) return false;
      return host == candidate || host.endsWith('.$candidate');
    });
  }

  static String _hostSiteCandidate(String value) {
    final normalized = value.toLowerCase().trim();
    if (normalized.isEmpty) return '';

    final parsed = Uri.tryParse(normalized);
    final host = parsed?.host.toLowerCase();
    if (host != null && host.isNotEmpty) return host;

    return normalized
        .replaceFirst(RegExp(r'^https?://'), '')
        .split('/')
        .first;
  }
}
