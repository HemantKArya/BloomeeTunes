import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:Bloomee/core/constants/setting_keys.dart';
import 'package:Bloomee/plugins/models/plugin_repository.dart';
import 'package:Bloomee/plugins/utils/plugin_constants.dart';
import 'package:Bloomee/plugins/services/plugin_repository_service.dart';
import 'package:Bloomee/services/db/dao/settings_dao.dart';
import 'package:Bloomee/services/plugin/plugin_load_state_service.dart';
import 'package:Bloomee/services/plugin/plugin_service.dart';
import 'package:Bloomee/src/rust/api/plugin/plugin_info.dart';
import 'package:Bloomee/src/rust/api/plugin/types.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class _HostedRepoEntry {
  final String url;
  final bool install;

  const _HostedRepoEntry({required this.url, required this.install});

  factory _HostedRepoEntry.fromJson(Map<String, dynamic> json) {
    return _HostedRepoEntry(
      url: json['url']?.toString() ?? '',
      install: json['install'] as bool? ?? false,
    );
  }
}

class PluginBootstrapResult {
  final bool success;
  final List<String> errors;
  const PluginBootstrapResult({required this.success, required this.errors});
}

class PluginBootstrapProgress {
  final int percent;

  const PluginBootstrapProgress(this.percent);
}

class PluginBootstrapService {
  static const String hostedRepositoriesUrl =
      'https://hemantkarya.github.io/BloomeeTunes/repositories.json';

  static const int maxRetries = 3;

  static const Duration syncGap = Duration(minutes: 30);

  static bool _bootstrapDone = false;

  static bool get bootstrapDone => _bootstrapDone;

  static Future<void> checkAndCacheDone(SettingsDAO settingsDao) async {
    _bootstrapDone = await settingsDao
            .getSettingBool(SettingKeys.repositoriesBootstrapped) ??
        false;
  }

  static Future<void> _markDone(SettingsDAO settingsDao) async {
    await settingsDao.putSettingBool(
        SettingKeys.repositoriesBootstrapped, true);
    _bootstrapDone = true;
  }

