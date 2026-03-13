import 'dart:convert';
import 'dart:developer';
import 'dart:ui';
import 'package:Bloomee/blocs/lyrics/lyrics_cubit.dart';
import 'package:Bloomee/core/constants/setting_keys.dart';
import 'package:Bloomee/core/di/service_locator.dart';
import 'package:Bloomee/core/models/lyrics_models.dart';
import 'package:Bloomee/l10n/app_localizations.dart';
import 'package:Bloomee/screens/widgets/sign_board_widget.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/services/db/dao/settings_dao.dart';
import 'package:Bloomee/services/db/db_provider.dart';
import 'package:Bloomee/services/plugin/plugin_service.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:Bloomee/src/rust/api/plugin/commands.dart';
import 'package:Bloomee/src/rust/api/plugin/models.dart' as plugin_models;
import 'package:Bloomee/src/rust/api/plugin/types.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';

class LyricsSearchDelegate extends SearchDelegate {
  final String mediaID;
  final String searchFieldLabelText;
  @override
  String? get searchFieldLabel => searchFieldLabelText;

  final PluginService _pluginService = ServiceLocator.pluginService;
  final SettingsDAO _settingsDao = SettingsDAO(DBProvider.db);

  LyricsSearchDelegate({
    required this.mediaID,
    required this.searchFieldLabelText,
  });

  Future<List<String>> _getLyricsPluginIds() async {
    final raw = await _settingsDao.getSettingStr(SettingKeys.lyricsPriority);
    List<String> stored = [];
    if (raw != null && raw.isNotEmpty) {
      try {
        stored = List<String>.from(jsonDecode(raw) as List);
      } catch (_) {}
    }

    final loadedIds = _pluginService.getLoadedPlugins().toSet();
    final active = stored.where(loadedIds.contains).toList();
    if (active.isNotEmpty) return active;

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
              LyricsProviderCommand.search(query: q)),
        );
        if (response is PluginResponse_LyricsSearchResults) {
          results.addAll(
              response.field0.map((m) => (pluginId: pluginId, match: m)));
        }
      } catch (e) {
        log('Lyrics search failed for $pluginId: $e', name: 'LyricsSearch');
      }
    }
    return results;
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Default_Theme.themeColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(
          color: Default_Theme.primaryColor1.withValues(alpha: 0.4),
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        border: InputBorder.none,
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.w500,
        ),
      ),
      scaffoldBackgroundColor: Default_Theme.themeColor,
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          onPressed: () => query = '',
          icon: Icon(MingCute.close_fill,
              color: Default_Theme.primaryColor1.withValues(alpha: 0.6),
              size: 20),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
      const SizedBox(width: 8),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, null),
      icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildBody(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildBody(context);

  Widget _buildBody(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (query.trim().isEmpty) {
      return Center(
        child: SignBoardWidget(
          message: l10n.lyricsSearchEmptyPrompt,
          icon: MingCute.search_2_line,
        ),
      );
    }

    return FutureBuilder<
        List<({String pluginId, plugin_models.LyricsMatch match})>>(
      future: _searchPlugins(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
                color: Default_Theme.accentColor2, strokeWidth: 3),
          );
        }

        final results = snapshot.data ?? [];
        if (results.isEmpty) {
          return Center(
            child: SignBoardWidget(
              message: l10n.lyricsSearchNoResults(query.trim()),
              icon: MingCute.ghost_line,
            ),
          );
        }

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
                maxWidth: 800), // Desktop elegant containment
            child: ListView.separated(
              itemCount: results.length,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final result = results[index];
                return _LyricsResultCard(
                  pluginId: result.pluginId,
                  match: result.match,
                  mediaID: mediaID,
                  searchDelegate: this,
                );
              },
            ),
          ),
        );
      },
    );
  }
}

// ── Smart Interactive Card (Redesigned Layout) ───────────────────────────────

class _LyricsResultCard extends StatefulWidget {
  final String pluginId;
  final plugin_models.LyricsMatch match;
  final String mediaID;
  final LyricsSearchDelegate searchDelegate;

  const _LyricsResultCard({
    required this.pluginId,
    required this.match,
    required this.mediaID,
    required this.searchDelegate,
  });

