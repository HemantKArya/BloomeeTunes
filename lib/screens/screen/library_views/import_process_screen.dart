import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';

import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/l10n/app_localizations.dart';
import 'package:Bloomee/plugins/blocs/import/content_import_cubit.dart';
import 'package:Bloomee/plugins/blocs/import/content_import_state.dart';
import 'package:Bloomee/plugins/blocs/plugin/plugin_bloc.dart';
import 'package:Bloomee/plugins/blocs/plugin/plugin_state.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:Bloomee/src/rust/api/plugin/models.dart';

// ── Screen ──────────────────────────────────────────────────────────────────

/// Full-screen import process.
/// [ContentImportCubit] is provided globally (main.dart) — state survives navigation.
class ImportProcessScreen extends StatefulWidget {
  final String pluginId;
  const ImportProcessScreen({super.key, required this.pluginId});

  @override
  State<ImportProcessScreen> createState() => _ImportProcessScreenState();
}

class _ImportProcessScreenState extends State<ImportProcessScreen> {
  final _urlController = TextEditingController();

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _startImport(ContentImportCubit cubit) {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;
    cubit.checkUrl(widget.pluginId, url);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PluginBloc, PluginState>(
      listenWhen: (prev, curr) =>
          prev.loadedPluginIds.contains(widget.pluginId) &&
          !curr.loadedPluginIds.contains(widget.pluginId),
      listener: (context, _) {
        if (context.mounted) context.pop();
      },
      child: Scaffold(
        backgroundColor: Default_Theme.themeColor,
        appBar: _buildAppBar(context),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: BlocConsumer<ContentImportCubit, ContentImportState>(
              listener: (context, state) {
                if (state.phase == ImportPhase.done) {
                  SnackbarService.showMessage(
                    AppLocalizations.of(context)!
                        .importTracksSaved(state.resolvedCount),
                  );
                }
                if (state.phase == ImportPhase.error && state.error != null) {
                  SnackbarService.showMessage(
                    _localizedImportError(context, state.error!),
                  );
                }
              },
              builder: (context, state) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  layoutBuilder: (currentChild, previousChildren) => Stack(
                    alignment: Alignment.topCenter,
                    children: <Widget>[
                      ...previousChildren,
                      if (currentChild != null) currentChild,
                    ],
                  ),
                  child: _buildPhaseContent(context, state),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      iconTheme: const IconThemeData(color: Default_Theme.primaryColor1),
      title: BlocBuilder<ContentImportCubit, ContentImportState>(
        builder: (context, state) {
          final title = state.collectionInfo?.title;
          // Only using the highlight/heavy font for the main App Bar title
          return Text(
            title?.isNotEmpty == true
                ? title!
                : AppLocalizations.of(context)!.importTitle,
            style: Default_Theme.secondoryTextStyleMedium.merge(
              const TextStyle(
                color: Default_Theme.primaryColor1,
                fontSize: 20,
              ),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );
        },
      ),
    );
  }

  Widget _buildPhaseContent(BuildContext context, ContentImportState state) {
    final cubit = context.read<ContentImportCubit>();
    switch (state.phase) {
      case ImportPhase.idle:
        return _UrlInputView(
          key: const ValueKey('url_input'),
          controller: _urlController,
          onSubmit: () => _startImport(cubit),
        );
      case ImportPhase.checkingUrl:
      case ImportPhase.fetchingInfo:
        return _LoadingView(
          key: const ValueKey('checking'),
          message: AppLocalizations.of(context)!.importCheckingUrl,
          collectionInfo: state.collectionInfo,
        );
      case ImportPhase.fetchingTracks:
        return _LoadingView(
          key: const ValueKey('fetching_tracks'),
          message: AppLocalizations.of(context)!.importFetchingTracks,
          collectionInfo: state.collectionInfo,
        );
      case ImportPhase.resolving:
        return _ResolvingView(
          key: const ValueKey('resolving'),
          state: state,
        );
      case ImportPhase.review:
        return _ReviewView(
          key: const ValueKey('review'),
          state: state,
          onSave: () => cubit.saveToLibrary(),
          onReset: () => cubit.reset(),
        );
      case ImportPhase.saving:
        return _LoadingView(
          key: const ValueKey('saving'),
          message: AppLocalizations.of(context)!.importSavingToLibrary,
          collectionInfo: state.collectionInfo,
        );
      case ImportPhase.done:
        return _DoneView(
          key: const ValueKey('done'),
          state: state,
          onDone: () => context.pop(),
          onImportMore: () => cubit.reset(),
        );
      case ImportPhase.error:
        return _ErrorView(
          key: const ValueKey('error'),
          error: state.error == null
              ? AppLocalizations.of(context)!.importUnknownError
              : _localizedImportError(context, state.error!),
          onRetry: () => cubit.reset(),
        );
    }
  }
}

String _localizedImportError(BuildContext context, String rawError) {
  final l10n = AppLocalizations.of(context)!;
  if (rawError == 'This plugin cannot handle the provided URL.') {
    return l10n.importErrorCannotHandleUrl;
  }
  if (rawError
          .startsWith('Unexpected response when fetching collection info') ||
      rawError.startsWith('Unexpected response when fetching tracks')) {
    return l10n.importErrorUnexpectedResponse;
  }
  if (rawError.startsWith('Failed to check URL: ')) {
    return l10n.importErrorFailedToCheck(
      rawError.substring('Failed to check URL: '.length),
    );
  }
  if (rawError.startsWith('Failed to fetch collection info: ')) {
    return l10n.importErrorFailedToFetchInfo(
      rawError.substring('Failed to fetch collection info: '.length),
    );
  }
  if (rawError.startsWith('Failed to fetch tracks: ')) {
    return l10n.importErrorFailedToFetchTracks(
      rawError.substring('Failed to fetch tracks: '.length),
    );
  }
  if (rawError.startsWith('Failed to save playlist: ')) {
    return l10n.importErrorFailedToSave(
      rawError.substring('Failed to save playlist: '.length),
    );
  }
  return rawError;
}

// ── URL Input ────────────────────────────────────────────────────────────────

class _UrlInputView extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;

  const _UrlInputView({
    super.key,
    required this.controller,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Default_Theme.accentColor2.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(MingCute.link_fill,
                color: Default_Theme.accentColor2, size: 48),
          ),
          const SizedBox(height: 32),
          Text(
            AppLocalizations.of(context)!.importPasteUrlHint,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              height: 1.4,
              color:
                  Colors.white70, // Standard clean text, no custom heavy fonts
            ),
          ),
          const SizedBox(height: 40),
          Container(
            decoration: BoxDecoration(
              color: Default_Theme.primaryColor1.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: Default_Theme.primaryColor1.withValues(alpha: 0.1)),
            ),
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.go,
              autofocus: true,
              cursorColor: Default_Theme.accentColor2,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ), // Clean standard typography for URL entry
              decoration: InputDecoration(
                hintText: 'https://...',
                hintStyle: TextStyle(
                  color: Default_Theme.primaryColor2.withValues(alpha: 0.4),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Icon(MingCute.search_2_line,
                      color: Default_Theme.primaryColor2.withValues(alpha: 0.6),
                      size: 20),
                ),
                prefixIconConstraints:
                    const BoxConstraints(minWidth: 40, minHeight: 40),
                suffixIcon: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: controller,
                  builder: (_, v, __) => v.text.isEmpty
                      ? const SizedBox.shrink()
                      : IconButton(
                          icon: Icon(Icons.cancel,
                              size: 20,
                              color: Default_Theme.primaryColor2
                                  .withValues(alpha: 0.8)),
                          onPressed: controller.clear,
                        ),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 18),
              ),
              onSubmitted: (_) => onSubmit(),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: onSubmit,
            style: FilledButton.styleFrom(
              backgroundColor: Default_Theme.accentColor2,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: Text(
              AppLocalizations.of(context)!.importAction,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Loading / Fetching ───────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  final String message;
  final ImportCollectionSummary? collectionInfo;

  const _LoadingView({super.key, required this.message, this.collectionInfo});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (collectionInfo != null) ...[
              _CollectionHeader(info: collectionInfo!),
              const SizedBox(height: 40),
            ],
            CircularProgressIndicator(
              color: Default_Theme.accentColor2,
              backgroundColor:
                  Default_Theme.primaryColor1.withValues(alpha: 0.1),
              strokeWidth: 4,
            ),
            const SizedBox(height: 24),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Default_Theme.primaryColor2,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Collection Header ────────────────────────────────────────────────────────

class _CollectionHeader extends StatelessWidget {
  final ImportCollectionSummary info;
  const _CollectionHeader({required this.info});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Default_Theme.primaryColor1.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: Default_Theme.primaryColor1.withValues(alpha: 0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 72,
              height: 72,
              child: info.thumbnailUrl?.isNotEmpty == true
                  ? CachedNetworkImage(
                      imageUrl: info.thumbnailUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => _thumbPlaceholder(),
                      errorWidget: (_, __, ___) => _thumbPlaceholder(),
                    )
                  : _thumbPlaceholder(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Allowed to use heavy font here as it acts as a page/section header
                Text(
                  info.title,
                  style: Default_Theme.secondoryTextStyle.merge(
                    const TextStyle(
                      color: Default_Theme.primaryColor1,
                      fontSize: 16,
                    ),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                if (info.owner != null)
                  Text(
                    info.owner!,
                    style: TextStyle(
                      color: Default_Theme.primaryColor2.withValues(alpha: 0.8),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 4),
                if (info.trackCount != null)
                  Text(
                    AppLocalizations.of(context)!
                        .importTrackCount(info.trackCount!),
                    style: TextStyle(
                      color: Default_Theme.accentColor2.withValues(alpha: 0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _thumbPlaceholder() => Container(
        color: Default_Theme.primaryColor1.withValues(alpha: 0.08),
        child: Icon(MingCute.playlist_fill,
            color: Default_Theme.primaryColor2.withValues(alpha: 0.5),
            size: 32),
      );
}

// ── Resolving View ───────────────────────────────────────────────────────────

class _ResolvingView extends StatelessWidget {
  final ContentImportState state;
  const _ResolvingView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final total = state.totalTracks;
    final done = state.resolvedCount + state.failedCount;
    final progress = total > 0 ? done / total : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (state.collectionInfo != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: _CollectionHeader(info: state.collectionInfo!),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!
                    .importResolvingProgress(done, total),
                style: const TextStyle(
                  color: Default_Theme.primaryColor2,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: Default_Theme.accentColor2,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor:
                  Default_Theme.primaryColor1.withValues(alpha: 0.1),
              valueColor:
                  const AlwaysStoppedAnimation(Default_Theme.accentColor2),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.only(bottom: 24),
            itemCount: state.tracks.length,
            separatorBuilder: (_, __) => Divider(
                height: 1,
                color: Default_Theme.primaryColor1.withValues(alpha: 0.05),
                indent: 72),
            itemBuilder: (context, index) =>
                _ResolvingTrackTile(entry: state.tracks[index]),
          ),
        ),
      ],
    );
  }
}

// ── Review View ──────────────────────────────────────────────────────────────

class _ReviewView extends StatefulWidget {
  final ContentImportState state;
  final VoidCallback onSave;
  final VoidCallback onReset;

  const _ReviewView({
    super.key,
    required this.state,
    required this.onSave,
    required this.onReset,
  });

  @override
  State<_ReviewView> createState() => _ReviewViewState();
}

class _ReviewViewState extends State<_ReviewView> {
  final Map<int, bool> _expanded = {};

  void _toggle(int i) =>
      setState(() => _expanded[i] = !(_expanded[i] ?? false));

  @override
  Widget build(BuildContext context) {
    final s = widget.state;
    final toSave = s.tracks.where((t) => t.effectiveTrack != null).length;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Column(
            children: [
              if (s.collectionInfo != null)
                _CollectionHeader(info: s.collectionInfo!),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _StatChip(
                      icon: Icons.check_circle,
                      label: '${s.resolvedCount}',
                      color: Colors.green),
                  _StatChip(
                      icon: Icons.cancel,
                      label: '${s.failedCount}',
                      color: Colors.redAccent),
                  _StatChip(
                      icon: Icons.list_alt,
                      label: '${s.totalTracks}',
                      color: Default_Theme.primaryColor2),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: s.tracks.length,
            itemBuilder: (context, i) => _ReviewTrackTile(
              key: ValueKey(i),
              entry: s.tracks[i],
              index: i,
              isExpanded: _expanded[i] ?? false,
              onToggle: () => _toggle(i),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          decoration: BoxDecoration(
            color: Default_Theme.themeColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, -4),
              )
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onReset,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                        color:
                            Default_Theme.primaryColor2.withValues(alpha: 0.3)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.buttonCancel,
                    style: const TextStyle(
                      color: Default_Theme.primaryColor2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: toSave > 0 ? widget.onSave : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: Default_Theme.accentColor2,
                    disabledBackgroundColor:
                        Default_Theme.accentColor2.withValues(alpha: 0.3),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.importSaveTracks(toSave),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Stat chip ────────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _StatChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
                color: color, fontSize: 13, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

// ── Resolving Track Tile ─────────────────────────────────────────────────────

class _ResolvingTrackTile extends StatelessWidget {
  final ImportTrackEntry entry;
  const _ResolvingTrackTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final src = entry.sourceTrack;

    final statusWidget = switch (entry.status) {
      TrackResolutionStatus.pending => Icon(Icons.hourglass_empty,
          size: 20, color: Default_Theme.primaryColor2.withValues(alpha: 0.5)),
      TrackResolutionStatus.resolving => const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
              strokeWidth: 2, color: Default_Theme.accentColor2),
        ),
      TrackResolutionStatus.resolved =>
        const Icon(Icons.check_circle, size: 22, color: Colors.green),
      TrackResolutionStatus.failed =>
        const Icon(Icons.cancel, size: 22, color: Colors.redAccent),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 48,
              height: 48,
              child: src.thumbnailUrl?.isNotEmpty == true
                  ? CachedNetworkImage(
                      imageUrl: src.thumbnailUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => _miniPlaceholder(),
                    )
                  : _miniPlaceholder(),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  src.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  src.artists.join(', '),
                  style: TextStyle(
                    color: Default_Theme.primaryColor2.withValues(alpha: 0.8),
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
          statusWidget,
        ],
      ),
    );
  }

  Widget _miniPlaceholder() => Container(
      color: Default_Theme.primaryColor1.withValues(alpha: 0.08),
      child: Icon(MingCute.music_2_fill,
          color: Default_Theme.primaryColor2.withValues(alpha: 0.4), size: 20));
}

// ── Review Track Tile (expandable) ───────────────────────────────────────────

class _ReviewTrackTile extends StatelessWidget {
  final ImportTrackEntry entry;
  final int index;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _ReviewTrackTile({
    super.key,
    required this.entry,
    required this.index,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final src = entry.sourceTrack;
    final effective = entry.effectiveTrack;
    final cubit = context.read<ContentImportCubit>();

    final Color statusColor = entry.isSkipped
        ? Default_Theme.primaryColor2
        : effective != null
            ? Colors.green
            : Colors.redAccent;

    final IconData statusIcon = entry.isSkipped
        ? Icons.remove_circle
        : effective != null
            ? Icons.check_circle
            : Icons.cancel;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isExpanded
            ? Default_Theme.primaryColor1.withValues(alpha: 0.03)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isExpanded
              ? Default_Theme.accentColor2.withValues(alpha: 0.2)
              : Colors.transparent,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: entry.candidates.isNotEmpty ? onToggle : null,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 52,
                      height: 52,
                      child: src.thumbnailUrl?.isNotEmpty == true
                          ? CachedNetworkImage(
                              imageUrl: src.thumbnailUrl!,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => _miniPlaceholder(),
                            )
                          : _miniPlaceholder(),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          src.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          src.artists.join(', '),
                          style: TextStyle(
                            color: Default_Theme.primaryColor2
                                .withValues(alpha: 0.8),
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (effective != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Row(
                              children: [
                                const Icon(MingCute.arrows_right_line,
                                    size: 14,
                                    color: Default_Theme.accentColor2),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    '${effective.title} • ${effective.artists.map((a) => a.name).join(', ')}',
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                          alpha:
                                              0.95), // Bright white text for visibility
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else if (entry.isSkipped)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              AppLocalizations.of(context)!.importSkipped,
                              style: TextStyle(
                                color: Colors.white
                                    .withValues(alpha: 0.7), // Good contrast
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(statusIcon, color: statusColor, size: 22),
                      if (entry.candidates.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        AnimatedRotation(
                          turns: isExpanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(Icons.expand_more,
                              color: Default_Theme.primaryColor2
                                  .withValues(alpha: 0.8),
                              size: 20),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: isExpanded && entry.candidates.isNotEmpty
                ? _CandidateList(entry: entry, index: index, cubit: cubit)
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _miniPlaceholder() => Container(
      color: Default_Theme.primaryColor1.withValues(alpha: 0.08),
      child: Icon(MingCute.music_2_fill,
          color: Default_Theme.primaryColor2.withValues(alpha: 0.4), size: 22));
}

// ── Candidate Picker ─────────────────────────────────────────────────────────

class _CandidateList extends StatelessWidget {
  final ImportTrackEntry entry;
  final int index;
  final ContentImportCubit cubit;
  const _CandidateList(
      {required this.entry, required this.index, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final selected = entry.selectedCandidateIndex;
    final autoIdx = entry.resolvedTrack != null ? 0 : null;
    final effectiveSelected = selected ?? autoIdx;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Divider(
              height: 1,
              color: Default_Theme.primaryColor1.withValues(alpha: 0.06)),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Text(
              AppLocalizations.of(context)!.importMatchOptions,
              style: const TextStyle(
                color: Default_Theme.accentColor2,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
          ...List.generate(entry.candidates.length, (ci) {
            return _CandidateTile(
              track: entry.candidates[ci],
              isSelected: effectiveSelected == ci,
              onTap: () => cubit.pickCandidate(index, ci),
            );
          }),
          _SkipTile(
            isSelected: selected == -1,
            onTap: () => cubit.pickCandidate(index, -1),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _CandidateTile extends StatelessWidget {
  final Track track;
  final bool isSelected;
  final VoidCallback onTap;
  const _CandidateTile(
      {required this.track, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            _CustomRadio(
                isSelected: isSelected, color: Default_Theme.accentColor2),
            const SizedBox(width: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                width: 40,
                height: 40,
                child: track.thumbnail.url.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: track.thumbnail.url,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => _miniPlaceholder(),
                      )
                    : _miniPlaceholder(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.title,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    track.artists.map((a) => a.name).join(', '),
                    style: TextStyle(
                      color: Default_Theme.primaryColor2.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniPlaceholder() => Container(
      color: Default_Theme.primaryColor1.withValues(alpha: 0.08),
      child: Icon(MingCute.music_2_fill,
          color: Default_Theme.primaryColor2.withValues(alpha: 0.3), size: 18));
}

class _SkipTile extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;
  const _SkipTile({required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            _CustomRadio(
                isSelected: isSelected, color: Default_Theme.primaryColor2),
            const SizedBox(width: 14),
            SizedBox(
              width: 40,
              height: 40,
              child: Center(
                child: Icon(Icons.block,
                    size: 24,
                    color: Default_Theme.primaryColor2.withValues(alpha: 0.6)),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              AppLocalizations.of(context)!.importSkipTrack,
              style: TextStyle(
                color: Default_Theme.primaryColor2.withValues(alpha: 0.9),
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Radio Button matching the provided design exactly
class _CustomRadio extends StatelessWidget {
  final bool isSelected;
  final Color color;
  const _CustomRadio({required this.isSelected, required this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 22,
      height: 22,
      padding: const EdgeInsets.all(
          3.5), // The blank gap between outer ring and inner dot
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected
              ? color
              : Default_Theme.primaryColor2.withValues(alpha: 0.4),
          width: 2.5, // Thick outer ring
        ),
      ),
      child: isSelected
          ? Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color, // Solid inner dot
              ),
            )
          : null,
    );
  }
}

// ── Done View ────────────────────────────────────────────────────────────────

class _DoneView extends StatelessWidget {
  final ContentImportState state;
  final VoidCallback onDone;
  final VoidCallback onImportMore;

  const _DoneView(
      {super.key,
      required this.state,
      required this.onDone,
      required this.onImportMore});

  @override
  Widget build(BuildContext context) {
    final thumb = state.collectionInfo?.thumbnailUrl;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                if (thumb?.isNotEmpty == true)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: SizedBox(
                        width: 110,
                        height: 110,
                        child: CachedNetworkImage(
                            imageUrl: thumb!, fit: BoxFit.cover),
                      ),
                    ),
                  ),
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle,
                      color: Colors.green, size: 52),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Text(
              AppLocalizations.of(context)!
                  .importTracksSaved(state.resolvedCount),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (state.collectionInfo?.title.isNotEmpty == true) ...[
              const SizedBox(height: 10),
              Text(
                state.collectionInfo!.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Default_Theme.primaryColor2.withValues(alpha: 0.8),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const SizedBox(height: 48),
            FilledButton(
              onPressed: onDone,
              style: FilledButton.styleFrom(
                backgroundColor: Default_Theme.accentColor2,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: Text(
                AppLocalizations.of(context)!.importDone,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onImportMore,
              style: TextButton.styleFrom(
                  foregroundColor: Default_Theme.primaryColor1),
              child: Text(
                AppLocalizations.of(context)!.importMore,
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Error View ───────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorView({super.key, required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline,
                  color: Colors.redAccent, size: 40),
            ),
            const SizedBox(height: 24),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 36),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 20),
              label: Text(AppLocalizations.of(context)!.importTryAgain),
              style: FilledButton.styleFrom(
                backgroundColor: Default_Theme.accentColor2,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