  static Future<PluginBootstrapResult> run({
    required PluginService pluginService,
    required PluginRepositoryService repositoryService,
    required SettingsDAO settingsDao,
    required void Function(PluginBootstrapProgress progress) onProgress,
  }) async {
    final errors = <String>[];

    onProgress(const PluginBootstrapProgress(8));

    List<_HostedRepoEntry> entries;
    try {
      entries = await _fetchHostedEntries();
      log('Fetched ${entries.length} repository entries',
          name: 'PluginBootstrap');
    } catch (e) {
      log('Failed to fetch repositories.json: $e', name: 'PluginBootstrap');
      errors
          .add('Could not reach the plugin catalogue. Check your connection.');
      return PluginBootstrapResult(success: false, errors: errors);
    }

    final existingUrls = await repositoryService.getSavedRepositoryUrls();
    for (final entry in entries) {
      if (entry.url.isEmpty) continue;
      if (!existingUrls.contains(entry.url)) {
        try {
          await repositoryService.addRepositoryUrl(entry.url);
          log('Added repository: ${entry.url}', name: 'PluginBootstrap');
        } catch (e) {
          log('Could not save repository URL ${entry.url}: $e',
              name: 'PluginBootstrap');
          // Non-fatal — continue with install attempts anyway.
        }
      }
    }
    onProgress(const PluginBootstrapProgress(24));

    final installEntries =
        entries.where((e) => e.install && e.url.isNotEmpty).toList();
    final installRepos = <PluginRepositoryModel>[];

    for (var repoIndex = 0; repoIndex < installEntries.length; repoIndex++) {
      final entry = installEntries[repoIndex];
      onProgress(PluginBootstrapProgress(24 +
          ((repoIndex + 1) *
              16 ~/
              (installEntries.isEmpty ? 1 : installEntries.length))));

      try {
        final repoModel = await repositoryService.fetchRepository(entry.url);
        installRepos.add(repoModel);
        log('Loaded repo "${repoModel.name}" with ${repoModel.plugins.length} plugin(s)',
            name: 'PluginBootstrap');
      } catch (e) {
        log('Could not load repository at ${entry.url}: $e',
            name: 'PluginBootstrap');
        errors.add('Failed to load plugin repository: $e');
      }
    }

    final available = await _safeGetAvailable(pluginService);
    final installedIds = available.map((p) => p.manifest.id).toSet();
    final totalPlugins =
        installRepos.fold<int>(0, (sum, repo) => sum + repo.plugins.length);
    var processedPlugins = 0;

    for (final repo in installRepos) {
      for (final plugin in repo.plugins) {
        onProgress(PluginBootstrapProgress(40 +
            ((processedPlugins * 55) ~/
                (totalPlugins == 0 ? 1 : totalPlugins))));

        if (installedIds.contains(plugin.id)) {
          processedPlugins++;
          continue;
        }

        bool installed = false;
        String? lastError;

        for (int attempt = 1; attempt <= maxRetries; attempt++) {
          try {
            final bytes = await _downloadBytes(plugin.downloadUrl);
            final tmpDir = await getTemporaryDirectory();
            final file = File('${tmpDir.path}/${plugin.assetName}');
            await file.writeAsBytes(bytes, flush: true);

            final result = await pluginService.installPlugin(
              packedFilePath: file.path,
              shouldLoad: true,
            );

            final ok = result.status == PluginInstallStatus.installed ||
                result.status == PluginInstallStatus.updated ||
                result.status == PluginInstallStatus.alreadyInstalled;

            if (ok) {
              installed = true;
              installedIds.add(plugin.id);
            } else {
              lastError =
                  'Install returned status: ${result.status.name}${result.error != null ? ' — ${result.error}' : ''}';
            }
          } catch (e) {
            lastError = e.toString();
          }

          if (!installed && attempt < maxRetries) {
            await Future<void>.delayed(Duration(seconds: attempt * 2));
          }
          if (installed) break;
        }

        if (!installed) {
          errors.add('Could not install "${plugin.name}": $lastError');
        }

        processedPlugins++;
        onProgress(PluginBootstrapProgress(40 +
            ((processedPlugins * 55) ~/
                (totalPlugins == 0 ? 1 : totalPlugins))));
      }
    }

    if (errors.isEmpty) {
      // Ensure all installed plugins (the ones we just installed/updated)
      // are added to the auto-load list so they are actually used.
      try {
        final loadStateService = PluginLoadStateService(settingsDao);
        final currentAutoLoad = await loadStateService.readAutoLoadPluginIds();

        // Ensure everything that is "available" and part of our bootstrap
        // is in the auto-load list.
        final available = await _safeGetAvailable(pluginService);
        final bootstrapIds = available
            .where((p) => installedIds.contains(p.manifest.id))
            .map((p) => p.manifest.id)
            .toSet();

        if (bootstrapIds.isNotEmpty) {
          await loadStateService
              .writeAutoLoadPluginIds({...currentAutoLoad, ...bootstrapIds});
          log('Added ${bootstrapIds.length} plugins to auto-load list',
              name: 'PluginBootstrap');
        }
      } catch (e) {
        log('Failed to update auto-load list: $e', name: 'PluginBootstrap');
      }

      await _markDone(settingsDao);
      log('Plugin bootstrap completed successfully.', name: 'PluginBootstrap');
    } else {
      log('Plugin bootstrap completed with ${errors.length} error(s).',
          name: 'PluginBootstrap');
    }

    onProgress(const PluginBootstrapProgress(100));

    return PluginBootstrapResult(
      success: errors.isEmpty,
      errors: errors,
    );
  }