  @override
  State<_LyricsResultCard> createState() => _LyricsResultCardState();
}

class _LyricsResultCardState extends State<_LyricsResultCard> {
  bool _isApplying = false;

  Future<void> _applyDirectly() async {
    final l10n = AppLocalizations.of(context)!;
    if (_isApplying) return;
    setState(() => _isApplying = true);

    try {
      final response = await ServiceLocator.pluginService.execute(
        pluginId: widget.pluginId,
        request: PluginRequest.lyricsProvider(
          LyricsProviderCommand.getLyricsById(id: widget.match.id),
        ),
      );

      if (response is PluginResponse_LyricsById && mounted) {
        final fetchedLyrics = pluginLyricsToLyrics(
          response.field0,
          artist: widget.match.artist,
          title: widget.match.title,
          album: widget.match.album,
          durationMs: widget.match.durationMs,
          mediaID: widget.mediaID,
        );

        context
            .read<LyricsCubit>()
            .setLyricsToDB(fetchedLyrics, widget.mediaID);
        SnackbarService.showMessage(l10n.lyricsSearchApplied);
        widget.searchDelegate.close(context, null);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isApplying = false);
        SnackbarService.showMessage(l10n.lyricsSearchFetchFailed);
      }
    }
  }

  void _openPreview() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _LyricsPreviewModal(
        pluginId: widget.pluginId,
        match: widget.match,
        mediaID: widget.mediaID,
        parentContext: context,
        searchDelegate: widget.searchDelegate,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasSynced =
        widget.match.syncType != plugin_models.LyricsSyncType.none;

    return Container(
      decoration: BoxDecoration(
        color: Default_Theme.primaryColor1.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: Default_Theme.primaryColor1.withValues(alpha: 0.06)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _isApplying ? null : _applyDirectly,
            splashColor: Default_Theme.primaryColor1.withValues(alpha: 0.06),
            highlightColor: Default_Theme.primaryColor1.withValues(alpha: 0.04),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.center, // Perfect vertical alignment
                children: [
                  // Icon Indicator
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: hasSynced
                          ? Default_Theme.accentColor2.withValues(alpha: 0.12)
                          : Default_Theme.primaryColor1.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: hasSynced
                            ? Default_Theme.accentColor2.withValues(alpha: 0.2)
                            : Colors.transparent,
                      ),
                    ),
                    child: Center(
                      child: _isApplying
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Default_Theme.accentColor2))
                          : Icon(
                              hasSynced
                                  ? MingCute.align_center_fill
                                  : MingCute.document_line,
                              color: hasSynced
                                  ? Default_Theme.accentColor2
                                  : Default_Theme.primaryColor1
                                      .withValues(alpha: 0.6),
                              size: 22,
                            ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Text Info + Inline Badge
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                widget.match.title,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.95),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // INLINE BADGE: Looks natural and flows with the text
                            if (hasSynced) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Default_Theme.accentColor2
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                      color: Default_Theme.accentColor2
                                          .withValues(alpha: 0.2)),
                                ),
                                child: Text(
                                  l10n.lyricsSearchSynced,
                                  style: TextStyle(
                                      color: Default_Theme.accentColor2,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          widget.match.artist,
                          style: TextStyle(
                            color: Default_Theme.primaryColor2
                                .withValues(alpha: 0.7),
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Compact Icon-Only Preview Button
                  Material(
                    color: Colors.transparent,
                    child: Tooltip(
                      message: l10n.lyricsSearchPreviewTooltip,
                      child: InkWell(
                        onTap: _isApplying ? null : _openPreview,
                        borderRadius: BorderRadius.circular(10),
                        splashColor:
                            Default_Theme.primaryColor1.withValues(alpha: 0.1),
                        highlightColor:
                            Default_Theme.primaryColor1.withValues(alpha: 0.05),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Default_Theme.primaryColor1
                                .withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: Default_Theme.primaryColor1
                                    .withValues(alpha: 0.05)),
                          ),
                          child: Icon(
                            MingCute.eye_2_line,
                            size: 18,
                            color: Default_Theme.primaryColor1
                                .withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Premium Blur Modal ───────────────────────────────────────────────────────

class _LyricsPreviewModal extends StatefulWidget {
  final String pluginId;
  final plugin_models.LyricsMatch match;
  final String mediaID;
  final BuildContext parentContext;
  final LyricsSearchDelegate searchDelegate;

  const _LyricsPreviewModal({
    required this.pluginId,
    required this.match,
    required this.mediaID,
    required this.parentContext,
    required this.searchDelegate,
  });

  @override
  State<_LyricsPreviewModal> createState() => _LyricsPreviewModalState();
}

class _LyricsPreviewModalState extends State<_LyricsPreviewModal> {
  final PluginService _pluginService = ServiceLocator.pluginService;
  Lyrics? _fetchedLyrics;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLyrics();
  }

  Future<void> _fetchLyrics() async {
    try {
      final response = await _pluginService.execute(
        pluginId: widget.pluginId,
        request: PluginRequest.lyricsProvider(
            LyricsProviderCommand.getLyricsById(id: widget.match.id)),
      );
      if (response is PluginResponse_LyricsById && mounted) {
        setState(() {
          _fetchedLyrics = pluginLyricsToLyrics(
            response.field0,
            artist: widget.match.artist,
            title: widget.match.title,
            album: widget.match.album,
            durationMs: widget.match.durationMs,
            mediaID: widget.mediaID,
          );
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Default_Theme.themeColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Glassy Header
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 12, 12),
                decoration: BoxDecoration(
                  color: Default_Theme.primaryColor1.withValues(alpha: 0.02),
                  border: Border(
                      bottom: BorderSide(
                          color: Default_Theme.primaryColor1
                              .withValues(alpha: 0.08))),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color:
                            Default_Theme.primaryColor1.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.lyricsSearchPreview,
                                style: TextStyle(
                                  color: Default_Theme.accentColor2
                                      .withValues(alpha: 0.8),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.match.title,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.95),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(MingCute.close_fill,
                              color: Default_Theme.primaryColor1
                                  .withValues(alpha: 0.6),
                              size: 24),
                          onPressed: () => Navigator.pop(context),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Body (Lyrics)
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: Default_Theme.accentColor2))
                : _fetchedLyrics == null || _fetchedLyrics!.lyricsPlain.isEmpty
                    ? Center(
                        child: SignBoardWidget(
                          message: l10n.lyricsSearchPreviewLoadFailed,
                          icon: MingCute.ghost_line,
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 32),
                        physics: const BouncingScrollPhysics(),
                        child: Text(
                          _fetchedLyrics!.lyricsPlain,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 17,
                            height: 1.8,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
          ),

          // Footer Action
          if (!_isLoading &&
              _fetchedLyrics != null &&
              _fetchedLyrics!.lyricsPlain.isNotEmpty)
            Container(
              padding: EdgeInsets.fromLTRB(
                  24, 16, 24, MediaQuery.of(context).padding.bottom + 24),
              decoration: BoxDecoration(
                  color: Default_Theme.themeColor,
                  border: Border(
                      top: BorderSide(
                          color: Default_Theme.primaryColor1
                              .withValues(alpha: 0.05))),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, -10)),
                  ]),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    widget.parentContext
                        .read<LyricsCubit>()
                        .setLyricsToDB(_fetchedLyrics!, widget.mediaID);
                    SnackbarService.showMessage(l10n.lyricsSearchApplied);
                    Navigator.pop(context);
                    widget.searchDelegate.close(widget.parentContext, null);
                  },
                  borderRadius: BorderRadius.circular(16),
                  splashColor:
                      Default_Theme.accentColor2.withValues(alpha: 0.2),
                  highlightColor:
                      Default_Theme.accentColor2.withValues(alpha: 0.1),
                  child: Container(
                    height: 54,
                    width: double.infinity,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Default_Theme.accentColor2.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color:
                              Default_Theme.accentColor2.withValues(alpha: 0.4),
                          width: 1.5),
                    ),
                    child: Text(
                      l10n.lyricsSearchApplyAction,
                      style: TextStyle(
                        color: Default_Theme.accentColor2,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
