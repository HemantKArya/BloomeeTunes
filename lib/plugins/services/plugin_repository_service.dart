import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:Bloomee/services/db/dao/settings_dao.dart';
import 'package:Bloomee/plugins/models/plugin_repository.dart';

class PluginRepositoryService {
  final SettingsDAO _settingsDao;
  static const String _reposKey = 'user_plugin_repositories';
  static Future<void> _mutationChain = Future<void>.value();

  PluginRepositoryService({required SettingsDAO settingsDao})
      : _settingsDao = settingsDao;

  Future<T> _enqueueMutation<T>(Future<T> Function() action) {
    final completer = Completer<T>();
    _mutationChain = _mutationChain.catchError((_) {}).then((_) async {
      try {
        completer.complete(await action());
      } catch (e, stack) {
        completer.completeError(e, stack);
      }
    });
    return completer.future;
  }

  /// Fetch and parse a repository from a URL
  Future<PluginRepositoryModel> fetchRepository(String url) async {
    try {
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final jsonMap = jsonDecode(response.body);
        return PluginRepositoryModel.fromJson(url, jsonMap);
      } else {
        throw Exception(
            'Failed to fetch repository: HTTP ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to parse repository at $url: $e');
    }
  }

  /// Get the list of saved repository URLs
  Future<List<String>> getSavedRepositoryUrls() async {
    final urlsJson = await _settingsDao.getSettingStr(_reposKey);
    if (urlsJson != null && urlsJson.isNotEmpty) {
      try {
        final List<dynamic> list = jsonDecode(urlsJson);
        return list.map((e) => e.toString()).toList();
      } catch (e) {
        return [];
      }
    }
    return [];
  }

  /// Add a new repository URL
  Future<void> addRepositoryUrl(String url) async {
    await ensureRepositoryUrls(<String>[url]);
  }

  /// Remove a repository URL
  Future<void> removeRepositoryUrl(String url) async {
    await _enqueueMutation(() async {
      final urls = await getSavedRepositoryUrls();
      if (urls.contains(url)) {
        urls.remove(url);
        await _settingsDao.putSettingStr(_reposKey, jsonEncode(urls));
      }
    });
  }

  Future<int> ensureRepositoryUrls(Iterable<String> urls) {
    return _enqueueMutation(() async {
      final existing = (await getSavedRepositoryUrls()).toSet();
      final validToAdd = urls
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .where((e) => Uri.tryParse(e)?.isAbsolute ?? false)
          .where((e) => !existing.contains(e))
          .toList(growable: false);

      if (validToAdd.isEmpty) return 0;

      existing.addAll(validToAdd);
      final updated = existing.toList()..sort();
      await _settingsDao.putSettingStr(_reposKey, jsonEncode(updated));
      return validToAdd.length;
    });
  }
}