  static Future<void> autoSelectPluginDefaults(
    PluginService pluginService,
    SettingsDAO settingsDao,
  ) async {
    try {
      final available = await _safeGetAvailable(pluginService);

      final currentSuggestion =
          await settingsDao.getSettingStr(SettingKeys.suggestionPluginId);
      if (currentSuggestion == null || currentSuggestion.isEmpty) {
        final suggestionPlugin = available.firstWhere(
          (p) => p.pluginType == PluginType.searchSuggestionProvider,
          orElse: () => throw StateError('none'),
        );
        await settingsDao.putSettingStr(
            SettingKeys.suggestionPluginId, suggestionPlugin.manifest.id);
        log('Auto-selected suggestion plugin: ${suggestionPlugin.manifest.id}',
            name: 'PluginBootstrap');
      }

      final currentHome =
          await settingsDao.getSettingStr(SettingKeys.homePluginId);
      if (currentHome == null || currentHome.isEmpty) {
        final homePlugin = available.firstWhere(
          (p) => p.pluginType == PluginType.contentResolver,
          orElse: () => throw StateError('none'),
        );
        await settingsDao.putSettingStr(
            SettingKeys.homePluginId, homePlugin.manifest.id);
        log('Auto-selected home plugin: ${homePlugin.manifest.id}',
            name: 'PluginBootstrap');
      }

      final currentSearch =
          await settingsDao.getSettingStr(SettingKeys.searchPluginId);
      if (currentSearch == null || currentSearch.isEmpty) {
        final searchPlugin = available.firstWhere(
          (p) => p.pluginType == PluginType.contentResolver,
          orElse: () => throw StateError('none'),
        );
        await settingsDao.putSettingStr(
            SettingKeys.searchPluginId, searchPlugin.manifest.id);
        log('Auto-selected search plugin: ${searchPlugin.manifest.id}',
            name: 'PluginBootstrap');
      }
    } catch (_) {}
  }

  static Future<void> syncOnAppOpenIfDue({
    required PluginService pluginService,
    required PluginRepositoryService repositoryService,
    required SettingsDAO settingsDao,
  }) async {
    final now = DateTime.now().toUtc();
    final lastSyncRaw =
        await settingsDao.getSettingStr(SettingKeys.pluginRepositoryLastSync);
    final lastSync =
        lastSyncRaw == null ? null : DateTime.tryParse(lastSyncRaw)?.toUtc();

    if (lastSync != null && now.difference(lastSync) < syncGap) {
      return;
    }

    await syncRepositoriesAndAutoUpdate(
      pluginService: pluginService,
      repositoryService: repositoryService,
      settingsDao: settingsDao,
    );
  }

  static Future<void> syncRepositoriesAndAutoUpdate({
    required PluginService pluginService,
    required PluginRepositoryService repositoryService,
    required SettingsDAO settingsDao,
  }) async {
    try {
      final hostedEntries = await _fetchHostedEntries();
      final existingUrls = await repositoryService.getSavedRepositoryUrls();
      final knownUrls = existingUrls.toSet();

      for (final entry in hostedEntries) {
        if (entry.url.isEmpty || knownUrls.contains(entry.url)) {
          continue;
        }
        try {
          await repositoryService.addRepositoryUrl(entry.url);
          knownUrls.add(entry.url);
        } catch (e) {
          log('Failed to add hosted repository ${entry.url}: $e',
              name: 'PluginBootstrap');
        }
      }

      final repos = <PluginRepositoryModel>[];
      for (final url in knownUrls) {
        try {
          repos.add(await repositoryService.fetchRepository(url));
        } catch (e) {
          log('Failed to fetch repository $url: $e', name: 'PluginBootstrap');
        }
      }

      if (repos.isEmpty) {
        return;
      }

      await pluginService.refreshPlugins();
      final available = await _safeGetAvailable(pluginService);
      final installedById = <String, PluginInfo>{
        for (final plugin in available) plugin.manifest.id: plugin,
      };

      final remoteLatestById = <String, RemotePluginModel>{};
      for (final repo in repos) {
        for (final remote in repo.plugins) {
          if (!_isRemoteManifestCompatible(remote)) {
            continue;
          }
          final existing = remoteLatestById[remote.id];
          if (existing == null ||
              _compareVersions(remote.version, existing.version) > 0) {
            remoteLatestById[remote.id] = remote;
          }
        }
      }

      for (final entry in installedById.entries) {
        final pluginId = entry.key;
        final local = entry.value;
        final remote = remoteLatestById[pluginId];
        if (remote == null) {
          continue;
        }
        if (local.manifest.manifestVersion != CURRENT_MANIFEST_VERSION) {
          continue;
        }
        if (_compareVersions(remote.version, local.manifest.version) <= 0) {
          continue;
        }

        try {
          await _installRemotePluginWithRetry(
            pluginService: pluginService,
            plugin: remote,
            retries: maxRetries,
          );

          // Add to auto-load list if updated.
          final loadStateService = PluginLoadStateService(settingsDao);
          final current = await loadStateService.readAutoLoadPluginIds();
          if (!current.contains(pluginId)) {
            await loadStateService
                .writeAutoLoadPluginIds({...current, pluginId});
          }
        } catch (e) {
          log('Auto-update failed for $pluginId: $e', name: 'PluginBootstrap');
        }
      }

      await pluginService.refreshPlugins();
      await autoSelectPluginDefaults(pluginService, settingsDao);
      await settingsDao.putSettingStr(
        SettingKeys.pluginRepositoryLastSync,
        DateTime.now().toUtc().toIso8601String(),
      );
    } catch (e, stack) {
      log('Background plugin sync failed',
          error: e, stackTrace: stack, name: 'PluginBootstrap');
    }
  }

