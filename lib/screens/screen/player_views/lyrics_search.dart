import 'dart:convert';
import 'dart:developer';

import 'package:Bloomee/blocs/lyrics/lyrics_cubit.dart';
import 'package:Bloomee/core/constants/setting_keys.dart';
import 'package:Bloomee/core/di/service_locator.dart';
import 'package:Bloomee/core/models/lyrics_models.dart';
import 'package:Bloomee/screens/widgets/sign_board_widget.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/services/db/dao/settings_dao.dart';
import 'package:Bloomee/services/db/db_provider.dart';
import 'package:Bloomee/services/plugin/plugin_service.dart';
import 'package:Bloomee/src/rust/api/plugin/commands.dart';
import 'package:Bloomee/src/rust/api/plugin/models.dart' as plugin_models;
import 'package:Bloomee/src/rust/api/plugin/types.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';

class LyricsSearchDelegate extends SearchDelegate {
  final String mediaID;
  @override
  String? get searchFieldLabel => "Search lyrics...";

  final PluginService _pluginService = ServiceLocator.pluginService;
  final SettingsDAO _settingsDao = SettingsDAO(DBProvider.db);

  LyricsSearchDelegate({required this.mediaID});

  Future<List<String>> _getLyricsPluginIds() async {
    final raw = await _settingsDao.getSettingStr(SettingKeys.lyricsPriority);
    List<String> stored = [];
    if (raw != null && raw.isNotEmpty) {
      try {
        stored = List<String>.from(jsonDecode(raw) as List);
      } catch (_) {}
    }

    // Keep only IDs that are actually loaded right now.
    final loadedIds = _pluginService.getLoadedPlugins().toSet();
    final active = stored.where(loadedIds.contains).toList();
    if (active.isNotEmpty) return active;

    // Fallback: enumerate every loaded LyricsProvider plugin so search works
    // even when the user hasn't explicitly configured a priority list.
    try {
      final available = await _pluginService.getAvailablePlugins();
      return available
          .where((p) =>
              p.pluginType == PluginType.lyricsProvider &&
              loadedIds.contains(p.manifest.id))
          .map((p) => p.manifest.id)
          .toList();
    } catch (e) {
      log('Failed to enumerate lyrics plugins: $e', name: 'LyricsSearch');
      return [];
    }
  }

  /// Returns results tagged with their source plugin ID so we can call the
  /// correct plugin in [_fetchById] without wasting roundtrips.
  Future<List<({String pluginId, plugin_models.LyricsMatch match})>>
      _searchPlugins(String q) async {
    if (q.trim().isEmpty) return [];
    final pluginIds = await _getLyricsPluginIds();
    if (pluginIds.isEmpty) return [];

    final results = <({String pluginId, plugin_models.LyricsMatch match})>[];
    for (final pluginId in pluginIds) {
      try {
        final response = await _pluginService.execute(
          pluginId: pluginId,
          request: PluginRequest.lyricsProvider(
            LyricsProviderCommand.search(query: q),
          ),
        );
        if (response is PluginResponse_LyricsSearchResults) {
          results.addAll(
            response.field0.map((m) => (pluginId: pluginId, match: m)),
          );
        }
      } catch (e) {
        log('Lyrics search failed for $pluginId: $e', name: 'LyricsSearch');
      }
    }
    return results;
  }

  Future<Lyrics?> _fetchById(
    String pluginId,
    String id,
    plugin_models.LyricsMatch match,
  ) async {
    try {
      final response = await _pluginService.execute(
        pluginId: pluginId,
        request: PluginRequest.lyricsProvider(
          LyricsProviderCommand.getLyricsById(id: id),
        ),
      );
      if (response is PluginResponse_LyricsById) {
        return pluginLyricsToLyrics(
          response.field0,
          artist: match.artist,
          title: match.title,
          album: match.album,
          durationMs: match.durationMs,
          mediaID: mediaID,
        );
      }
    } catch (e) {
      log('GetLyricsById failed for $pluginId: $e', name: 'LyricsSearch');
    }
    return null;
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: const AppBarTheme(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20))),
        backgroundColor: Color.fromARGB(255, 19, 19, 19),
        iconTheme: IconThemeData(color: Default_Theme.primaryColor1),
      ),
      textTheme: TextTheme(
        titleLarge: const TextStyle(
          color: Default_Theme.primaryColor1,
        ).merge(Default_Theme.secondoryTextStyleMedium),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(
          color: Default_Theme.primaryColor2.withValues(alpha: 0.3),
        ).merge(Default_Theme.secondoryTextStyle),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () => query = '', icon: const Icon(MingCute.close_fill))
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, null),
      icon: const Icon(MingCute.arrow_left_fill),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildSearchResults(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchResults(context);

  Widget _buildSearchResults(BuildContext context) {
    return FutureBuilder<
        List<({String pluginId, plugin_models.LyricsMatch match})>>(
      future: _searchPlugins(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Default_Theme.accentColor2,
            ),
          );
        }

        final results = snapshot.data ?? [];
        if (results.isEmpty) {
          return Center(
            child: SignBoardWidget(
              message: query.trim().isEmpty
                  ? "Type to search lyrics"
                  : "No results found",
              icon: MingCute.look_up_line,
            ),
          );
        }

        return ListView.builder(
          itemCount: results.length,
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemBuilder: (context, index) {
            final (:pluginId, :match) = results[index];
            final hasSynced =
                match.syncType != plugin_models.LyricsSyncType.none;
            return ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              title: Text(
                match.title,
                style:
                    const TextStyle(color: Default_Theme.primaryColor1).merge(
                  Default_Theme.secondoryTextStyleMedium,
                ),
              ),
              subtitle: Row(
                children: [
                  Flexible(
                    child: Text(
                      match.artist,
                      style: TextStyle(
                        color:
                            Default_Theme.primaryColor1.withValues(alpha: 0.7),
                      ).merge(Default_Theme.secondoryTextStyle),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (hasSynced) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2ECC71).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Synced',
                        style: TextStyle(
                          color: Color(0xFF2ECC71),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              onTap: () async {
                final lyrics = await _fetchById(pluginId, match.id, match);
                if (lyrics != null && context.mounted) {
                  context.read<LyricsCubit>().setLyricsToDB(lyrics, mediaID);
                  if (context.mounted) Navigator.of(context).pop();
                }
              },
            );
          },
        );
      },
    );
  }
}