  static Future<void> _installRemotePluginWithRetry({
    required PluginService pluginService,
    required RemotePluginModel plugin,
    required int retries,
  }) async {
    String? lastError;

    for (int attempt = 1; attempt <= retries; attempt++) {
      try {
        final bytes = await _downloadBytes(plugin.downloadUrl);
        final tmpDir = await getTemporaryDirectory();
        final file = File('${tmpDir.path}/${plugin.assetName}');
        await file.writeAsBytes(bytes, flush: true);

        final result = await pluginService.installPlugin(
          packedFilePath: file.path,
          shouldLoad: true,
        );

        final ok = result.status == PluginInstallStatus.installed ||
            result.status == PluginInstallStatus.updated ||
            result.status == PluginInstallStatus.alreadyInstalled;
        if (ok) {
          return;
        }

        lastError =
            'Install returned status ${result.status.name}${result.error == null ? '' : ': ${result.error}'}';
      } catch (e) {
        lastError = e.toString();
      }

      if (attempt < retries) {
        await Future<void>.delayed(Duration(seconds: attempt * 2));
      }
    }

    throw Exception('Failed to update ${plugin.id}: $lastError');
  }

  static bool _isRemoteManifestCompatible(RemotePluginModel plugin) {
    final value = int.tryParse(plugin.manifestVersion.trim());
    return value != null && value == CURRENT_MANIFEST_VERSION;
  }

  static int _compareVersions(String left, String right) {
    final leftParts = RegExp(r'\d+')
        .allMatches(left)
        .map((m) => int.parse(m.group(0)!))
        .toList();
    final rightParts = RegExp(r'\d+')
        .allMatches(right)
        .map((m) => int.parse(m.group(0)!))
        .toList();

    if (leftParts.isEmpty && rightParts.isEmpty) {
      return left.compareTo(right);
    }

    final maxLen = leftParts.length > rightParts.length
        ? leftParts.length
        : rightParts.length;
    for (var i = 0; i < maxLen; i++) {
      final l = i < leftParts.length ? leftParts[i] : 0;
      final r = i < rightParts.length ? rightParts[i] : 0;
      if (l != r) {
        return l.compareTo(r);
      }
    }
    return 0;
  }

  static Future<List<_HostedRepoEntry>> _fetchHostedEntries() async {
    final response = await http
        .get(Uri.parse(hostedRepositoriesUrl))
        .timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final list = json['repositories'] as List<dynamic>?;
    if (list == null) throw const FormatException('Missing "repositories" key');
    return list
        .map((e) =>
            _HostedRepoEntry.fromJson(Map<String, dynamic>.from(e as Map)))
        .where((e) => e.url.isNotEmpty)
        .toList();
  }

  static Future<Uint8List> _downloadBytes(String url) async {
    final response =
        await http.get(Uri.parse(url)).timeout(const Duration(seconds: 45));
    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }
    return response.bodyBytes;
  }

  static Future<List<PluginInfo>> _safeGetAvailable(
      PluginService pluginService) async {
    try {
      return await pluginService.getAvailablePlugins();
    } catch (_) {
      return [];
    }
  }
}
